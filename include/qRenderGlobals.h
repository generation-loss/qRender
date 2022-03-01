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
#include "qRenderCamera.h"

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
		
		Globals(Camera* _sceneCamera)
		: sceneCamera(_sceneCamera)
		, lastTime(0)
		, debugMode(eDebugMode_None)
		{
			qRender::DebugMenu::Instance()->Value("Rendering", NULL, "Debug Mode", debugMode, eDebugMode_None, eDebugMode_Count - 1, sDebugModeNames);
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
