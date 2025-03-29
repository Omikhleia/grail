# Grail API documentation

The API is not totally stable yet, and is subject to change.

(This being said, the Grail library is already used by the author in several modules for the SILE typesetting system, so the basics will probably remain the same.)

## Painters

The Grail library provides two painters: the **DefaultPainter** and the **RoughPainter** classes.

The **DefaultPainter** is a simple painter that draws shapes with solid colors and shadows.

```lua
local DefaultPainter = require("grail.painters.default")
local painter = DefaultPainter({ ... })
```

The **RoughPainter** is a painter that draws shapes with a sketchy, hand-drawn style. Under the hood, it is based on the [**rough-lua**](https://github.com/Omikhleia/rough-lua) module.

```lua
local RoughPainter = require("grail.painters.rough")
local painter = RoughPainter({ ... })
```

### Constructor

When instantiated, the painter may be passed options, which act as default options for the drawing functions.
These may be overridden by passing a table of options to the said drawing function. See [Drawing options](#drawing-options).

#### `DefaultPainter([options])`

Creates a new DefaultPainter instance.

#### `RoughPainter([options])`

Creates a new RoughPainter instance.

### Methods

Painter methods return a structured representation of the drawing.

The painter instance is not supposed to be used directly, but rather through a **PathRenderer** instance. The later is responsible for converting the drawing to a string that can be used in a PDF document.

## Path renderer

The **PathRenderer** class implements generic drawing functions to create vector graphics.

When instantiated without any painter, it uses the DefaultPainter class

You can instantiate and pass your own DefaultPainter or RoughPainter class to the PathRenderer constructor.

Example:

```lua
local RoughPainter = require("grail.painters.rough")
local PathRenderer = require("grail.renderers.pdf")
local graphics = PathRenderer(RoughPainter())
```

### Constructor

#### `PathRenderer([painter])`

Creates a new PathRenderer instance.

### Methods supported by both painters

#### `line(x1, y1, x2, y2 [, options])`

Draws a line from (x1, y1) to (x2, y2).

#### `rectangle(x, y, width, height [, options])`

Draws a rectangle with the top-left corner at (x, y) with the specified width and height.

#### `ellipse(x, y, width, height [, options])`

Draws an ellipse with the center at (x, y) and the specified width and height.

#### `circle(x, y, diameter [, options])`

Draws a circle with the center at (x, y) and the specified diameter.

#### `arc(x, y, width, height, start, stop, closed [, options])`

Draws an arc described as a section of en ellipse.

The point (x, y) represent sthe center of that ellipse, and width, height are the dimensions of that ellipse.

The start and stop angles are given in radians, and represent the angles of the start and stop points of the arc.

If "closed" is true, lines are drawn to connect the two end points of the arc to the center.

### Methods supported by the DefaultPainter only

#### `rectangleShadow (x, y, width, height, shadowSize [, options])`

Draws the dropped shadow of the corresponding rectangle.

The shadow is an L-shaped shadow, with the shadowSize being the size of the shadow in both directions, as offset from the corresponding rectangle.

#### `roundedRectangle (x, y, width, height, rx, ry [, options])`

Draws a rounded rectangle with the top-left corner at (x, y) with the specified width and height.

The rx and ry parameters are the radii of the rounded corners.

#### `roundedRectangleShadow (x, y, width, height, rx, ry, shadowSize [, options])`

Draws the dropped shadow of a rounded rectangle.

The shadow is an L-shaped rounded shadow, with the shadowSize being the size of the shadow in both directions, as offset from the corresponding rounded rectangle.

#### `curlyBrace (x1, y1, x2, y2, width, thickness, curvyness [, options])`

Draws a curly brace with the top-left corner at (x1, y1) and the bottom-right corner at (x2, y2).

The width defines how far the middle of the curly brace is from the line connecting the two points.

The thickness defines the thickness of the curly brace.

The curvyness defines how much the curly brace is curved. It should be a number between 0.5 and 1, defining how curvy
is the brace: 0.5 is the “normal” value (quite straight) and higher values giving a more “expressive” brace (anything above 0.725 is probably quite useless)

#### `pieSector (x, y, radius, startAngle, arcAngle, ratio [, options])`

Draws a pie sector with the center at (x, y).

A pie sector here is a ring sector inscribed between two circles with the same center and different radii.

The radius corresponds to the outer circle, and the inner circle radius is defined as a ratio of the outer circle radius.

The pie sector starts at a given angle and has a given arc angle size.

For interesting examples using pie sectors, you may want too look at [**piechart.sile**](https://github.com/Omikhleia/piecharts.sile), a pie chart module for the SILE typesetting system.

## Drawing options

Options affect the way shapes are drawn.

### Options common to both painters

#### stroke

Stroke color of the shape. See [Colors](#colors).

#### strokeWidth

Stroke width of the shape.

#### fill

Fill color of the shape. See [Colors](#colors).

#### rounded

Boolean value indicating whether the line caps and joins should be rounded or not.

The curly brace drawing method sets this option to true by default.

### Options specific to the RoughPainter

Astute readers will notice that the options are those from the **rough-lua** module, but let's go through them anyway.

#### roughness

Numerical value indicating how rough the drawing is. A rectangle with the roughness of 0 would be a perfect rectangle. Default value is 1. There is no upper limit to this value, but a value over 10 is mostly useless.

#### bowing

Numerical value indicating how curvy the lines are when drawing a sketch. A value of 0 will cause straight lines. Default value is 1.

#### fillStyle

The name of the fill style to use. The following styles are available:
 - hachure (default)
 - solid
 - zigzag
 - cross-hatch
 - dots
 - dashed
 - zigzag-line

#### fillWeight

The width of the hachure lines. If not set, it defaults to half the strokeWidth.
When using dots styles to fill the shape, this value represents the diameter of the dot.

#### hachureAngle

Numerical value (in degrees) that defines the angle of the hachure lines.

#### hachureGap

Numerical value that defines the average gap, in points, between two hachure lines. Default value of the hachureGap is set to four times the strokeWidth of that shape.

#### dashOffset

When filling a shape using the dashed style, this property indicates the nominal length of dash (in points). If not set, it defaults to the hachureGap value.

#### dashGap

When filling a shape using the dashed style, this property indicates the nominal gap between dashes (in points). If not set, it defaults to the hachureGap value.

#### zigzagOffset

When filling a shape using the zigzag-line style, this property indicates the nominal width of the zig-zag triangle in each line. If not set, it defaults to the hachureGap value.

#### curveStepCount

When drawing ellipses, circles, and arcs, number of points to estimate the shape. Default value is 9.

#### curveFitting

When drawing ellipses, circles, and arcs, how close should the rendered dimensions be when compared to the specified one. Default value is 0.95. A value of 1 will ensure that the dimensions are almost 100% accurate.

#### curveTightness

When drawing ellipses, circles, and arcs, how tight should the curve be.

#### preserveVertices

When randomizing shapes do not randomize locations of the end points. e.g. end points of line or a curve. Boolean value, defaults to false

#### disableMultiStroke

By default, multiple strokes are applied to sketch the shape. Setting this property to true will disable this behavior.

#### disableMultiStrokeFill

By default, multiple strokes are applied to sketch the hachure lines to fill the shape. Setting this property to true will disable this behavior.

#### seed

The seed for the PRNG (Pseudo Random Number Generator) used to randomize the drawing.

## Colors

The Grail library provides a simple naive **Color** class to represent and manipulate colors.

```lua
local Color = require("grail.color")
local col = Color("#4cb252") -- nice greenish color
```

_Note to SILE users:_ when used from SILE, Grail's Color class derives from the `SILE.types.color` class, and thus has all the methods and features of that class.

### Constructor

#### `Color(color)`

Creates a new color instance.

The color parameter can be:
 - a string in the form of a hex color code (e.g. `#4cb252`),
 - a table with the red, green, and blue components of the color in the 0-1 range (e.g. `{r=0.3, g=0.7, b=0.5}`),
 - a table with the cyan, magenta, yellow, and black components of the color in the 0-1 range (e.g. `{c=0.3, m=0.7, y=0.5, k=0}`),
 - a table with a single (grayscale) value in the 0-1 range (e.g. `{l=0.5}`)
 - (_When used from SILE_) other formats supported by the `SILE.types.color` class, including named colors.

### Methods

#### `toHSL()`

Converts the color to HSL (Hue, Saturation, Lightness) values.

```lua
local h, s, l = col:toHSL()
```

#### (Static) `fromHSL(h, s, l)`

Creates a new color instance from HSL values.

```lua
local col = Color.fromHSL(h, s, l)
```
