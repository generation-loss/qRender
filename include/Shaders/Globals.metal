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

#include "Globals.h"
#include "Util.h"

half3 DebugColour(constant qRender::ShadingGlobals &shadingGlobals, half3 result, half3 linearBaseColour, half3 localNormal, half3 localTangent, half3 localBitangent, half3 worldNormal, half3 worldTangent, half3 worldBitangent, float2 uv, half3 normalMap, half NdotL, half shadow, half ssao, half3 indirect, half3 direct)
{
#if DEBUG_SHADING
	
	if (shadingGlobals.debugMode == qRender::eDebugMode_None)
		return result;
	
	else if (shadingGlobals.debugMode == qRender::eDebugMode_BaseColourLinear)
		return linearBaseColour;
	
	else if (shadingGlobals.debugMode == qRender::eDebugMode_BaseColourGamma)
		return Gamma(linearBaseColour);
	
	else if (shadingGlobals.debugMode == qRender::eDebugMode_LocalNormal)
		return localNormal * 0.5h + 0.5h;
	
	else if (shadingGlobals.debugMode == qRender::eDebugMode_LocalTangent)
		return localTangent * 0.5h + 0.5h;
	
	else if (shadingGlobals.debugMode == qRender::eDebugMode_LocalBitangent)
		return localBitangent * 0.5h + 0.5h;
	
	else if (shadingGlobals.debugMode == qRender::eDebugMode_WorldNormal)
		return worldNormal * 0.5h + 0.5h;
	
	else if (shadingGlobals.debugMode == qRender::eDebugMode_WorldNormalX)
		return worldNormal.xxx * 0.5h + 0.5h;
	
	else if (shadingGlobals.debugMode == qRender::eDebugMode_WorldNormalY)
		return worldNormal.yyy * 0.5h + 0.5h;
	
	else if (shadingGlobals.debugMode == qRender::eDebugMode_WorldNormalZ)
		return worldNormal.zzz * 0.5h + 0.5h;
	
	else if (shadingGlobals.debugMode == qRender::eDebugMode_WorldTangent)
		return worldTangent * 0.5h + 0.5h;
	
	else if (shadingGlobals.debugMode == qRender::eDebugMode_WorldBitangent)
		return worldBitangent * 0.5h + 0.5h;
	
	else if (shadingGlobals.debugMode == qRender::eDebugMode_UV)
		return half3((half2)uv, 0);
		
	else if (shadingGlobals.debugMode == qRender::eDebugMode_UVX)
		return half3(uv.x);
		
	else if (shadingGlobals.debugMode == qRender::eDebugMode_UVY)
		return half3(uv.y);
		
	else if (shadingGlobals.debugMode == qRender::eDebugMode_NormalMap)
		return normalMap * 0.5h + 0.5h;
			
	else if (shadingGlobals.debugMode == qRender::eDebugMode_NdotL)
		return NdotL;
		
	else if (shadingGlobals.debugMode == qRender::eDebugMode_ShadowMap)
		return shadow;
		
	else if (shadingGlobals.debugMode == qRender::eDebugMode_SSAO)
		return ssao;
		
	else if (shadingGlobals.debugMode == qRender::eDebugMode_Indirect)
		return indirect;
		
	else if (shadingGlobals.debugMode == qRender::eDebugMode_Direct)
		return direct;
		
	else if (shadingGlobals.debugMode == qRender::eDebugMode_IndirectCombined)
		return indirect * ssao;
		
	else if (shadingGlobals.debugMode == qRender::eDebugMode_DirectCombined)
		return direct * (NdotL * shadow);
		
	return half3(0, 1, 0);
	
#else
	
	return result;
	
#endif
}
