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

#ifndef __Q_RENDER_SHADOW_MAP_H__
#define __Q_RENDER_SHADOW_MAP_H__

#include "qRenderCamera.h"
#include "qRenderSubsystem.h"
#include "qRenderGlobals.h"
#include "Shaders/ShadowMapGlobals.h"

#define USE_SHADOW_MSAA (0)

using namespace qMetal;

namespace qRender
{
	class ShadowMap : public Subsystem
	{
	public:

		enum eUpdate
		{
			eUpdate_EveryFrame,
			eUpdate_EvenFrames,
			eUpdate_OddFrames,
			eUpdate_OnlyWhenForced
		};

		typedef struct Config
		{
			NSUInteger      renderSize;
			float			cascadeSize[SHADOW_CASCADE_COUNT];
			eUpdate			update[SHADOW_CASCADE_COUNT];
			float 			nearPlane;
			float			farPlane;
			bool			quantize;
			
			Config()
			: renderSize(512)
			, nearPlane(1.0f)
			, farPlane(200.0f)
			, quantize(true)
			{
				cascadeSize[0] = 32.0f;
				DebugMenu::Instance()->Value("Lighting", "Shadows", "Casscade 0 size", cascadeSize[0], 1.0f, 1.0f, 128.0f);
				
				for (int i = 1; i < SHADOW_CASCADE_COUNT; ++i)
				{
					cascadeSize[i] = cascadeSize[i - 1] * 4.0f;
					update[i] = eUpdate_EveryFrame;
					char label[64];
					sprintf(label, "Cascade %i size", i);
					DebugMenu::Instance()->Value("Lighting", "Shadows", label, cascadeSize[i], 1.0f, 1.0f, 512.0f * i * i * i);
				}
				
				DebugMenu::Instance()->Value("Lighting", "Shadows", "Quantize", quantize);
			}
		} Config;
		
		ShadowMap(Config* _config);
		
		void Init(Globals* globals);
		
		void Update(Globals* globals);
		void Update(Globals* globals, const bool forceAll);
		
		void Encode(const Globals* globals) const;
		void Encode(const Globals* globals, const bool forceAll) const;
		
		inline Texture* GetTexture() const
		{
	#if USE_SHADOW_MSAA
			return cameraRenderTarget[0]->DepthResolveTexture();
	#else
			return cameraRenderTarget[0]->DepthTexture();
	#endif
		}
		
		inline RenderTarget* GetRenderTarget() const
		{
			return cameraRenderTarget[0];
		}
		
	private:
		
		inline bool ShouldRender(int cascadeIdx, bool forceAll) const;
		
		Config				*config;
		
		RenderTarget		*cameraRenderTarget[SHADOW_CASCADE_COUNT];
		Camera				*camera[SHADOW_CASCADE_COUNT];
	};
}

#endif /* __Q_RENDER_SHADOW_MAP_H__ */
