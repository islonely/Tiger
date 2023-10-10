module dom

import strings

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
[heap]
pub struct Document {
	// spec doesn't say this extends Node, but from the language it
	// uses it appears it does?
	Node // GlobalEventHandlers
pub mut:
	doctype      ?&DocumentType
	mode         DocumentMode
	content_type string
	scripting    bool = true
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
	form                      ?&HTMLFormElement
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
pub fn Document.new() &Document {
	// this is stupid imo, but the spec calls for it
	mut doc := &Document{
		node_type: .document
	}
	doc.owner_document = doc
	return doc
}

// has_child_nodes returns whether or not the embedded Node has children.
[inline]
pub fn (doc Document) has_child_nodes() bool {
	return doc.child_nodes.len > 0
}

// append_child adds a node to the embedded Node.
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

// to_html converts a document's element, comment, and text nodes into HTML.
pub fn (mut doc Document) to_html() string {
	mut builder := strings.new_builder(5000)
	if doctype := doc.doctype {
		builder.write_string(doctype.to_html())
	}
	for i in 0 .. doc.child_nodes.len {
		mut child_node := doc.child_nodes[i]
		if mut child_node is Element {
			builder.writeln(child_node.to_html(0))
		} else if mut child_node is CommentNode {
			builder.writeln('<!--${child_node.text}-->')
		}
	}
	return builder.str()
}

// pretty_print prints a pretty list of all the document's descendants.
[inline]
pub fn (doc Document) pretty_print() {
	println(doc.pretty_string())
}

// pretty_string returns the Document as a tree.
[inline]
pub fn (doc Document) pretty_string() string {
	uri := if doc.base_uri != '' { doc.base_uri } else { '<no_uri>' }
	return 'document@${uri}\n' + NodeInterface(doc).recur_pretty_str(1, 2)
}
