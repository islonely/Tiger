module dom

pub const foreign_attrs = ['xlink:actuate', 'xlink:arcrole', 'xlink:href', 'xlink:role', 'xlink:show',
	'xlink:title', 'xlink:type', 'xml:lang', 'xml:space', 'xmlns', 'xmlns:xlink']

// Attribute is an HTML tag attribute.
pub struct Attribute {
	Node
	namespace_uri string
	prefix        string
	local_name    string
	name          string
	value         string
	owner_element ?&ElementInterface
}

// https://html.spec.whatwg.org/multipage/parsing.html#adjust-foreign-attributes
pub fn Attribute.adjusted_foreign(name string, value string) Attribute {
	name_to_split := if name == 'xmlns' {
		':${name}'
	} else {
		name
	}
	split := name_to_split.split(':')
	namespace_uri := match split[0] {
		'xlink' { namespaces[NamespaceURI.xlink] }
		'xml' { namespaces[NamespaceURI.xml] }
		'xmlns' { namespaces[NamespaceURI.xmlns] }
		else { namespaces[NamespaceURI.html] }
	}
	return Attribute{
		namespace_uri: namespace_uri
		prefix:        split[0]
		local_name:    split[1]
		value:         value
	}
}
