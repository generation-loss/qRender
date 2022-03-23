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

#include "ShadowMap.h"
#include "Util.h"
#include "Poisson.h"

void ShadowUVSliceDepth(float3 pos, float4x4 mat0, float4x4 mat1, float4x4 mat2, float4x4 mat3, constant ShadowMapGlobals &globals, thread float2 &uv, thread uint &slice, thread float &depth, thread half &validShadow)
{
	float4 pos4 					= float4(pos, 1.0f);
	
	float4 shadowPos40 				= mat0 * pos4;
	float3 shadowPos0 				= shadowPos40.xyz / shadowPos40.www;
	
	float4 shadowPos41 				= mat1 * pos4;
	float3 shadowPos1 				= shadowPos41.xyz / shadowPos41.www;
	
	float4 shadowPos42 				= mat2 * pos4;
	float3 shadowPos2 				= shadowPos42.xyz / shadowPos42.www;
	
	float4 shadowPos43 				= mat3 * pos4;
	float3 shadowPos3 				= shadowPos43.xyz / shadowPos43.www;
	
	float maxPos0 					= max(abs(shadowPos0.x), abs(shadowPos0.y));
	float maxPos1 					= max(abs(shadowPos1.x), abs(shadowPos1.y));
	float maxPos2 					= max(abs(shadowPos2.x), abs(shadowPos2.y));
	float maxPos3 					= max(abs(shadowPos3.x), abs(shadowPos3.y));
	
	//TODO could explicitly store some reused values
	float in0						= step(maxPos0, 0.99f);
	float in1						= step(maxPos1, 0.99f) * (1.0f - in0);
	float in2						= step(maxPos2, 0.99f) * (1.0f - in1) * (1.0f - in0);
	float in3						= step(maxPos3, 0.99f) * (1.0f - in2) * (1.0f - in1) * (1.0f - in0);
	
	uv 								= ((shadowPos0.xy * in0) + (shadowPos1.xy * in1) + (shadowPos2.xy) * in2 + (shadowPos3.xy * in3)) * float2(0.5f, 0.5f) + float2(0.5f, 0.5f);
	slice							= (uint)(in1 * 1.0f + in2 * 2.0f + in3 * 3.0f); //TODO what happens if we are out of all? back to zero isn't good.
	depth							= (shadowPos0.z * in0 + shadowPos1.z * in1 + shadowPos2.z * in2 + shadowPos3.z * in3);
	validShadow						= (half)max(in0, max3(in1, in2, in3));
}

half ShadowPCSS(float3 pos, float4x4 mat0, float4x4 mat1, float4x4 mat2, float4x4 mat3, constant ShadowMapGlobals &globals, depth2d_array<float, access::sample> shadowMap, sampler shadowMapSampler)
{
	float2 UV;
	uint slice;
	float depth;
	half validShadow;
	
	ShadowUVSliceDepth(pos, mat0, mat1, mat2, mat3, globals, UV, slice, depth, validShadow);

	half shadow = 0.0h;
	
	if (slice == 0)
	{
		float theta						= dot(pos.xy, float2(1021.0f, 727.0f)); //faux random
		float2x2 poissonRotate			= float2x2(cos(theta), sin(theta), -sin(theta), cos(theta));
		
		const half LIGHT_DEPTH	 		= 0.1h;
		
		// BLOCKER SEARCH
		
		half blockerDepth				= 0.0h;
		half blockerCount				= 0.0h;
		
		for (int x = 0; x < POISSON_SAMPLE_COUNT_12; ++x)
		{
			float2 rotatedPoissonUV 		= poissonRotate * POISSON_SAMPLES_12[x];
			float2 poissonUV 				= UV + globals.blockerSearchSize * rotatedPoissonUV / float2(shadowMap.get_width(), shadowMap.get_height());
			float4 d 						= shadowMap.gather(shadowMapSampler, float2(poissonUV.x, 1.0f - poissonUV.y), slice);
			
			float4 s						= step(d, depth - globals.bias[slice]);
			
			blockerDepth					+= dot(s, d);
			blockerCount					+= dot(float4(1.0f), s);
		}
		
		if (blockerCount < 0.5h)
		{
			return 1.0h;
		}
		
		blockerDepth					/= blockerCount;
		
		if (blockerDepth > (depth - globals.bias[slice]))
		{
			return 1.0h;
		}
		
		// PENUBRA SEARCH
		
		float penumbraSize				= (depth - blockerDepth) * globals.lightSize / (blockerDepth - LIGHT_DEPTH);

		half shadowTap					= 0.0h;

		for (int x = 0; x < POISSON_SAMPLE_COUNT_24; ++x)
		{
			float2 rotatedPoissonUV 		= poissonRotate * POISSON_SAMPLES_24[x];
			float2 poissonUV 				= UV + penumbraSize * rotatedPoissonUV / float2(shadowMap.get_width(), shadowMap.get_height());
			float4 shadowTap4				= shadowMap.gather(shadowMapSampler, float2(poissonUV.x, 1.0f - poissonUV.y), slice);
			shadowTap						+= (half)dot(float4(0.25f), step(float4(depth - globals.bias[slice]), shadowTap4));
		}
		
		shadow							= shadowTap / (half)POISSON_SAMPLE_COUNT_24;
	}
	else
	{
		float4 shadowTap4				= shadowMap.gather(shadowMapSampler, float2(UV.x, 1.0f - UV.y), slice);
		shadow							= (half)dot(float4(0.25f), step(float4(depth - globals.bias[slice]), shadowTap4));
	}

	return shadow * validShadow + (1.0h - validShadow);
}

half ShadowSingleTap(float3 pos, float4x4 mat0, float4x4 mat1, float4x4 mat2, float4x4 mat3, constant ShadowMapGlobals &globals, depth2d_array<float, access::sample> shadowMap, sampler shadowMapSampler)
{
	float2 UV;
	uint slice;
	float depth;
	half validShadow;
	
	ShadowUVSliceDepth(pos, mat0, mat1, mat2, mat3, globals, UV, slice, depth, validShadow);
	
	float4 shadowTap4				= shadowMap.gather(shadowMapSampler, float2(UV.x, 1.0f - UV.y), slice);
	half shadow						= (half)dot(float4(0.25f), step(float4(depth - globals.bias[slice]), shadowTap4));
	
	return shadow * validShadow + (1.0h - validShadow);
}


half ShadowWorldPosition(float3 worldPos, constant ShadowMapGlobals &globals, depth2d_array<float, access::sample> shadowMap, sampler shadowMapSampler)
{
	return ShadowPCSS(worldPos, globals.cascadeViewProject[0], globals.cascadeViewProject[1], globals.cascadeViewProject[2], globals.cascadeViewProject[3], globals, shadowMap, shadowMapSampler);
}

half ShadowWorldPositionSingleTap(float3 worldPos, constant ShadowMapGlobals &globals, depth2d_array<float, access::sample> shadowMap, sampler shadowMapSampler)
{
	return ShadowSingleTap(worldPos, globals.cascadeViewProject[0], globals.cascadeViewProject[1], globals.cascadeViewProject[2], globals.cascadeViewProject[3], globals, shadowMap, shadowMapSampler);
}

half ShadowViewPosition(float3 viewPos, constant ShadowMapGlobals &globals, depth2d_array<float, access::sample> shadowMap, sampler shadowMapSampler)
{
	return ShadowPCSS(viewPos, globals.cascadeProject[0], globals.cascadeProject[1], globals.cascadeProject[2], globals.cascadeViewProject[3], globals, shadowMap, shadowMapSampler);
}
