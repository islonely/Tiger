module dom

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
	mode ShadowRootMode [required]
	delegates_focus bool
	slot_assignment SlotAssignmentMode = .named
}

// https://dom.spec.whatwg.org/#interface-element
pub struct Element {
	Node
pub mut:
	namespace_uri ?string
	prefix        ?string
	local_name    string
	tag_name      string
	id            string
	class_name    string
	class_list    []string
	slot          string
	attributes    map[string]string
}

// has_attributes returns whether or not the Element
// has any attributes associated with it.
[inline]
fn (e Element) has_attributes() bool {
	return e.attributes.len > 0
}
