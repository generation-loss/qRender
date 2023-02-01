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

#ifndef __Q_RENDER_SUBSYSTEMS_H__
#define __Q_RENDER_SUBSYSTEMS_H__

#include "qMetal.h"
#include "qRenderSubsystem.h"
#include "qRenderGlobals.h"
#include "qRenderAtmosphere.h"
#include "qRenderHeightMap.h"
#include "qRenderReflectionProbe.h"
#include "qRenderPrepass.h"
#include "qRenderSSAO.h"
#include "qRenderShadowMap.h"

using namespace qMetal;

namespace qRender
{
	class Subsystems : public Subsystem
	{
	public:
		typedef struct Config
		{
			Config()
			: atmosphereConfig(new Atmosphere::Config())
			, heightMapConfig(new HeightMap::Config())
			, reflectionProbeConfig(new ReflectionProbe::Config())
			, prepassConfig(new Prepass::Config())
			, ssaoConfig(new SSAO::Config())
			, shadowMapConfig(new ShadowMap::Config())
			{
			}
			
			Atmosphere::Config* atmosphereConfig;
			HeightMap::Config* heightMapConfig;
			ReflectionProbe::Config* reflectionProbeConfig;
			Prepass::Config* prepassConfig;
			SSAO::Config* ssaoConfig;
			ShadowMap::Config* shadowMapConfig;
		} Config;
		
		Subsystems(Config* _config);
		
		void Init(Globals* globals);
	
		void Update(Globals* globals);
		
		void Encode(const Globals* globals) const;
		
		void Drag(qVector2 location, qVector2 velocity);
		
		void AddSubsystem(Subsystem* subsystem)
		{
			subsystems.push_back(subsystem);
		}
		
		Atmosphere* GetAtmosphere() const
		{
			return atmosphere;
		}
		
		HeightMap* GetHeightMap() const
		{
			return heightMap;
		}
		
		ReflectionProbe* GetReflectionProbe() const
		{
			return reflectionProbe;
		}
		
		Prepass* GetPrepass() const
		{
			return prepass;
		}
		
		SSAO* GetSSAO() const
		{
			return ssao;
		}
		
		ShadowMap* GetShadowMap() const
		{
			return shadowMap;
		}
		
	protected:
	
		std::vector<Subsystem*> subsystems;
		
	private:
	
		Config* config;
		Atmosphere* atmosphere;
		HeightMap* heightMap;
		ReflectionProbe* reflectionProbe;
		Prepass* prepass;
		SSAO* ssao;
		ShadowMap* shadowMap;
	};
}

#endif /* __Q_RENDER_SUBSYSTEMS_H__ */
