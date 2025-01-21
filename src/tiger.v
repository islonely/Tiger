module main

import window

@[console]
fn main() {
	mut app := window.App.new()
	app.open_url('https://example.com')
	app.win.run()
}
