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

#ifndef __Q_RENDER_SUBSYSTEM_H__
#define __Q_RENDER_SUBSYSTEM_H__

#include "qMetal.h"
#include "qRenderCamera.h"
#include "qRenderGlobals.h"
#include "qRenderRenderable.h"

using namespace qMetal;

namespace qRender
{
	class Subsystem
	{
	public:
	
		virtual void Update(Globals *globals) = 0;
		
		virtual void Encode(const Globals *globals) const = 0;
		
		void AddRenderable(qRender::Renderable* renderable)
		{
			renderables.push_back(renderable);
		}
		
		//TODO make this more generic to touch events
		virtual void Drag(qVector2 location, qVector2 velocity) {}
		
	protected:
	
		std::vector<qRender::Renderable*> renderables;
	};
}

#endif /* __Q_RENDER_SUBSYSTEM_H__ */
