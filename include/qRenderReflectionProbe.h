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

#ifndef __Q_RENDER_REFLECTION_PROBE_H__
#define __Q_RENDER_REFLECTION_PROBE_H__

#include "qMath.h"
#include "qMetal.h"
#include "qRenderCamera.h"
#include "qRenderGlobals.h"
#include "qRenderSubsystem.h"
#include "Shaders/ShadingGlobals.h"

using namespace qMetal;

namespace qRender
{
	class ReflectionProbe : public Subsystem
	{
		qVector3 kFaceDirection[6] =
		{
			qVector3(1, 0, 0),
			qVector3(-1, 0, 0),
			qVector3(0, 1, 0),
			qVector3(0, -1, 0),
			qVector3(0, 0, 1),
			qVector3(0, 0, -1)
		};
		
		qVector3 kFaceUp[6] =
		{
			qVector3_Up,
			qVector3_Up,
			qVector3(0, 0, -1),
			qVector3(0, 0, 1),
			qVector3_Up,
			qVector3_Up
		};

	public:

		typedef struct Config
		{
			uint32_t      			size;
			qVector3				position;
			Camera::Config			*cameraConfig;
			bool					updateSingleFacePerFrame;		//TODO this has to be true or we need every reflection probe material to be 6x buffered
			bool					updateSingleFacePerFrameIndirect;
			RenderTarget* 			baseRenderTarget;
			
			Config()
			: size(128)
			, position(qVector3_Zero)
			, cameraConfig(NULL)
			, updateSingleFacePerFrame(true)
			, updateSingleFacePerFrameIndirect(false)
			, baseRenderTarget(NULL)
			{
			}
			
		} Config;
		
		ReflectionProbe(Config* _config);
		
		void Init(Globals* globals);
		
		void Update(Globals* globals);
		
		void Encode(const Globals* globals) const;
		
		void EncodeIndirect(const Globals* globals) const;
		
		void AddIndirectRenderable(Renderable* renderable);
		
		inline Texture* GetIndirectTexture() const
		{
			return indirectRenderTarget[0]->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Lighting);
		}
		
		inline Texture* GetTexture() const
		{
			return renderTarget[0]->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Lighting);
		}
		
		inline RenderTarget* GetRenderTarget(int face) const
		{
			return renderTarget[face];
		}
		
	private:
		
		Config						*config;
				
		RenderTarget				*indirectRenderTarget[6];
		RenderTarget				*renderTarget[6];
				
		Camera						*camera[6];
		uint32_t					currentSlice;
		
		std::vector<Renderable*>	indirectRenderables;
	};
}

#endif /* __Q_RENDER_REFLECTION_PROBE_H__ */
