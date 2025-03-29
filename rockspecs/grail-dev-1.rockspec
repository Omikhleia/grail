rockspec_format = "3.0"
package = "grail"
version = "dev-1"
source = {
  url = "git+https://github.com/Omikhleia/grail.git",
}
description = {
  summary = "A Graphics Intermediate Library",
  detailed = [[
    Grail (A Graphics Intermediate Library) is a small Lua graphics library that lets you draw lines, polygons and curves.
  ]],
  homepage = "https://github.com/Omikhleia/grail",
  license = "MIT",
}
dependencies = {
  "lua >= 5.1",
  "penlight",
  "rough",
}
build = {
  type = "builtin",
  modules = {
    ["grail.renderer"]                                 = "grail/renderer.lua",
    ["grail.renderers.base"]                           = "grail/renderers/base.lua",
    ["grail.renderers.pdf"]                            = "grail/renderers/pdf.lua",

    ["grail.color"]                                    = "grail/color/init.lua",
    ["grail.color.compat"]                             = "grail/color/compat.lua",

    ["grail.painters.default"]                         = "grail/painters/default.lua",
    ["grail.painters.rough"]                           = "grail/painters/rough.lua",

    ["grail.shapes.arc"]                               = "grail/shapes/arc.lua",
  }
}
