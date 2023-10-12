module dom

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#htmlspanelement
pub struct HTMLSpanElement {
	HTMLElement
}

[inline]
pub fn HTMLSpanElement.new(owner_document &Document) &HTMLSpanElement {
	return &HTMLSpanElement{
		owner_document: owner_document
		tag_name: 'span'
	}
}
