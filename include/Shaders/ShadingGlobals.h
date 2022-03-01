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

#ifndef __Q_RENDER_SHADING_GLOBALS_H__
#define __Q_RENDER_SHADING_GLOBALS_H__

#include <simd/SIMD.h>

using namespace simd;

#define USE_DEFFERRED_RENDERING (0)

#define USE_DEFERRED_WORLD_POSITION (1)

namespace qRender
{
	typedef enum eGBufferRenderTarget
	{
		eGBufferRenderTarget_Lighting,
	#if USE_DEFFERRED_RENDERING
		eGBufferRenderTarget_Albedo_Roughness,
		eGBufferRenderTarget_Normal,
	#if USE_DEFERRED_WORLD_POSITION
		eGBufferRenderTarget_WorldPos,
	#else
		eGBufferRenderTarget_Depth,
	#endif
	#endif //#if USE_DEFFERRED_RENDERING,
		eGBufferRenderTarget_Count
	} eGBufferRenderTarget;

	#define DEBUG_MODES \
	/*          enum	*/ \
	DEBUG_MODE(	None				) \
	DEBUG_MODE(	BaseColourLinear	) \
	DEBUG_MODE(	BaseColourGamma 	) \
	DEBUG_MODE(	LocalNormal 		) \
	DEBUG_MODE(	LocalTangent 		) \
	DEBUG_MODE(	LocalBitangent  	) \
	DEBUG_MODE(	WorldNormal 		) \
	DEBUG_MODE(	WorldTangent 		) \
	DEBUG_MODE(	WorldBitangent  	) \
	DEBUG_MODE(	NormalMap 			) \
	DEBUG_MODE(	NdotL 				) \
	DEBUG_MODE(	UV 					) \
	DEBUG_MODE(	UVX 				) \
	DEBUG_MODE(	UVY 				) \
	DEBUG_MODE(	ShadowMap 			) \
	DEBUG_MODE(	SSAO				) \
	DEBUG_MODE(	Indirect 			) \
	DEBUG_MODE(	Direct 				) \
	DEBUG_MODE(	IndirectCombined	) \
	DEBUG_MODE(	DirectCombined  	) \

	enum eDebugMode
	{
	#define DEBUG_MODE(xxenum) eDebugMode_ ## xxenum,
			DEBUG_MODES
	#undef DEBUG_MODE
		eDebugMode_Count
	};

	struct ShadingGlobals
	{
		eDebugMode debugMode;
		
		half3 directionToKeyLight;
		half3 directionToKeyLightClamped;
		half3 keyLightColour;
		
		ShadingGlobals()
		: debugMode(eDebugMode_None)
		, directionToKeyLight(1)
		, directionToKeyLightClamped(1)
		, keyLightColour(0)
		{
		}
	};
}

#endif /* __Q_RENDER_SHADING_GLOBALS_H__ */
