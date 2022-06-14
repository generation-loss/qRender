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

#include "qRenderSSAO.h"
	
qRender::SSAO::SSAO(Config *_config)
: config(_config)
, renderAsCompute( false )
{
#pragma mark Debug Menu
	
	DebugMenu::Instance()->Value("Lighting", "AO", "Render As Compute", renderAsCompute);
	DebugMenu::Instance()->Value("Lighting", "AO", "Num Angles", config->tweaks.numAngles, 1, 1, 32);
	DebugMenu::Instance()->Value("Lighting", "AO", "Num Samples Per Angle", config->tweaks.numSamplesPerAngle, 1.0, 1, 32);
	DebugMenu::Instance()->Value("Lighting", "AO", "Radius", config->tweaks.radius, 0.1f, 0.1f, 50.0f);
	DebugMenu::Instance()->Value("Lighting", "AO", "Tangent Bias", config->tweaks.tangentBias, 0.01, 0.0, 1.0);
	DebugMenu::Instance()->Value("Lighting", "AO", "Blur Size", config->tweaks.blurSize, 1, 0, 5);
	DebugMenu::Instance()->Value("Lighting", "AO", "Blur Depth Threshold", config->tweaks.blurDepthThreshold, 0.01, 0.0, 100.0);
	
#pragma mark Render Targets
	
	ComputeTexture::Config *aoAccumulateTextureConfig = new ComputeTexture::Config(@"SSAO Accumulate", config->width / config->aoScale, config->height / config->aoScale, Texture::ePixelFormat_RG16f);
	accumulateTexture = new ComputeTexture(aoAccumulateTextureConfig);
	
	ComputeTexture::Config *upscaleBlurTextureConfig = new ComputeTexture::Config(@"SSAO Upscale Blur", config->width / config->blurScale, config->height / config->blurScale, Texture::ePixelFormat_R8);
	upscaleBlurTexture = new ComputeTexture(upscaleBlurTextureConfig);
	
#pragma mark Textures
	
	Noise::Config *noiseConfig = new Noise::Config(@"SSAO Noise Texture");
	noiseConfig->width = config->width / config->aoScale;
	noiseConfig->height = config->height / config->aoScale;
	noiseConfig->pixelFormat = Texture::ePixelFormat_R16f;
	noiseConfig->mode = Noise::eMode_Random;
	noise = new Noise(noiseConfig);
	
#pragma mark RenderTarget
	
	RenderTarget::Config *renderTargetConfig = new RenderTarget::Config(@"SSAO Accumulate");
	
	renderTargetConfig->colorAttachmentCount = RenderTarget::eColorAttachment_1;
	
	renderTargetConfig->colourTextureConfig[0] = new Texture::Config(@"SSAO Accumulate as Render");
	renderTargetConfig->colourTextureConfig[0]->width = config->width / config->aoScale;
	renderTargetConfig->colourTextureConfig[0]->height = config->height / config->aoScale;
	renderTargetConfig->colourTextureConfig[0]->pixelFormat = Texture::ePixelFormat_RGBA16f;
	renderTargetConfig->colourTextureConfig[0]->mipMaps = false;
	renderTargetConfig->colourTextureConfig[0]->msaa = Texture::eMSAA_1;
	renderTargetConfig->colourTextureSamplerState[0] = SamplerState::PredefinedState(eSamplerState_PointPointNone_ClampClamp);
	
	renderTarget = new RenderTarget(renderTargetConfig);
	
#pragma mark Materials
	
	SSAOAccumulateMaterial::Config *accumulateComputeMaterialConfig 								= new SSAOAccumulateMaterial::Config(@"AO Accumulate Material");
	accumulateComputeMaterialConfig->computeFunction  												= new Function(@"AOAccumulateShader");
	accumulateComputeMaterialConfig->computeParamsIndex												= AOAccumulateComputeStream_Params;
	accumulateComputeMaterialConfig->computeTextures[AOAccumulateComputeStream_WorldPosTexture] 	= config->prepass->GetWorldPosTexture();
	accumulateComputeMaterialConfig->computeTextures[AOAccumulateComputeStream_WorldNormal]			= config->prepass->GetWorldNormalTexture();
	accumulateComputeMaterialConfig->computeTextures[AOAccumulateComputeStream_Noise]				= noise->GetTexture();
	accumulateComputeMaterialConfig->computeTextures[AOAccumulateComputeStream_AOTexture] 			= accumulateTexture;
	accumulateComputeMaterial 																		= new SSAOAccumulateMaterial(accumulateComputeMaterialConfig);
	
	SSAOAccumulateMaterial::Config *upscaleBlurMaterialComputeConfig 								= new SSAOAccumulateMaterial::Config(@"AO Upscale Material");
	upscaleBlurMaterialComputeConfig->computeFunction  												= new Function(@"AOUpscaleBlurShader");
	upscaleBlurMaterialComputeConfig->computeParamsIndex											= AOAccumulateComputeStream_Params;
	upscaleBlurMaterialComputeConfig->computeTextures[AOAccumulateComputeStream_WorldPosTexture] 	= config->prepass->GetWorldPosTexture();
	upscaleBlurMaterialComputeConfig->computeTextures[AOAccumulateComputeStream_AOTexture]			= accumulateTexture;
	upscaleBlurMaterialComputeConfig->computeTextures[AOAccumulateComputeStream_AOUpscaleTexture]	= upscaleBlurTexture;
	upscaleBlurMaterialCompute																		= new SSAOAccumulateMaterial(upscaleBlurMaterialComputeConfig);
	
	SSAOAccumulateMaterial::Config *upscaleBlurMaterialRenderConfig 								= new SSAOAccumulateMaterial::Config(@"AO Upscale Material");
	upscaleBlurMaterialRenderConfig->computeFunction  												= new Function(@"AOUpscaleBlurShader");
	upscaleBlurMaterialRenderConfig->computeParamsIndex												= AOAccumulateComputeStream_Params;
	upscaleBlurMaterialRenderConfig->computeTextures[AOAccumulateComputeStream_WorldPosTexture] 	= config->prepass->GetWorldPosTexture();
	upscaleBlurMaterialRenderConfig->computeTextures[AOAccumulateComputeStream_AOTexture]			= renderTarget->ColourTexture(RenderTarget::eColorAttachment_0);
	upscaleBlurMaterialRenderConfig->computeTextures[AOAccumulateComputeStream_AOUpscaleTexture]	= upscaleBlurTexture;
	upscaleBlurMaterialRender																		= new SSAOAccumulateMaterial(upscaleBlurMaterialRenderConfig);
	
	AccumulateRenderMaterial::Config *accumulateRenderMaterialConfig = new AccumulateRenderMaterial::Config(@"Atmosphere Accumulate Render Material");
	accumulateRenderMaterialConfig->blendStates[RenderTarget::eColorAttachment_0] = BlendState::PredefinedState(eBlendState_Off);
	accumulateRenderMaterialConfig->cullState = CullState::PredefinedState(eCullState_Disable);
	accumulateRenderMaterialConfig->depthStencilState = DepthStencilState::PredefinedState(eDepthStencilState_TestDisable_WriteDisable_StencilDisable);
	accumulateRenderMaterialConfig->vertexFunction = new Function(@"AOVertexShader");
	accumulateRenderMaterialConfig->vertexParamsIndex = AOVertexStream_Params;
	accumulateRenderMaterialConfig->fragmentFunction = new Function(@"AOAccumulateFragmentShader");
	accumulateRenderMaterialConfig->fragmentTextureIndex = AOAccumulateFragmentStream_TextureArgumentBuffer;
	accumulateRenderMaterialConfig->fragmentParamsIndex = AOAccumulateFragmentStream_Params;
	accumulateRenderMaterialConfig->fragmentTextures[AOAccumulateFragmentTextureArgumentBuffer_WorldPosTexture] = config->prepass->GetWorldPosTexture();
	accumulateRenderMaterialConfig->fragmentSamplers[AOAccumulateFragmentTextureArgumentBuffer_WorldPosTexture] = AOAccumulateFragmentTextureArgumentBuffer_WorldPosSampler;
	accumulateRenderMaterialConfig->fragmentTextures[AOAccumulateFragmentTextureArgumentBuffer_WorldNormalTexture] = config->prepass->GetWorldNormalTexture();
	accumulateRenderMaterialConfig->fragmentSamplers[AOAccumulateFragmentTextureArgumentBuffer_WorldNormalTexture] = AOAccumulateFragmentTextureArgumentBuffer_WorldNormalSampler;
	accumulateRenderMaterialConfig->fragmentTextures[AOAccumulateFragmentTextureArgumentBuffer_NoiseTexture] = noise->GetTexture();
	accumulateRenderMaterialConfig->fragmentSamplers[AOAccumulateFragmentTextureArgumentBuffer_NoiseTexture] = AOAccumulateFragmentTextureArgumentBuffer_NoiseSampler;
	accumulateRenderMaterial = new AccumulateRenderMaterial(accumulateRenderMaterialConfig, renderTarget);
	
#pragma mark Mesh
	
	qVector4 *vertices = new qVector4[4]
	{
		qVector4(-1.0f, -1.0f, 0.0f, 1.0f),
		qVector4(-1.0f, +1.0f, 0.0f, 1.0f),
		qVector4(+1.0f, +1.0f, 0.0f, 1.0f),
		qVector4(+1.0f, -1.0f, 0.0f, 1.0f)
	};
	
	qVector2 *uvs = new qVector2[4]
	{
		qVector2(0.0f, 1.0f),
		qVector2(0.0f, 0.0f),
		qVector2(1.0f, 0.0f),
		qVector2(1.0f, 1.0f)
	};
	
	uint16_t *indices = new uint16_t[6]
	{
		0, 1, 2, 0, 2, 3
	};
	
	Mesh::Config *compositeMeshConfig = new Mesh::Config(@"SSAO full screen mesh");
	
	compositeMeshConfig->vertexStreamCount = AOVertexStreamArgumentBuffer_Count;
	compositeMeshConfig->vertexStreamIndex = AOVertexStream_StreamArgumentBuffer;
	
	compositeMeshConfig->vertexCount = 4;
	compositeMeshConfig->indexCount = 6;
	
	compositeMeshConfig->vertexStreams[AOVertexStreamArgumentBuffer_Position].type = Mesh::eVertexStreamType_Float4;
	compositeMeshConfig->vertexStreams[AOVertexStreamArgumentBuffer_Position].data = vertices;
	
	compositeMeshConfig->vertexStreams[AOVertexStreamArgumentBuffer_UV].type = Mesh::eVertexStreamType_Float2;
	compositeMeshConfig->vertexStreams[AOVertexStreamArgumentBuffer_UV].data = uvs;
	
	compositeMeshConfig->indices16 = indices;
	
	fullScreenMesh = new Mesh(compositeMeshConfig);
}

void qRender::SSAO::Init(Globals *globals)
{
}

void qRender::SSAO::Update(Globals *globals)
{
}

void qRender::SSAO::Encode(const Globals *globals) const
{
	qMetal::Device::PushDebugGroup(@"SSAO");
	
	AOAccumulateComputeParams *params = renderAsCompute ? accumulateComputeMaterial->CurrentFrameComputeParams() : accumulateRenderMaterial->CurrentFrameFragmentParams();
	
	params->prepassWidth 		= (float)config->width;
	params->prepassHeight 		= (float)config->height;
	params->accumulateWidth 	= (float)(config->width / config->aoScale);
	params->accumulateHeight 	= (float)(config->height /  config->aoScale);
	params->blurWidth			= (float)(config->width / config->blurScale);
	params->blurHeight			= (float)(config->height /  config->blurScale);
	memcpy(&params->cameraGlobals, &globals->sceneCameraGlobals, sizeof(CameraGlobals));
	memcpy(&params->tweaks, &config->tweaks, sizeof(AOAccumulateComputeTweaks));
	
	AOAccumulateComputeParams *upscaleBlurParams = renderAsCompute ? upscaleBlurMaterialCompute->CurrentFrameComputeParams() : upscaleBlurMaterialRender->CurrentFrameComputeParams();
	
	upscaleBlurParams->prepassWidth 		= (float)config->width;
	upscaleBlurParams->prepassHeight 		= (float)config->height;
	upscaleBlurParams->accumulateWidth 		= (float)(config->width / config->aoScale);
	upscaleBlurParams->accumulateHeight 	= (float)(config->height /  config->aoScale);
	upscaleBlurParams->blurWidth			= (float)(config->width / config->blurScale);
	upscaleBlurParams->blurHeight			= (float)(config->height /  config->blurScale);
	memcpy(&upscaleBlurParams->cameraGlobals, &globals->sceneCameraGlobals, sizeof(CameraGlobals));
	memcpy(&upscaleBlurParams->tweaks, &config->tweaks, sizeof(AOAccumulateComputeTweaks));
	
	if (renderAsCompute)
	{
		id<MTLComputeCommandEncoder> encoder = Device::ComputeEncoder(@"SSAO");
		accumulateComputeMaterial->EncodeCompute(encoder, config->width / config->aoScale, config->height / config->aoScale);
		upscaleBlurMaterialCompute->EncodeCompute(encoder, config->width / config->blurScale, config->height / config->blurScale);
		[encoder endEncoding];
	}
	else
	{
		id<MTLRenderCommandEncoder> renderEncoder = renderTarget->Begin();
		fullScreenMesh->Encode(renderEncoder, accumulateRenderMaterial);
		renderTarget->End();
		
		id<MTLComputeCommandEncoder> computeEncoder = Device::ComputeEncoder(@"SSAO");
		upscaleBlurMaterialRender->EncodeCompute(computeEncoder, config->width / config->blurScale, config->height / config->blurScale);
		[computeEncoder endEncoding];
	}
	
	qMetal::Device::PopDebugGroup();
}
