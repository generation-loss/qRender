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

#include "qRenderPrepass.h"

qRender::Prepass::Prepass(Config *_config)
: config(_config)
{
	RenderTarget::Config *renderTargetConfig = new RenderTarget::Config(@"Depth Normal Prepass");
	
	renderTargetConfig->colorAttachmentCount = RenderTarget::eColorAttachment_2;
	
	renderTargetConfig->colourTextureConfig[eDepthNormalRenderTarget_WorldPos] = new Texture::Config(@"Depth Normal Prepass World Position");
	renderTargetConfig->colourTextureConfig[eDepthNormalRenderTarget_WorldPos]->width = config->width / config->scale;
	renderTargetConfig->colourTextureConfig[eDepthNormalRenderTarget_WorldPos]->height = config->height / config->scale;
	renderTargetConfig->colourTextureConfig[eDepthNormalRenderTarget_WorldPos]->pixelFormat = Texture::ePixelFormat_RGBA32f;
	renderTargetConfig->colourTextureConfig[eDepthNormalRenderTarget_WorldPos]->mipMaps = false;
	renderTargetConfig->colourTextureConfig[eDepthNormalRenderTarget_WorldPos]->msaa = Texture::eMSAA_1;
	renderTargetConfig->colourTextureSamplerState[eDepthNormalRenderTarget_WorldPos] = SamplerState::PredefinedState(eSamplerState_LinearLinearNone_ClampClamp);
	
	renderTargetConfig->colourTextureConfig[eDepthNormalRenderTarget_WorldNormal] = new Texture::Config(@"Depth Normal Prepass World Normal");
	renderTargetConfig->colourTextureConfig[eDepthNormalRenderTarget_WorldNormal]->width = config->width / config->scale;
	renderTargetConfig->colourTextureConfig[eDepthNormalRenderTarget_WorldNormal]->height = config->height / config->scale;
	renderTargetConfig->colourTextureConfig[eDepthNormalRenderTarget_WorldNormal]->pixelFormat = Texture::ePixelFormat_RGBA16f;
	renderTargetConfig->colourTextureConfig[eDepthNormalRenderTarget_WorldNormal]->mipMaps = false;
	renderTargetConfig->colourTextureConfig[eDepthNormalRenderTarget_WorldNormal]->msaa = Texture::eMSAA_1;
	renderTargetConfig->colourTextureSamplerState[eDepthNormalRenderTarget_WorldNormal] = SamplerState::PredefinedState(eSamplerState_LinearLinearNone_ClampClamp);

	renderTargetConfig->depthTextureConfig = new Texture::Config(@"Depth Normal Prepass Depth");
	renderTargetConfig->depthTextureConfig->width = config->width / config->scale;
	renderTargetConfig->depthTextureConfig->height = config->height / config->scale;
	renderTargetConfig->depthTextureConfig->pixelFormat = Texture::ePixelFormat_Depth32f;
	renderTargetConfig->depthTextureConfig->mipMaps = false;
	renderTargetConfig->depthTextureConfig->storage = Texture::eStorage_Memoryless;
	renderTargetConfig->depthTextureConfig->msaa = Texture::eMSAA_1;
	renderTargetConfig->depthTextureSamplerState = SamplerState::PredefinedState(eSamplerState_LinearLinearNone_ClampClamp);
	
	renderTarget = new RenderTarget(renderTargetConfig);
}
	
void qRender::Prepass::Init(Globals *globals)
{
}

void qRender::Prepass::Update(Globals *globals)
{
}

void qRender::Prepass::Encode(const Globals *globals) const
{
	id<MTLRenderCommandEncoder> encoder = renderTarget->Begin();
	for(auto &it : renderables)
	{
		it->Encode(encoder, globals->sceneCamera, globals, eRenderablePass_Prepass);
	}
	renderTarget->End();
}
