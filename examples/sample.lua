pl = require("pl.import_into")() -- needed as global

local PathRenderer = require("grail.renderers.pdf")
local Color = require("grail.color")

-- Sample regular drawing

local renderer1 = PathRenderer()
local drawing1 = renderer1:circle(0, 0, 100, {
  fill = Color("#b2524c"),
  stroke = "none",
})

print("--- Drawing 1 ---")
print(drawing1)

-- Sample drawing with rough style

local RoughPainter = require("grail.painters.rough")
local renderer2 = PathRenderer(RoughPainter())
local drawing2 = renderer2:circle(0, 0, 100, {
  fill = Color("#b2524c"),
  fillStyle = "cross-hatch",
  stroke = Color("#000000"),
  strokeWidth = 0.4
})

print("--- Drawing 2 ---")
print(drawing2)

-- Sample regular drawing with gradient

local drawing3, grads3 = renderer1:circle(0, 0, 100, {
  fill = Color("viridis 90"),
  stroke = "none",
})

print("--- Drawing 3 ---")
print(drawing3)
print("Gradients used in Drawing 3:")
for _, grad in ipairs(grads3) do
  print("  instance name", grad.name, "gradient name", grad.gradient.name, "angle", grad.angle)
end

os.exit(0)
