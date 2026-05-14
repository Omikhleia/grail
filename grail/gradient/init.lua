--- Accessor functions for named gradients.
--
-- @license MIT
-- @copyright (c) 2026 Didier Willis
-- @module grail.gradient

local GrailError = SU and SU.error or error
local Color = require("grail.color")

local GRADIENTS = require("grail.gradient.presets")

local usedGradients = {}

--- Retrieves a gradient specification by name.
--
-- @tparam string name Name of the gradient
-- @treturn Gradient|nil Gradient specification or nil if not found
local function getGradient (name)
  if not usedGradients[name] then
    local gradientFunc = GRADIENTS[name]
    if not gradientFunc then
      return nil
    end
    local stops = pl.tablex.map(function (spot)
      return Color(spot)
    end, gradientFunc())
    local gradientSpec = {
      name = name,
      stops = stops,
      _refcount = 0 -- Internal private field.
    }
    usedGradients[name] = gradientSpec
  end
  return usedGradients[name]
end

--- Registers a new gradient with a given name and a function that returns its color stops.
--
-- @tparam string name Name of the gradient
-- @tparam function lambda Function that returns a list of color stops
local function registerGradient (name, lambda)
  -- Name must not end in digits as we'll use a reference counter to generate unique names
  -- for gradients that are used multiple times.
  if name:match("%d$") then
    GrailError("Gradient name '" .. name .. "' must not end in digits.")
  end
  if GRADIENTS[name] then
    GrailError("Gradient '" .. name .. "' is already defined.")
  end
  GRADIENTS[name] = lambda
end

--- Creates a reference to a named gradient with an optional angle.
--
-- It is used by the path drawing logic, and not intended for direct use by users.
--
-- @tparam string name Name of the gradient
-- @tparam[opt] number angle Angle of the gradient in degrees (default 0)
-- @treturn GradientRef A gradient reference-counted object
local function referenceGradient (name, angle)
  local gradientSpec = getGradient(name)
  if not gradientSpec then
    GrailError("Gradient '" .. name .. "' is not defined.")
  end
  gradientSpec._refcount = gradientSpec._refcount + 1
  local refname = name .. gradientSpec._refcount
  return { name = refname, angle = angle or 0, gradient = gradientSpec }
end

return {
  getGradient = getGradient,
  registerGradient = registerGradient,
  referenceGradient = referenceGradient,
}
