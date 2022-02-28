# qRender
qRender builds on [qMetal](https://github.com/generation-loss/qMetal), to provide the scaffolding of a rendering engine built on Metal.

## Features qRender provides

### Renderable

A class that any renderable object can inherit from, to provide a consistent update and dispatch API

### Subsystem

A class that any rendering subsystem (e.g. shadow map, height map, etc.) can inherit from, to provide a consistent update and dispatch API

### Subsystems

A collection of subsystems that are useful for a rendering engine. First up is a height map, more are to follow

### Render Globals

A blob of globally scoped data that can be shared between code and shaders, and inherited from by any renderee. By default, it includes time and camera data. 

### Camera

A model of a physical camera that supports perspective and isometric views, and includes properties such as ISO, aperture, and shutter speed to translate into exposure values.

### Debug Menu

An on-screen debug menu that supports boolean, integer, and floating point data, with the ability to bind to values within the code base, and manipulate them at run time.
