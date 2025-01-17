module main

import parser
import graphics.window as win

fn main() {
	// src := '<!--test--><!DOCTYPE html><html lang="en-US"><head><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Title name</title></head><body><p>Some paragraph with a <a href="#link">link</a></p></body></html>'.runes()
	// mut p := parser.Parser.from_runes(src)
	mut p := parser.Parser.from_url('https://example.com/')!
	mut doc := p.parse()
	println(doc.pretty_string())
	println(doc.to_html())

	mut window := win.Window.new(document: doc)
	window.run()
}
