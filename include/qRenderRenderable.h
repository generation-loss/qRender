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

#ifndef __Q_RENDER_RENDERABLE_H__
#define __Q_RENDER_RENDERABLE_H__

#include "qMetal.h"
#include "qRenderCamera.h"
#include "qRenderGlobals.h"

using namespace qMetal;

namespace qRender
{
	class Renderable
	{
	public:
		virtual void InitRender(const Camera *camera, const Globals *globals) { }
		virtual void PopulateGlobals(Globals *globals, Camera* sceneCamera) { }
		virtual void Update(Globals *globals) = 0;
		
		//TODO make this more generic to touch events
		virtual void Drag(qVector2 location, qVector2 velocity) {}
		
		virtual void Encode(id<MTLRenderCommandEncoder> encoder, const Camera *camera, const Globals *globals, const int32_t pass) const = 0;
		
		//optional compute shader
		virtual void EncodeCompute(id<MTLComputeCommandEncoder> encoder, const Camera *camera, const Globals *globals, const int32_t pass) const { };
		
		//optional indirect command buffer reset / optimization pass
		virtual void Reset(const int32_t pass) const { };
		virtual void Optimize(const int32_t pass) const { };
	};
}

#endif /* __Q_RENDER_RENDERABLE_H__ */
