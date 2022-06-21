module dom

// Attribute represents and HTML attribute (id="someId").
[heap]
struct Attribute {
	AbstractNode
pub mut:
	namespace_uri string
	prefix        string
	local_name    string
	name          string
	owner_element &Element = 0
__global:
	value string
}

pub fn new_attribute(namespace string, prefix string, local_name string, value string, element &Element) &Attribute {
	return &Attribute{AbstractNode{}, namespace, prefix, local_name, if prefix.len == 0 {
		local_name
	} else {
		'$prefix:$local_name'
	}, element, value}
}

pub fn (a &Attribute) get_qualified_name() string {
	return if a.prefix.len == 0 {
		a.local_name
	} else {
		'$a.prefix:$a.local_name'
	}
}
