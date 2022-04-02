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

#ifndef __Q_RENDER_DEBUG_MENU_H__
#define __Q_RENDER_DEBUG_MENU_H__

#include "qMetal.h"
#include "qMath.h"
#include "Shaders/DebugMenuParams.h"
#if TARGET_OS_IPHONE
#include <UIKit/UIKit.h>
#else
#include <AppKit/AppKit.h>
#endif
#include <CoreText/CoreText.h>
#include <map>

#define ITEM_WIDTH 400.0f
#define ITEM_HEIGHT 30.0f
#define ITEM_MARGIN 5.0f
#define LABEL_LENGTH 64UL

using namespace qMetal;

namespace qRender
{
	class DebugMenu
	{
	public:

		typedef struct Config
		{
			float      			screenWidth;
			float				screenHeight;
			id<MTLDevice> 		device;
		} Config;
		
		static void Init(Config *config);
		
		static DebugMenu* Instance() { qASSERT(instance != NULL); return instance; }
		
		bool Active() const;
		void Encode(id<MTLRenderCommandEncoder> encoder);
		void Toggle();
		void Tap(CGPoint location);
		void DragBegan(CGPoint location);
		void DragMoved(CGPoint location);
		void DragEnded(CGPoint location);
		
		void Value(const char* category, const char* subcategory, const char *label, bool &value);
		void Value(const char* category, const char* subcategory, const char *label, NSUInteger &value, NSUInteger increment = 1, NSUInteger minimum = std::numeric_limits<NSUInteger>::min(), NSUInteger maximum = std::numeric_limits<NSUInteger>::max());
		void Value(const char* category, const char* subcategory, const char *label, uint32_t &value, uint32_t increment = 1, uint32_t minimum = std::numeric_limits<uint32_t>::min(), uint32_t maximum = std::numeric_limits<uint32_t>::max());
		void Value(const char* category, const char* subcategory, const char *label, int &value, int increment = 1, int minimum = std::numeric_limits<int>::min(), int maximum = std::numeric_limits<int>::max());
		void Value(const char* category, const char* subcategory, const char *label, half &value, half increment = 0.1, half minimum = std::numeric_limits<half>::min(), half maximum = std::numeric_limits<half>::max());
		void Value(const char* category, const char* subcategory, const char *label, float &value, float increment = 0.1f, float minimum = std::numeric_limits<float>::min(), float maximum = std::numeric_limits<float>::max());
		void Value(const char* category, const char* subcategory, const char *label, int &value, int minimum, int maximum, const char** names);
		
	private:
		
		Config					*config;
		
		DebugMenu(Config *config);
		
		static DebugMenu		*instance;
		
	#ifdef DEBUG
		
	public:
		
		typedef Material<DebugMenuVertexParams, -1, DebugMenuVertexStream_Params, DebugMenuFragmentParams, DebugMenuFragmentStream_TextureArgumentBuffer, DebugMenuFragmentStream_Params> DebugMaterial;
		
		typedef Mesh<DebugMenuVertexStreamArgumentBuffer_Count, DebugMenuVertexStream_StreamArgumentBuffer> DebugMesh;
		
	private:
		
		struct Item
		{
			Item(const char* label, unsigned long itemNumber, Config *config);
			bool Hit(CGPoint location);
			void Tap(CGPoint location, bool fromDrag);
			
			virtual bool isCategory() const { return false; }
			virtual bool isBack() const { return false; }
			
			char label[LABEL_LENGTH];
			DebugMaterial *material;
			DebugMenuVertexParams vertexParams;
			DebugMenuFragmentParams fragmentParams;
			Texture *texture;
			
		protected:
			virtual void HandleTap(CGPoint location, bool fromDrag) = 0;
			virtual void UpdateTexture() = 0;
			
			void UpdatePositionSize(unsigned long itemNumber, Config *config);
		};
		
		typedef std::vector<Item*> Items;
		
		struct CategoryItem : Item
		{
			CategoryItem(const char* label, unsigned long itemNumber, Config *config);
			bool isCategory() const { return true; }
			Items *items;
			
			protected:
			void HandleTap(CGPoint location, bool fromDrag);
			void UpdateTexture();
		};
		
		struct BackItem : Item
		{
			BackItem(const char* label, unsigned long itemNumber, Config *config);
			bool isBack() const { return true; }
			Items *parent;
			
			protected:
			void HandleTap(CGPoint location, bool fromDrag);
			void UpdateTexture();
		};
		
		struct BoolItem : Item
		{
			bool &value;
			
			BoolItem(const char* label, unsigned long itemNumber, Config *config, bool &value);
			
			protected:
			void HandleTap(CGPoint location, bool fromDrag);
			void UpdateTexture();
		};
		
		template<typename T>
		struct ValueItem : Item
		{
			T &value;
			T increment;
			T minimum;
			T maximum;
			
			ValueItem(const char* label, unsigned long itemNumber, Config *config, T &value, T increment, T minimum, T maximum);
			
			protected:
			void HandleTap(CGPoint location, bool fromDrag);
			void UpdateTexture();
		};
		
		struct EnumItem : Item
		{
			int &value;
			int minimum;
			int maximum;
			const char** names;
			
			EnumItem(const char* label, unsigned long itemNumber, Config *config, int &value, int minimum, int maximum, const char** names);
			
			protected:
			void HandleTap(CGPoint location, bool fromDrag);
			void UpdateTexture();
		};
		
		typedef ValueItem<NSUInteger> NSUIntegerItem;
		typedef ValueItem<uint32_t> UInt32Item;
		typedef ValueItem<int32_t> 	Int32Item;
		typedef ValueItem<half> 	HalfItem;
		typedef ValueItem<float> 	FloatItem;
		
		static void FillWithString(Texture* texture, NSString* string);
		static Texture* TextureWithLabel(char* label);
		
		Items* CategoryItems(const char* category, const char* subcategory);
		bool					rendering;
		DebugMesh				*mesh;
		Items					*topLevelItems;
		Items					*activeItems;
		Item					*draggedItem;
	#endif
	};

}

#endif /* __Q_RENDER_DEBUG_MENU_H__ */
