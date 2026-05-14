--- Grail base color class, compatible superset of `SILE.types.color`.
--
-- Some code derived from SILE, MIT-licensed, The SILE Typesetter
--
-- @license MIT
-- @copyright (c) 2024, 2025, 2026 Didier Willis / The SILE Typesetter
-- @module grail.color.compat

local COLORS = require("grail.color.presets")
local GRADIENTS = require("grail.gradient.presets")
local GrailError = SU and SU.error or error

local color = pl.class({
  -- BEGIN INTERNALLY COMPATIBLE WITH SILE
  type = "color",
  -- RGB
  r = nil,
  g = nil,
  b = nil,
  -- CMYK
  c = nil,
  m = nil,
  y = nil,
  k = nil,
  -- Grayscale
  l = nil,
  -- END INTERNALLY COMPATIBLE WITH SILE
  -- Gradient
  G = nil,
  angle = nil,
})

function color:_init (input)
  local c = type(input) == "string" and self:parse(input) or input
  for k, v in pairs(c) do
      self[k] = v
  end
  return self
end

function color.parse (_, input)
  local r, g, b, c, m, y, k, l
  if not input or type(input) ~= "string" then
    GrailError("Not a color specification string (" .. tostring(input) .. ")")
  end
  input = string.lower(input)
  local named = COLORS[input]
  if named then
    return { r = named[1] / 255, g = named[2] / 255, b = named[3] / 255 }
  end
  local gname, gangle = input:match("^([^%s]+)%s*(%-?%d*)$")
  if gname and GRADIENTS[gname] then
    return { G = gname, angle = tonumber(gangle or 0) or 0 }
  end
  r, g, b = input:match("^#(%x%x)(%x%x)(%x%x)$")
  if r then
    return { r = tonumber("0x" .. r) / 255, g = tonumber("0x" .. g) / 255, b = tonumber("0x" .. b) / 255 }
  end
  r, g, b = input:match("^#(%x)(%x)(%x)$")
  if r then
    return { r = tonumber("0x" .. r) / 15, g = tonumber("0x" .. g) / 15, b = tonumber("0x" .. b) / 15 }
  end
  c, m, y, k = input:match("^(%d+%.?%d*)%s+(%d+%.?%d*)%s+(%d+%.?%d*)%s+(%d+%.?%d*)$")
  if c then
    return { c = tonumber(c) / 255, m = tonumber(m) / 255, y = tonumber(y) / 255, k = tonumber(k) / 255 }
  end
  c, m, y, k = input:match("^(%d+%.?%d*)%%%s+(%d+%.?%d*)%%%s+(%d+%.?%d*)%%%s+(%d+%.?%d*)%%$")
  if c then
    return { c = tonumber(c) / 100, m = tonumber(m) / 100, y = tonumber(y) / 100, k = tonumber(k) / 100 }
  end
  r, g, b = input:match("^(%d+%.?%d*)%s+(%d+%.?%d*)%s+(%d+%.?%d*)$")
  if r then
    return { r = tonumber(r) / 255, g = tonumber(g) / 255, b = tonumber(b) / 255 }
  end
  r, g, b = input:match("^(%d+%.?%d*)%%%s+(%d+%.?%d*)%%%s+(%d+%.?%d*)%%$")
  if r then
    return { r = tonumber(r) / 100, g = tonumber(g) / 100, b = tonumber(b) / 100 }
  end
  l = input:match("^(%d+.?%d*)$")
  if l then
    return { l = tonumber(l) / 255 }
  end
  GrailError("Unparsable color " .. input)
end

function color:toString ()
  if self.r and self.g and self.b then
    return string.format("#%02x%02x%02x", math.floor(self.r * 255), math.floor(self.g * 255), math.floor(self.b * 255))
  end
  if self.c and self.m and self.y and self.k then
    return string.format("%d%% %d%% %d%% %d%%", math.floor(self.c * 100), math.floor(self.m * 100), math.floor(self.y * 100), math.floor(self.k * 100))
  end
  if self.l then
    return string.format("%d", math.floor(self.l * 255))
  end
  if self.G then
    return string.format("%s %d", self.G, self.angle or 0)
  end
  GrailError("Invalid color specification")
end

return color
