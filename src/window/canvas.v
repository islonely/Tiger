module window

import iui as ui
import gg
import gx
import os

// Canvas is a Component that you can draw to as if it was a gg.Context.
@[heap]
pub struct Canvas implements ui.Component {
	ui.Component_A
mut:
	gg &gg.Context
pub mut:
	parent_window &ui.Window
	frame         fn (mut ui.DrawEvent) = fn (mut _ ui.DrawEvent) {}
	bg_color      gx.Color              = gx.white
}

@[params]
pub struct CanvasCfg {
__global:
	bg_color gx.Color = gx.white
}

// Canvas.new creates a new Canvas.
pub fn Canvas.new(parent_window &ui.Window, cfg CanvasCfg) &Canvas {
	mut canvas := &Canvas{
		parent_window: parent_window
		gg:            parent_window.gg
		bg_color:      cfg.bg_color
	}
	return canvas
}

// draw is the function used by the UI to draw a Component to the window.
pub fn (mut canvas Canvas) draw(ctx &ui.GraphicsContext) {
	canvas.set_bounds(canvas.parent.x, canvas.parent.y, canvas.parent.width, canvas.parent.height)
	canvas.Component_A.draw(ctx)
}

// set_frame sets the function which is called on each draw of the Canvas.
pub fn (mut canvas Canvas) set_frame(frame fn (mut ui.DrawEvent)) {
	canvas.frame = frame
	canvas.subscribe_event('draw', frame)
}

// draw_text draws text to the canvas.
pub fn (mut canvas Canvas) draw_text(local_x int, local_y int, text string, cfg gx.TextCfg) {
	font_path := os.resource_abs_path('src/fonts/Times New Roman.ttf')
	canvas.parent_window.set_font(font_path)
	// canvas.gg.draw_text(canvas.x + local_x, canvas.y + local_y, text, cfg)
	canvas.parent_window.graphics_context.draw_text(canvas.x + local_x, canvas.y + local_y,
		text, canvas.parent_window.graphics_context.font, cfg)
}

// clear draws a rectangle over the entire canvas effectively clearing the canvas.
pub fn (mut canvas Canvas) clear() {
	canvas.gg.draw_rect_filled(canvas.parent.x, canvas.parent.y, canvas.parent.width,
		canvas.parent.height, canvas.bg_color)
}
