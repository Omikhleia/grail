--- Color conversion and manipulation utilities.
--
-- Caveat:
-- Implemented with the help of a LLM and from various online documentation,
-- but not carefully tested.
-- NO GUARANTEE OF CORRECTNESS, USE WITH CAUTION.
--
-- @license MIT
-- @copyright (c) 2024, 2025, 2026 Didier Willis
-- @module grail.color.utils

--  RGB / HSL CONVERSIONS

-- Converts an RGB (Red, Green, Blue) color to HSL (Hue, Saturation, Lightness)
-- @tparam table color Table with RGB values (r, g, b) in the range 0..1.
-- @treturn number h Hue (0..1)
-- @treturn number s Saturation (0..1)
-- @treturn number l Lightness (0..1)
local function rgbToHsl (color)
  local r, g, b = color.r, color.g, color.b
  local max = math.max(r, g, b)
  local min = math.min(r, g, b)
  local h, s
  local l = (max + min) / 2

  if min == max then
    -- achromatic
    h = 0
    s = 0
  else
    local d = max - min
    s = l > 0.5 and (d / (2 - max - min)) or (d / (max + min))
    if max == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then
      h = (b - r) / d + 2
    else -- max == b
      h = (r - g) / d + 4
    end
    h = h / 6
  end
  return h, s, l
end

--- Helper for Hue to RGB conversion, used in HSL to RGB conversion.
local function hue2rgb (p, q, t)
  if t < 0 then t = t + 1 end
  if t > 1 then t = t - 1 end
  if t < 1/6 then return p + (q - p) * 6 * t end
  if t < 1/2 then return q end
  if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
  return p
end

--- Converts an HSL (Hue, Saturation, Lightness) color to RGB (Red, Green, Blue).
-- @tparam number h Hue (0..1)
-- @tparam number s Saturation (0..1)
-- @tparam number l Lightness (0..1)
-- @treturn table   Table with RGB values (r, g, b) in the range 0..1
local function hslToRgb (h, s, l)
  local r, g, b;

  if s == 0 then
    -- achromatic
    r = l
    g = l
    b = l
  else
    local q = (l < 0.5) and (l * (1 + s)) or (l + s - l * s)
    local p = 2 * l - q
    r = hue2rgb(p, q, h + 1/3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1/3)
  end
  return { r = r, g = g, b = b }
end

-- Darkening and lightening functions based on the Oklab color space

local function clamp(x, min, max)
  if x < min then return min end
  if x > max then return max end
  return x
end

local function cbrt(x)
  if x >= 0 then
    return x ^ (1 / 3)
  else
    return -(-x) ^ (1 / 3)
  end
end

local function srgbToLinear(x)
  x = x / 255
  if x <= 0.04045 then
    return x / 12.92
  end
  return ((x + 0.055) / 1.055) ^ 2.4
end

local function linearToSrgb(x)
  if x <= 0.0031308 then
    x = x * 12.92
  else
    x = 1.055 * (x ^ (1 / 2.4)) - 0.055
  end
  return math.floor(clamp(x, 0, 1) * 255 + 0.5)
end

--- Converts an RGB color to Oklab color space.
--
-- @tparam number r Red component (0..255)
-- @tparam number g Green component (0..255)
-- @tparam number b Blue component (0..255)
-- @treturn number L Lightness (0..1)
-- @treturn number a Green-Red component (-1..1)
-- @treturn number b Blue-Yellow component (-1..1)
local function rgbToOklab(r, g, b)
  r = srgbToLinear(r)
  g = srgbToLinear(g)
  b = srgbToLinear(b)

  local l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
  local m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
  local s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

  l = cbrt(l)
  m = cbrt(m)
  s = cbrt(s)

  return 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
         1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
         0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
end

--- Converts an Oklab color to RGB color space.
--
-- @tparam number L Lightness (0..1)
-- @tparam number a Green-Red component (-1..1)
-- @tparam number b Blue-Yellow component (-1..1)
-- @treturn number r Red component (0..255)
-- @treturn number g Green component (0..255)
-- @treturn number b Blue component (0..255)
local function oklabToRgb(L, a, b)
  local l = L + 0.3963377774 * a + 0.2158037573 * b
  local m = L - 0.1055613458 * a - 0.0638541728 * b
  local s = L - 0.0894841775 * a - 1.2914855480 * b

  l = l * l * l
  m = m * m * m
  s = s * s * s

  local r =  4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
  local g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
  local b2 = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s

  return linearToSrgb(r),
         linearToSrgb(g),
         linearToSrgb(b2)
end

--- Converts an Oklab color to Oklch color space.
--
-- @tparam number L Lightness (0..1)
-- @tparam number a Green-Red component (-1..1)
-- @tparam number b Blue-Yellow component (-1..1)
-- @treturn number L Lightness (0..1)
-- @treturn number C Chroma (0..1)
-- @treturn number h Hue (0..1)
local function oklabToOklch(L, a, b)
  -- Note:
  --  - math.atan2(b, a) in some versions of Lua, which had math.atan(x) only...
  --  - doing it as mat.atan(b / a) works poorly when a is close to zero...
  --  - math.atan(b, a) is now supported, while math.atan2 is removed...
  -- It's shitty as hell and we need the following compatibility tweak.
  -- luacheck: push ignore 143
  local atan2 = math.atan2 or math.atan
  -- luacheck: pop
  local C = math.sqrt(a * a + b * b)
  local h = atan2(b, a)

  return L, C, h
end

--- Converts an Oklch color to Oklab color space.
--
-- @tparam number L Lightness (0..1)
-- @tparam number C Chroma (0..1)
-- @tparam number h Hue (0..1)
-- @treturn number L Lightness (0..1)
-- @treturn number a Green-Red component (-1..1)
-- @treturn number b Blue-Yellow component (-1..1)
local function oklchToOklab(L, C, h)
  local a = C * math.cos(h)
  local b = C * math.sin(h)
  return L, a, b
end

--- Lightens an RGB color by a given amount, with an optional chroma reduction for better perceptual results.
--
-- The chroma reduction (default 0.3) aims to prevent oversaturation when lightening highly saturated colors.
--
-- @tparam number r Red component (0..255)
-- @tparam number g Green component (0..255)
-- @tparam number b Blue component (0..255)
-- @tparam number amount Lightening amount (0..1)
-- @tparam[opt] number chromaReduction chroma reduction factor (0..1)
-- @treturn number r New red component (0..255)
-- @treturn number g New green component (0..255)
-- @treturn number b New blue component (0..255)
local function lightenRgb(r, g, b, amount, chromaReduction)
  chromaReduction = chromaReduction or 0.3
  local L, a, b2 = rgbToOklab(r, g, b)
  local _, C, h = oklabToOklch(L, a, b2)

  -- Increase perceptual lightness toward white
  L = L + (1 - L) * amount
  -- Adapt chroma slightly for stability, especially at high lightness levels
  C = C * (1 - amount * chromaReduction)

  local newL, newA, newB = oklchToOklab(L, C, h)
  return oklabToRgb(newL, newA, newB)
end

--- Darkens an RGB color by a given amount, with an optional chroma reduction for better perceptual results.
--
-- The chroma reduction (default 0.3) aims to prevent oversaturation when darkening highly saturated colors.
--
-- @tparam number r Red component (0..255)
-- @tparam number g Green component (0..255)
-- @tparam number b Blue component (0..255)
-- @tparam number amount Darkening amount (0..1)
-- @tparam[opt] number chromaReduction chroma reduction factor (0..1)
-- @treturn number r New red component (0..255)
-- @treturn number g New green component (0..255)
-- @treturn number b New blue component (0..255)
local function darkenRgb(r, g, b, amount, chromaReduction)
  chromaReduction = chromaReduction or 0.3
  local L, a, b2 = rgbToOklab(r, g, b)
  local _, C, h = oklabToOklch(L, a, b2)

  -- Decrease perceptual lightness toward black
  L = L * (1 - amount)
  -- Adapt chroma slightly for stability, especially at low lightness levels
  C = C * (1 - amount * chromaReduction)

  local newL, newA, newB = oklchToOklab(L, C, h)
  return oklabToRgb(newL, newA, newB)
end

return {
  -- RGB / HSL conversions
  rgbToHsl = rgbToHsl,
  hslToRgb = hslToRgb,
  -- Oklab / Oklch conversions
  oklabToOklch = oklabToOklch,
  oklchToOklab = oklchToOklab,
  rgbToOklab = rgbToOklab,
  oklabToRgb = oklabToRgb,
  -- RGB lightening/darkening
  lightenRgb = lightenRgb,
  darkenRgb = darkenRgb
}
