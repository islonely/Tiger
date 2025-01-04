module window

import components
import dom
import gg
import gx
import parser
import viewport

const title = 'Cyberian Tiger'

@[heap; noinit]
pub struct Window {
mut:
	context &gg.Context = unsafe { nil }
pub mut:
	address_bar components.TextField
	// The goal of multiple viewports is to allow for a single window display
	// multiple different views of the same web page. One with normal desktop
	// aspect ratio and size, one with a tablet aspect ratio and size, and one
	// with a phone aspect ratio and size. This is useful for testing how a
	// web page will look on different devices without having to actually
	// switch between devices.
	//
	// Thought about this later, but it would be nice to view two different
	// websites side by side in one tab.
	desktop_viewport &viewport.Viewport = unsafe { nil }
	tablet_viewport  ?&viewport.Viewport
	phone_viewport   ?&viewport.Viewport
}

@[params]
pub struct NewWindowOptions {
__global:
	width      int = 1920
	height     int = 1080
	fullscreen bool
	maximized  bool = true
	document   ?&dom.Document
}

pub fn Window.new(params &NewWindowOptions) &Window {
	mut win := &Window{}
	win.context = gg.new_context(
		width:      if params.width > 0 { params.width } else { 1920 }
		height:     if params.height > 0 { params.height } else { 1080 }
		fullscreen: params.fullscreen
		// maximized: params.maximized
		user_data:    win
		frame_fn:     win.frame
		event_fn:     win.event
		bg_color:     gx.white
		window_title: title
	)
	win.address_bar = components.TextField{
		width: win.width()
		value: 'https://example.com/'
	}
	win.desktop_viewport = &viewport.Viewport{
		context:  mut win.context
		global_x: 0
		global_y: win.address_bar.height
		width:    win.width()
		height:   win.height()
		document: if doc := params.document { doc } else { dom.Document.new() }
	}
	return win
}

pub fn (window Window) width() int {
	return window.context.width
}

pub fn (window Window) height() int {
	return window.context.height
}

// frame is invoked by the context every frame.
pub fn (mut win Window) frame(_ voidptr) {
	win.context.begin()
	win.address_bar.draw(mut win.context)
	win.desktop_viewport.draw()
	win.context.end()
}

pub fn (mut win Window) event(evt &gg.Event, _ voidptr) {
	if evt.typ == .key_down {
		if evt.key_code == .enter {
			mut p := parser.Parser.from_url(win.address_bar.value) or {
				win.address_bar.value = err.msg()
				return
			}
			mut doc := p.parse()
			println(doc.to_html())
			win.desktop_viewport = &viewport.Viewport{
				context:  mut win.context
				global_x: 0
				global_y: win.address_bar.height
				width:    win.width()
				height:   win.height()
				document: doc
			}

			return
		}

		win.address_bar.write_key_code(evt.key_code, win.context.key_modifiers)
	}
}

@[inline]
pub fn (mut win Window) run() {
	win.context.run()
}
