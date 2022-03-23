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

#ifndef __Q_RENDER_SHADER_SHADOW_MAP_H__
#define __Q_RENDER_SHADER_SHADOW_MAP_H__

#include "ShadowMapGlobals.h"

using namespace metal;

half ShadowWorldPosition(float3 worldPos, constant ShadowMapGlobals &globals, depth2d_array<float, access::sample> shadowMap, sampler shadowMapSampler);
half ShadowWorldPositionSingleTap(float3 viewPos, constant ShadowMapGlobals &globals, depth2d_array<float, access::sample> shadowMap, sampler shadowMapSampler);

half ShadowViewPosition(float3 viewPos, constant ShadowMapGlobals &globals, depth2d_array<float, access::sample> shadowMap, sampler shadowMapSampler);

#endif /* __Q_RENDER_SHADER_SHADOW_MAP_H__ */
