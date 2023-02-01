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
#include "AtmosphereParams.h"
#include "Util.h"
#include "ShadowMap.h"

using namespace metal;


//RENDER

struct Vertex
{
	float4 position [[position]];
	float2 uv;
};

typedef struct AtmosphereVertexStreamArgumentBuffer
{
	device float4* position		[[ id(AtmosphereVertexStreamArgumentBuffer_Position)	]];
	device packed_float2* uv	[[ id(AtmosphereVertexStreamArgumentBuffer_UV)			]];
} AtmosphereVertexStreamArgumentBuffer;

vertex Vertex AtmosphereVertexShader(
											constant AtmosphereVertexStreamArgumentBuffer &streams [[ buffer(AtmosphereVertexStream_StreamArgumentBuffer) ]],
											constant AtmosphereVertexParams &params [[ buffer(AtmosphereVertexStream_Params) ]],
											uint vid [[vertex_id]])
{
	Vertex vert;
	vert.position = streams.position[vid];
	vert.uv = streams.uv[vid];
	return vert;
}

typedef struct AtmosphereAccumulateFragmentTextureArgumentBuffer
{
	texture2d<float, access::sample> worldPosTexture			[[ id(AtmosphereAccumulateFragmentTextureArgumentBuffer_WorldPosTexture) 		]];
	sampler worldPosSampler									[[ id(AtmosphereAccumulateFragmentTextureArgumentBuffer_WorldPosSampler) 		]];
	depth2d_array<float, access::sample> shadowMap			[[ id(AtmosphereAccumulateFragmentTextureArgumentBuffer_ShadowTexture)			]];
	sampler shadowMapSampler								[[ id(AtmosphereAccumulateFragmentTextureArgumentBuffer_ShadowSampler) 			]];
	texturecube<half, access::sample> reflectionProbeCube	[[ id(AtmosphereAccumulateFragmentTextureArgumentBuffer_ReflectionProbeTexture)	]];
	sampler reflectionProbeSampler							[[ id(AtmosphereAccumulateFragmentTextureArgumentBuffer_ReflectionProbeSampler)	]];
} AtmosphereCompositeFragmentTextureArgumentBuffer;

fragment half4 AtmosphereAccumulateFragmentShader(
												  Vertex vert [[stage_in]],
												  device AtmosphereCompositeFragmentTextureArgumentBuffer &textures [[ buffer(AtmosphereAccumulateFragmentStream_TextureArgumentBuffer) ]],
												  constant AtmosphereAccumulateComputeParams &params [[buffer(AtmosphereAccumulateFragmentStream_Params)]])
{
	float2 depthNormalUV 				= (vert.uv * params.scale) / params.depthNormalScale;
	const float3 baseWorldPos 			= textures.worldPosTexture.sample(textures.worldPosSampler, depthNormalUV).xyz;
	
	const float3 camToWorld				= baseWorldPos - params.cameraPosition;
	const float camToWorldLength		= length(camToWorld);
	const float camToWorldLengthClamped	= min(camToWorldLength, params.tweaks.maxDistance);
	const float3 camToWorldNorm			= normalize(camToWorld);
	const float3 camToWorldClamped 		= camToWorldNorm * camToWorldLengthClamped;
	const float3 stepSize				= camToWorldClamped / (float)params.tweaks.numSamples;
	
	float3 currentWorldPosition			= params.cameraPosition;
	
	half3 indirectColour 				= textures.reflectionProbeCube.sample(textures.reflectionProbeSampler, camToWorldNorm).rgb;
	
	half shadow = 0.0h;
	
	for(half d = 0; d < params.tweaks.numSamples; ++d)
	{
		currentWorldPosition				+= stepSize;
		shadow 								+= ShadowWorldPositionSingleTap(currentWorldPosition, params.shadowGlobals, textures.shadowMap, textures.shadowMapSampler);
	}
	
	shadow								/= params.tweaks.numSamples;
	
	return half4(indirectColour, shadow);
}


//COMPUTE

constexpr sampler shadowMapSampler = sampler(coord::normalized, address::clamp_to_edge, filter::linear);
constexpr sampler reflectionProbeSampler = sampler(coord::normalized, address::clamp_to_edge, filter::linear, mip_filter::linear);

kernel void AtmosphereAccumulateKernel(
									   texture2d<float, access::sample> worldPosTexture		[[ texture(AtmosphereAccumulateComputeStream_WorldPosTexture)		]],
									   depth2d_array<float, access::sample> shadowMap		[[ texture(AtmosphereAccumulateComputeStream_ShadowTexture)			]],
									   texturecube<half, access::sample> reflectionProbeCube[[ texture(AtmosphereAccumulateComputeStream_ReflectionProbeTexture)]],
									   texture2d<half, access::write> atmosphereTexture		[[ texture(AtmosphereAccumulateComputeStream_AtmosphereTexture)		]],
									   constant AtmosphereAccumulateComputeParams &params	[[ buffer(AtmosphereAccumulateComputeStream_Params) 				]],
									   uint2 gid 											[[ thread_position_in_grid											]])
{
	uint2 depthNormalGID 				= (gid * params.scale) / params.depthNormalScale;
	const float3 baseWorldPos 			= worldPosTexture.read(depthNormalGID).xyz;
	
	const float3 camToWorld				= baseWorldPos - params.cameraPosition;
	const float camToWorldLength		= length(camToWorld);
	const float camToWorldLengthClamped	= min(camToWorldLength, params.tweaks.maxDistance);
	const float3 camToWorldNorm			= normalize(camToWorld);
	const float3 camToWorldClamped 		= camToWorldNorm * camToWorldLengthClamped;
	const float3 stepSize				= camToWorldClamped / (float)params.tweaks.numSamples;
	
	float3 currentWorldPosition			= params.cameraPosition;
	
	half3 indirectColour 				= reflectionProbeCube.sample(reflectionProbeSampler, camToWorldNorm).rgb;
	
	half shadow = 0.0h;
	
	for(half d = 0; d < params.tweaks.numSamples; ++d)
	{
		currentWorldPosition				+= stepSize;
		shadow 								+= ShadowWorldPositionSingleTap(currentWorldPosition, params.shadowGlobals, shadowMap, shadowMapSampler);
	}
	
	shadow								/= params.tweaks.numSamples;
	
	uint2 outGID						= uint2(gid.x, uint(params.height) - gid.y);
	
	atmosphereTexture.write(half4(indirectColour, shadow), outGID);
}

kernel void AtmosphereBlurHKernel(
								  texture2d<half, access::read> atmosphereTextureIn		[[ texture(AtmosphereBlurComputeStream_AtmosphereTexture)	]],
								  texture2d<half, access::write> atmosphereTextureOut	[[ texture(AtmosphereBlurComputeStream_AtmosphereTexture2)	]],
								  uint2 gid 											[[ thread_position_in_grid									]],
								  uint2 gridSize 										[[ threads_per_grid											]])
{
	
	half4 atmosphere				= 0;
	
	uint minX 						= min(gid.x, 4u);
	uint maxX						= min(gridSize.x - gid.x - 1, 4u);
	
	//9 sample gaussian with sigma = 2 (http://dev.theomader.com/gaussian-kernel-calculator/)
	atmosphere						+= atmosphereTextureIn.read(gid - uint2(min(minX, 4u), 0)) * 0.028532h;
	atmosphere						+= atmosphereTextureIn.read(gid - uint2(min(minX, 3u), 0)) * 0.067234h;
	atmosphere						+= atmosphereTextureIn.read(gid - uint2(min(minX, 2u), 0)) * 0.124009h;
	atmosphere						+= atmosphereTextureIn.read(gid - uint2(min(minX, 1u), 0)) * 0.179044h;
	atmosphere						+= atmosphereTextureIn.read(gid)						   * 0.202360h;
	atmosphere						+= atmosphereTextureIn.read(gid + uint2(min(maxX, 1u), 0)) * 0.179044h;
	atmosphere						+= atmosphereTextureIn.read(gid + uint2(min(maxX, 2u), 0)) * 0.124009h;
	atmosphere						+= atmosphereTextureIn.read(gid + uint2(min(maxX, 3u), 0)) * 0.067234h;
	atmosphere						+= atmosphereTextureIn.read(gid + uint2(min(maxX, 4u), 0)) * 0.028532h;
	
	atmosphereTextureOut.write(atmosphere, gid);
}

kernel void AtmosphereBlurVKernel(
								  texture2d<half, access::read> atmosphereTextureIn		[[ texture(AtmosphereBlurComputeStream_AtmosphereTexture)	]],
								  texture2d<half, access::write> atmosphereTextureOut	[[ texture(AtmosphereBlurComputeStream_AtmosphereTexture2)	]],
								  uint2 gid 											[[ thread_position_in_grid									]],
								  uint2 gridSize 										[[ threads_per_grid											]])
{
	
	half4 atmosphere				= 0;
	
	uint minY 						= min(gid.y, 4u);
	uint maxY						= min(gridSize.y - gid.y - 1, 4u);
	
	//9 sample gaussian with sigma = 2 (http://dev.theomader.com/gaussian-kernel-calculator/)
	atmosphere						+= atmosphereTextureIn.read(gid - uint2(0, min(minY, 4u))) * 0.028532h;
	atmosphere						+= atmosphereTextureIn.read(gid - uint2(0, min(minY, 3u))) * 0.067234h;
	atmosphere						+= atmosphereTextureIn.read(gid - uint2(0, min(minY, 2u))) * 0.124009h;
	atmosphere						+= atmosphereTextureIn.read(gid - uint2(0, min(minY, 1u))) * 0.179044h;
	atmosphere						+= atmosphereTextureIn.read(gid)			 			   * 0.202360h;
	atmosphere						+= atmosphereTextureIn.read(gid + uint2(0, min(maxY, 1u))) * 0.179044h;
	atmosphere						+= atmosphereTextureIn.read(gid + uint2(0, min(maxY, 2u))) * 0.124009h;
	atmosphere						+= atmosphereTextureIn.read(gid + uint2(0, min(maxY, 3u))) * 0.067234h;
	atmosphere						+= atmosphereTextureIn.read(gid + uint2(0, min(maxY, 4u))) * 0.028532h;
	
	atmosphereTextureOut.write(atmosphere, gid);
}
