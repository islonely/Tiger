module dom

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlparagraphelement
pub struct HTMLParagraphElement {
	HTMLElement
pub mut:
	// obsolete
	align string
}

[inline]
pub fn HTMLParagraphElement.new(owner_document &Document) &HTMLParagraphElement {
	return &HTMLParagraphElement{
		owner_document: owner_document
		local_name: 'p'
	}
}
