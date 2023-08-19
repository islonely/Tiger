module dom

// CommentNode
pub struct CommentNode {
	Node
pub mut:
	text string
}

enum NodeType {
	element = 1
	attributetext
	cdata_section
	entity_reference
	entity
	processing_instruction
	comment
	document
	document_type
	document_fragment
	notation
}

enum DocumentPosition {
	disconnected = 0x01
	preceding = 0x02
	following = 0x04
	contains = 0x08
	contained_by = 0x10
	implementation_specific = 20
}

[params]
struct GetRootNodeOptions {
	composed bool
}

// https://dom.spec.whatwg.org/#node
[heap]
pub interface NodeInterface {
mut:
	node_type      NodeType
	node_name      string
	base_uri       string
	is_connected   bool
	owner_document ?&Document
	parent_node    ?&NodeInterface
	parent_element ?&Element
	child_nodes    []&NodeInterface
	first_child    ?&NodeInterface
	last_child     ?&NodeInterface
	prev_sibling   ?&NodeInterface
	next_sibling   ?&NodeInterface
	node_value     ?string
	text_content   ?string
}

[heap]
pub struct Node {
	// EventTarget
pub mut:
	node_type      NodeType
	node_name      string
	base_uri       string
	is_connected   bool
	owner_document ?&Document
	parent_node    ?&NodeInterface
	parent_element ?&Element
	child_nodes    []&NodeInterface
	first_child    ?&NodeInterface
	last_child     ?&NodeInterface
	prev_sibling   ?&NodeInterface
	next_sibling   ?&NodeInterface
	node_value     ?string
	text_content   ?string
}

// has_child_nodes returns whether or not the Node has children nodes.
[inline]
pub fn (n NodeInterface) has_child_nodes() bool {
	return n.child_nodes.len > 0
}

// this is supposed to return a Node?
pub fn (mut n NodeInterface) append_child(child &NodeInterface) {
	if !n.has_child_nodes() {
		unsafe {
			n.first_child = child
		}
	}
	n.child_nodes << child
}