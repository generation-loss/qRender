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

#include "qRenderAtmosphere.h"

qRender::Atmosphere::Atmosphere(qRender::Atmosphere::Config* _config)
: config(_config)
, renderAsCompute(true)
{
	//DEBUG MENU
	
	DebugMenu::Instance()->Value("Lighting", "Atmosphere", "RenderAsCompute", renderAsCompute);
	DebugMenu::Instance()->Value("Lighting", "Atmosphere", "Num Samples", config->tweaks.numSamples, 1.0, 1.0, 64.0);
	DebugMenu::Instance()->Value("Lighting", "Atmosphere", "Max Raymarch Distance", config->tweaks.maxDistance, 10.f, 0.0f, 10000.0f);
	DebugMenu::Instance()->Value("Lighting", "Atmosphere", "Blur Passes", config->blurPasses, 1u, 0u, 20u);
	
	//COMPUTE
	
	ComputeTexture::Config* atmosphereAccumulateTextureConfig = new ComputeTexture::Config(@"Atmosphere Accumulate as Compute", config->width / config->scale, config->height / config->scale, Texture::ePixelFormat_RGBA16f);
	accumulateTexture[0] = new ComputeTexture(atmosphereAccumulateTextureConfig);
	accumulateTexture[1] = new ComputeTexture(atmosphereAccumulateTextureConfig);
	
	AccumulateComputeMaterial::Config* accumulateComputeMaterialConfig 											= new AccumulateComputeMaterial::Config(@"Atmosphere Accumulate Compute Material");
	accumulateComputeMaterialConfig->computeFunction  															= new Function(@"AtmosphereAccumulateKernel");
	accumulateComputeMaterialConfig->computeParamsIndex 														= AtmosphereAccumulateComputeStream_Params;
	accumulateComputeMaterialConfig->computeTextures[AtmosphereAccumulateComputeStream_WorldPosTexture]			= config->prepass->GetWorldPosTexture();
	accumulateComputeMaterialConfig->computeTextures[AtmosphereAccumulateComputeStream_ShadowTexture]			= config->shadowMap->GetTexture();
	accumulateComputeMaterialConfig->computeTextures[AtmosphereAccumulateComputeStream_ReflectionProbeTexture]	= config->reflectionProbe->GetIndirectTexture();
	accumulateComputeMaterialConfig->computeTextures[AtmosphereAccumulateComputeStream_AtmosphereTexture]		= accumulateTexture[0];
	accumulateComputeMaterial 																					= new AccumulateComputeMaterial(accumulateComputeMaterialConfig);
	
	BlurComputeMaterial::Config* blurMaterialConfig0 															= new BlurComputeMaterial::Config(@"Atmosphere Blur Material 0");
	blurMaterialConfig0->computeFunction  																		= new Function(@"AtmosphereBlurHKernel");
	blurMaterialConfig0->computeTextures[AtmosphereBlurComputeStream_AtmosphereTexture]							= accumulateTexture[0];
	blurMaterialConfig0->computeTextures[AtmosphereBlurComputeStream_AtmosphereTexture2]						= accumulateTexture[1];
	blurMaterial[0]	 																							= new BlurComputeMaterial(blurMaterialConfig0);
	
	BlurComputeMaterial::Config* blurMaterialConfig1 															= new BlurComputeMaterial::Config(@"Atmosphere Blur Material 1");
	blurMaterialConfig1->computeFunction  																		= new Function(@"AtmosphereBlurVKernel");
	blurMaterialConfig1->computeTextures[AtmosphereBlurComputeStream_AtmosphereTexture]							= accumulateTexture[1];
	blurMaterialConfig1->computeTextures[AtmosphereBlurComputeStream_AtmosphereTexture2]						= accumulateTexture[0];
	blurMaterial[1]	 																							= new BlurComputeMaterial(blurMaterialConfig1);
	
	//RENDER
	
	RenderTarget::Config* renderTargetConfig = new RenderTarget::Config(@"Atmosphere Accumulate");
	
	renderTargetConfig->colorAttachmentCount = RenderTarget::eColorAttachment_1;
	
	renderTargetConfig->colourTextureConfig[0] = new Texture::Config(@"Atmosphere Accumulate as Render");
	renderTargetConfig->colourTextureConfig[0]->width = config->width / config->scale;
	renderTargetConfig->colourTextureConfig[0]->height = config->height / config->scale;
	renderTargetConfig->colourTextureConfig[0]->pixelFormat = Texture::ePixelFormat_RGBA16f;
	renderTargetConfig->colourTextureConfig[0]->mipMaps = false;
	renderTargetConfig->colourTextureConfig[0]->msaa = Texture::eMSAA_1;
	renderTargetConfig->colourTextureSamplerState[0] = SamplerState::PredefinedState(eSamplerState_LinearLinearNone_ClampClamp);
	
	renderTarget = new RenderTarget(renderTargetConfig);
	
	AccumulateRenderMaterial::Config* accumulateRenderMaterialConfig = new AccumulateRenderMaterial::Config(@"Atmosphere Accumulate Render Material");
	accumulateRenderMaterialConfig->blendStates[RenderTarget::eColorAttachment_0] = BlendState::PredefinedState(eBlendState_Off);
	accumulateRenderMaterialConfig->cullState = CullState::PredefinedState(eCullState_Disable);
	accumulateRenderMaterialConfig->depthStencilState = DepthStencilState::PredefinedState(eDepthStencilState_TestDisable_WriteDisable_StencilDisable);
	accumulateRenderMaterialConfig->vertexFunction = new Function(@"AtmosphereVertexShader");
	accumulateRenderMaterialConfig->vertexParamsIndex = AtmosphereVertexStream_Params;
	accumulateRenderMaterialConfig->fragmentFunction = new Function(@"AtmosphereAccumulateFragmentShader");
	accumulateRenderMaterialConfig->fragmentTextureIndex = AtmosphereAccumulateFragmentStream_TextureArgumentBuffer;
	accumulateRenderMaterialConfig->fragmentParamsIndex = AtmosphereAccumulateFragmentStream_Params;
	accumulateRenderMaterialConfig->fragmentTextures[AtmosphereAccumulateFragmentTextureArgumentBuffer_WorldPosTexture] = config->prepass->GetWorldPosTexture();
	accumulateRenderMaterialConfig->fragmentSamplers[AtmosphereAccumulateFragmentTextureArgumentBuffer_WorldPosTexture] = AtmosphereAccumulateFragmentTextureArgumentBuffer_WorldPosSampler;
	accumulateRenderMaterialConfig->fragmentTextures[AtmosphereAccumulateFragmentTextureArgumentBuffer_ShadowTexture] = config->shadowMap->GetTexture();
	accumulateRenderMaterialConfig->fragmentSamplers[AtmosphereAccumulateFragmentTextureArgumentBuffer_ShadowTexture] = AtmosphereAccumulateFragmentTextureArgumentBuffer_ShadowSampler;
	accumulateRenderMaterialConfig->fragmentTextures[AtmosphereAccumulateFragmentTextureArgumentBuffer_ReflectionProbeTexture] = config->reflectionProbe->GetIndirectTexture();
	accumulateRenderMaterialConfig->fragmentSamplers[AtmosphereAccumulateFragmentTextureArgumentBuffer_ReflectionProbeTexture] = AtmosphereAccumulateFragmentTextureArgumentBuffer_ReflectionProbeSampler;
	accumulateRenderMaterial = new AccumulateRenderMaterial(accumulateRenderMaterialConfig, renderTarget);
	
	//MESH
	
	qVector4* vertices = new qVector4[4]
	{
		qVector4(-1.0f, -1.0f, 0.0f, 1.0f),
		qVector4(-1.0f, +1.0f, 0.0f, 1.0f),
		qVector4(+1.0f, +1.0f, 0.0f, 1.0f),
		qVector4(+1.0f, -1.0f, 0.0f, 1.0f)
	};
	
	qVector2* uvs = new qVector2[4]
	{
		qVector2(0.0f, 1.0f),
		qVector2(0.0f, 0.0f),
		qVector2(1.0f, 0.0f),
		qVector2(1.0f, 1.0f)
	};
	
	uint16_t* indices = new uint16_t[6]
	{
		0, 1, 2, 0, 2, 3
	};
	
	Mesh::Config* compositeMeshConfig = new Mesh::Config(@"Atmosphere full screen mesh");
	
	compositeMeshConfig->vertexStreamCount = AtmosphereVertexStreamArgumentBuffer_Count;
	compositeMeshConfig->vertexStreamIndex = AtmosphereVertexStream_StreamArgumentBuffer;
	
	compositeMeshConfig->vertexCount = 4;
	compositeMeshConfig->indexCount = 6;
	
	compositeMeshConfig->vertexStreams[AtmosphereVertexStreamArgumentBuffer_Position].type = Mesh::eVertexStreamType_Float4;
	compositeMeshConfig->vertexStreams[AtmosphereVertexStreamArgumentBuffer_Position].data = vertices;
	
	compositeMeshConfig->vertexStreams[AtmosphereVertexStreamArgumentBuffer_UV].type = Mesh::eVertexStreamType_Float2;
	compositeMeshConfig->vertexStreams[AtmosphereVertexStreamArgumentBuffer_UV].data = uvs;
	
	compositeMeshConfig->indices16 = indices;
	
	fullScreenMesh = new Mesh(compositeMeshConfig);
}

void qRender::Atmosphere::Init(Globals* globals)
{
}

void qRender::Atmosphere::Update(Globals* globals)
{
}

void qRender::Atmosphere::Encode(const Globals* globals) const
{
	qMetal::Device::PushDebugGroup(@"Atmosphere");
	
	AtmosphereAccumulateComputeParams* params = renderAsCompute ? accumulateComputeMaterial->CurrentFrameComputeParams() : accumulateRenderMaterial->CurrentFrameFragmentParams();
	
	params->width = (float)(config->width / config->scale);
	params->height = (float)(config->height /  config->scale);
	params->scale = config->scale;
	params->depthNormalScale = config->depthNormalScale;
	
	memcpy(&params->shadowGlobals, &globals->shadow, sizeof(ShadowMapGlobals));
	
	memcpy(&params->tweaks, &config->tweaks, sizeof(AtmosphereAccumulateComputeTweaks));
	
	if (renderAsCompute)
	{
		id<MTLComputeCommandEncoder> encoder = Device::ComputeEncoder(@"Atmosphere");
		
		accumulateComputeMaterial->EncodeCompute(encoder, config->width / config->scale, config->height / config->scale);
		
//		for(uint32_t blurPass = 0; blurPass < config->blurPasses; ++blurPass)
//		{
//			blurMaterial[0]->EncodeCompute(encoder, config->width / config->scale, config->height / config->scale);
//			blurMaterial[1]->EncodeCompute(encoder, config->width / config->scale, config->height / config->scale);
//		}
		
		[encoder endEncoding];
	}
	else
	{
		id<MTLRenderCommandEncoder> encoder = renderTarget->Begin();
		
		fullScreenMesh->Encode(encoder, accumulateRenderMaterial);
		
		renderTarget->End();
	}
	
	qMetal::Device::PopDebugGroup();
}
