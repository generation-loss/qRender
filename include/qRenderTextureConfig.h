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

#ifndef __Q_RENDER_TEXTURE_CONFIG_H__
#define __Q_RENDER_TEXTURE_CONFIG_H__

#include "qMetal.h"

using namespace qMetal;

namespace qRender
{
	typedef struct TextureConfig
	{
		Texture* texture;
		
		TextureConfig()
		: texture(NULL)
		{}
		
		TextureConfig(NSDictionary* jsonConfig, NSString* _path, const SamplerState* samplerState = SamplerState::PredefinedState(eSamplerState_LinearLinearLinear_RepeatRepeat))
		{
			NSString* textureName = [jsonConfig objectForKey:@"texture"];
			texture = Texture::LoadByName([_path stringByAppendingString:textureName], false, samplerState);
		}
		
		friend std::ostream& operator<<(std::ostream& out, const TextureConfig& config)
		{
			out << "texture: " << config.texture->GetName() << std::endl;
			return out;
		}
	} TexturConfig;
}

#endif /* __Q_RENDER_TEXTURE_CONFIG_H__ */
