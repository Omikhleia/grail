# grail

[![license](https://img.shields.io/github/license/Omikhleia/grail?label=License)](LICENSE)
[![Luacheck](https://img.shields.io/github/actions/workflow/status/Omikhleia/grail/luacheck.yml?branch=main&label=Luacheck&logo=Lua)](https://github.com/Omikhleia/grail/actions?workflow=Luacheck)
[![Luarocks](https://img.shields.io/luarocks/v/Omikhleia/grail?label=Luarocks&logo=Lua)](https://luarocks.org/modules/Omikhleia/grail)

Grail (A Graphics Intermediate Library) is a small Lua graphics library that lets you draw lines, polygons and curves.

It is born from the author's need to draw such shapes in several advanced modules for the SILE typesetting system.

**Early development**: 
The code still has some dependencies on SILE, but they are planned to be removed in the future.
The API is subject to change, and the library is not yet fully documented.

## Features

TBD

## Installation

Installation relies on the **luarocks** package manager.

To install the latest version, you may use the provided “rockspec”:

```
luarocks install grail
```

The module depends on the `penlight` library and on the `rough` library. The dependencies are installed automatically by luarocks, if not already present.

## Usage

With the `DefaultPainter`:

```lua
local PathRenderer = require("grail.renderer")
local Color = require("grail.color")

local graphics = PathRenderer()
local drawing = graphics:circle(0, 0, 100, {
  fill = Color("#b2524c"),
  stroke = "none",
})
```

With the `RoughPainter` (for sketchy drawings):

```lua
local RoughPainter = require("grail.painters.rough")
local graphics = PathRenderer(RoughPainter())
local drawing = graphics:circle(0, 0, 100, {
  fill = Color("#b2524c"),
  fillStyle = "cross-hatch",
  stroke = Color("#000000"),
  strokeWidth = 0.4
})
```

The returned `drawing` is a string that contains the PDF graphics instructions to draw the shape.

## Historical notes

Most of the initial code was extracted from the author's earlier modules for the SILE typesetting system, notably [**ptable.sile**](https://github.com/Omikhleia/ptable.sile) and [**piecharts.sile**](https://github.com/Omikhleia/piecharts.sile), and made into a standalone module.

Hence, most of the code was already used in production, and was generalized to be used in other contexts and in other modules.

## License

The code and samples in this repository are released under the MIT License, (c) 2025 Omikhleia, Didier Willis.
