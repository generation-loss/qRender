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

#include "Atmosphere.h"

half3 Atmosphere(half3 colour, float3 worldPosition, float2 uv, constant AtmosphereGlobals &globals, constant qRender::ShadingGlobals &shadingGlobals, constant CameraGlobals &cameraGlobals, texture2d<half, access::sample> atmosphereTex, sampler atmosphereSampler)
{
	//TODO could upload some more optimized params to avoid dividtes, e.g. upload 1/globals.maxDistance and 1/(globals.maxHeight - globals.minHeight)
	const float3 camToWorld				= worldPosition - cameraGlobals.position;
	const float camToWorldLength		= length(camToWorld);
	const float camToWorldLength01		= saturate(camToWorldLength / globals.maxDistance);

	const float normalizedHeight		= saturate((worldPosition.y - globals.minHeight) / (globals.maxHeight - globals.minHeight)) + 0.01f;

	const float heightFog				= saturate(pow(globals.heightBase, -globals.heightDensity * normalizedHeight) / normalizedHeight);
	const float distanceFog				= saturate(1.0f - pow(globals.distanceBase, -globals.distanceDensity * camToWorldLength01));

	const half fogAmount				= (half)(heightFog * distanceFog);

	half4 atmosphereSample 				= atmosphereTex.sample(atmosphereSampler, uv);
	half3 indirectColour 				= atmosphereSample.rgb;
	half shadow							= atmosphereSample.a;

	half3 baseColour					= half3(globals.colourR, globals.colourG, globals.colourB);
	half3 fogColour 					= baseColour * (shadow * shadingGlobals.keyLightColour + indirectColour);

	return mix(colour, fogColour, saturate(fogAmount));
}
