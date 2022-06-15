--[[
	FontSet demo.
	Tested LÖVE versions: 11.4
--]]

require("demo_test_libs.strict")

love.keyboard.setKeyRepeat(true)

local fontSet = require("font_set")

local translate_y = 0 -- Y scroll

-- Clamps the font scale.
local SCALE_MIN = 0.01
local SCALE_MAX = 16

-- Scale when drawing the canvas to screen.
local demo_canvas_scale = 1

-- Grab some defaults and other system info.
local orig_font = love.graphics.newFont(12)
local gfx_limits = love.graphics.getSystemLimits()

local font_scale = 1.0
local font_pt = 12 -- This is roughly font_scale * 12

local demo_text = "The quick brown fox jumps over the lazy dog\tGAME OVER"

-- The demo renders to a canvas so that we can zoom in and check on per-pixel drawing characteristics.
local canvas
local function reloadCanvas()
	if canvas then
		canvas:release()
		canvas = false
	end
	canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight(), {})
	canvas:setFilter("nearest", "nearest")

	collectgarbage("collect")
	collectgarbage("collect")
end


-- Turn off FontSet's cleaning. We will do cleanup manually after reloading multiple fonts.
fontSet.conf.aggressive_cleanup = false


-- ImageFont Glyph Strings

local i_font_glyphs = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

local glyphs_cp437 =
 "☺☻♥♦♣♠•◘○◙♂♀♪♫☼►◄↕‼¶§▬↨↑↓→←∟↔▲▼" ..
" !\"#$%&'()*+,-./0123456789:;<=>?" ..
"@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_" ..
"`abcdefghijklmnopqrstuvwxyz{|}~⌂" ..
"ÇüéâäàåçêëèïîìÄÅÉæÆôöòûùÿÖÜ¢£¥₧ƒ" ..
"áíóúñÑªº¿⌐¬½¼¡«»░▒▓│┤╡╢╖╕╣║╗╝╜╛┐" ..
"└┴┬├─┼╞╟╚╔╩╦╠═╬╧╨╤╥╙╘╒╓╫╪┘┌█▄▌▐▀" ..
"αßΓπΣσµτΦΘΩδ∞φε∩≡±≥≤⌠⌡÷≈°∙·√ⁿ²■"

local glyphs_math_criminal = " 0123456789abcdef"


-- Reference TTF Fonts.

local ttf_fonts = {}

-- These four were auto-converted TTF versions of the 'term_thick_var' ImageFont.
-- I don't know if I converted them correctly, so I've commented them out here.
-- I used YellowAfterlife's 'Pixel Font Converter!' utility.
--[[
ttf_fonts[ 1] = fontSet.newTrueType("demo_fonts/term_thick_var/term_thick_var.ttf", "normal")
ttf_fonts[ 2] = fontSet.newTrueType("demo_fonts/term_thick_var/term_thick_var.ttf", "light")
ttf_fonts[ 3] = fontSet.newTrueType("demo_fonts/term_thick_var/term_thick_var.ttf", "mono")
ttf_fonts[ 4] = fontSet.newTrueType("demo_fonts/term_thick_var/term_thick_var.ttf", "none")
--]]

ttf_fonts[ 1] = fontSet.newTrueType("demo_fonts/ttf/Quantico-Regular.ttf")
ttf_fonts[ 2] = fontSet.newTrueType("demo_fonts/ttf/TurretRoad-ExtraBold.ttf")
ttf_fonts[ 3] = fontSet.newTrueType("demo_fonts/ttf/NotoSans-Regular.ttf")
ttf_fonts[ 4] = fontSet.newTrueType("demo_fonts/ttf/Oswald-Regular.ttf")
ttf_fonts[ 5] = fontSet.newTrueType("demo_fonts/ttf/RobotoMono-Regular.ttf")
ttf_fonts[ 6] = fontSet.newTrueType("demo_fonts/ttf/SourceSansPro-Regular.ttf")


-- ImageFont sets
local i_fonts = {}

--[[
For the first three rows, we test rendering the fonts in three ways: nearest neighbor, linear, and 4x prescaled + linear.

Only "Terminal Thick, Variable" is displayed in the demo because I'm running out of space to draw things.
--]]

i_fonts[1] = fontSet.newImageFont( {
	{size = 12, src = "demo_fonts/img_sets/term_thick_var_1x1.png"},
	{size = 24, src = "demo_fonts/img_sets/term_thick_var_2x2.png"},
	{size = 36, src = "demo_fonts/img_sets/term_thick_var_3x3.png"},
	{size = 48, src = "demo_fonts/img_sets/term_thick_var_4x4.png"},
	},
	i_font_glyphs
)
i_fonts[2] = fontSet.newImageFont( {{size = 12, src = "demo_fonts/img_sets/term_thick_var_1x1.png"}}, i_font_glyphs)
i_fonts[3] = fontSet.newImageFont( {{size = 12, src = "demo_fonts/img_sets/term_thick_var_1x1.png"}}, i_font_glyphs)
i_fonts[3]:setFilter("nearest", "nearest")

i_fonts[4] = fontSet.newImageFont( {
	{size = 12, src = "demo_fonts/img_sets/term_thin_var_1x1.png"},
	{size = 24, src = "demo_fonts/img_sets/term_thin_var_2x2.png"},
	{size = 36, src = "demo_fonts/img_sets/term_thin_var_3x3.png"},
	{size = 48, src = "demo_fonts/img_sets/term_thin_var_4x4.png"},
	},
	i_font_glyphs
)
i_fonts[5] = fontSet.newImageFont( {{size = 12, src = "demo_fonts/img_sets/term_thin_var_1x1.png"}}, i_font_glyphs)
i_fonts[6] = fontSet.newImageFont( {{size = 12, src = "demo_fonts/img_sets/term_thin_var_1x1.png"}}, i_font_glyphs)
i_fonts[6]:setFilter("nearest", "nearest")

i_fonts[7] = fontSet.newImageFont( {
	{size = 12, src = "demo_fonts/img_sets/microtonal_mono_1x1.png"},
	{size = 24, src = "demo_fonts/img_sets/microtonal_mono_2x2.png"},
	{size = 36, src = "demo_fonts/img_sets/microtonal_mono_3x3.png"},
	{size = 48, src = "demo_fonts/img_sets/microtonal_mono_4x4.png"},
	},
	i_font_glyphs
)
i_fonts[8] = fontSet.newImageFont( {{size = 12, src = "demo_fonts/img_sets/microtonal_mono_1x1.png"}},	i_font_glyphs, 0)
i_fonts[9] = fontSet.newImageFont( {{size = 12, src = "demo_fonts/img_sets/microtonal_mono_1x1.png"}}, i_font_glyphs, 0)
i_fonts[9]:setFilter("nearest", "nearest")

i_fonts[10] = fontSet.newImageFont( {
	{size = 12, src = "demo_fonts/img_sets/dosbox_437_1x1.png"},
	{size = 24, src = "demo_fonts/img_sets/dosbox_437_2x2.png"},
	{size = 36, src = "demo_fonts/img_sets/dosbox_437_3x3.png"},
	{size = 48, src = "demo_fonts/img_sets/dosbox_437_4x4.png"},
	},
	glyphs_cp437
)
i_fonts[11] = fontSet.newImageFont( {{size = 12, src = "demo_fonts/img_sets/dosbox_437_1x1.png"}}, glyphs_cp437)
i_fonts[12] = fontSet.newImageFont( {{size = 12, src = "demo_fonts/img_sets/dosbox_437_1x1.png"}}, glyphs_cp437)
i_fonts[12]:setFilter("nearest", "nearest")

i_fonts[13] = fontSet.newImageFont( {
	{size = 12, src = "demo_fonts/img_sets/microtaller_mono_1x1.png"},
	{size = 24, src = "demo_fonts/img_sets/microtaller_mono_2x2.png"},
	{size = 36, src = "demo_fonts/img_sets/microtaller_mono_3x3.png"},
	{size = 48, src = "demo_fonts/img_sets/microtaller_mono_4x4.png"},
	},
	i_font_glyphs
)
i_fonts[14] = fontSet.newImageFont( {{size = 12, src = "demo_fonts/img_sets/microtaller_mono_1x1.png"}}, i_font_glyphs)
i_fonts[15] = fontSet.newImageFont( {{size = 12, src = "demo_fonts/img_sets/microtaller_mono_1x1.png"}}, i_font_glyphs)
i_fonts[15]:setFilter("nearest", "nearest")

--[[
	This ImageFont is configured to behave similarly to bitmap fonts in the old Windows console, where
	you could choose from a number of completely different sets of raster fonts that implemented the same
	glyphs.

	Manually drawing a full ASCII set at dozens of sizes would practically be a fulltime job, which is
	why this set only has digits and A-to-F, and only 11 sizes.
--]]
i_fonts[16] = fontSet.newImageFont( {
	{size = 5, src = "demo_fonts/img_sets/math_criminal_5pt_1x1.png"},
	{size = 6, src = "demo_fonts/img_sets/math_criminal_6pt_1x1.png"},
	{size = 8, src = "demo_fonts/img_sets/math_criminal_8pt_1x1.png"},
	{size = 9, src = "demo_fonts/img_sets/math_criminal_9pt_1x1.png"},
	{size = 10, src = "demo_fonts/img_sets/math_criminal_10pt_1x1.png"},
	{size = 11, src = "demo_fonts/img_sets/math_criminal_11pt_1x1.png"},
	{size = 12, src = "demo_fonts/img_sets/math_criminal_12pt_1x1.png"},
	{size = 18, src = "demo_fonts/img_sets/math_criminal_18pt_1x1.png"},
	{size = 24, src = "demo_fonts/img_sets/math_criminal_24pt_1x1.png"},
	{size = 48, src = "demo_fonts/img_sets/math_criminal_48pt_1x1.png"},
	{size = 72, src = "demo_fonts/img_sets/math_criminal_72pt_1x1.png"},
	},
	glyphs_math_criminal
)
i_fonts[16]:setScaleMode("fixed") -- <- locks font scale to 1.0
i_fonts[16]:setSelectMode("round")
i_fonts[16]:setExtraSpacing(2)
i_fonts[16]:setLineHeight(1.5)


-- BMFonts.
--[[
	Unless you have a really good reason, I don't recommend generating so many size variations (in this case, 1..72)
	of single BMFonts over just using a TTF. It takes up a lot of disk space relative to what you get. Multi-color
	and detailed BMFonts are another story, but even then, they probably don't require so many size variations.

	The demo is set up like this for testing purposes (as in, testing both FontSet and some BMFont generators.)
--]]
local b_fonts = {}
do
	-- NOTE: The upper-case "T" in this font kind of looks like it's cut off at the top. That's just how the font looks.
	local temp = {}
	for i = 1, 72 do
		temp[i] = {}
		temp[i].size = i
		temp[i].src = "demo_fonts/bmf/clicker_script/clicker_" .. i .. ".fnt"
	end
	b_fonts[1] = fontSet.newBMFont(temp)
	b_fonts[1]:setScaleMode("fixed")
end


do
	local temp = {}
	for i = 1, 72 do
		temp[i] = {}
		temp[i].size = i
		temp[i].src = "demo_fonts/bmf/quantico/quantico_" .. i .. ".fnt"
		i = i + 1
	end
	b_fonts[2] = fontSet.newBMFont(temp)
	b_fonts[2]:setScaleMode("fixed")
end


-- Uncomment to test creating every subset before moving forward.
--[[
for i, ttf in ipairs(ttf_fonts) do
	print("ttf", i)
	ttf:testSubsets()
end
for i, bmf in ipairs(b_fonts) do
	print("bmf", i)
 	bmf:testSubsets()
end
for i, i_font in ipairs(i_fonts) do
	print("i_font", i)
	i_font:testSubsets()
end
--]]


--[[
	Three "views" with different sets of fonts are bound to keyboard keys 1, 2 and 3.
	1 contains the most fonts, 2 is some ImageFonts isolated, and 3 is just BMFonts.
--]]
local set1 = {}
set1.i = {
	i_fonts[3],
	i_fonts[2],
	i_fonts[1],
	i_fonts[16],
}
-- Uncomment to put all loaded ImageFonts into view 1.
--[[
set1.i = {}
for i, i_f in ipairs(i_fonts) do
	set1.i[i] = i_f
end
--]]

set1.t = {}
for i, ttf in ipairs(ttf_fonts) do
	set1.t[i] = ttf
end

set1.b = {}
for i, bmf in ipairs(b_fonts) do
	set1.b[i] = bmf
end

local set2 = {}
set2.i = {
	i_fonts[3],
	i_fonts[2],
	i_fonts[1],
	i_fonts[16],
}
set2.t = {}
set2.b = {}


local set3 = {}
set3.i = {}
set3.t = {}
set3.b = {}
for i, bmf in ipairs(b_fonts) do
	set3.b[i] = bmf
end


local set = set1
local function assignSet1()
	set = set1
end
local function assignSet2()
	set = set2
end
local function assignSet3()
	set = set3
end
assignSet1()


local function updateFonts()
	font_pt = math.max(1, font_scale * 12)

	-- NOTE: TTF newFont() will fail if you try to pass a size less than 1.
	for i, tbl in ipairs(ttf_fonts) do
		tbl:reload(math.max(1, math.floor(font_pt - 0.5)))
	end
	for i, tbl in ipairs(i_fonts) do
		tbl:reload(font_pt)
	end
	for i, tbl in ipairs(b_fonts) do
		tbl:reload(font_pt)
	end

	collectgarbage("collect")
	collectgarbage("collect")
end


function love.load(arguments)
	reloadCanvas()
	updateFonts()
end


function love.resize(w, h)
	reloadCanvas()
end


function love.keypressed(kc, sc)

	if sc == "escape" then
		love.event.quit()

	elseif sc == "up" then
		local scale_move = 1.05
		if love.keyboard.isScancodeDown("lctrl", "rctrl") then
			scale_move = 1.005
		end
		font_scale = math.min(SCALE_MAX, font_scale * scale_move)
		updateFonts()

	elseif sc == "down" then
		local scale_move = 0.95
		if love.keyboard.isScancodeDown("lctrl", "rctrl") then
			scale_move = 0.995
		end
		font_scale = math.max(SCALE_MIN, font_scale * scale_move)
		updateFonts()

	elseif sc == "kp*" or sc == "8" then
		font_scale = math.max(1, math.floor(0.5 + font_scale))
		updateFonts()

	elseif sc == "kp-" then
		font_scale = 1
		updateFonts()

	elseif sc == "pagedown" then
		translate_y = translate_y - 32

	elseif sc == "pageup" then
		translate_y = translate_y + 32

	elseif sc == "1" then
		assignSet1()

	elseif sc == "2" then
		assignSet2()

	elseif sc == "3" then
		assignSet3()

	elseif sc == "-" then
		demo_canvas_scale = math.max(0.125, demo_canvas_scale - 0.125)

	elseif sc == "=" then
		demo_canvas_scale = math.min(64, demo_canvas_scale + 0.125)

	elseif sc == "tab" then
		love.window.setVSync(1 - love.window.getVSync())
	end
end


--function love.update(dt)


function love.draw()
	local lg = love.graphics

	lg.setColor(0.1, 0.1, 0.1, 1.0)
	lg.rectangle("fill", 0, 0, love.graphics.getDimensions())
	lg.setColor(1,1,1,1)
	lg.setFont(orig_font)
	--lg.printf(":o", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")

	lg.setColor(1, 1, 1, 1)
	lg.setBlendMode("alpha", "alphamultiply")

	lg.push("all")

	lg.setCanvas(canvas)

	lg.setColor(0,0,0,1)
	lg.rectangle("fill", 0, 0, canvas:getDimensions())
	lg.setColor(1,1,1,1)

	-- Print ImageFonts
	for i, i_font in ipairs(set.i) do
		local text = demo_text
		-- Test fixed-scale ImageFont set
		if i == 4 then
			text = "0123456789 abcdef"
		end
		local obj, t_scale = i_font:getFont()
		--print(i, "t_scale", t_scale)
		lg.setFont(obj)

		--local xx = math.floor((lg.getWidth()) / 2 - (obj:getWidth(text) * sx) / 2)
		local xx = 32
		local yy = 0

		lg.print(text, xx, yy, 0, t_scale, t_scale)
		lg.translate(0, math.ceil(obj:getHeight() * obj:getLineHeight() * t_scale))
	end

	-- Print TTFs
	for i, t_font in ipairs(set.t) do
		local obj = t_font:getFont()

		lg.setFont(obj)
		lg.print(demo_text, 32, 0)

		lg.translate(0, math.ceil(obj:getHeight() * obj:getLineHeight()))
	end

	-- Print BMFonts
	for i, bmf in ipairs(set.b) do
		local obj, t_scale = bmf:getFont()
		lg.setFont(obj)
		local xx = 32
		local yy = 0

		lg.print(demo_text, xx, yy, 0, t_scale, t_scale)
		lg.translate(0, math.ceil(obj:getHeight() * obj:getLineHeight() * t_scale))
	end

	lg.pop()

	lg.push("all")

	lg.setCanvas()

	lg.scale(demo_canvas_scale)

	lg.setBlendMode("alpha", "premultiplied")
	lg.draw(canvas, 0, translate_y)
	lg.setBlendMode("alpha", "alphamultiply")

	lg.pop()

	-- Print stats
	lg.setColor(0,0,0,0.8)
	lg.rectangle("fill", 0, lg.getHeight() - 96, lg.getWidth(), 96)
	lg.setColor(1,1,1,1)

	lg.setFont(orig_font)
	lg.print("font_scale: " .. font_scale .. "\ncanvas scale: " .. demo_canvas_scale .. "\nFPS: " .. love.timer.getFPS() .. "\nAvgDelta: " .. love.timer.getAverageDelta(), 16, lg.getHeight() - 96)

	-- Print controls
	lg.print("(up/down) change size\n(ctrl+up/ctrl+down) change size, but, like, slower\n(pgup/pgdn) Scroll Y\n(1-3) Change View\n(8/*) Round scale", lg.getWidth() - 488, lg.getHeight() - 96)
	lg.print("(-/=) Scale canvas\n(tab) Toggle VSync", lg.getWidth() - 160, lg.getHeight() - 96)
end

