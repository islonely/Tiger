module dom

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlulistelement
pub struct HTMLUListElement {
	HTMLElement
pub mut:
	// obsolete
	compact bool
	@type   string
}

[inline]
pub fn HTMLUListElement.new(owner_document &Document) &HTMLUListElement {
	return &HTMLUListElement{
		owner_document: owner_document
		tag_name: 'ul'
	}
}
