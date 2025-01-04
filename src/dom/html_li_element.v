module dom

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmllielement
pub struct HTMLLIElement {
	HTMLElement
pub mut:
	value i64
	// obsolete
	@type string
}

@[inline]
pub fn HTMLLIElement.new(owner_document &Document) &HTMLLIElement {
	return &HTMLLIElement{
		owner_document: owner_document
		tag_name:       'li'
	}
}
