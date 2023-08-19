module dom

pub enum DocumentReadyState {
	loading
	inertactive
	complete
}

pub enum DocumentVisibilityState {
	visible
	hidden
}

pub enum DocumentMode {
	no_quirks
	quirks
	limited_quirks
}

pub enum DocumentFormatType {
	html
	xml
}

// type HTMLOrSVGScriptElement = HTMLScriptElement | SVGScriptElement

// https://html.spec.whatwg.org/multipage/dom.html#document
pub struct Document {
	// spec doesn't say this extends Node, but from the language it
	// uses it appears it does?
	Node // GlobalEventHandlers
pub mut:
	doctype      ?&DocumentType
	mode         DocumentMode
	content_type string
	// url                    URL
	// encoding               Encoding
	// origin                 Origin
	@type                     DocumentFormatType
	parser_cannot_change_mode bool
	location                  ?Location
	domain                    string
	referrer                  string
	cookie                    string
	last_modified             string
	ready_state               DocumentReadyState
	title                     string
	dir                       string
	body                      ?&HTMLElement
	head                      ?&HTMLHeadElement
	// images HTMLCollection
	// embeds HTMLCollection
	// plugins HTMLCollection
	// links HTMLCollection
	// forms HTMLCollection
	// scripts HTMLCollection
	// current_script HTMLOrSVGScriptElement
	design_mode      string
	hidden           bool
	visibility_state DocumentVisibilityState
	// onreadystatechange EventHandler
	// onvisibilitychange EventHandler
	// obsolete
	fg_color    string
	link_color  string
	vlink_color string
	alink_color string
	bg_color    string
}

[inline]
pub fn (doc Document) has_child_nodes() bool {
	return doc.child_nodes.len > 0
}

pub fn (mut doc Document) append_child(child &NodeInterface) {
	if !doc.has_child_nodes() {
		unsafe {
			doc.first_child = child
		}
	}
	doc.child_nodes << child
	unsafe {
		doc.last_child = child
	}
}
