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

#ifndef __Q_RENDER_PREPASS_H__
#define __Q_RENDER_PREPASS_H__

#include "qMetal.h"
#include "qMath.h"
#include "qRenderSubsystem.h"
#include "qRenderCamera.h"
#include "qRenderGlobals.h"
#include "Shaders/Prepass.h"

using namespace qMetal;

namespace qRender
{
	class Prepass : public Subsystem
	{
	public:
		typedef struct Config
		{
			uint32_t      			width;
			uint32_t      			height;
			uint32_t				scale;
			
			Config()
			: width(512)
			, height(512)
			{
			}
			
		} Config;
		
		Prepass(Config *_config);
	
		void Init(Globals *globals);
	
		void Update(Globals *globals);
		
		void Encode(const Globals *globals) const;
		
		inline Texture* GetWorldPosTexture() const
		{
			return renderTarget->ColourTexture((RenderTarget::eColorAttachment)eDepthNormalRenderTarget_WorldPos);
		}
		
		inline Texture* GetWorldNormalTexture() const
		{
			return renderTarget->ColourTexture((RenderTarget::eColorAttachment)eDepthNormalRenderTarget_WorldNormal);
		}
		
		inline Texture* GetDepthTexture() const
		{
			qBREAK("DepthNormal prepass hardware depth texture is memoryless; we use render eye-space z");
			return nullptr;
		}
		
		inline RenderTarget* GetRenderTarget() const
		{
			return renderTarget;
		}
		
	private:
		
		Config				*config;
		
		RenderTarget		*renderTarget;
	};
}

#endif /* __Q_RENDER_PREPASS_H__ */
