module window

import parser
import iui as ui

@[heap; noinit]
pub struct App {
pub mut:
	win    &ui.Window
	tabbox &ui.Tabbox
}

// open_url parses the source code from the given URL and opens the content
// in a new tab
pub fn (mut app App) open_url(url string) {
	mut p := parser.Parser.from_url(url) or {
		println('Failed to parse URL: ${err.str()}')
		exit(1)
	}
	mut doc := p.parse()
	mut tab := Tab.new(mut doc)
	app.tabbox.add_child(url, tab.view)
}

// App.new creates a new instance of the App.
pub fn App.new() &App {
	mut app := &App{
		win:    ui.Window.new(
			title:  'Tiger'
			width:  1280
			height: 720
		)
		tabbox: ui.Tabbox.new()
	}
	app.win.set_theme(ui.theme_ocean())

	mut address_bar := ui.TextField.new()
	mut address_bar_panel := ui.Panel.new(
		layout: ui.GridLayout.new(
			cols: 1
			rows: 1
			vgap: 0
		)
	)
	address_bar_panel.add_child(address_bar)

	mut main_panel := ui.Panel.new(
		layout: ui.BorderLayout.new()
	)
	main_panel.add_child_with_flag(address_bar_panel, ui.borderlayout_north)
	main_panel.add_child_with_flag(app.tabbox, ui.borderlayout_center)

	app.win.add_child(main_panel)
	return app
}
