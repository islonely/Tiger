module dom

import strings

pub const (
	namespaces = ['http://www.w3.org/1999/xhtml', 'http://www.w3.org/1998/Math/MathML',
		'http://www.w3.org/2000/svg', 'http://www.w3.org/1999/xlink',
		'http://www.w3.org/XML/1998/namespace', 'http://www.w3.org/2000/xmlns/']
)

pub enum NamespaceURI {
	html
	mathml
	svg
	xlink
	xml
	xmlns
}

enum SlotAssignmentMode {
	manual
	named
}

enum ShadowRootMode {
	open
	closed
}

[params]
struct ShadowRootInit {
	mode            ShadowRootMode     [required]
	delegates_focus bool
	slot_assignment SlotAssignmentMode = .named
}

// https://dom.spec.whatwg.org/#interface-element
pub interface Element {
	NodeInterface
mut:
	prefix ?string
	local_name string
	tag_name string
	id string
	class_name string
	class_list []string
	slot string
	attributes map[string]string
	namespace_uri ?string
}

// has_attributes returns whether or not the Element
// has any attributes associated with it.
[inline]
fn (e Element) has_attributes() bool {
	return e.attributes.len > 0
}

// to_html converts the element into HTML.
pub fn (mut element Element) to_html(depth int) string {
	mut builder := strings.new_builder(1000)
	builder.write_string('\t'.repeat(depth) + '<${element.local_name}')
	for attribute_name, attribute_value in element.attributes {
		builder.write_string(' ${attribute_name}="${attribute_value}"')
	}
	builder.write_string('>')
	if element.child_nodes.len > 0 {
		builder.writeln('')
		for i in 0 .. element.child_nodes.len {
			mut child_node := element.child_nodes[i]
			if mut child_node is Element {
				builder.write_string(child_node.to_html(depth + 1))
			} else if mut child_node is Text {
				builder.write_string(child_node.data)
			} else if mut child_node is CommentNode {
				builder.write_string('<!--${child_node.text}-->')
			}
		}
		builder.write_string('\t'.repeat(depth))
	}
	builder.writeln('</${element.local_name}>')
	return builder.str()
}
