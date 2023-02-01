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

#include "qRenderNoise.h"
	
qRender::Noise::Noise(Config* _config)
: config(_config)
{
	if (config->mode == eMode_PrebakedCloud)
	{
		texture = Texture::LoadByName(@"assets/noise/textures/noise.ktx");
		return;
	}
	
	Texture::Config* textureConfig = new Texture::Config([NSString stringWithFormat:@"%@ noise texture", config->name]);
	textureConfig->width = config->width;
	textureConfig->height = config->height;
	textureConfig->pixelFormat = config->pixelFormat;
	textureConfig->storage = Texture::eStorage_CPUandGPU;
	texture = new Texture(textureConfig, SamplerState::PredefinedState(eSamplerState_PointPointNone_RepeatRepeat));
	
	const NSUInteger dataSize = config->width * config->height;
	
	if(config->pixelFormat == Texture::ePixelFormat_RGBA32f)
	{
		qRGBA32f* data = new qRGBA32f[dataSize];
		
		if (config->mode == eMode_Random)
		{
			for(int i = 0; i < dataSize; ++i)
			{
				data[i] = qRandom(qRGBA32f_Transparent, qRGBA32f_White);
			}
		}
		else if (config->mode == eMode_Hammersley)
		{
			for(int i = 0; i < dataSize; ++i)
			{
				uint32_t bits = (i << 16u) | (i >> 16u);
				bits = ((bits & 0x55555555u) << 1u) | ((bits & 0xAAAAAAAAu) >> 1u);
				bits = ((bits & 0x33333333u) << 2u) | ((bits & 0xCCCCCCCCu) >> 2u);
				bits = ((bits & 0x0F0F0F0Fu) << 4u) | ((bits & 0xF0F0F0F0u) >> 4u);
				bits = ((bits & 0x00FF00FFu) << 8u) | ((bits & 0xFF00FF00u) >> 8u);
				float y = float(bits) * 2.3283064365386963e-10; // / 0x100000000
				
				data[i] = qRGBA32f(y, float(i) / float(dataSize), 0.0f, 0.0f);
			}
		}
		else if (config->mode == eMode_Worley)
		{
			int32_t pointCounts[4] = {4, 8, 16, 32};
			
			for(int32_t channel = 0; channel < 4; ++channel)
			{
				const int32_t pointCount = pointCounts[channel];
				
				qVector2* points = new qVector2[pointCount];
				
				for(int32_t point = 0; point < pointCount; ++point)
				{
					points[point] = qVector2(qRandom(0, config->width), qRandom(0, config->height));
				}
				
				float maxDistance = sqrtf((float)(config->width * config->width + config->height * config->height));
				
				for(int32_t x = 0; x < config->width; ++x)
				{
					for(int32_t y = 0; y < config->width; ++y)
					{
						float minDistance = maxDistance;
						
						for(int32_t point = 0; point < pointCount; ++point)
						{
							float distance = qVector2::Length(qVector2((float)x, (float)y) - points[point]);
							minDistance = qMin(minDistance, distance);
						}
						
						data[y * config->width + x][channel] = minDistance / maxDistance;
					}
				}
			}
		}
		else
		{
			qBREAK("Unsupported RGBA32f noise mode");
		}
		
		texture->Fill(data);
	}
	else if(config->pixelFormat == Texture::ePixelFormat_RGBA16f)
	{
		qRGBA16f* data = new qRGBA16f[dataSize];
		
		if (config->mode == eMode_Random)
		{
			for(int i = 0; i < dataSize; ++i)
			{
				data[i] = qRandom(qRGBA32h_Transparent, qRGBA32h_White);
			}
		}
		else if (config->mode == eMode_Hammersley)
		{
			for(int i = 0; i < dataSize; ++i)
			{
				uint32_t bits = (i << 16u) | (i >> 16u);
				bits = ((bits & 0x55555555u) << 1u) | ((bits & 0xAAAAAAAAu) >> 1u);
				bits = ((bits & 0x33333333u) << 2u) | ((bits & 0xCCCCCCCCu) >> 2u);
				bits = ((bits & 0x0F0F0F0Fu) << 4u) | ((bits & 0xF0F0F0F0u) >> 4u);
				bits = ((bits & 0x00FF00FFu) << 8u) | ((bits & 0xFF00FF00u) >> 8u);
				float y = float(bits) * 2.3283064365386963e-10; // / 0x100000000
				
				data[i] = qRGBA16f(y, float(i) / float(dataSize), 0.0f, 0.0f);
			}
		}
		else if (config->mode == eMode_Worley)
		{
			int32_t pointCounts[4] = {4, 8, 16, 32};
			
			for(int32_t channel = 0; channel < 4; ++channel)
			{
				const int32_t pointCount = pointCounts[channel];
				
				qVector2* points = new qVector2[pointCount];
				
				for(int32_t point = 0; point < pointCount; ++point)
				{
					points[point] = qVector2(qRandom(0, config->width), qRandom(0, config->height));
				}
				
				float maxDistance = sqrtf((float)(config->width * config->width + config->height * config->height));
				
				for(int32_t x = 0; x < config->width; ++x)
				{
					for(int32_t y = 0; y < config->width; ++y)
					{
						float minDistance = maxDistance;
						
						for(int32_t point = 0; point < pointCount; ++point)
						{
							float distance = qVector2::Length(qVector2((float)x, (float)y) - points[point]);
							minDistance = qMin(minDistance, distance);
						}
						
						data[y * config->width + x][channel] = minDistance / maxDistance;
					}
				}
			}
		}
		else
		{
			qBREAK("Unsupported RGBA32f noise mode");
		}
		
		texture->Fill(data);
	}
	else if(config->pixelFormat == Texture::ePixelFormat_R32f)
	{
		float* data = new float[dataSize];
		
		if (config->mode == eMode_Random)
		{
			for(int i = 0; i < dataSize; ++i)
			{
				data[i] = qRandom(0.0f, 1.0f);
			}
		}
		else if (config->mode == eMode_Worley)
		{
			const int32_t pointCount = 16; //TODO configurable?
			
			qVector2* points = new qVector2[pointCount];
			
			for(int32_t point = 0; point < pointCount; ++point)
			{
				points[point] = qVector2(qRandom(0, config->width), qRandom(0, config->height));
			}
			
			float maxDistance = sqrtf((float)(config->width * config->width + config->height * config->height));
			
			for(int32_t x = 0; x < config->width; ++x)
			{
				for(int32_t y = 0; y < config->width; ++y)
				{
					float minDistance = maxDistance;
					
					for(int32_t point = 0; point < pointCount; ++point)
					{
						float distance = qVector2::Length(qVector2((float)x, (float)y) - points[point]);
						minDistance = qMin(minDistance, distance);
					}
					
					data[y * config->width + x] = minDistance / maxDistance;
				}
			}
		}
		else
		{
			qBREAK("Unsupported R32f noise mode");
		}
		
		texture->Fill(data);
	}
	else if(config->pixelFormat == Texture::ePixelFormat_R16f)
	{
		half* data = new half[dataSize];
		
		if (config->mode == eMode_Random)
		{
			for(int i = 0; i < dataSize; ++i)
			{
				data[i] = (half)qRandom(0.0, 1.0);
			}
		}
		else if (config->mode == eMode_Worley)
		{
			const int32_t pointCount = 16; //TODO configurable?
			
			qVector2* points = new qVector2[pointCount];
			
			for(int32_t point = 0; point < pointCount; ++point)
			{
				points[point] = qVector2(qRandom(0, config->width), qRandom(0, config->height));
			}
			
			float maxDistance = sqrtf((float)(config->width * config->width + config->height * config->height));
			
			for(int32_t x = 0; x < config->width; ++x)
			{
				for(int32_t y = 0; y < config->width; ++y)
				{
					float minDistance = maxDistance;
					
					for(int32_t point = 0; point < pointCount; ++point)
					{
						float distance = qVector2::Length(qVector2((float)x, (float)y) - points[point]);
						minDistance = qMin(minDistance, distance);
					}
					
					data[y * config->width + x] = half(minDistance / maxDistance);
				}
			}
		}
		else
		{
			qBREAK("Unsupported R16f noise mode");
		}
		
		texture->Fill(data);
	}
	else
	{
		qBREAK("Unsupported noise pixel format");
	}
}
