module dom

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
struct Node {
	EventTarget
mut:
	node_type      NodeType
	node_name      string
	base_uri       string
	is_connected   bool
	owner_document ?&Document
	parent_node    ?&Node
	parent_element ?&Element
	child_nodes    []&Node
	first_child    ?&Node
	last_child     ?&Node
	prev_sibling   ?&Node
	next_sibling   ?&Node
	node_value     ?string
	text_content   ?string
}

// has_child_nodes returns whether or not the Node has children nodes.
[inline]
fn (n Node) has_child_nodes() bool {
	return n.child_nodes.len > 0
}
