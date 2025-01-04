module dom

pub struct Attribute {
	Node
	namespace_uri string
	prefix        string
	local_name    string
	name          string
	value         string
	owner_element ?&ElementInterface
}
