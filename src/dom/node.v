module dom

import strings
import term

// https://infra.spec.whatwg.org/#html-namespace
const namespace = {
	'html':   'http://www.w3.org/1999/xhtml'
	'mathml': 'http://www.w3.org/1998/Math/MathML'
	'svg':    'http://www.w3.org/2000/svg'
	'xlink':  'http://www.w3.org/1999/xlink'
	'xml':    'http://www.w3.org/XML/1998/namespace'
	'xmlns':  'http://www.w3.org/2000/xmlns/'
}

// CommentNode
pub struct CommentNode {
	Node
pub mut:
	text string
}

// new instantiates a CommentNode
pub fn CommentNode.new(owner_document &Document, text string) &CommentNode {
	return &CommentNode{
		owner_document: owner_document
		text:           text
		node_type:      .comment
	}
}

pub enum NodeType {
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

pub enum DocumentPosition {
	disconnected            = 0x01
	preceding               = 0x02
	following               = 0x04
	contains                = 0x08
	contained_by            = 0x10
	implementation_specific = 20
}

@[params]
struct GetRootNodeOptions {
	composed bool
}

// https://dom.spec.whatwg.org/#node
pub interface NodeInterface {
mut:
	node_type      NodeType
	node_name      string
	base_uri       string
	is_connected   bool
	owner_document ?&Document
	parent_node    ?&NodeInterface
	parent_element ?&ElementInterface
	child_nodes    []&NodeInterface
	first_child    ?&NodeInterface
	last_child     ?&NodeInterface
	prev_sibling   ?&NodeInterface
	next_sibling   ?&NodeInterface
	node_value     ?string
	text_content   ?string
}

@[heap]
pub struct Node {
	// EventTarget
pub mut:
	node_type      NodeType
	node_name      string
	base_uri       string
	is_connected   bool
	owner_document ?&Document
	parent_node    ?&NodeInterface
	parent_element ?&ElementInterface
	child_nodes    []&NodeInterface
	first_child    ?&NodeInterface
	last_child     ?&NodeInterface
	prev_sibling   ?&NodeInterface
	next_sibling   ?&NodeInterface
	node_value     ?string
	text_content   ?string
}

// has_child_nodes returns whether or not the Node has children nodes.
@[inline]
pub fn (n NodeInterface) has_child_nodes() bool {
	return n.child_nodes.len > 0
}

// append_child adds a node to the embedded Node.
// this is supposed to return a Node?
pub fn (mut n NodeInterface) append_child(child &NodeInterface) {
	if !n.has_child_nodes() {
		unsafe {
			n.first_child = child
		}
	} else {
		unsafe {
			child.prev_sibling = n.child_nodes[n.child_nodes.len - 1]
		}
	}
	n.child_nodes << child
	unsafe {
		n.last_child = child
	}
}

// text returns the data from the text nodes within the Node.
pub fn (node NodeInterface) text() string {
	mut builder := strings.new_builder(5000)
	for i, child in node.child_nodes {
		text := if child is Text {
			child.data
		} else if child is HTMLElement {
			if child.tag_name in ['style', 'script', 'title'] {
				continue
			}
			node.child_nodes[i].text()
		} else {
			child.text()
		}
		builder.write_string(text)
	}
	return builder.str().trim_space().replace('\n', ' ').replace('\t', ' ').replace('  ',
		' ')
}

// recur_pretty_str creates a pretty list of all the descendants of the node.
fn (n NodeInterface) recur_pretty_str(depth int) string {
	mut bldr := strings.new_builder(n.child_nodes.len * 50)
	for child in n.child_nodes {
		name := if child is ElementInterface {
			mut name_builder := strings.new_builder(200)
			elem_name := term_red(child.tag_name)
			name_builder.write_string(':${elem_name}')
			for attr_name, attr_val in child.attributes {
				name := term_green(attr_name)
				val := term_orange('"${attr_val}"')
				name_builder.write_string('&${name}=${val}')
			}
			name_builder.str()
		} else if child is CommentNode {
			':"${child.text}"'
		} else if child is DocumentType {
			':${child.name}'
		} else if child is Text {
			plaintext := if child.is_whitespace() {
				'<whitespace>'
			} else {
				child.data.replace('\n', ' ').replace('\t', ' ').replace('  ', '')
			}
			text := term_gray('"${plaintext}"')
			':${text}'
		} else {
			':<no_name>'
		}
		prefix := '  '.repeat(depth)
		clr_fn := term_colors[depth % term_colors.len]
		bldr.write_string('${prefix}${clr_fn('|__')}${term.bright_blue(child.node_type.str())}${name}\n')
		bldr.write_string(child.recur_pretty_str(depth + 1))
	}
	return bldr.str()
}
