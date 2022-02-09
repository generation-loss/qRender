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

#include "qRenderCamera.h"

void qRender::Camera::ExtractFrustumPlanes()
{
	// left
	globals.planes[0].x = globals.vp.columns[0][3] + globals.vp.columns[0][0];
    globals.planes[0].y = globals.vp.columns[1][3] + globals.vp.columns[1][0];
    globals.planes[0].z = globals.vp.columns[2][3] + globals.vp.columns[2][0];
    globals.planes[0].w = globals.vp.columns[3][3] + globals.vp.columns[3][0];
	
    // right
    globals.planes[1].x = globals.vp.columns[0][3] - globals.vp.columns[0][0];
    globals.planes[1].y = globals.vp.columns[1][3] - globals.vp.columns[1][0];
    globals.planes[1].z = globals.vp.columns[2][3] - globals.vp.columns[2][0];
    globals.planes[1].w = globals.vp.columns[3][3] - globals.vp.columns[3][0];
	
    // bottom
    globals.planes[2].x = globals.vp.columns[0][3] + globals.vp.columns[0][1];
    globals.planes[2].y = globals.vp.columns[1][3] + globals.vp.columns[1][1];
    globals.planes[2].z = globals.vp.columns[2][3] + globals.vp.columns[2][1];
    globals.planes[2].w = globals.vp.columns[3][3] + globals.vp.columns[3][1];
	
    // top
    globals.planes[3].x = globals.vp.columns[0][3] - globals.vp.columns[0][1];
    globals.planes[3].y = globals.vp.columns[1][3] - globals.vp.columns[1][1];
    globals.planes[3].z = globals.vp.columns[2][3] - globals.vp.columns[2][1];
    globals.planes[3].w = globals.vp.columns[3][3] - globals.vp.columns[3][1];
	
    // near
    globals.planes[4].x = globals.vp.columns[0][3] + globals.vp.columns[0][2];
    globals.planes[4].y = globals.vp.columns[1][3] + globals.vp.columns[1][2];
    globals.planes[4].z = globals.vp.columns[2][3] + globals.vp.columns[2][2];
    globals.planes[4].w = globals.vp.columns[3][3] + globals.vp.columns[3][2];
	
	// far
    globals.planes[5].x = globals.vp.columns[0][3] - globals.vp.columns[0][2];
    globals.planes[5].y = globals.vp.columns[1][3] - globals.vp.columns[1][2];
    globals.planes[5].z = globals.vp.columns[2][3] - globals.vp.columns[2][2];
    globals.planes[5].w = globals.vp.columns[3][3] - globals.vp.columns[3][2];
	
	//Normalize
	globals.planes[0] /= sqrtf(globals.planes[0].x * globals.planes[0].x + globals.planes[0].y * globals.planes[0].y + globals.planes[0].z * globals.planes[0].z);
	globals.planes[1] /= sqrtf(globals.planes[1].x * globals.planes[1].x + globals.planes[1].y * globals.planes[1].y + globals.planes[1].z * globals.planes[1].z);
	globals.planes[2] /= sqrtf(globals.planes[2].x * globals.planes[2].x + globals.planes[2].y * globals.planes[2].y + globals.planes[2].z * globals.planes[2].z);
	globals.planes[3] /= sqrtf(globals.planes[3].x * globals.planes[3].x + globals.planes[3].y * globals.planes[3].y + globals.planes[3].z * globals.planes[3].z);
	globals.planes[4] /= sqrtf(globals.planes[4].x * globals.planes[4].x + globals.planes[4].y * globals.planes[4].y + globals.planes[4].z * globals.planes[4].z);
	globals.planes[5] /= sqrtf(globals.planes[5].x * globals.planes[5].x + globals.planes[5].y * globals.planes[5].y + globals.planes[5].z * globals.planes[5].z);
}

bool qRender::Camera::InFrustum(qVector4 aabbMin, qVector4 aabbMax) const
{
    for(int i = 0; i < 6; i++)
    {
        int out = 0;
		
		out += (globals.planes[i].x * aabbMin.x + globals.planes[i].y * aabbMin.y + globals.planes[i].y * aabbMin.z + globals.planes[i].w) < 0.0f ? 1 : 0;
		out += (globals.planes[i].x * aabbMax.x + globals.planes[i].y * aabbMin.y + globals.planes[i].y * aabbMin.z + globals.planes[i].w) < 0.0f ? 1 : 0;
		out += (globals.planes[i].x * aabbMin.x + globals.planes[i].y * aabbMax.y + globals.planes[i].y * aabbMin.z + globals.planes[i].w) < 0.0f ? 1 : 0;
		out += (globals.planes[i].x * aabbMax.x + globals.planes[i].y * aabbMax.y + globals.planes[i].y * aabbMin.z + globals.planes[i].w) < 0.0f ? 1 : 0;
		out += (globals.planes[i].x * aabbMin.x + globals.planes[i].y * aabbMin.y + globals.planes[i].y * aabbMax.z + globals.planes[i].w) < 0.0f ? 1 : 0;
		out += (globals.planes[i].x * aabbMax.x + globals.planes[i].y * aabbMin.y + globals.planes[i].y * aabbMax.z + globals.planes[i].w) < 0.0f ? 1 : 0;
		out += (globals.planes[i].x * aabbMin.x + globals.planes[i].y * aabbMax.y + globals.planes[i].y * aabbMax.z + globals.planes[i].w) < 0.0f ? 1 : 0;
		out += (globals.planes[i].x * aabbMax.x + globals.planes[i].y * aabbMax.y + globals.planes[i].y * aabbMax.z + globals.planes[i].w) < 0.0f ? 1 : 0;
        
		if( out == 8 )
		{
			return false;
		}
    }

    return true;
}
