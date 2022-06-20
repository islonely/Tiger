module main

import parser
import net.http

fn main() {
	// src := http.get_text('https://example.com/').runes()
	src := '<!DOCTYPE html><html lang="en-US"><head><title>some title</title></head><body><p>a paragraph with these &bullet; things</p></body></html>'.runes()
	mut p := parser.new(src)
	p.run()
}
