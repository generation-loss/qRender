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

#ifndef __Q_RENDER_GLOBALS_H__
#define __Q_RENDER_GLOBALS_H__

#include "Shaders/ShadingGlobals.h"
#include "Shaders/TimeGlobals.h"
#include "Shaders/CameraGlobals.h"
#include "Shaders/ShadowMapGlobals.h"
#include "Shaders/AtmosphereGlobals.h"

#include "qRenderCamera.h"
#include "qRenderDebugMenu.h"

namespace qRender
{
	static const char* sDebugModeNames[eDebugMode_Count] = {
	#define DEBUG_MODE(xxenum) #xxenum,
			DEBUG_MODES
	#undef DEBUG_MODE
	};

	typedef struct Globals
	{
		ShadingGlobals shading;
		TimeGlobals timeGlobals;
		CameraGlobals sceneCameraGlobals;
		Camera *sceneCamera;
		
		ShadowMapGlobals shadow;
		AtmosphereGlobals atmosphere;
		
		Globals(Camera* _sceneCamera)
		: sceneCamera(_sceneCamera)
		, lastTime(0)
		, debugMode(eDebugMode_None)
		{
			DebugMenu::Instance()->Value("Rendering", NULL, "Debug Mode", debugMode, eDebugMode_None, eDebugMode_Count - 1, sDebugModeNames);
			
			DebugMenu::Instance()->Value("Lighting", "Shadows", "Blocker search size", shadow.blockerSearchSize, 1.0f, 0.0f, 16.0f);
			DebugMenu::Instance()->Value("Lighting", "Shadows", "Light size", shadow.lightSize, 1.0, 0.0, 64.0);
			DebugMenu::Instance()->Value("Lighting", "Shadows", "Cascade 0 Bias", shadow.bias[0], 0.001, 0.0, 0.1);
			DebugMenu::Instance()->Value("Lighting", "Shadows", "Cascade 1 Bias", shadow.bias[1], 0.001, 0.0, 0.1);
			DebugMenu::Instance()->Value("Lighting", "Shadows", "Cascade 2 Bias", shadow.bias[2], 0.001, 0.0, 0.1);
			DebugMenu::Instance()->Value("Lighting", "Shadows", "Cascade 3 Bias", shadow.bias[3], 0.001, 0.0, 0.1);

			DebugMenu::Instance()->Value("Lighting", "Atmosphere", "Distance base", atmosphere.distanceBase, 0.01, 0.01f, 10.0f);
			DebugMenu::Instance()->Value("Lighting", "Atmosphere", "Distance density", atmosphere.distanceDensity, 0.01, 0.0f, 5.0f);
			DebugMenu::Instance()->Value("Lighting", "Atmosphere", "Max fog distance", atmosphere.maxDistance, 10.f, 0.0f, 4096.0f);
			DebugMenu::Instance()->Value("Lighting", "Atmosphere", "Height base", atmosphere.heightBase, 0.01, 0.001f, 20.0f);
			DebugMenu::Instance()->Value("Lighting", "Atmosphere", "Height density", atmosphere.heightDensity, 0.01, 0.0f, 5.0f);
			DebugMenu::Instance()->Value("Lighting", "Atmosphere", "Min height", atmosphere.minHeight, 10.0f, -1000.0f, 1000.0f);
			DebugMenu::Instance()->Value("Lighting", "Atmosphere", "Max height", atmosphere.maxHeight, 10.0f, -1000.0f, 1000.0f);
			DebugMenu::Instance()->Value("Lighting", "Atmosphere", "Colour R", atmosphere.colourR, 0.01, 0.0, 1.0);
			DebugMenu::Instance()->Value("Lighting", "Atmosphere", "Colour G", atmosphere.colourG, 0.01, 0.0, 1.0);
			DebugMenu::Instance()->Value("Lighting", "Atmosphere", "Colour B", atmosphere.colourB, 0.01, 0.0, 1.0);
		}
		
		void Update(float time)
		{
			timeGlobals.time = time;
			timeGlobals.dTime = time - lastTime;
			lastTime = time;
			
			shading.debugMode = (eDebugMode)debugMode;
			
			memcpy(&sceneCameraGlobals, &sceneCamera->globals, sizeof(CameraGlobals));
		}
		
	private:
		
		float lastTime;
		int debugMode;
		
	} Globals;
}

#endif /* __Q_RENDER_GLOBALS_H__ */
