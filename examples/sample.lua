pl = require("pl.import_into")() -- needed as global

local PathRenderer = require("grail.renderers.pdf")
local Color = require("grail.color")

local graphics = PathRenderer()
local drawing1 = graphics:circle(0, 0, 100, {
  fill = Color("#b2524c"),
  stroke = "none",
})

print("--- Drawing 1 ---")
print(drawing1)

local RoughPainter = require("grail.painters.rough")
local rgraphics = PathRenderer(RoughPainter())
local drawing2 = rgraphics:circle(0, 0, 100, {
  fill = Color("#b2524c"),
  fillStyle = "cross-hatch",
  stroke = Color("#000000"),
  strokeWidth = 0.4
})

print("--- Drawing 2 ---")
print(drawing2)
