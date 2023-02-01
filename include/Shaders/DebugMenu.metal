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

#include <metal_stdlib>
#include "DebugMenuParams.h"

using namespace metal;

struct Vertex
{
	float4 position [[position]];
	float2 uv;
};

typedef struct DebugMenuVertexStreamArgumentBuffer
{
	device float4* position		[[ id(DebugMenuVertexStreamArgumentBuffer_Position)	]];
	device packed_float2* uv	[[ id(DebugMenuVertexStreamArgumentBuffer_UV)	]];
} DebugMenuVertexStreamArgumentBuffer;

vertex Vertex DebugMenuVertexShader(
	constant DebugMenuVertexStreamArgumentBuffer &streams [[ buffer(DebugMenuVertexStream_StreamArgumentBuffer) ]],
	constant DebugMenuVertexParams &params [[ buffer(DebugMenuVertexStream_Params) ]],
	uint vid [[vertex_id]])
{
    Vertex vert;
	vert.position.xy = params.position + streams.position[vid].xy * params.size;
	vert.position.y = -vert.position.y;
	vert.position.zw = float2(0.0f, 1.0f);
	
	vert.uv = streams.uv[vid];
	
	return vert;
}

typedef struct DebugMenuFragmentStreamTextureArgumentBuffer
{
	texture2d<half, access::sample> baseColourTexture 	[[ id(DebugMenuFragmentTextureArgumentBuffer_BaseColourTexture)		]];
	sampler baseColourSampler 							[[ id(DebugMenuFragmentTextureArgumentBuffer_BaseColourSampler)		]];
} DebugMenuFragmentStreamTextureArgumentBuffer;

fragment half4 DebugMenuFragmentShader(
	Vertex vert [[stage_in]],
	device DebugMenuFragmentStreamTextureArgumentBuffer &textures [[ buffer(DebugMenuFragmentStream_TextureArgumentBuffer) ]],
	constant DebugMenuFragmentParams &params [[buffer(DebugMenuFragmentStream_Params)]])
{
	half text = textures.baseColourTexture.sample(textures.baseColourSampler, vert.uv).r; //grayscale
	half alpha = max(text, vert.uv.x > params.progress ? 0.6h : 0.4h);
	return half4(text, text, text, alpha);
}
