module dom

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmldivelement
pub struct HTMLDivElement {
	HTMLElement
pub mut:
	// obsolete
	align string
}

@[inline]
pub fn HTMLDivElement.new(owner_document &Document) &HTMLDivElement {
	return &HTMLDivElement{
		owner_document: owner_document
		tag_name:       'div'
	}
}
