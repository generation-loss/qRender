/*
Copyright (c) 2023 Generation Loss Interactive

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

#include "qRenderCluster.h"
	
qRender::Cluster::Cluster(Config* _config)
: config(_config)
{
	qASSERT(config->vertexStreamCount < qMetal::Mesh::VertexStreamLimit);
	
	for(NSUInteger i = 0; i < config->vertexStreamCount; ++i)
	{
		vertexBuffers[i] = [qMetal::Device::Get() newBufferWithLength:((NSUInteger)config->vertexStreamTypes[i] * config->maxVertices) options:MTLResourceStorageModePrivate];
		vertexBuffers[i].label = [NSString stringWithFormat:@"Cluster vertex buffer %ul", (unsigned long)i];
	}
}

void qRender::Cluster::AddClusterableMesh(Mesh::Config* config, NSUInteger clusterCount)
{
}

void qRender::Cluster::Init(Globals* globals)
{
}

void qRender::Cluster::Update(Globals* globals)
{
}

void qRender::Cluster::Encode(const Globals* globals) const
{
}
