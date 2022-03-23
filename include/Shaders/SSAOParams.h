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

#ifndef __Q_RENDER_SHADER_SSAO_PARAMS_H__
#define __Q_RENDER_SHADER_SSAO_PARAMS_H__

#include <simd/simd.h>
#include "CameraGlobals.h"

using namespace simd;

// GENERIC VERTEX SHADER

typedef enum eAOVertexStream
{
	AOVertexStream_StreamArgumentBuffer,
	AOVertexStream_Params
} eAOVertexStream;

typedef enum eAOVertexStreamArgumentBuffer
{
	AOVertexStreamArgumentBuffer_Position,
	AOVertexStreamArgumentBuffer_UV,
	AOVertexStreamArgumentBuffer_Count
} eAOVertexStreamArgumentBuffer;

typedef enum eAOVertexTextureArgumentBuffer
{
	AOVertexTexture_Count
} eAOVertexTextureArgumentBuffer;

typedef struct AOVertexParams
{
} AOVertexParams;

// ACCUMULATE FRAGMENT

typedef enum eAOAccumulateFragmentStream
{
	AOAccumulateFragmentStream_TextureArgumentBuffer,
	AOAccumulateFragmentStream_Params,
} eAOAccumulateFragmentStream;

typedef enum eAOAccumulateFragmentTextureArgumentBuffer
{
	AOAccumulateFragmentTextureArgumentBuffer_WorldPosTexture,
	AOAccumulateFragmentTextureArgumentBuffer_WorldPosSampler,
	AOAccumulateFragmentTextureArgumentBuffer_WorldNormalTexture,
	AOAccumulateFragmentTextureArgumentBuffer_WorldNormalSampler,
	AOAccumulateFragmentTextureArgumentBuffer_NoiseTexture,
	AOAccumulateFragmentTextureArgumentBuffer_NoiseSampler,
} eAOAccumulateFragmentTextureArgumentBuffer;

// UPDATE

typedef enum AOAccumulateComputeStream
{
	AOAccumulateComputeStream_WorldPosTexture,
	AOAccumulateComputeStream_WorldNormal,
	AOAccumulateComputeStream_Noise,
	AOAccumulateComputeStream_AOTexture,
	AOAccumulateComputeStream_AOUpscaleTexture,
	AOAccumulateComputeStream_Params
} AOAccumulateComputeStream;

typedef struct AOAccumulateComputeTweaks
{
	float numAngles;
	float numSamplesPerAngle;
	float radius;
	half tangentBias;
	int blurSize;
	half blurDepthThreshold;
	
	AOAccumulateComputeTweaks()
	: numAngles(6.0)
	, numSamplesPerAngle(6.0)
	, radius(2.0)
	, tangentBias(0.21)
	, blurSize(1)
	, blurDepthThreshold(1.0)
	{
	}
} AOAccumulateComputeTweaks;

typedef struct AOAccumulateComputeParams
{
	half prepassWidth;
	half prepassHeight;
	half accumulateWidth;
	half accumulateHeight;
	half blurWidth;
	half blurHeight;
	CameraGlobals cameraGlobals;
	AOAccumulateComputeTweaks tweaks;
} AOAccumulateComputeParams;

#endif /* __Q_RENDER_SHADER_SSAO_PARAMS_H__ */
