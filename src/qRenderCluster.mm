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
, currentClusterableMesh(0)
, currentVertexOffset(0)
, currentIndexOffset(0)
, finalized(false)
{
	qASSERT(config->vertexStreamCount < qMetal::Mesh::VertexStreamLimit);

	
	for(NSUInteger i = 0; i < config->vertexStreamCount; ++i)
	{
		vertexBuffersRaw[i] = new uint8_t[(NSUInteger)config->vertexStreamTypes[i] * config->maxVertices];
	}
	
	indexBufferRaw = new uint32_t[config->maxIndices];
	
	clusterableMeshes = new ClusterableMesh[config->maxMeshes];
}

void qRender::Cluster::AddClusterableMesh(Mesh::Config* meshConfig, NSUInteger clusterCount)
{
	qASSERT(!finalized);
	qASSERTM(meshConfig->vertexStreamCount == config->vertexStreamCount, "Vertex stream mismatch between cluster and mesh");
	qASSERTM(meshConfig->indices16 == NULL, "Clusters only support 32-bit indices");
	qASSERTM(meshConfig->indices32 != NULL, "Clusters only support 32-bit indices");
	qASSERTM(currentIndexOffset + meshConfig->indexCount < config->maxIndices, "Index overflow in cluster. Need %lu, but only %lu left", meshConfig->indexCount, config->maxIndices - currentIndexOffset);
	qASSERTM(currentVertexOffset + meshConfig->vertexCount < config->maxVertices, "Vertex overflow in cluster. Need %lu, but only %lu left", meshConfig->vertexCount, config->maxVertices - currentVertexOffset);
	
	for(NSUInteger i = 0; i < meshConfig->indexCount; ++i)
	{
		indexBufferRaw[currentIndexOffset + i] = meshConfig->indices32[i];
	}
	
	for(NSUInteger i = 0; i < config->vertexStreamCount; ++i)
	{
		qASSERTM(meshConfig->vertexStreams[i].type == config->vertexStreamTypes[i], "Vertex stream type mismatch between cluster and mesh at stream %lu", i);
		memcpy(vertexBuffersRaw[i] + ((NSUInteger)config->vertexStreamTypes[i] * currentVertexOffset), meshConfig->vertexStreams[i].data, (NSUInteger)config->vertexStreamTypes[i] * meshConfig->vertexCount);
	}
	
	clusterableMeshes[currentClusterableMesh].vertexCount = meshConfig->vertexCount;
	clusterableMeshes[currentClusterableMesh].indexCount = meshConfig->indexCount;
	clusterableMeshes[currentClusterableMesh].vertexOffset = currentVertexOffset;
	clusterableMeshes[currentClusterableMesh].indexOffset = currentIndexOffset;
	clusterableMeshes[currentClusterableMesh].clusterCount = clusterCount;
	
	currentIndexOffset += meshConfig->indexCount;
	currentClusterableMesh += 1;
}

void qRender::Cluster::Finalize()
{
	qASSERT(!finalized);
	
	for(NSUInteger i = 0; i < config->vertexStreamCount; ++i)
	{
		vertexBuffers[i] = [qMetal::Device::Get() newBufferWithBytesNoCopy:vertexBuffers[i] length:((NSUInteger)config->vertexStreamTypes[i] * config->maxVertices) options:MTLResourceStorageModePrivate deallocator:nil];
		vertexBuffers[i].label = [NSString stringWithFormat:@"Cluster vertex buffer %lu", i];
	}
	
	indexBuffer = [qMetal::Device::Get() newBufferWithBytesNoCopy:indexBufferRaw length:(sizeof(uint32_t) * config->maxIndices) options:MTLResourceStorageModePrivate deallocator:nil];
	indexBuffer.label = @"Cluster index buffer";
	
	finalized = true;
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
