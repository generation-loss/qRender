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

#include "qRenderHeightMap.h"

qRender::HeightMap::HeightMap(Config *_config)
: config(_config)
{
	RenderTarget::Config *renderTargetConfig = new RenderTarget::Config([NSString stringWithFormat:@"Height Map"]);
	renderTargetConfig->colorAttachmentCount = RenderTarget::eColorAttachment_0;
	renderTargetConfig->depthTextureConfig = new Texture::Config(@"Height Map Depth");
	renderTargetConfig->depthTextureConfig->type = Texture::eType_2D;
	renderTargetConfig->depthTextureConfig->width = config->size;
	renderTargetConfig->depthTextureConfig->height = config->size;
	renderTargetConfig->depthTextureConfig->pixelFormat = Texture::ePixelFormat_Depth32f;
	renderTargetConfig->depthTextureConfig->mipMaps = false;
	renderTargetConfig->depthTextureSamplerState = SamplerState::PredefinedState(eSamplerState_LinearLinearNone_ClampClamp);
	renderTarget = new RenderTarget(renderTargetConfig);
	
	camera = new qRender::Camera(config->cameraConfig);
}

void qRender::HeightMap::Update(qRender::Globals *globals)
{
	camera->SetPosition(globals->sceneCamera->GetPosition() + qVector3(0.0f, 100.0f, 0.0f));
	camera->SetLookAt(globals->sceneCamera->GetPosition(), qVector3(1.0f, 0.0f, 0.0f));
}

void qRender::HeightMap::Encode(const qRender::Globals *globals) const
{
	id<MTLComputeCommandEncoder> computeCommandEncoder = Device::ComputeEncoder(@"Height Map Compute");
	for(auto &it : renderables)
	{
		it->EncodeCompute(computeCommandEncoder, camera, globals, eRenderablePass_HeightMap);
	}
	[computeCommandEncoder endEncoding];
		
	id<MTLRenderCommandEncoder> encoder = renderTarget->Begin();
	for(auto &it : renderables)
	{
		it->Encode(encoder, camera, globals, eRenderablePass_HeightMap);
	}
	renderTarget->End();
}
