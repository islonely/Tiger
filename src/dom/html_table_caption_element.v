module dom

// https://html.spec.whatwg.org/multipage/tables.html#htmltablecaptionelement
pub struct HTMLTableCaptionElement {
	HTMLElement
pub mut:
	// obsolete
	align string
}

[inline]
pub fn HTMLTableCaptionElement.new(owner_document &Document) &HTMLTableCaptionElement {
	return &HTMLTableCaptionElement{
		owner_document: owner_document
		tag_name: 'caption'
	}
}
