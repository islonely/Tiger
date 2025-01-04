module dom

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlmenuelement
pub struct HTMLMenuElement {
	HTMLElement
pub mut:
	// obsolete
	compact bool
}

@[inline]
pub fn HTMLMenuElement.new(owner_document &Document) &HTMLMenuElement {
	return &HTMLMenuElement{
		owner_document: owner_document
		tag_name:       'menu'
	}
}
