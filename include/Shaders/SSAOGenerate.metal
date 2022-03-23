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
#include "SSAOParams.h"
#include "Util.h"

using namespace metal;

//RENDER

struct Vertex
{
	float4 position [[position]];
	float2 uv;
};

typedef struct AOVertexStreamArgumentBuffer
{
	device float4 *position		[[ id(AOVertexStreamArgumentBuffer_Position)	]];
	device packed_float2 *uv	[[ id(AOVertexStreamArgumentBuffer_UV)			]];
} AOVertexStreamArgumentBuffer;

vertex Vertex AOVertexShader(
											constant AOVertexStreamArgumentBuffer &streams [[ buffer(AOVertexStream_StreamArgumentBuffer) ]],
											constant AOVertexParams &params [[ buffer(AOVertexStream_Params) ]],
											uint vid [[vertex_id]])
{
	Vertex vert;
	vert.position = streams.position[vid];
	vert.uv = streams.uv[vid];
	return vert;
}

typedef struct AOAccumulateFragmentTextureArgumentBuffer
{
	texture2d<float, access::sample> worldPosTexture			[[ id(AOAccumulateFragmentTextureArgumentBuffer_WorldPosTexture) 		]];
	sampler worldPosSampler										[[ id(AOAccumulateFragmentTextureArgumentBuffer_WorldPosSampler) 		]];
	texture2d<half, access::sample> worldNormalTexture			[[ id(AOAccumulateFragmentTextureArgumentBuffer_WorldNormalTexture) 	]];
	sampler worldNormalSampler									[[ id(AOAccumulateFragmentTextureArgumentBuffer_WorldNormalSampler) 	]];
	texture2d<half, access::sample> noiseTexture				[[ id(AOAccumulateFragmentTextureArgumentBuffer_NoiseTexture) 			]];
	sampler noiseSampler										[[ id(AOAccumulateFragmentTextureArgumentBuffer_NoiseSampler) 			]];
} AOCompositeFragmentTextureArgumentBuffer;

fragment half4 AOAccumulateFragmentShader(
												  Vertex vert [[stage_in]],
												  device AOCompositeFragmentTextureArgumentBuffer &textures [[ buffer(AOAccumulateFragmentStream_TextureArgumentBuffer) ]],
												  constant AOAccumulateComputeParams &params [[buffer(AOAccumulateFragmentStream_Params)]])
{
	const float3 position		= textures.worldPosTexture.sample(textures.worldPosSampler, vert.uv).xyz;
	const half4 normalMask		= textures.worldNormalTexture.sample(textures.worldNormalSampler, vert.uv);
	const half random			= textures.noiseTexture.sample(textures.noiseSampler, vert.uv).x * M_PI_H;
	
	const half cameraDepth 		= (half)( params.cameraGlobals.v * float4( position.xyz, 1.0f ) ).z;
	
	if (normalMask.w == 0.0h)
	{
		return half4( 1.0h, cameraDepth, 0.0h, 0.0h );
	}
	
	const half3 normal			= normalize( normalMask.xyz );
	
	const float2 uvStepSize		= float2( 1.0f, 1.0f ) / float2( params.prepassWidth, params.prepassHeight );
	
	const float alpha 			= 2.0 * M_PI_F / params.tweaks.numAngles; 		//TODO could upload
	
	half ao						= 0.0h;
	
	const float radiusSquared 	= params.tweaks.radius * params.tweaks.radius;
	
	for(float a = 0; a < params.tweaks.numAngles; ++a)
	{
		const float theta 			= alpha * a + random;
		const float2 uvDir			= float2( cos(theta), sin(theta) );
		float stepScale				= 1.0f;
		
		half localAo				= 0.0h;
		
		for(float s = 1; s <= params.tweaks.numSamplesPerAngle; ++s)
		{
			const float2 localUV				= vert.uv + ( uvDir * uvStepSize * s * stepScale );
			const float3 localPosition			= textures.worldPosTexture.sample(textures.worldPosSampler, localUV).xyz;
			const float3 toLocalPosition 		= localPosition - position;
			const float toLocalDistance			= length( toLocalPosition );
			
			stepScale							= max( 1.0f, ( s / params.tweaks.numSamplesPerAngle ) / ( toLocalDistance / params.tweaks.radius ) ); //how far we should have stepped vs. how far we did step
			
			//AO is the amount of horizon that's blocked, with some wrapping, and scaled by the distance away
			half currentAO						= dot( normal, (half3)normalize( toLocalPosition ) );
			currentAO 							= saturate( ( currentAO - params.tweaks.tangentBias ) / ( 1.0h - params.tweaks.tangentBias ) );
			currentAO							*= 1.0h - saturate( toLocalDistance * toLocalDistance / radiusSquared );
			localAo								= max( localAo, currentAO );
		}
		
		ao += localAo;
	}
	
	ao /= params.tweaks.numAngles;
	
	return half4( saturate( 1.0h - ao ), cameraDepth, 0.0h, 0.0h );
}

// COMPUTE

kernel void AOAccumulateShader(
							   texture2d<float, access::sample> worldPosTexture	[[ texture(AOAccumulateComputeStream_WorldPosTexture)	]],
							   texture2d<half, access::sample> normalTexture	[[ texture(AOAccumulateComputeStream_WorldNormal)		]],
							   texture2d<half, access::sample> noiseTexture		[[ texture(AOAccumulateComputeStream_Noise)				]],
							   texture2d<half, access::write> aoTexture			[[ texture(AOAccumulateComputeStream_AOTexture)			]],
							   constant AOAccumulateComputeParams &params		[[ buffer(AOAccumulateComputeStream_Params) 			]],
							   uint2 gid 										[[ thread_position_in_grid								]])
{
	const float3 position		= worldPosTexture.read(gid).xyz;
	const half4 normalMask		= normalTexture.read(gid);
	const half random			= noiseTexture.read(gid).r * M_PI;
	
	const float cameraDepth 	= ( params.cameraGlobals.v * float4( position.xyz, 1.0f ) ).z;
	
	if (normalMask.w == 0.0h)
	{
		aoTexture.write(half4(1.0h, cameraDepth, 0, 0), gid);
		return;
	}
	
	const half3 normal			= normalize( normalMask.xyz );
	
	const float alpha 			= 2.0 * M_PI_F / params.tweaks.numAngles; 		//TODO could upload
	
	half ao						= 0.0h;
	
	const float radiusSquared 	= params.tweaks.radius * params.tweaks.radius;
	
	for(float a = 0; a < params.tweaks.numAngles; ++a)
	{
		const float theta 			= alpha * a + random;
		const float2 uvDir			= float2( cos(theta), sin(theta) );
		float stepScale				= 1.0f;
		
		half localAo				= 0.0;
		
		for(float s = 1; s <= params.tweaks.numSamplesPerAngle; ++s)
		{
			const uint2 localGID				= gid + (uint2)( uvDir * s * stepScale );
			const float3 localPosition			= worldPosTexture.read(localGID).xyz;
			const float3 toLocalPosition 		= localPosition - position;
			const float toLocalDistance			= length( toLocalPosition );
			
			stepScale							= max( 1.0f, ( s / params.tweaks.numSamplesPerAngle )  / ( toLocalDistance / params.tweaks.radius ) ); //how far we should have stepped vs. how far we did step
			
			//AO is the amount of horizon that's blocked, with some wrapping, and scaled by the distance away
			half currentAO						= dot( normal, (half3)normalize( toLocalPosition ) );
			currentAO 							= saturate( ( currentAO - params.tweaks.tangentBias ) / ( 1.0h - params.tweaks.tangentBias ) );
			currentAO							*= 1.0h - saturate( toLocalDistance * toLocalDistance / radiusSquared );
			localAo								= max( localAo, currentAO );
		}
		
		ao += localAo;
	}
	
	ao /= params.tweaks.numAngles;
	
	aoTexture.write(half4(1.0 - ao, cameraDepth, 0, 0), gid);
}

kernel void AOUpscaleBlurShader(
								texture2d<float, access::sample> worldPosTexture	[[ texture(AOAccumulateComputeStream_WorldPosTexture)	]],
								texture2d<half, access::read> aoTexture				[[ texture(AOAccumulateComputeStream_AOTexture)			]],
								texture2d<half, access::write> upscaleBlurTexture	[[ texture(AOAccumulateComputeStream_AOUpscaleTexture)	]],
								constant AOAccumulateComputeParams &params			[[ buffer(AOAccumulateComputeStream_Params) 			]],
								uint2 gid 											[[ thread_position_in_grid								]])
{
	const float3 position		= worldPosTexture.read(gid).xyz;
	const half baseDepth	 	= ( params.cameraGlobals.v * float4( position.xyz, 1.0f ) ).z;
	
	const uint2	baseGID			= (uint2)((half2)gid * (params.accumulateWidth / params.blurWidth));
	
	half ao						= 0.0h;
	
	half sampleCount			= 0.0h;
	
	const int2 intGID			= (int2)baseGID;
	
	for (int x = -params.tweaks.blurSize; x <= params.tweaks.blurSize; ++x)
	{
		for(int y = -params.tweaks.blurSize; y <= params.tweaks.blurSize; ++y)
		{
			uint2 sampleGID = (uint2)(intGID + int2(x, y));
			const half2 sampleAODepth 	= aoTexture.read(sampleGID).xy;
			
			const half sampleAO			= sampleAODepth.x;
			const half sampleDepth 		= sampleAODepth.y;
			
			if (abs(baseDepth - sampleDepth) <= params.tweaks.blurDepthThreshold)
			{
				ao 							+= sampleAO;
				sampleCount					+= 1.0h;
			}
		}
	}
	

	
	uint2 outGID				= uint2(gid.x, (uint)params.blurHeight - gid.y);
	upscaleBlurTexture.write(sampleCount == 0.0h ? 1.0h : (ao / sampleCount), outGID);
}
