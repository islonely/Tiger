module viewport

import dom
import gg

// Viewport is the part of the window that the web page is rendered to.
@[heap]
pub struct Viewport {
pub mut:
	context  &gg.Context
	global_x int
	global_y int
	width    int
	height   int
__global:
	// todo: replace default new document with a start page
	document &dom.Document = dom.Document.new()
}

// Viewport.new creates a new Viewport with the given width and height.
pub fn Viewport.new(mut context gg.Context, global_x int, global_y int, width int, height int) &Viewport {
	return &Viewport{
		context:  context
		global_x: global_x
		global_y: global_y
		width:    width
		height:   height
	}
}

pub fn (mut viewport Viewport) draw() {
	lines := viewport.document.to_html().replace('\t', ' '.repeat(4)).split_into_lines()
	for i, line in lines {
		y := viewport.global_y + i * 16
		viewport.context.draw_text(viewport.global_x, y, line)
	}
}
