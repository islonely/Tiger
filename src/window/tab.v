module window

import iui as ui
import dom

// Tab is a single web page.
@[heap; noinit]
pub struct Tab {
pub mut:
	view &ui.ScrollView = unsafe { nil }
	doc  &dom.Document
}

// Tab.new creates a new tab from the given DOM.
pub fn Tab.new(mut doc dom.Document) &Tab {
	mut tab := &Tab{
		doc: doc
	}
	tab.view = ui.ScrollView.new(
		view: ui.Textbox.new(lines: doc.to_html().split_into_lines())
	)
	return tab
}
