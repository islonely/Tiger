module window

import iui as ui
import parser
import dom

// WebView is a rendered view of HTML and CSS.
@[heap; noinit]
pub struct WebView implements ui.Component {
	ui.ScrollView
mut:
	canvas &Canvas
	doc    &dom.Document
}

// WebView.new creates a new instance of WebView from the provided DOM document.
pub fn WebView.new(parent_window &ui.Window, mut doc dom.Document) &WebView {
	mut webview := &WebView{
		canvas: Canvas.new(parent_window)
		doc:    doc
	}
	webview.ScrollView = ui.ScrollView.new(view: webview.canvas)
	webview.canvas.parent = &ui.Component_A(&webview.ScrollView)
	webview.canvas.set_frame(fn [mut webview, mut doc] (mut event ui.DrawEvent) {
		webview.canvas.clear()
		webview.canvas.draw_text(0, 0, doc.text())
	})
	return webview
}

// WebView.from_url creates a new WebView instance from the provied URL.
pub fn WebView.from_url(parent_window &ui.Window, url string) !&WebView {
	mut p := parser.Parser.from_url(url)!
	mut doc := p.parse()
	return WebView.new(parent_window, mut doc)
}
