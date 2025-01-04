module dom

@[params]
struct AssignedNodesOptions {
	flatten bool
}

// https://html.spec.whatwg.org/multipage/scripting.html#htmlslotelement
pub struct HTMLSlotElement {
	HTMLElement
pub mut:
	name string
}

@[inline]
pub fn HTMLSlotElement.new(owner_document &Document) &HTMLSlotElement {
	return &HTMLSlotElement{
		owner_document: owner_document
		tag_name:       'slot'
	}
}
