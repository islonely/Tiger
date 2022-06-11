module main

import parser
import net.http

fn main() {
	src := http.get_text('https://example.com/').runes()
	mut p := parser.new(src)
	p.run()
}
