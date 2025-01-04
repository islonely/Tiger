module dom

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlolistelement
pub struct HTMLOListElement {
	HTMLElement
pub mut:
	reversed bool
	start    i64
	@type    string
	// obsolete
	compact bool
}

@[inline]
pub fn HTMLOListElement.new(owner_document &Document) &HTMLOListElement {
	return &HTMLOListElement{
		owner_document: owner_document
		tag_name:       'ol'
	}
}
