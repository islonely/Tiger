module main

import parser

fn main() {
	// src := '<!DOCTYPE html><html lang="en-US"><head><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Title name</title></head><body><p>Some paragraph with a <a href="#link">link</a></p></body></html>'.runes()
	// mut p := parser.new(src)
	mut p := parser.new_url('https://example.com/')
	p.parse()
}
