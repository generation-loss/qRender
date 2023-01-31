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

#include "qMath.h"
#include "qMetal.h"

using namespace qMetal;

namespace qRender {
	class Cluster
	{
	public:
		
		typedef struct Config
		{
			NSString				*name;
			
			Config(NSString *_name)
			: name([_name retain])
			{
			}
			
			friend std::ostream& operator<<(std::ostream& out, const Config& config)
			{
				out << "name " << [config.name cStringUsingEncoding:NSUTF8StringEncoding] << std::endl;
				return out;
			}
			
		} Config;
		
		Cluster(Config *_config);
		
	private:
		Config *config;
	};
}

#endif /* __Q_RENDER_CLUSTER_H__ */
