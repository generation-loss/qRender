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

#ifndef __Q_RENDER_SHADER_ATMOSPHERE_PARAMS_H__
#define __Q_RENDER_SHADER_ATMOSPHERE_PARAMS_H__

#include <simd/simd.h>
#include "ShadowMapGlobals.h"
#include "AtmosphereGlobals.h"

using namespace simd;

// GENERIC VERTEX SHADER

typedef enum eAtmosphereVertexStream
{
	AtmosphereVertexStream_StreamArgumentBuffer,
	AtmosphereVertexStream_Params
} eAtmosphereVertexStream;

typedef enum eAtmosphereVertexStreamArgumentBuffer
{
	AtmosphereVertexStreamArgumentBuffer_Position,
	AtmosphereVertexStreamArgumentBuffer_UV,
	AtmosphereVertexStreamArgumentBuffer_Count
} eAtmosphereVertexStreamArgumentBuffer;

typedef enum eAtmosphereVertexTextureArgumentBuffer
{
	AtmosphereVertexTexture_Count
} eAtmosphereVertexTextureArgumentBuffer;

typedef struct AtmosphereVertexParams
{
} AtmosphereVertexParams;

// ACCUMULATE FRAGMENT

typedef enum eAtmosphereAccumulateFragmentStream
{
	AtmosphereAccumulateFragmentStream_TextureArgumentBuffer,
	AtmosphereAccumulateFragmentStream_Params,
} eAtmosphereAccumulateFragmentStream;

typedef enum eAtmosphereAccumulateFragmentTextureArgumentBuffer
{
	AtmosphereAccumulateFragmentTextureArgumentBuffer_WorldPosTexture,
	AtmosphereAccumulateFragmentTextureArgumentBuffer_WorldPosSampler,
	AtmosphereAccumulateFragmentTextureArgumentBuffer_ShadowTexture,
	AtmosphereAccumulateFragmentTextureArgumentBuffer_ShadowSampler,
	AtmosphereAccumulateFragmentTextureArgumentBuffer_ReflectionProbeTexture,
	AtmosphereAccumulateFragmentTextureArgumentBuffer_ReflectionProbeSampler,
} eAtmosphereAccumulateFragmentTextureArgumentBuffer;

// RENDER

typedef enum AtmosphereAccumulateComputeStream
{
	AtmosphereAccumulateComputeStream_WorldPosTexture,
	AtmosphereAccumulateComputeStream_ShadowTexture,
	AtmosphereAccumulateComputeStream_ReflectionProbeTexture,
	AtmosphereAccumulateComputeStream_AtmosphereTexture,
	AtmosphereAccumulateComputeStream_Params
} AtmosphereAccumulateComputeStream;

typedef struct AtmosphereAccumulateComputeTweaks
{
	half numSamples;
	float maxDistance;
	
	AtmosphereAccumulateComputeTweaks()
	: numSamples(64.0)
	, maxDistance(2000.0f)
	{
	}
} AtmosphereAccumulateComputeTweaks;

typedef struct AtmosphereAccumulateComputeParams
{
	half width;
	half height;
	uint scale;
	uint depthNormalScale;
	float3 cameraPosition;
	ShadowMapGlobals shadowGlobals;
	AtmosphereAccumulateComputeTweaks tweaks;
} AtmosphereAccumulateComputeParams;

//BLUR

typedef enum AtmosphereBlurComputeStream
{
	AtmosphereBlurComputeStream_AtmosphereTexture,
	AtmosphereBlurComputeStream_AtmosphereTexture2
} AtmosphereBlurComputeStream;

#endif /* __Q_RENDER_SHADER_ATMOSPHERE_PARAMS_H__ */
