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

#include "qRenderSubsystems.h"
	
qRender::Subsystems::Subsystems(Config* _config)
: config(_config)
{
	HeightMap::Config* heightMapConfig = config->heightMapConfig == NULL ? new HeightMap::Config() : config->heightMapConfig;
	heightMap = new HeightMap(heightMapConfig);
	this->AddSubsystem(heightMap);
	
	Cluster::Config* clusterConfig = config->heightMapConfig == NULL ? new Cluster::Config() : config->clusterConfig;
	cluster = new Cluster(clusterConfig);
	this->AddSubsystem(cluster);
	
	ShadowMap::Config* shadowMapConfig = config->shadowMapConfig == NULL ? new ShadowMap::Config() : config->shadowMapConfig;
	shadowMap = new ShadowMap(shadowMapConfig);
	this->AddSubsystem(shadowMap);
	
	ReflectionProbe::Config* reflectionProbeConfig = config->reflectionProbeConfig == NULL ? new ReflectionProbe::Config() : config->reflectionProbeConfig;
	reflectionProbe = new ReflectionProbe(reflectionProbeConfig);
	this->AddSubsystem(reflectionProbe);
	
	Prepass::Config* prepassConfig = config->prepassConfig == NULL ? new Prepass::Config() : config->prepassConfig;
	prepass = new Prepass(prepassConfig);
	this->AddSubsystem(prepass);
	
	SSAO::Config* ssaoConfig = config->ssaoConfig == NULL ? new SSAO::Config() : config->ssaoConfig;
	ssaoConfig->prepass = prepass;
	ssao = new SSAO(ssaoConfig);
	this->AddSubsystem(ssao);
	
	Atmosphere::Config* atmosphereConfig = config->atmosphereConfig == NULL ? new Atmosphere::Config() : config->atmosphereConfig;
	atmosphereConfig->prepass = prepass;
	atmosphereConfig->reflectionProbe = reflectionProbe;
	atmosphereConfig->shadowMap = shadowMap;
	atmosphere = new Atmosphere(atmosphereConfig);
	this->AddSubsystem(atmosphere);
}
	
void qRender::Subsystems::Init(Globals* globals)
{
	for(auto &it : subsystems)
	{
		it->Init(globals);
	}
}
	
void qRender::Subsystems::Update(qRender::Globals* globals)
{
	for(auto &it : subsystems)
	{
		it->Update(globals);
	}
}

void qRender::Subsystems::Encode(const qRender::Globals* globals) const
{
	//TODO this needs to be in a better order
	reflectionProbe->EncodeIndirect(globals);
	for(auto &it : subsystems)
	{
		it->Encode(globals);
	}
}
		
void qRender::Subsystems::Drag(qVector2 location, qVector2 velocity)
{
	for(auto &it : subsystems)
	{
		it->Drag(location, velocity);
	}
}
