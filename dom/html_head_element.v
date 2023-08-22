module dom

// https://html.spec.whatwg.org/multipage/semantics.html#htmlheadelement
pub struct HTMLHeadElement {
	HTMLElement
}

[inline]
pub fn HTMLHeadElement.new(owner_document &Document) &HTMLHeadElement {
	return &HTMLHeadElement{
		owner_document: owner_document
		local_name: 'head'
	}
}
