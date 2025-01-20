module main

import window

fn main() {
	mut app := window.App.new()
	app.open_url('https://example.com')
	app.win.run()
}
