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

#ifndef __Q_RENDER_HEIGHT_MAP_H__
#define __Q_RENDER_HEIGHT_MAP_H__

#include "qMath.h"
#include "qMetal.h"
#include "qRenderCamera.h"
#include "qRenderGlobals.h"
#include "qRenderSubsystem.h"

using namespace qMetal;

namespace qRender
{
	class HeightMap : public Subsystem
	{
	public:

		typedef struct Config
		{
			uint32_t      				size;
			Camera::Config				*cameraConfig;
			
			Config()
			: size(512)
			, cameraConfig(new Camera::Config(@"Height Map"))
			{
				cameraConfig->type = Camera::eType_Orthographic;
				cameraConfig->nearPlane = 1.0f;
				cameraConfig->farPlane = 1000.0f;
				cameraConfig->width = 100.0f;
				cameraConfig->height = 100.0f;
			}
			
		} Config;
		
		HeightMap(Config *_config);
		
		void Init(Globals *globals);
		
		void Update(Globals *globals);
		
		void Encode(const Globals *globals) const;
		
		inline Texture* GetTexture() const
		{
			return renderTarget->DepthTexture();
		}
		
		inline RenderTarget* GetRenderTarget() const
		{
			return renderTarget;
		}
		
	private:
		
		Config				*config;
		
		RenderTarget		*renderTarget;
		
		Camera				*camera;
	};
}

#endif /* __Q_RENDER_HEIGHT_MAP_H__ */
