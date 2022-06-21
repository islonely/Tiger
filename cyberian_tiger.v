module main

import parser

fn main() {
	// src := http.get_text('https://example.com/').runes()
	src := '<!DOCTYPE html><html lang="en-US"><head><title>Title name</title></head><body><p>Some paragraph with a <a href="#link">link</a></p></body></html>'.runes()
	mut p := parser.new(src)
	// mut p := parser.new_url('https://example.com/')
	p.parse()
}
