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

#ifndef __Q_RENDER_SHADER_ATMOSPHERE_H__
#define __Q_RENDER_SHADER_ATMOSPHERE_H__


#include "AtmosphereGlobals.h"
#include "ShadingGlobals.h"
#include "CameraGlobals.h"

using namespace metal;

half3 Atmosphere(half3 colour, float3 worldPosition, float2 uv, constant AtmosphereGlobals &globals, constant qRender::ShadingGlobals &shadingGlobals, constant CameraGlobals &cameraGlobals, texture2d<half, access::sample> atmosphereTex, sampler atmosphereSampler);

#endif /* __Q_RENDER_SHADER_ATMOSPHERE_H__ */