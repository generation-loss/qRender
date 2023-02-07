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

#ifndef __Q_RENDER_CLUSTER_H__
#define __Q_RENDER_CLUSTER_H__

#include "qMetal.h"
#include "qRenderSubsystem.h"
#include "Shaders/ClusterParams.h"

using namespace qMetal;

namespace qRender {
	class Cluster : public Subsystem
	{
	public:
	
		struct Config
		{
			Config()
			: vertexStreamCount(1)
			, maxVertices(1000)
			, maxIndices(2000)
			, maxMeshes(1)
			{
			}
			
			NSUInteger vertexStreamCount;
			qMetal::Mesh::eVertexStreamType vertexStreamTypes[qMetal::Mesh::VertexStreamLimit];
			NSUInteger maxVertices;
			NSUInteger maxIndices;
			NSUInteger maxMeshes;
			
		};
		
		Cluster(Config* _config);
		
		void Finalize();
		
		void Init(Globals* globals);
		
		void Update(Globals* globals);
		
		void Encode(const Globals* globals) const;
		
		void AddClusterableMesh(Mesh::Config* meshConfig, NSUInteger clusterCount);
		
	private:
	
		Config* config;
		
		bool finalized;
		
		uint8_t* vertexBuffersRaw[qMetal::Mesh::VertexStreamLimit];
		uint32_t* indexBufferRaw;
		
		ClusterableMesh *clusterableMeshes;
		
		id<MTLBuffer> vertexBuffers[qMetal::Mesh::VertexStreamLimit];
		id<MTLBuffer> indexBuffer;
		
		NSUInteger clusterableMeshCount;
		NSUInteger currentVertexOffset;
		NSUInteger currentIndexOffset;
		
		typedef Material<EmptyParams, EmptyParams, ClusterComputeInitParams> ClusterInitMaterial;
		
		ClusterInitMaterial 		*initMaterial;
		
	};
}

#endif /* __Q_RENDER_CLUSTER_H__ */
