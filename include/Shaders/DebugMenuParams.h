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

#ifndef __Q_RENDER_DEBUG_MENU_PARAMS_H__
#define __Q_RENDER_DEBUG_MENU_PARAMS_H__

#include <simd/simd.h>

using namespace simd;

//VERTEX

typedef enum eDebugMenuVertexStream
{
	DebugMenuVertexStream_StreamArgumentBuffer,
	DebugMenuVertexStream_Params
} eDebugMenuVertexStream;

typedef enum eDebugMenuVertexStreamArgumentBuffer
{
	DebugMenuVertexStreamArgumentBuffer_Position,
	DebugMenuVertexStreamArgumentBuffer_UV,
	DebugMenuVertexStreamArgumentBuffer_Count
} eDebugMenuVertexStreamArgumentBuffer;

typedef enum eDebugMenuVertexTextureArgumentBuffer
{
} eDebugMenuVertexTextureArgumentBuffer;

typedef struct DebugMenuVertexParams
{
	float2 position;
	float2 size;
} DebugMenuVertexParams;

//FRAGMENT

typedef enum eDebugMenuFragmentStream
{
	DebugMenuFragmentStream_TextureArgumentBuffer,
	DebugMenuFragmentStream_Params,
} eDebugMenuFragmentStream;

typedef enum eDebugMenuFragmentTextureArgumentBuffer
{
	DebugMenuFragmentTextureArgumentBuffer_BaseColourTexture,
	DebugMenuFragmentTextureArgumentBuffer_BaseColourSampler,
} eDebugMenuFragmentTextureArgumentBuffer;


typedef struct DebugMenuFragmentParams
{
	float progress; //normalized
} DebugMenuFragmentParams;

#endif /* __Q_RENDER_DEBUG_MENU_PARAMS_H__ */
