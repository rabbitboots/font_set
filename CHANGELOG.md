# FontSet Changelog

## 1.0.1 - 15 June 2022

* Removed MSAA settings from demo (main.lua), and all mentions of it from the readme. With the exception of the version number change, the core library file (font_set.lua) is unaltered from 1.0.0.
  * I had stated that a sufficiently high MSAA setting may smooth out pixel art fonts at non-integral scales with nearest neighbor filtering. On my PC, an MSAA level of 9 caused this effect. But from what I read about MSAA, it seems like it should only affect the edges of triangles. So then, I'm not sure why I'm getting this behavior. Maybe the graphics driver is enabling another form of anti-aliasing as well at this level? Without knowing for sure, I feel it's safer to just remove any mention of it.
* Started changelog.

