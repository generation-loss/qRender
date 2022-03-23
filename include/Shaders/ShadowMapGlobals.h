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

#ifndef __Q_RENDER_SHADOW_MAP_GLOBALS_H__
#define __Q_RENDER_SHADOW_MAP_GLOBALS_H__

#include <simd/SIMD.h>

#define SHADOW_CASCADE_COUNT (4)

struct ShadowMapGlobals
{
	ShadowMapGlobals()
	: lightSize(64.0)
	, blockerSearchSize(8.0f)
	{
		bias[0] = 0.001;
		bias[1] = 0.001;
		bias[2] = 0.003;
		bias[3] = 0.008;
	}
	
	matrix_float4x4 cascadeViewProject[SHADOW_CASCADE_COUNT];
	matrix_float4x4 cascadeProject[SHADOW_CASCADE_COUNT];
	half bias[SHADOW_CASCADE_COUNT];
	half lightSize;
	float blockerSearchSize;
};

#endif /* __Q_RENDER_SHADOW_MAP_GLOBALS_H__ */
