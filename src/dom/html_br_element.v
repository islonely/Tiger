module dom

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#htmlbrelement
pub struct HTMLBRElement {
	HTMLElement
pub mut:
	// obsolete
	clear string
}

[inline]
pub fn HTMLBRElement.new(owner_document &Document) &HTMLBRElement {
	return &HTMLBRElement{
		owner_document: owner_document
		tag_name: 'br'
	}
}
