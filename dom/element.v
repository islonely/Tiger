module dom

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
pub struct Element {
	Node
pub mut:
	prefix     ?string
	local_name string
	tag_name   string
	id         string
	class_name string
	class_list []string
	slot       string
	attributes map[string]string
__global:
	namespace_uri ?string
}

// has_attributes returns whether or not the Element
// has any attributes associated with it.
[inline]
fn (e Element) has_attributes() bool {
	return e.attributes.len > 0
}
