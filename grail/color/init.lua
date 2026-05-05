--- Grail color class.
--
-- @license MIT
-- @copyright (c) 2024, 2025, 2026 Didier Willis
-- @module grail.color

local base = require("grail.color.compat")
local GrailError = SU and SU.error or error
local Color = pl.class(base)
local utils = require("grail.color.utils")
local rgbToHsl, hslToRgb = utils.rgbToHsl, utils.hslToRgb

-- Converts a color to HSL (Hue, Saturation, Lightness) values.
-- @treturn number h Hue (0..1)
-- @treturn number s Saturation (0..1)
-- @treturn number l Lightness (0..1)
function Color:toHsl ()
  if self.r then
    return rgbToHsl(self)
  end
  if self.k then
    -- First convert CMYK to RGB
    local kr = (1 - self.k)
    return rgbToHsl({
      r = (1 - self.c) * kr,
      g = (1 - self.m) * kr,
      b = (1 - self.y) * kr,
    })
  end
  if self.l then
    -- First convert Grayscale to RGB
    return rgbToHsl({
      r = self.l,
      g = self.l,
      b = self.l,
    })
  end
  if self.G then
    -- Gradients don't convert to HSL
    GrailError("Cannot convert gradient to HSL")
  end

  GrailError("Invalid color specification")
end

--- Static method to create a Color object from HSL values
-- @tparam number h Hue (0..1)
-- @tparam number s Saturation (0..1)
-- @tparam number l Lightness (0..1)
-- @treturn Color A new Color object
function Color.fromHsl (h, s, l)
  return Color(hslToRgb(h, s, l))
end

return Color
