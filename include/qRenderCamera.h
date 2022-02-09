/*
Copyright (c) 2022 Generation Loss Interactive

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#ifndef __Q_RENDER_CAMERA_H__
#define __Q_RENDER_CAMERA_H__

#include "qMath.h"
#include <cstring>
#include "Shaders/CameraGlobals.h"
#include "qRenderDebugMenu.h"

namespace qRender
{
	class Camera
	{
	public:
		
		enum eType
		{
			eType_Perspective,
			eType_Orthographic
		};
		
		typedef struct Config
		{
			NSString *name;
			
			eType type;
			
			qVector3 position;
			qVector3 lookAt;
			qVector3 up;
			
			float nearPlane;
			float farPlane;
			
			//perspective
			float FoVY;
			float aspectRatio;
			
			//orthographic
			float width;
			float height;
			
			float focusDistance;
			
			float ISO;
			float aperture;
			float shutterSpeed;
			
			bool quantize;
			float quantizeStep;
			
			uint32_t pixelWidth;
			uint32_t pixelHeight;
			
		#if DEBUG
			float DEBUG_distanceToCamera;
		#endif
			
			Config(NSString *_name)
			: name(_name)
			, type(eType_Perspective)
			, position(qVector3_One)
			, lookAt(qVector3_Zero)
			, up(qVector3_Up)
			, nearPlane(0.1f)
			, farPlane(1000.0f)
			, FoVY(60.0f)
			, aspectRatio(4.0f / 3.0f)
			, width(100.0f)
			, height(100.0f)
			, focusDistance(25.0f)
			, ISO(100.0f)
			, aperture(16.0f)
			, shutterSpeed(1.0f / 100.0f)
			, quantize(false)
			, quantizeStep(1.0f)
			, pixelWidth(1)
			, pixelHeight(1)
		#if DEBUG
			, DEBUG_distanceToCamera(400.0f)
		#endif
			{
				DebugMenu::Instance()->Value("Camera", [name UTF8String], "Focal distance", focusDistance, 0.1f, 0.0f, 1000.0f);
				DebugMenu::Instance()->Value("Camera", [name UTF8String], "Vertical field of view", FoVY, 0.1f, 1.0f, 180.0f);
				DebugMenu::Instance()->Value("Camera", [name UTF8String], "ISO", ISO, 50.0f, 50.0f, 100000.0f);
				DebugMenu::Instance()->Value("Camera", [name UTF8String], "Aperture", aperture, 0.1f, 1.4f, 24.0f);
				DebugMenu::Instance()->Value("Camera", [name UTF8String], "Shutter Speed", shutterSpeed, 0.001f, 0.0f, 1.0f);
			#if DEBUG
				DebugMenu::Instance()->Value("Camera", [name UTF8String], "Distance to camera", DEBUG_distanceToCamera, 1.0f, 1.0f, 400.0f);
			#endif
			}
		} Config;
		
		Camera( Config *_config)
		: config(_config)
		{
			UpdateGlobals();
		}
		
		void SetWidth(float width)
		{
			qASSERT(config->type == eType_Orthographic);
			config->width = width;
			UpdateGlobals();
		}
		
		void SetHeight(float height)
		{
			qASSERT(config->type == eType_Orthographic);
			config->height = height;
			UpdateGlobals();
		}
		
		void SetNearPlane(float nearPlane)
		{
			config->nearPlane = nearPlane;
			UpdateGlobals();
		}
		
		void SetFarPlane(float farPlane)
		{
			config->farPlane = farPlane;
			UpdateGlobals();
		}
		
		void SetPosition(qVector3 position)
		{
			config->position = position;
			UpdateGlobals();
		}
		
		void SetLookAt(qVector3 lookAt, qVector3 up = qVector3_Up)
		{
			config->lookAt = lookAt;
			config->up = up;
			UpdateGlobals();
		}
		
		qVector3 GetPosition() const
		{
			return config->position;
		}
		
		qVector3 GetLookAt() const
		{
			return config->lookAt;
		}
		
		float Exposure() const
		{
			float e = 1.2f * (config->aperture * config->aperture / config->shutterSpeed) * (100.0f / config->ISO);
			return 1.0f / e;
		}
		
		bool InFrustum(qVector4 aabbMin, qVector4 aabbMax) const;
		
		CameraGlobals globals;
		
	protected:
		Config	*config;
		
		void UpdateGlobals()
		{
			const float focalLength = 0.0024 * tanf(qDegToRad(config->FoVY) * 0.5f); //24 mm high film for 35mm senseor, https://en.wikipedia.org/wiki/Angle_of_view and matches https://www.nikonians.org/reviews/fov-tables
			
			globals.focusDistance 	= config->focusDistance;
			globals.focalLength 	= focalLength;
			globals.ISO 			= config->ISO;
			globals.aperture 		= config->aperture;
			globals.shutterSpeed 	= config->shutterSpeed;
			
			globals.zBufferParams.x = 1.0f - config->farPlane / config->nearPlane;
			globals.zBufferParams.y = config->farPlane / config->nearPlane;
			globals.zBufferParams.z = globals.zBufferParams.x / config->farPlane;
			globals.zBufferParams.w = globals.zBufferParams.y / config->farPlane;
			
			globals.position.x = config->position.x;
			globals.position.y = config->position.y;
			globals.position.z = config->position.z;
			
			globals.lookAt.x = config->lookAt.x;
			globals.lookAt.y = config->lookAt.y;
			globals.lookAt.z = config->lookAt.z;
			
			qVector3 viewDir = qVector3::Normalize(config->lookAt - config->position);
			
			globals.viewDir.x = viewDir.x;
			globals.viewDir.y = viewDir.y;
			globals.viewDir.z = viewDir.z;
			
			qMatrix4 view = qCamera::LookAt(config->position, config->lookAt, config->up);
			qMatrix4 project;
			
			switch (config->type)
			{
				case eType_Perspective:
					project = qCamera::Perspective(config->FoVY, config->aspectRatio, config->nearPlane, config->farPlane);
					break;
				
				case eType_Orthographic:
					project = qCamera::Orthographic(config->width, config->height, config->nearPlane, config->farPlane);
					break;
				
				default:
					qASSERT("Unknown camera type");
					break;
			}
			qMatrix4 viewProject = project * view;
			
			if (config->quantize)
			{
				viewProject.mm[3][0] = roundf(viewProject.mm[3][0] * config->quantizeStep) / config->quantizeStep;
				viewProject.mm[3][1] = roundf(viewProject.mm[3][1] * config->quantizeStep) / config->quantizeStep;
				viewProject.mm[3][2] = roundf(viewProject.mm[3][2] * config->quantizeStep) / config->quantizeStep;
			}
			
			memcpy(&globals.v, &view, sizeof(matrix_float4x4));
			memcpy(&globals.p, &project, sizeof(matrix_float4x4));
			memcpy(&globals.vp, &viewProject, sizeof(matrix_float4x4));
			
			ExtractFrustumPlanes();
			
			globals.screenSize.x = (float)config->pixelWidth;
			globals.screenSize.y = (float)config->pixelHeight;
		}
		
		void ExtractFrustumPlanes();
		
	#if DEBUG
		void UpdateDebugGlobals()
		{
			globals.DEBUG_distanceToCamera = config->DEBUG_distanceToCamera;
		}
	#endif
	};
}

#endif /* __Q_RENDER_CAMERA_H__ */
