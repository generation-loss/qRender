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

#ifndef __Q_RENDER_CAMERA_GLOBALS_H__
#define __Q_RENDER_CAMERA_GLOBALS_H__

#include <simd/SIMD.h>

using namespace simd;

struct CameraGlobals
{
	float focusDistance;
	float focalLength;
	
	float ISO;
	float aperture;
	float shutterSpeed;
	
	float farPlane;
	float nearPlane;
	
	float4 zBufferParams; //x is (1-far/near), y is (far/near), z is (x/far) and w is (y/far).
	
	float3 position;
	float3 lookAt;
	float3 viewDir; //lookAt - position; normalized
	
	matrix_float4x4 v;
	matrix_float4x4 p;
	matrix_float4x4 vp;
	
	float4 planes[6];
	
	float2 screenSize;
	
#if DEBUG
	float DEBUG_distanceToCamera;
#endif
	
	CameraGlobals()
	: focusDistance(10.0f)
	, focalLength(3.0f)
	, ISO(100.0f)
	, aperture(16.0f)
	, shutterSpeed(1.0f / 100.0f)
	, zBufferParams(1)
	, position(0)
	, lookAt(1)
	, viewDir(1)
	, screenSize(1)
#if DEBUG
	, DEBUG_distanceToCamera(400)
#endif
	{
	}
};

#endif /* __Q_RENDER_CAMERA_GLOBALS_H__ */
