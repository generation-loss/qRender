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

#ifndef __Q_RENDER_NOISE_H__
#define __Q_RENDER_NOISE_H__

#include "qMath.h"
#include "qMetal.h"

using namespace qMetal;

namespace qRender {
	class Noise
	{
	public:
		enum eMode
		{
			eMode_Random,
			eMode_Hammersley,
			eMode_Worley,
			eMode_PrebakedCloud
		};
		
		typedef struct Config
		{
			NSString				*name;
							
			int32_t					width;
			int32_t					height;
			
			eMode					mode;
			Texture::ePixelFormat 	pixelFormat;
			
			Config(NSString *_name)
			: name(_name)
			, width(128)
			, height(128)
			, pixelFormat(Texture::ePixelFormat_RGBA32f)
			{
			}
			
			friend std::ostream& operator<<(std::ostream& out, const Config& config)
			{
				out << "name " << [config.name cStringUsingEncoding:NSUTF8StringEncoding] << std::endl;
				out << "width " << config.width << std::endl;
				out << "height " << config.height << std::endl;
				out << "pixel format " << config.pixelFormat << std::endl;
				return out;
			}
			
		} Config;
		
		Noise(Config *_config);
		
		inline Texture* GetTexture()
		{
			return texture;
		}
		
	private:
		Config *config;
		Texture *texture;
	};
}

#endif /* __Q_RENDER_NOISE_H__ */
