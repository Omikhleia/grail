--- PDF Path renderer class for Grail.
--
-- @license MIT
-- @copyright (c) 2022, 2023, 2026 Didier Willis
-- @module grail.renderers.pdf

local GrailError = SU and SU.error or error
local Grads = require("grail.gradient")
local referenceGradient = Grads.referenceGradient

-- HELPERS

--- Round number to string for output.
--
-- @tparam  number    number    number value
-- @treturn string              rounded value as string
local function _r (number)
  -- Lua 5.3+ formats floats as 1.0 and integers as 1
  -- Also some PDF readers do not like double precision.
  return math.floor(number) == number and tostring(math.floor(number)) or string.format("%.5f", number)
end

--- Builds a PDF graphics color (stroke or fill) from a color (or gradient).
--
-- @tparam  table|nil  Color     Parsed color object
-- @tparam  boolean    stroke    Stroke (true) or fill (false)
-- @tparam  pl.Map     cache     Cache for used gradients in a given drawable
-- @treturn string               PDF graphics color
local function makeColorHelper (color, stroke, cache)
  if not color then
    return "" -- let current color be used
  end
  local colspec
  local colop
  local usedgrad
  if color.r then -- RGB
    colspec = table.concat({ _r(color.r), _r(color.g), _r(color.b) }, " ")
    colop = stroke and "RG" or "rg"
  elseif color.c then -- CMYK
    colspec = table.concat({ _r(color.c), _r(color.m), _r(color.y), _r(color.k) }, " ")
    colop = stroke and "K" or "k"
  elseif color.l then -- Grayscale
    colspec = _r(color.l)
    colop = stroke and "G" or "g"
  elseif color.G then -- Named gradient
    local cached = cache:get(color.G)
    if cached then
      usedgrad = cached
    else
      usedgrad = referenceGradient(color.G, color.angle)
      cache:set(color.G, usedgrad)
    end
    colspec = "/Pattern " .. (stroke and "CS" or "cs") .. " /" .. usedgrad.name
    colop   = stroke and "SCN" or "scn"
  else
    GrailError("Invalid color specification")
  end
  return colspec .. " " .. colop, usedgrad
end

local function opsToPath (drawing, _)  -- drawing, precision
  local path = {}
  for _, item in ipairs(drawing.ops) do
    local data = item.data
    -- NOTE: we currently ignore the decimal precision option
    if item.op == "move" then
      path[#path + 1] = _r(data[1]) .. " " .. _r(data[2]) .. " m"
    elseif item.op == 'bcurveTo' then
      path[#path + 1] = _r(data[1]) .. " " .. _r(data[2]) .. " " .. _r(data[3]) .. " " .. _r(data[4]) .. " " .. _r(data[5]) .. " " .. _r(data[6]) .. " c"
    elseif item.op == "vcurveTo" then
      path[#path + 1] = _r(data[1]) .. " " .. _r(data[2]) .. " " .. _r(data[3]) .. " " .. _r(data[4]) .. " v"
    elseif item.op == "ycurveTo" then
      path[#path + 1] = _r(data[1]) .. " " .. _r(data[2]) .. " " .. _r(data[3]) .. " " .. _r(data[4]) .. " y"
    elseif item.op == "rect" then
      path[#path + 1] = _r(data[1]) .. " " .. _r(data[2]) .. " " .. _r(data[3]) .. " " .. _r(data[4]) .. " re"
    elseif item.op == "lineTo" then
      path[#path + 1] = _r(data[1]) .. " " ..  _r(data[2]) .. " l"
    end
  end
  return table.concat(path, " ")
end

-- PDF PATH RENDERER

local base = require("grail.renderers.base")
local PathRenderer = pl.class(base)

function PathRenderer:draw (drawable, clippable)
  local sets = drawable.sets or {}
  local o = drawable.options
  local precision = drawable.options.fixedDecimalPlaceDigits
  local g = {}
  -- In a given drawable, items may share gradients as they are in the same coordinate space.
  -- Note: the order of gradiens does not matter but pl.OrderedMap() could be nice for easier debugging.
  local cacheGradients = pl.Map()

  for _, drawing in ipairs(sets) do
    local strokeColor, fillColor
    local path = opsToPath(drawing, precision)
    if o.rounded == true then
      path = path .. " 1 J 1 j"
    end
    -- path = stroke only
    if drawing.type == "path" then
      strokeColor = makeColorHelper(o.stroke, true, cacheGradients)
      path = table.concat({
          path,
          strokeColor,
          _r(o.strokeWidth), "w",
          "S"
      }, " ")
    -- fillPath = fill only
    elseif drawing.type == "fillPath" then
      fillColor = makeColorHelper(o.fill, false, cacheGradients)
      path = table.concat({
        path,
        fillColor,
        "f"
      }, " ")
    -- fillSketch = stroke only, using fill color
    elseif drawing.type == "fillSketch" then
      strokeColor = makeColorHelper(o.fill, true, cacheGradients)
      path = table.concat({
        path,
        strokeColor,
        _r(o.strokeWidth), "w",
        "S"
      }, " ")
    -- shape = fill and stroke in one operation
    elseif drawing.type == "shape" then
      strokeColor = makeColorHelper(o.stroke, true, cacheGradients)
      fillColor = makeColorHelper(o.fill, false, cacheGradients)
      path = table.concat({
        path,
        strokeColor,
        fillColor,
        _r(o.strokeWidth), "w",
        "B"
      }, " ")
    else
      GrailError("Unknown drawing type: " .. drawing.type)
    end
    if path then
      g[#g + 1] = path
    end
  end
  local path = table.concat(g, " ")
  if clippable then
    -- Enclose drawing path in a group with the clipping path
    clippable.options = drawable.options
    local clip = opsToPath(clippable.sets[1], precision)
     path = table.concat({
       "q",
       clip, "W n",
       path,
       "Q"
     }, " ")
  end
  return path, cacheGradients:values()
end

return PathRenderer
