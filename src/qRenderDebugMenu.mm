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

#include "qRenderDebugMenu.h"

qRender::DebugMenu* qRender::DebugMenu::instance = NULL;

void qRender::DebugMenu::Init(Config* _config)
{
	qRender::DebugMenu::instance = new qRender::DebugMenu(_config);
}

qRender::DebugMenu::DebugMenu(Config* _config)
: config(_config)
#if DEBUG
, rendering(false)
, activeItems(NULL)
, draggedItem(NULL)
#endif
{
#if DEBUG
	qVector4* vertices = new qVector4[4]
	{
		qVector4(0.0f, 0.0f, 0.0f, 1.0f),
		qVector4(0.0f, 1.0f, 0.0f, 1.0f),
		qVector4(1.0f, 1.0f, 0.0f, 1.0f),
		qVector4(1.0f, 0.0f, 0.0f, 1.0f)
	};
	
	qVector2* uvs = new qVector2[4]
	{
		qVector2(0.0f, 0.0f),
		qVector2(0.0f, 1.0f),
		qVector2(1.0f, 1.0f),
		qVector2(1.0f, 0.0f)
	};
	
	uint16_t* indices = new uint16_t[6]
	{
		0, 1, 2, 0, 2, 3
	};
	
	Mesh::Config* meshConfig = new Mesh::Config(@"Debug Menu Mesh");
	
	meshConfig->vertexStreamCount = DebugMenuVertexStreamArgumentBuffer_Count;
	meshConfig->vertexStreamIndex = DebugMenuVertexStream_StreamArgumentBuffer;
	
	meshConfig->vertexCount = 4;
	meshConfig->indexCount = 6;
	
	meshConfig->vertexStreams[DebugMenuVertexStreamArgumentBuffer_Position].type = Mesh::eVertexStreamType_Float4;
	meshConfig->vertexStreams[DebugMenuVertexStreamArgumentBuffer_Position].data = vertices;
	
	meshConfig->vertexStreams[DebugMenuVertexStreamArgumentBuffer_UV].type = Mesh::eVertexStreamType_Float2;
	meshConfig->vertexStreams[DebugMenuVertexStreamArgumentBuffer_UV].data = uvs;
	
	meshConfig->indices16 = indices;
	
	mesh = new Mesh(meshConfig);
	
	topLevelItems = new Items();
#endif
}

void qRender::DebugMenu::Value(const char* category, const char* subcategory, const char* label, bool &value)
{
#if DEBUG
	Items* items = CategoryItems(category, subcategory);
	items->push_back( new BoolItem(label, items->size(), config, value) );
#endif
}

void qRender::DebugMenu::Value(const char* category, const char* subcategory, const char* label, NSUInteger &value, NSUInteger increment, NSUInteger minimum, NSUInteger maximum)
{
#if DEBUG
	Items* items = CategoryItems(category, subcategory);
	items->push_back( new NSUIntegerItem(label, items->size(), config, value, increment, minimum, maximum) );
#endif
}

void qRender::DebugMenu::Value(const char* category, const char* subcategory, const char* label, uint32_t &value, uint32_t increment, uint32_t minimum, uint32_t maximum)
{
#if DEBUG
	Items* items = CategoryItems(category, subcategory);
	items->push_back( new UInt32Item(label, items->size(), config, value, increment, minimum, maximum) );
#endif
}

void qRender::DebugMenu::Value(const char* category, const char* subcategory, const char* label, int &value, int increment, int minimum, int maximum)
{
#if DEBUG
	Items* items = CategoryItems(category, subcategory);
	items->push_back( new Int32Item(label, items->size(), config, value, increment, minimum, maximum) );
#endif
}

void qRender::DebugMenu::Value(const char* category, const char* subcategory, const char* label, half &value, half increment, half minimum, half maximum)
{
#if DEBUG
	Items* items = CategoryItems(category, subcategory);
	items->push_back( new HalfItem(label, items->size(), config, value, increment, minimum, maximum) );
#endif
}

void qRender::DebugMenu::Value(const char* category, const char* subcategory, const char* label, float &value, float increment, float minimum, float maximum)
{
#if DEBUG
	Items* items = CategoryItems(category, subcategory);
	items->push_back( new FloatItem(label, items->size(), config, value, increment, minimum, maximum) );
#endif
}

void qRender::DebugMenu::Value(const char* category, const char* subcategory, const char* label, int &value, int minimum, int maximum, const char** names)
{
#if DEBUG
	Items* items = CategoryItems(category, subcategory);
	items->push_back( new EnumItem(label, items->size(), config, value, minimum, maximum, names) );
#endif
}

bool qRender::DebugMenu::Active() const
{
#if DEBUG
	return rendering;
#else
	return false;
#endif
}

void qRender::DebugMenu::Encode(id<MTLRenderCommandEncoder> encoder)
{
#if DEBUG
	if (!rendering)
	{
		return;
	}
	
	Items* itemsToEncode = (activeItems == NULL) ? topLevelItems : activeItems;
	
	for(auto &item : *itemsToEncode)
	{
		DebugMenuVertexParams* vertexParams = item->material->CurrentFrameVertexParams();
		memcpy(vertexParams, &(item->vertexParams), sizeof(DebugMenuVertexParams));
		
		DebugMenuFragmentParams* fragmentParams = item->material->CurrentFrameFragmentParams();
		memcpy(fragmentParams, &(item->fragmentParams), sizeof(DebugMenuFragmentParams));
		
		mesh->Encode(encoder, item->material);
	}
#endif
}

void qRender::DebugMenu::Toggle()
{
#if DEBUG
	rendering = !rendering;
	
	qSPAM("HillsDebugMenu Toggle %s", rendering ? "Showing" : "Hidden");
#endif
}

void qRender::DebugMenu::Tap(CGPoint location)
{
#if DEBUG
	if (!rendering)
	{
		return;
	}
	
	CGPoint locationNormalized = CGPointMake(2.0f * location.x / config->screenWidth - 1.0f, 2.0f * location.y / config->screenHeight - 1.0f);
	
	Items &items = (activeItems == NULL) ? *topLevelItems : *activeItems;
	
	for(auto &item : items)
	{
		if (item->Hit(locationNormalized))
		{
			item->Tap(locationNormalized, false);
			
			if (item->isCategory())
			{
				activeItems = ((CategoryItem*)item)->items;
			}
			
			if (item->isBack())
			{
				activeItems = ((BackItem*)item)->parent;
			}
			
//			qSPAM("HillsDebugMenu Tap %s [%0.f, %0.f]", item->label, location.x, location.y);
			break;
		}
	}
#endif
}

void qRender::DebugMenu::DragBegan(CGPoint location)
{
#if DEBUG
	if (!rendering)
	{
		return;
	}
	
	qWARNING(draggedItem == NULL, "HillsDebugMenu Drag Began with another active drag on %s", draggedItem->label);
	
	CGPoint locationNormalized = CGPointMake(2.0f * location.x / config->screenWidth - 1.0f, 2.0f * location.y / config->screenHeight - 1.0f);
	
	if (activeItems == NULL)
	{
		//no drag on top level items
		return;
	}
	else
	{
		for(auto &item : *activeItems)
		{
			if (item->Hit(locationNormalized))
			{
				if (std::strcmp(item->label, "Back") != 0)
				{
					draggedItem = item;
					draggedItem->Tap(locationNormalized, true);
					
//					qSPAM("HillsDebugMenu Drag Began %s [%0.f, %0.f]", draggedItem->label, location.x, location.y);
				}
				break;
			}
		}
	}
#endif
}

void qRender::DebugMenu::DragMoved(CGPoint location)
{
#if DEBUG
	if (!rendering || (draggedItem == NULL))
	{
		return;
	}
	
	CGPoint locationNormalized = CGPointMake(2.0f * location.x / config->screenWidth - 1.0f, 2.0f * location.y / config->screenHeight - 1.0f);
	
	draggedItem->Tap(locationNormalized, true);
	
//	qSPAM("HillsDebugMenu Drag Moved %s [%0.f, %0.f]", draggedItem->label, location.x, location.y);
#endif
}

void qRender::DebugMenu::DragEnded(CGPoint location)
{
#if DEBUG
	if (!rendering || (draggedItem == NULL))
	{
		return;
	}
	
//	qSPAM("HillsDebugMenu Drag Ended %s [%0.f, %0.f]", draggedItem->label, location.x, location.y);
	
	draggedItem = NULL;
#endif
}

#if DEBUG

qRender::DebugMenu::Items* qRender::DebugMenu::CategoryItems(const char* category, const char* subcategory)
{
	CategoryItem* categoryItem = NULL;
	for(auto &item : *topLevelItems)
	{
		if (item->isCategory() && (strcmp(item->label, category) == 0))
		{
			categoryItem = (CategoryItem*)item;
			break;
		}
	}
	
	if (categoryItem == NULL)
	{
		categoryItem = new CategoryItem(category, topLevelItems->size(), config);
		
		BackItem* backItem = new BackItem("Back", 0, config);
		backItem->parent = topLevelItems;
		
		categoryItem->items->push_back(backItem);
		
		topLevelItems->push_back(categoryItem);
	}
	
	if (subcategory == NULL)
	{
		return categoryItem->items;
	}
	
	CategoryItem* subcategoryItem = NULL;
	for(auto &item : *(categoryItem->items))
	{
		if (item->isCategory() && (strcmp(item->label, subcategory) == 0))
		{
			subcategoryItem = (CategoryItem*)item;
			break;
		}
	}
	
	if (subcategoryItem == NULL)
	{
		subcategoryItem = new CategoryItem(subcategory, categoryItem->items->size(), config);
		
		BackItem* backItem = new BackItem("Back", 0, config);
		backItem->parent = categoryItem->items;
		
		subcategoryItem->items->push_back(backItem);
		
		categoryItem->items->push_back(subcategoryItem);
	}
	
	return subcategoryItem->items;
}

qRender::DebugMenu::Item::Item(const char* _label, unsigned long itemNumber, Config* _config)
{
	qASSERT(strlen(_label) + 1 < LABEL_LENGTH);
	memcpy(label, _label, strlen(_label) + 1);
	
	UpdatePositionSize(itemNumber, _config);
	
	//Create texture
	
	Texture::Config* config = new Texture::Config([[NSString alloc] initWithUTF8String:label]);
	config->width = ITEM_WIDTH;
	config->height = ITEM_HEIGHT;
	config->storage = Texture::eStorage_CPUandGPU;
	
	texture = new Texture(config, SamplerState::PredefinedState(eSamplerState_LinearLinearLinear_RepeatRepeat));
	
	//Set texture
	
	DebugMaterial::Config* materialConfig = new DebugMaterial::Config(@"Debug Menu Material");
	materialConfig->blendStates[RenderTarget::eColorAttachment_0] = BlendState::PredefinedState(eBlendState_Alpha);
	materialConfig->cullState = CullState::PredefinedState(eCullState_Disable);
	materialConfig->depthStencilState = DepthStencilState::PredefinedState(eDepthStencilState_TestDisable_WriteDisable_StencilDisable);
	materialConfig->vertexFunction = new Function(@"DebugMenuVertexShader");
	materialConfig->vertexParamsIndex = DebugMenuVertexStream_Params;
	materialConfig->fragmentParamsIndex = DebugMenuFragmentStream_Params;
	materialConfig->fragmentTextureIndex = DebugMenuFragmentStream_TextureArgumentBuffer;
	materialConfig->fragmentFunction = new Function(@"DebugMenuFragmentShader");
	materialConfig->fragmentTextures[DebugMenuFragmentTextureArgumentBuffer_BaseColourTexture] = texture;
	materialConfig->fragmentSamplers[DebugMenuFragmentTextureArgumentBuffer_BaseColourTexture] = DebugMenuFragmentTextureArgumentBuffer_BaseColourSampler;
	
	//Create material
	
	material = new DebugMaterial(materialConfig, Texture::ePixelFormat_BGRA8, Texture::ePixelFormat_Invalid, Texture::ePixelFormat_Invalid, Texture::eMSAA_1);
}

void qRender::DebugMenu::Item::UpdatePositionSize(unsigned long itemNumber, Config* config)
{
	vertexParams.position.x = (((config->screenWidth - ITEM_WIDTH) / 2.0f) / config->screenWidth) * 2.0f - 1.0f;
	vertexParams.position.y = ((ITEM_MARGIN + itemNumber * (ITEM_HEIGHT + ITEM_MARGIN)) / config->screenHeight) * 2.0f - 1.0f;
	vertexParams.size.x = ITEM_WIDTH * 2.0f / config->screenWidth;
	vertexParams.size.y = ITEM_HEIGHT * 2.0f / config->screenHeight;
}

bool qRender::DebugMenu::Item::Hit(CGPoint location)
{
	if ((location.x >= vertexParams.position.x) &&
		(location.x < (vertexParams.position.x + vertexParams.size.x)) &&
		(location.y >= vertexParams.position.y) &&
		(location.y < (vertexParams.position.y + vertexParams.size.y)))
	{
//		qSPAM("Item Hit %s [%0.2f, %0.2f]", label, location.x, location.y);
		return true;
	}
	
	return false;
}

void qRender::DebugMenu::Item::Tap(CGPoint location, bool fromDrag)
{
	CGPoint location01 = CGPointMake((location.x - vertexParams.position.x) / vertexParams.size.x, (location.y - vertexParams.position.y)/vertexParams.size.y);
	
	if (fromDrag)
	{
		//drags can go out of range, clamp to 0-1
		location01.x = qSaturate(location01.x);
		location01.y = qSaturate(location01.y);
	}
		
	HandleTap(location01, fromDrag);
	UpdateTexture();
		
//	qSPAM("Item Tap %s [%0.2f, %0.2f]", label, location01.x, location01.y);
}

qRender::DebugMenu::CategoryItem::CategoryItem(const char* _label, unsigned long _itemNumber, Config* _config)
: Item( _label, _itemNumber, _config )
{
	items = new Items();
	UpdateTexture();
}

void qRender::DebugMenu::CategoryItem::HandleTap(CGPoint location, bool fromDrag)
{
}

void qRender::DebugMenu::CategoryItem::UpdateTexture()
{
	FillWithString(texture, [NSString stringWithUTF8String:label]);
	fragmentParams.progress = 0.0f;
}

qRender::DebugMenu::BackItem::BackItem(const char* _label, unsigned long _itemNumber, Config* _config)
: Item( _label, _itemNumber, _config )
{
	UpdateTexture();
}

void qRender::DebugMenu::BackItem::HandleTap(CGPoint location, bool fromDrag)
{
}

void qRender::DebugMenu::BackItem::UpdateTexture()
{
	FillWithString(texture, [NSString stringWithUTF8String:label]);
	fragmentParams.progress = 0.0f;
}

qRender::DebugMenu::BoolItem::BoolItem(const char* _label, unsigned long _itemNumber, Config* _config, bool &_value)
: Item( _label, _itemNumber, _config )
, value( _value )
{
	UpdateTexture();
}

void qRender::DebugMenu::BoolItem::HandleTap(CGPoint location, bool fromDrag)
{
	if (fromDrag)
	{
		value = location.x > 0.5f;
	}
	else
	{
		value = !value;
	}
}

void qRender::DebugMenu::BoolItem::UpdateTexture()
{
	char labelWithValue[LABEL_LENGTH];
	snprintf(labelWithValue, LABEL_LENGTH, "%s %s", label, value ? "Yes" : "No");
	FillWithString(texture, [NSString stringWithUTF8String:labelWithValue]);
	fragmentParams.progress = value ? 1.0f : 0.0f;
}

template<typename T>
qRender::DebugMenu::ValueItem<T>::ValueItem(const char* _label, unsigned long _itemNumber, Config* _config, T &_value, T _increment, T _minimum, T _maximum)
: Item( _label, _itemNumber, _config )
, value( _value )
, increment( _increment )
, minimum( _minimum )
, maximum( _maximum )
{
	UpdateTexture();
}

template<typename T>
void qRender::DebugMenu::ValueItem<T>::HandleTap(CGPoint location, bool fromDrag)
{
	if (fromDrag)
	{
		value = location.x * (maximum - minimum) + minimum;
		value = increment * qRound(value / increment);
	}
	else
	{
		value += (location.x > 0.5f) ? increment : -increment;
	}
	value = std::min(maximum, std::max(minimum, value));
}

template<>
void qRender::DebugMenu::ValueItem<NSUInteger>::UpdateTexture()
{
	char labelWithValue[LABEL_LENGTH];
	snprintf(labelWithValue, LABEL_LENGTH, "%s %lu", label, value);
	FillWithString(texture, [NSString stringWithUTF8String:labelWithValue]);
	fragmentParams.progress = float(value - minimum) / float(maximum - minimum);
}

template<>
void qRender::DebugMenu::ValueItem<uint32_t>::UpdateTexture()
{
	char labelWithValue[LABEL_LENGTH];
	snprintf(labelWithValue, LABEL_LENGTH, "%s %u", label, value);
	FillWithString(texture, [NSString stringWithUTF8String:labelWithValue]);
	fragmentParams.progress = float(value - minimum) / float(maximum - minimum);
}

template<>
void qRender::DebugMenu::ValueItem<int32_t>::UpdateTexture()
{
	char labelWithValue[LABEL_LENGTH];
	snprintf(labelWithValue, LABEL_LENGTH, "%s %i", label, value);
	FillWithString(texture, [NSString stringWithUTF8String:labelWithValue]);
	fragmentParams.progress = float(value - minimum) / float(maximum - minimum);
}

template<>
void qRender::DebugMenu::ValueItem<half>::UpdateTexture()
{
	char labelWithValue[LABEL_LENGTH];
	snprintf(labelWithValue, LABEL_LENGTH, "%s %0.4f", label, (float)value);
	FillWithString(texture, [NSString stringWithUTF8String:labelWithValue]);
	fragmentParams.progress = float(value - minimum) / float(maximum - minimum);
}

template<>
void qRender::DebugMenu::ValueItem<float>::UpdateTexture()
{
	char labelWithValue[LABEL_LENGTH];
	snprintf(labelWithValue, LABEL_LENGTH, "%s %0.4f", label, value);
	FillWithString(texture, [NSString stringWithUTF8String:labelWithValue]);
	fragmentParams.progress = float(value - minimum) / float(maximum - minimum);
}

qRender::DebugMenu::EnumItem::EnumItem(const char* _label, unsigned long _itemNumber, Config* _config, int &_value, int _minimum, int _maximum, const char** _names)
: Item( _label, _itemNumber, _config )
, value( _value )
, minimum( _minimum )
, maximum( _maximum )
, names( _names )
{
	UpdateTexture();
}

void qRender::DebugMenu::EnumItem::UpdateTexture()
{
	char labelWithValue[LABEL_LENGTH];
	snprintf(labelWithValue, LABEL_LENGTH, "%s %s", label, names[value]);
	FillWithString(texture, [NSString stringWithUTF8String:labelWithValue]);
	fragmentParams.progress = float(value - minimum) / float(maximum - minimum);
}

void qRender::DebugMenu::EnumItem::HandleTap(CGPoint location, bool fromDrag)
{
	if (fromDrag)
	{
		value = location.x * (maximum - minimum) + minimum;
		value = qRound(value);
	}
	else
	{
		value += (location.x > 0.5f) ? 1 : -1;
	}
	value = std::min(maximum, std::max(minimum, value));
}

void qRender::DebugMenu::FillWithString(Texture* texture, NSString* string)
{
	NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:string];
	NSRange stringRange = NSMakeRange(0, [string length]);
	
#if TARGET_OS_OSX
#define COLOR_CLASS NSColor
#define FONT_CLASS NSFont
#else
#define COLOR_CLASS UIColor
#define FONT_CLASS UIFont
#endif
	
	[attributedString addAttribute:NSForegroundColorAttributeName value:[COLOR_CLASS whiteColor] range:stringRange];
	[attributedString addAttribute:NSBackgroundColorAttributeName value:[COLOR_CLASS clearColor] range:stringRange];
	[attributedString addAttribute:NSFontAttributeName value:[FONT_CLASS fontWithName:@"HelveticaNeue-Light" size:(ITEM_HEIGHT-10.0f)] range:stringRange];
	
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, CGRectMake(0, 0, ITEM_WIDTH, ITEM_HEIGHT));
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
	
	size_t width 				= ITEM_WIDTH;
	size_t height 				= ITEM_HEIGHT;
	size_t bytesPerPixel		= 4;
	size_t bitsPerComponent		= 8;
	size_t bytesPerRow			= width * bytesPerPixel;
	size_t size					= width * height;
	CGColorSpaceRef colorSpace 	= CGColorSpaceCreateDeviceRGB();
	uint32_t bitmapInfo			= kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Host;
	qRGBA8 rawData[size];
	
	CGContextRef context 		= CGBitmapContextCreate((uint8_t*)(&rawData[0]),
														width,
														height,
														bitsPerComponent,
														bytesPerRow,
														colorSpace,
														bitmapInfo);
	
	CTFrameDraw(frame, context);
	
	texture->Fill(rawData);
	
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	CFRelease(frame);
	CGPathRelease(path);
	CFRelease(framesetter);
}

#endif //DEBUG
