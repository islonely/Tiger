module dom

// https://html.spec.whatwg.org/multipage/interactive-elements.html#htmldetailselement
pub struct HTMLDetailsElement {
	HTMLElement
pub mut:
	open bool
}

[inline]
pub fn HTMLDetailsElement.new(owner_document &Document) &HTMLDetailsElement {
	return &HTMLDetailsElement{
		owner_document: owner_document
		local_name: 'details'
	}
}
