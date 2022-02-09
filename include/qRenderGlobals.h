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

#include "Shaders/TimeGlobals.h"
#include "Shaders/CameraGlobals.h"
#include "qRenderCamera.h"

namespace qRender
{
	typedef struct Globals
	{
		TimeGlobals timeGlobals;
		CameraGlobals sceneCameraGlobals;
		
		Globals()
		: lastTime(0)
		{
		}
		
		void Update(float time, Camera* sceneCamera)
		{
			timeGlobals.time = time;
			timeGlobals.dTime = time - lastTime;
			lastTime = time;
			
			memcpy(&sceneCameraGlobals, &sceneCamera->globals, sizeof(CameraGlobals));
		}
		
	private:
		
		float lastTime;
		
	} Globals;
}

#endif /* __Q_RENDER_GLOBALS_H__ */
