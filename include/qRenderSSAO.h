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

#ifndef HillsSSAO_h
#define HillsSSAO_h

#include "qMetal.h"
#include "qMath.h"
#include "qRenderSubsystem.h"
#include "qRenderCamera.h"
#include "qRenderGlobals.h"
#include "qRenderNoise.h"
#include "qRenderPrepass.h"
#include "Shaders/SSAOParams.h"

using namespace qMetal;

namespace qRender
{
	class SSAO : public Subsystem
	{
	public:
		
		typedef struct Config
		{
			uint32_t      				width;
			uint32_t      				height;
			uint32_t					aoScale;
			uint32_t					blurScale;
			AOAccumulateComputeTweaks 	tweaks;
			Prepass*					prepass;
			
			Config()
			: width(512)
			, height(512)
			, aoScale(4)
			, blurScale(2)
			{}
		} Config;
		
		//COMPUTE
		typedef Material<EmptyParams, EmptyParams, AOAccumulateComputeParams> SSAOAccumulateMaterial;
	
		//RENDER
		typedef Material<AOVertexParams, AOAccumulateComputeParams> AccumulateRenderMaterial;
		
		SSAO(Config *_config);
		
		void Init(Globals *globals);
		
		void Update(Globals *globals);
		
		void Encode(const Globals *globals) const;
		
		inline Texture* GetTexture() const
		{
			return upscaleBlurTexture;
		}
		
	private:
		RenderTarget				*renderTarget;
		Mesh		 				*fullScreenMesh;
		AccumulateRenderMaterial	*accumulateRenderMaterial;
		
		ComputeTexture				*accumulateTexture;
		SSAOAccumulateMaterial		*accumulateComputeMaterial;
			
		Noise						*noise;
			
		ComputeTexture				*upscaleBlurTexture;
		SSAOAccumulateMaterial		*upscaleBlurMaterialCompute;
		SSAOAccumulateMaterial		*upscaleBlurMaterialRender;
			
		Config						*config;
		bool						renderAsCompute;
	};
}

#endif /* HillsSSAO_h */
