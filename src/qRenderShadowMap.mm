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

#include "qRenderShadowMap.h"

static bool evenFrame = true;

qRender::ShadowMap::ShadowMap(Config *_config)
: config(_config)
{
	// RENDER TARGETS FOR CASCADES
	
	RenderTarget::Config *cameraRenderTargetConfig = new RenderTarget::Config(@"Shadow Map 0");
	cameraRenderTargetConfig->colorAttachmentCount = RenderTarget::eColorAttachment_0;
	cameraRenderTargetConfig->depthTextureConfig = new Texture::Config(@"Shadow Map 0");
	cameraRenderTargetConfig->depthTextureConfig->type = Texture::eType_2DArray;
	cameraRenderTargetConfig->depthTextureConfig->width = config->renderSize;
	cameraRenderTargetConfig->depthTextureConfig->height = config->renderSize;
	cameraRenderTargetConfig->depthTextureConfig->arrayLength = SHADOW_CASCADE_COUNT;
	cameraRenderTargetConfig->depthTextureConfig->pixelFormat = Texture::ePixelFormat_Depth32f;
	cameraRenderTargetConfig->depthTextureConfig->mipMaps = false; //can't generate mip-maps using generateMipmapsForTexture for depth textures
	cameraRenderTargetConfig->slice = 0;
	cameraRenderTargetConfig->depthTextureSamplerState = SamplerState::PredefinedState(eSamplerState_PointPointNone_ClampClamp);
	cameraRenderTargetConfig->depthClearAction = RenderTarget::eClearAction_Clear;
	cameraRenderTargetConfig->depthClear = 1.0f;
#if USE_SHADOW_MSAA
	cameraRenderTargetConfig->depthTextureConfig->msaa = Texture::eMSAA_4;
	cameraRenderTargetConfig->depthTextureConfig->memoryless = true;
	
	cameraRenderTargetConfig->depthResolveTextureConfig = new Texture::Config();
	cameraRenderTargetConfig->depthResolveTextureConfig->type = Texture::eType_2D;
	cameraRenderTargetConfig->depthResolveTextureConfig->width = config->renderSize;
	cameraRenderTargetConfig->depthResolveTextureConfig->height = config->renderSize;
	cameraRenderTargetConfig->depthResolveTextureConfig->pixelFormat = Texture::ePixelFormat_Depth32f;
	cameraRenderTargetConfig->depthResolveTextureConfig->mipMaps = false;
	cameraRenderTargetConfig->depthResolveTextureSamplerState = SamplerState::PredefinedState(eSamplerState_PointPointNone_ClampClamp);
#endif
	cameraRenderTarget[0] = new RenderTarget(cameraRenderTargetConfig);
	
	for(int i = 1; i < SHADOW_CASCADE_COUNT; ++i)
	{
		RenderTarget::Config *cameraRenderTargetConfig = new RenderTarget::Config([NSString stringWithFormat:@"Shadow Map %u", i]);
		cameraRenderTargetConfig->colorAttachmentCount = RenderTarget::eColorAttachment_0;
		cameraRenderTargetConfig->slice = i;
		cameraRenderTargetConfig->depthTexture = cameraRenderTarget[0]->DepthTexture();
		cameraRenderTargetConfig->depthClearAction = RenderTarget::eClearAction_Clear;
		cameraRenderTargetConfig->depthClear = 1.0f;
#if USE_SHADOW_MSAA
		cameraRenderTargetConfig->depthResolveTexture = cameraRenderTarget[0]->DepthResolveTexture();
#endif
		cameraRenderTarget[i] = new RenderTarget(cameraRenderTargetConfig);
	}
	
	//CAMERAS
	
	for(int i = 0; i < SHADOW_CASCADE_COUNT; ++i)
	{
		Camera::Config *cameraConfig = new Camera::Config([NSString stringWithFormat:@"Shadow Cascade %i", i]);
		cameraConfig->type = Camera::eType_Orthographic;
		cameraConfig->nearPlane = config->nearPlane;
		cameraConfig->farPlane = config->farPlane;
		cameraConfig->width = config->cascadeSize[i];
		cameraConfig->height = config->cascadeSize[i];
		cameraConfig->quantize = true;
		cameraConfig->quantizeStep = float(config->renderSize) / config->cascadeSize[i];
		camera[i] = new Camera(cameraConfig);
	}
}

void qRender::ShadowMap::Init(Globals *globals)
{
}

void qRender::ShadowMap::Update(Globals *globals)
{
	Update(globals, false);
}

void qRender::ShadowMap::Update(Globals *globals, bool forceAll)
{
	Globals *hillsGlobals = static_cast<Globals*>(globals);

	qVector3 directionToKeyLight = qVector3::Normalize(qVector3(hillsGlobals->shading.directionToKeyLightClamped.x, hillsGlobals->shading.directionToKeyLightClamped.y, hillsGlobals->shading.directionToKeyLightClamped.z));
	
	//TODO tune this more?
	const float pushBack = 512.0f;
	const float farPlane = 2048.0f;

	for(int i = 0; i < SHADOW_CASCADE_COUNT; ++i)
	{
		if (!ShouldRender(i, forceAll))
		{
			continue;
		}
#if DEBUG
		camera[i]->SetWidth(config->cascadeSize[i]);
		camera[i]->SetHeight(config->cascadeSize[i]);
#endif
		camera[i]->SetFarPlane(farPlane);

		qVector3 newLookAt = hillsGlobals->sceneCamera->GetLookAt();
		qVector3 newPosition = newLookAt + directionToKeyLight * pushBack;
		
		camera[i]->SetPosition(newPosition);
		camera[i]->SetLookAt(newLookAt);
		
		memcpy(&(hillsGlobals->shadow.cascadeViewProject[i]), &(camera[i]->globals.vp), sizeof(matrix_float4x4));
		memcpy(&(hillsGlobals->shadow.cascadeProject[i]), &(camera[i]->globals.p), sizeof(matrix_float4x4));
	}
}

void qRender::ShadowMap::Encode(const Globals *globals) const
{
	Encode(globals, false);
}

void qRender::ShadowMap::Encode(const Globals *globals, bool forceAll) const
{
	qMetal::Device::PushDebugGroup(@"Shadow Map");
	
	id<MTLBlitCommandEncoder> resetBlitEncoder = qMetal::Device::BlitEncoder(@"Shadow Map ICB Reset");
	for(int i = 0; i < SHADOW_CASCADE_COUNT; ++i)
	{
		if (ShouldRender(i, forceAll))
		{
			[resetBlitEncoder pushDebugGroup:[NSString stringWithFormat:@"Shadow Map Reset %u", i]];
			for(auto &it : renderables)
			{
				it->Reset(resetBlitEncoder, eRenderablePass_ShadowMap0 + i);
			}
			[resetBlitEncoder popDebugGroup];
		}
	}
	[resetBlitEncoder endEncoding];
	
	id<MTLComputeCommandEncoder> shadowComputeCommandEncoder = Device::ComputeEncoder(@"Shadow Map Compute");
	for(int i = 0; i < SHADOW_CASCADE_COUNT; ++i)
	{
		if (ShouldRender(i, forceAll))
		{
			[shadowComputeCommandEncoder pushDebugGroup:[NSString stringWithFormat:@"Shadow Map Compute %u", i]];
			for(auto &it : renderables)
			{
				it->EncodeCompute(shadowComputeCommandEncoder, camera[i], globals, eRenderablePass_ShadowMap0 + i);
			}
			[shadowComputeCommandEncoder popDebugGroup];
		}
	}
	[shadowComputeCommandEncoder endEncoding];
	
	id<MTLBlitCommandEncoder> optimizeBlitEncoder = qMetal::Device::BlitEncoder(@"Shadow Map ICB Optimize");
	for(int i = 0; i < SHADOW_CASCADE_COUNT; ++i)
	{
		if (ShouldRender(i, forceAll))
		{
			[optimizeBlitEncoder pushDebugGroup:[NSString stringWithFormat:@"Shadow Map Optimize %u", i]];
			for(auto &it : renderables)
			{
				it->Optimize(optimizeBlitEncoder, eRenderablePass_ShadowMap0 + i);
			}
			[optimizeBlitEncoder popDebugGroup];
		}
	}
	[optimizeBlitEncoder endEncoding];
	
	for(int i = 0; i < SHADOW_CASCADE_COUNT; ++i)
	{
		if (ShouldRender(i, forceAll))
		{
			id<MTLRenderCommandEncoder> encoder = cameraRenderTarget[i]->Begin();
			for(auto &it : renderables)
			{
				it->Encode(encoder, camera[i], globals, eRenderablePass_ShadowMap0 + i);
			}
			cameraRenderTarget[i]->End();
		}
	}
	
	evenFrame = !evenFrame;
	
	qMetal::Device::PopDebugGroup();
}
	
inline bool qRender::ShadowMap::ShouldRender(int cascadeIdx, bool forceAll) const
{
	if (forceAll)
		return true;
	
	switch(config->update[cascadeIdx])
	{
		case eUpdate_EveryFrame:
			return true;
		case eUpdate_EvenFrames:
			return evenFrame;
		case eUpdate_OddFrames:
			return !evenFrame;
		case eUpdate_OnlyWhenForced:
			return false;
	}
	
	//shouldn't ever get here
	qBREAK("Unknown eUpdate value");
	return false;
}
