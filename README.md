# grail

[![license](https://img.shields.io/github/license/Omikhleia/grail?label=License)](LICENSE)
[![Luacheck](https://img.shields.io/github/actions/workflow/status/Omikhleia/grail/luacheck.yml?branch=main&label=Luacheck&logo=Lua)](https://github.com/Omikhleia/grail/actions?workflow=Luacheck)
[![Luarocks](https://img.shields.io/luarocks/v/Omikhleia/grail?label=Luarocks&logo=Lua)](https://luarocks.org/modules/Omikhleia/grail)

Grail (A Graphics Intermediate Library) is a small Lua graphics library that lets you draw lines, polygons and curves.

It is born from the author's need to draw such shapes in several advanced modules for the SILE typesetting system.

## Features

In a nutshell, Grail allows you to:

- Draw lines, polygons and curves, and more...
- Draw shapes with a "default" regular style or a "sketchy" hand-drawn style...
- ... And generate PDF graphics instructions, for use in PDF authoring systems such as the SILE typesetting system.

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
pl = require("pl.import_into")() -- needed as global

local PathRenderer = require("grail.renderers.pdf")
local Color = require("grail.color")

local graphics = PathRenderer()
local drawing1 = graphics:circle(0, 0, 100, {
  fill = Color("#b2524c"),
  stroke = "none",
})
```

With the `RoughPainter` (for sketchy "hand-drawn" style drawings):

```lua
...
local RoughPainter = require("grail.painters.rough")
local rgraphics = PathRenderer(RoughPainter())
local drawing2 = rgraphics:circle(0, 0, 100, {
  fill = Color("#b2524c"),
  fillStyle = "cross-hatch",
  stroke = Color("#000000"),
  strokeWidth = 0.4
})
```

In both cases, the returned drawing is a string that contains the PDF graphics instructions to draw the shape.

For more details, see [API documentation](./grail/API.md).

## Historical notes

Most of the initial code was extracted from the author's earlier modules for the SILE typesetting system, notably [**ptable.sile**](https://github.com/Omikhleia/ptable.sile) and [**piecharts.sile**](https://github.com/Omikhleia/piecharts.sile), and made into a standalone module.

Hence, most of the code was already used in production, and was generalized to be used in other contexts and in other modules.

## License

The code and samples in this repository are released under the MIT License, (c) 2025 Omikhleia, Didier Willis.
