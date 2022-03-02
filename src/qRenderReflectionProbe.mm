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

#include "qRenderReflectionProbe.h"

qRender::ReflectionProbe::ReflectionProbe(Config *_config)
: config(_config)
, currentSlice(0)
{
	//NOTE: neither memoryless nor MSAA is supported on cubemaps
	
	RenderTarget::Config *renderTargetConfig = new RenderTarget::Config([NSString stringWithFormat:@"Reflection Probe Face 0"]);
	
	renderTargetConfig->colorAttachmentCount = (RenderTarget::eColorAttachment)eGBufferRenderTarget_Count;
	
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Lighting] = new Texture::Config(@"Reflection Probe Lighting");
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Lighting]->type = Texture::eType_Cube;
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Lighting]->width = config->size;
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Lighting]->height = config->size;
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Lighting]->pixelFormat = config->baseRenderTarget->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Lighting)->GetConfig()->pixelFormat;
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Lighting]->mipMaps = true;
	
#if USE_DEFFERRED_RENDERING
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Albedo_Roughness] = new Texture::Config(@"Reflection Probe Albedo RGB Roughness A");
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Albedo_Roughness]->type = Texture::eType_Cube;
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Albedo_Roughness]->width = config->size;
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Albedo_Roughness]->height = config->size;
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Albedo_Roughness]->pixelFormat = baseRenderTarget->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Albedo_Roughness)->GetConfig()->pixelFormat;
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Albedo_Roughness]->mipMaps = false;
	
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Normal] = new Texture::Config(@"Reflection Probe Normal");
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Normal]->type = Texture::eType_Cube;
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Normal]->width = config->size;
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Normal]->height = config->size;
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Normal]->pixelFormat = baseRenderTarget->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Normal)->GetConfig()->pixelFormat;
	renderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Normal]->mipMaps = false;
	
#if USE_DEFERRED_WORLD_POSITION
	eGBufferRenderTarget depthWorldPositionRenderTarget = eGBufferRenderTarget_WorldPos;
	NSString *depthWorldPositionName = @"Reflection Probe World Position";
	NSString *depthWorldPositionIndirectName = @"Indirect Reflection Probe World Position";
#else
	eGBufferRenderTarget depthWorldPositionRenderTarget = eGBufferRenderTarget_Depth;
	NSString *depthWorldPositionName = @"Reflection Probe Depth as Texture";
	NSString *depthWorldPositionIndirectName = @"Indirect Reflection Probe Depth as Texture";
#endif
	
	renderTargetConfig->colourTextureConfig[depthWorldPositionRenderTarget] = new Texture::Config(depthWorldPositionName);
	renderTargetConfig->colourTextureConfig[depthWorldPositionRenderTarget]->type = Texture::eType_Cube;
	renderTargetConfig->colourTextureConfig[depthWorldPositionRenderTarget]->width = config->size;
	renderTargetConfig->colourTextureConfig[depthWorldPositionRenderTarget]->height = config->size;
	renderTargetConfig->colourTextureConfig[depthWorldPositionRenderTarget]->pixelFormat = baseRenderTarget->ColourTexture((RenderTarget::eColorAttachment)depthWorldPositionRenderTarget)->GetConfig()->pixelFormat;
	renderTargetConfig->colourTextureConfig[depthWorldPositionRenderTarget]->mipMaps = false;
#endif // #if USE_DEFFERRED_RENDERING
	
	renderTargetConfig->colourTextureSamplerState[eGBufferRenderTarget_Lighting] = SamplerState::PredefinedState(eSamplerState_LinearLinearLinear_ClampClamp);
#if USE_DEFFERRED_RENDERING
	renderTargetConfig->colourTextureSamplerState[eGBufferRenderTarget_Albedo_Roughness] = SamplerState::PredefinedState(eSamplerState_LinearLinearLinear_ClampClamp);
	renderTargetConfig->colourTextureSamplerState[eGBufferRenderTarget_Normal] = SamplerState::PredefinedState(eSamplerState_LinearLinearLinear_ClampClamp);
	renderTargetConfig->colourTextureSamplerState[depthWorldPositionRenderTarget] = SamplerState::PredefinedState(eSamplerState_LinearLinearLinear_ClampClamp);
#endif // #if USE_DEFFERRED_RENDERING

	renderTargetConfig->clearAction[eGBufferRenderTarget_Lighting] = RenderTarget::eClearAction_Clear;
	
	renderTargetConfig->clearColour[eGBufferRenderTarget_Lighting] = qRGBA32f_Black;
#if USE_DEFFERRED_RENDERING
	renderTargetConfig->clearAction[eGBufferRenderTarget_Albedo_Roughness] = RenderTarget::eClearAction_Nothing;
	renderTargetConfig->clearAction[eGBufferRenderTarget_Normal] = RenderTarget::eClearAction_Nothing;
	renderTargetConfig->clearAction[depthWorldPositionRenderTarget] = RenderTarget::eClearAction_Nothing;
#endif // #if USE_DEFFERRED_RENDERING

	renderTargetConfig->depthTextureConfig = new Texture::Config(@"Reflection Probe Depth");
	renderTargetConfig->depthTextureConfig->type = Texture::eType_Cube;
	renderTargetConfig->depthTextureConfig->width = config->size;
	renderTargetConfig->depthTextureConfig->height = config->size;
	renderTargetConfig->depthTextureConfig->pixelFormat = config->baseRenderTarget->DepthTexture()->GetConfig()->pixelFormat;
	renderTargetConfig->depthTextureConfig->mipMaps = false;
	renderTargetConfig->depthTextureSamplerState = SamplerState::PredefinedState(eSamplerState_LinearLinearNone_ClampClamp);
	
	renderTargetConfig->stencilTextureConfig = new Texture::Config(@"Reflection Probe Stencil");
	renderTargetConfig->stencilTextureConfig->type = Texture::eType_Cube;
	renderTargetConfig->stencilTextureConfig->width = config->size;
	renderTargetConfig->stencilTextureConfig->height = config->size;
	renderTargetConfig->stencilTextureConfig->pixelFormat = config->baseRenderTarget->StencilTexture()->GetConfig()->pixelFormat;
	renderTargetConfig->stencilTextureConfig->mipMaps = false;
	renderTargetConfig->stencilTextureSamplerState = SamplerState::PredefinedState(eSamplerState_LinearLinearNone_ClampClamp);
	
	renderTargetConfig->slice = 0;
	
	renderTarget[0] = new RenderTarget(renderTargetConfig);
	
	for (uint32_t i = 1; i < 6; ++i)
	{
		RenderTarget::Config *sharedFaceRenderTargetConfig = new RenderTarget::Config([NSString stringWithFormat:@"Reflection Probe Face %u", i]);
		
		sharedFaceRenderTargetConfig->colorAttachmentCount = (RenderTarget::eColorAttachment)eGBufferRenderTarget_Count;
		
		sharedFaceRenderTargetConfig->colourTexture[eGBufferRenderTarget_Lighting] = renderTarget[0]->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Lighting);
#if USE_DEFFERRED_RENDERING
		sharedFaceRenderTargetConfig->colourTexture[eGBufferRenderTarget_Albedo_Roughness] = renderTarget[0]->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Albedo_Roughness);
		sharedFaceRenderTargetConfig->colourTexture[eGBufferRenderTarget_Normal] = renderTarget[0]->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Normal);
		sharedFaceRenderTargetConfig->colourTexture[depthWorldPositionRenderTarget] = renderTarget[0]->ColourTexture((RenderTarget::eColorAttachment)depthWorldPositionRenderTarget);
#endif // #if USE_DEFFERRED_RENDERING
		
		sharedFaceRenderTargetConfig->colourTextureSamplerState[eGBufferRenderTarget_Lighting] = SamplerState::PredefinedState(eSamplerState_LinearLinearLinear_ClampClamp);
#if USE_DEFFERRED_RENDERING
		sharedFaceRenderTargetConfig->colourTextureSamplerState[eGBufferRenderTarget_Albedo_Roughness] = SamplerState::PredefinedState(eSamplerState_LinearLinearLinear_ClampClamp);
		sharedFaceRenderTargetConfig->colourTextureSamplerState[eGBufferRenderTarget_Normal] = SamplerState::PredefinedState(eSamplerState_LinearLinearLinear_ClampClamp);
		sharedFaceRenderTargetConfig->colourTextureSamplerState[depthWorldPositionRenderTarget] = SamplerState::PredefinedState(eSamplerState_LinearLinearLinear_ClampClamp);
#endif // #if USE_DEFFERRED_RENDERING

		sharedFaceRenderTargetConfig->clearAction[eGBufferRenderTarget_Lighting] = RenderTarget::eClearAction_Clear;
#if USE_DEFFERRED_RENDERING
		sharedFaceRenderTargetConfig->clearAction[eGBufferRenderTarget_Albedo_Roughness] = RenderTarget::eClearAction_Nothing;
		sharedFaceRenderTargetConfig->clearAction[eGBufferRenderTarget_Normal] = RenderTarget::eClearAction_Nothing;
		sharedFaceRenderTargetConfig->clearAction[depthWorldPositionRenderTarget] = RenderTarget::eClearAction_Nothing;
#endif // #if USE_DEFFERRED_RENDERING
		
		sharedFaceRenderTargetConfig->clearColour[eGBufferRenderTarget_Lighting] = qRGBA32f_Black;
		
		sharedFaceRenderTargetConfig->depthTexture = renderTarget[0]->DepthTexture();
		sharedFaceRenderTargetConfig->stencilTexture = renderTarget[0]->StencilTexture();
		sharedFaceRenderTargetConfig->slice = i;
		renderTarget[i] = new RenderTarget(sharedFaceRenderTargetConfig);
	}
	
	const uint32_t INDIRECT_SIZE = 32;
	
	RenderTarget::Config *indirectRenderTargetConfig = new RenderTarget::Config([NSString stringWithFormat:@"Indirect Reflection Probe Face 0"]);
	
	indirectRenderTargetConfig->colorAttachmentCount = (RenderTarget::eColorAttachment)eGBufferRenderTarget_Count;
	
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Lighting] = new Texture::Config(@"Indirect Reflection Probe Lighting");
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Lighting]->type = Texture::eType_Cube;
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Lighting]->width = INDIRECT_SIZE;
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Lighting]->height = INDIRECT_SIZE;
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Lighting]->pixelFormat = config->baseRenderTarget->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Lighting)->GetConfig()->pixelFormat;
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Lighting]->mipMaps = true;
	
#if USE_DEFFERRED_RENDERING
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Albedo_Roughness] = new Texture::Config(@"Indirect Reflection Probe Albedo RGB Roughness A");
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Albedo_Roughness]->type = Texture::eType_Cube;
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Albedo_Roughness]->width = INDIRECT_SIZE;
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Albedo_Roughness]->height = INDIRECT_SIZE;
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Albedo_Roughness]->pixelFormat = baseRenderTarget->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Albedo_Roughness)->GetConfig()->pixelFormat;
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Albedo_Roughness]->mipMaps = false;
	
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Normal] = new Texture::Config(@"Indirect Reflection Probe Normal");
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Normal]->type = Texture::eType_Cube;
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Normal]->width = INDIRECT_SIZE;
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Normal]->height = INDIRECT_SIZE;
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Normal]->pixelFormat = baseRenderTarget->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Normal)->GetConfig()->pixelFormat;
	indirectRenderTargetConfig->colourTextureConfig[eGBufferRenderTarget_Normal]->mipMaps = false;
	
	indirectRenderTargetConfig->colourTextureConfig[depthWorldPositionRenderTarget] = new Texture::Config(depthWorldPositionIndirectName);
	indirectRenderTargetConfig->colourTextureConfig[depthWorldPositionRenderTarget]->type = Texture::eType_Cube;
	indirectRenderTargetConfig->colourTextureConfig[depthWorldPositionRenderTarget]->width = INDIRECT_SIZE;
	indirectRenderTargetConfig->colourTextureConfig[depthWorldPositionRenderTarget]->height = INDIRECT_SIZE;
	indirectRenderTargetConfig->colourTextureConfig[depthWorldPositionRenderTarget]->pixelFormat = config->baseRenderTarget->ColourTexture((RenderTarget::eColorAttachment)depthWorldPositionRenderTarget)->GetConfig()->pixelFormat;
	indirectRenderTargetConfig->colourTextureConfig[depthWorldPositionRenderTarget]->mipMaps = false;
#endif // #if USE_DEFFERRED_RENDERING
	
	indirectRenderTargetConfig->colourTextureSamplerState[eGBufferRenderTarget_Lighting] = SamplerState::PredefinedState(eSamplerState_LinearLinearLinear_ClampClamp);
	
	indirectRenderTargetConfig->clearAction[eGBufferRenderTarget_Lighting] = RenderTarget::eClearAction_Clear;
	indirectRenderTargetConfig->clearColour[eGBufferRenderTarget_Lighting] = qRGBA32f_Black;
	
	indirectRenderTargetConfig->depthTextureConfig = new Texture::Config(@"Indirect Reflection Probe Depth");
	indirectRenderTargetConfig->depthTextureConfig->type = Texture::eType_Cube;
	indirectRenderTargetConfig->depthTextureConfig->width = INDIRECT_SIZE;
	indirectRenderTargetConfig->depthTextureConfig->height = INDIRECT_SIZE;
	indirectRenderTargetConfig->depthTextureConfig->pixelFormat = config->baseRenderTarget->DepthTexture()->GetConfig()->pixelFormat;
	indirectRenderTargetConfig->depthTextureConfig->mipMaps = false;
	indirectRenderTargetConfig->depthTextureSamplerState = SamplerState::PredefinedState(eSamplerState_LinearLinearNone_ClampClamp);
	
	indirectRenderTargetConfig->stencilTextureConfig = new Texture::Config(@"Indirect Reflection Probe Stencil");
	indirectRenderTargetConfig->stencilTextureConfig->type = Texture::eType_Cube;
	indirectRenderTargetConfig->stencilTextureConfig->width = INDIRECT_SIZE;
	indirectRenderTargetConfig->stencilTextureConfig->height = INDIRECT_SIZE;
	indirectRenderTargetConfig->stencilTextureConfig->pixelFormat = config->baseRenderTarget->StencilTexture()->GetConfig()->pixelFormat;
	indirectRenderTargetConfig->stencilTextureConfig->mipMaps = false;
	indirectRenderTargetConfig->stencilTextureSamplerState = SamplerState::PredefinedState(eSamplerState_LinearLinearNone_ClampClamp);
	
	indirectRenderTargetConfig->slice = 0;
	
	indirectRenderTarget[0] = new RenderTarget(indirectRenderTargetConfig);
	
	for (uint32_t i = 1; i < 6; ++i)
	{
		RenderTarget::Config *sharedFaceIndirectRenderTargetConfig = new RenderTarget::Config([NSString stringWithFormat:@"Indirect Reflection Probe Face %u", i]);
		
		sharedFaceIndirectRenderTargetConfig->colorAttachmentCount = (RenderTarget::eColorAttachment)eGBufferRenderTarget_Count;
		
		sharedFaceIndirectRenderTargetConfig->colourTexture[eGBufferRenderTarget_Lighting] = indirectRenderTarget[0]->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Lighting);
#if USE_DEFFERRED_RENDERING
		sharedFaceIndirectRenderTargetConfig->colourTexture[eGBufferRenderTarget_Albedo_Roughness] = indirectRenderTarget[0]->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Albedo_Roughness);
		sharedFaceIndirectRenderTargetConfig->colourTexture[eGBufferRenderTarget_Normal] = indirectRenderTarget[0]->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Normal);
		sharedFaceIndirectRenderTargetConfig->colourTexture[depthWorldPositionRenderTarget] = indirectRenderTarget[0]->ColourTexture((RenderTarget::eColorAttachment)depthWorldPositionRenderTarget);
#endif // #if USE_DEFFERRED_RENDERING
		
		sharedFaceIndirectRenderTargetConfig->colourTextureSamplerState[eGBufferRenderTarget_Lighting] = SamplerState::PredefinedState(eSamplerState_LinearLinearLinear_ClampClamp);
#if USE_DEFFERRED_RENDERING
		sharedFaceIndirectRenderTargetConfig->colourTextureSamplerState[eGBufferRenderTarget_Albedo_Roughness] = SamplerState::PredefinedState(eSamplerState_LinearLinearLinear_ClampClamp);
		sharedFaceIndirectRenderTargetConfig->colourTextureSamplerState[eGBufferRenderTarget_Normal] = SamplerState::PredefinedState(eSamplerState_LinearLinearLinear_ClampClamp);
		sharedFaceIndirectRenderTargetConfig->colourTextureSamplerState[depthWorldPositionRenderTarget] = SamplerState::PredefinedState(eSamplerState_LinearLinearLinear_ClampClamp);
#endif // #if USE_DEFFERRED_RENDERING
		
		sharedFaceIndirectRenderTargetConfig->clearAction[eGBufferRenderTarget_Lighting] = RenderTarget::eClearAction_Clear;
#if USE_DEFFERRED_RENDERING
		sharedFaceIndirectRenderTargetConfig->clearAction[eGBufferRenderTarget_Albedo_Roughness] = RenderTarget::eClearAction_Nothing;
		sharedFaceIndirectRenderTargetConfig->clearAction[eGBufferRenderTarget_Normal] = RenderTarget::eClearAction_Nothing;
		sharedFaceIndirectRenderTargetConfig->clearAction[depthWorldPositionRenderTarget] = RenderTarget::eClearAction_Nothing;
#endif // #if USE_DEFFERRED_RENDERING
		
		sharedFaceIndirectRenderTargetConfig->depthTexture = indirectRenderTarget[0]->DepthTexture();
		sharedFaceIndirectRenderTargetConfig->stencilTexture = indirectRenderTarget[0]->StencilTexture();
		sharedFaceIndirectRenderTargetConfig->slice = i;
		indirectRenderTarget[i] = new RenderTarget(sharedFaceIndirectRenderTargetConfig);
	}
	
	for (uint32_t i = 0; i < 6; ++i)
	{
		Camera::Config *cameraConfig = new Camera::Config([NSString stringWithFormat:@"Reflection Probe %i", i]);
		
		cameraConfig->position = config->position;
		cameraConfig->lookAt = config->position + kFaceDirection[i];
		cameraConfig->up = kFaceUp[i];
		
		cameraConfig->FoVY = 90.0;
		cameraConfig->aspectRatio = 1.0f;
		cameraConfig->nearPlane = config->cameraConfig->nearPlane;
		cameraConfig->farPlane = config->cameraConfig->farPlane;
		
		cameraConfig->ISO = config->cameraConfig->ISO;
		cameraConfig->aperture = config->cameraConfig->aperture;
		cameraConfig->shutterSpeed = config->cameraConfig->shutterSpeed;
		
		camera[i] = new Camera(cameraConfig);
	}
}

void qRender::ReflectionProbe::Init(Globals *globals)
{
	for(uint32_t i = 0; i < 6; ++i)
	{
		indirectRenderTarget[i]->Begin();
		indirectRenderTarget[i]->End();
		renderTarget[i]->Begin();
		renderTarget[i]->End();
	}
	
	id<MTLBlitCommandEncoder> blitEncoder = Device::BlitEncoder(@"Reflection Probe Init");
	for(uint32_t i = 0; i < 6; ++i)
	{
		[blitEncoder generateMipmapsForTexture:indirectRenderTarget[i]->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Lighting)->MTLTexture()];
		[blitEncoder generateMipmapsForTexture:renderTarget[i]->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Lighting)->MTLTexture()];
	}
	[blitEncoder endEncoding];
}

void qRender::ReflectionProbe::Update(Globals *globals)
{
	currentSlice = (currentSlice + 1) % 6;
}

void qRender::ReflectionProbe::EncodeIndirect(const Globals *globals) const
{
	if (config->updateSingleFacePerFrameIndirect)
	{
		id<MTLRenderCommandEncoder> indirectEncoder = indirectRenderTarget[currentSlice]->Begin();
		for(auto &it : indirectRenderables)
		{
			it->Encode(indirectEncoder, camera[currentSlice], globals, eRenderablePass_IndirectReflectionProbe0 + currentSlice);
		}
		indirectRenderTarget[currentSlice]->End();
		
		id<MTLBlitCommandEncoder> indirectBlitEncoder = Device::BlitEncoder(@"Reflection Probe Indirect");
		[indirectBlitEncoder generateMipmapsForTexture:indirectRenderTarget[currentSlice]->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Lighting)->MTLTexture()];
		[indirectBlitEncoder endEncoding];
	}
	else
	{
		for(uint32_t i = 0; i < 6; ++i)
		{
			id<MTLRenderCommandEncoder> indirectEncoder = indirectRenderTarget[i]->Begin();
			for(auto &it : indirectRenderables)
			{
				it->Encode(indirectEncoder, camera[i], globals, eRenderablePass_IndirectReflectionProbe0 + i);
			}
			indirectRenderTarget[i]->End();
		}
		
		id<MTLBlitCommandEncoder> indirectBlitEncoder = Device::BlitEncoder(@"Reflection Probe Indirect");
		for(uint32_t i = 0; i < 6; ++i)
		{
			[indirectBlitEncoder generateMipmapsForTexture:indirectRenderTarget[i]->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Lighting)->MTLTexture()];
		}
		[indirectBlitEncoder endEncoding];
	}
}

void qRender::ReflectionProbe::Encode(const Globals *globals) const
{
	if (config->updateSingleFacePerFrame)
	{
		for(auto &it : renderables)
		{
			it->Reset(eRenderablePass_ReflectionProbe);
		}
		
		id<MTLComputeCommandEncoder> reflectionComputeEncoder = Device::ComputeEncoder(@"Reflection Probe Render");;
		for(auto &it : renderables)
		{
			it->EncodeCompute(reflectionComputeEncoder, camera[currentSlice], globals, eRenderablePass_ReflectionProbe);
		}
		[reflectionComputeEncoder endEncoding];
		
		for(auto &it : renderables)
		{
			it->Optimize(eRenderablePass_ReflectionProbe);
		}
		
		id<MTLRenderCommandEncoder> encoder = renderTarget[currentSlice]->Begin();
		for(auto &it : renderables)
		{
			it->Encode(encoder, camera[currentSlice], globals, eRenderablePass_ReflectionProbe);
		}
		renderTarget[currentSlice]->End();

		id<MTLBlitCommandEncoder> blitEncoder = Device::BlitEncoder(@"Reflection Probe Mip Maps");
		[blitEncoder generateMipmapsForTexture:renderTarget[currentSlice]->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Lighting)->MTLTexture()];
		[blitEncoder endEncoding];
	}
	else
	{
		for(uint32_t i = 0; i < 6; ++i)
		{
			id<MTLRenderCommandEncoder> encoder = renderTarget[i]->Begin();
			for(auto &it : renderables)
			{
				it->Encode(encoder, camera[i], globals, eRenderablePass_ReflectionProbe);
			}
			renderTarget[i]->End();
		}

		id<MTLBlitCommandEncoder> blitEncoder = Device::BlitEncoder(@"Reflection Probe Mip Maps");
		for(uint32_t i = 0; i < 6; ++i)
		{
			[blitEncoder generateMipmapsForTexture:renderTarget[i]->ColourTexture((RenderTarget::eColorAttachment)eGBufferRenderTarget_Lighting)->MTLTexture()];
		}
		[blitEncoder endEncoding];
	}
}

void qRender::ReflectionProbe::AddIndirectRenderable(Renderable* renderable)
{
	indirectRenderables.push_back(renderable);
}

