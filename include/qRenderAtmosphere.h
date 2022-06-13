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

#ifndef __Q_RENDER_ATMOSPHERE_H__
#define __Q_RENDER_ATMOSPHERE_H__

#include "qMath.h"
#include "qMetal.h"
#include "Shaders/AtmosphereParams.h"
#include "qRenderPrepass.h"
#include "qRenderReflectionProbe.h"
#include "qRenderShadowMap.h"
#include "qRenderSubsystem.h"
#include "qRenderCamera.h"

using namespace qMetal;

namespace qRender
{
	class Atmosphere : public Subsystem
	{
	public:
		
		typedef struct Config
		{
			uint32_t      				width;
			uint32_t      				height;
			uint32_t					scale;
			uint32_t					depthNormalScale;
			uint32_t					blurPasses;
			AtmosphereAccumulateComputeTweaks 	tweaks;
			Prepass*					prepass;
			ShadowMap*					shadowMap;
			ReflectionProbe*			reflectionProbe;
			
			Config()
			: width(512)
			, height(512)
			, scale(8)
			, depthNormalScale(2)
			, blurPasses(1)
			, prepass(NULL)
			, shadowMap(NULL)
			, reflectionProbe(NULL)
			{}
		} Config;
		
		//COMPUTE
		typedef Material<EmptyParams, EmptyParams, AtmosphereAccumulateComputeParams> AccumulateComputeMaterial;
		typedef Material<EmptyParams, EmptyParams> BlurComputeMaterial;
		
		//RENDER
		typedef Material<AtmosphereVertexParams, AtmosphereAccumulateComputeParams> AccumulateRenderMaterial;
		typedef Mesh<AtmosphereVertexStreamArgumentBuffer_Count, AtmosphereVertexStream_StreamArgumentBuffer> FullScreenMesh;
		
		Atmosphere(Config *_config);
		
		void Init(Globals *globals);
		
		void Update(Globals *globals);
		
		void Encode(const Globals *globals) const;
		
		inline Texture* GetTexture() const
		{
			return renderAsCompute ? accumulateTexture[0] : renderTarget->ColourTexture(RenderTarget::eColorAttachment_0);
		}
		
	private:
		
		RenderTarget					*renderTarget;
		FullScreenMesh 					*fullScreenMesh;
		AccumulateRenderMaterial		*accumulateRenderMaterial;
		
		ComputeTexture					*accumulateTexture[2];
		AccumulateComputeMaterial		*accumulateComputeMaterial;
		BlurComputeMaterial				*blurMaterial[2];
		
		Config							*config;
		bool							renderAsCompute;
	};
}

#endif /* __Q_RENDER_ATMOSPHERE_H__ */
