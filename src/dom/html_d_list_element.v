module dom

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmldlistelement
pub struct HTMLDListElement {
	HTMLElement
pub mut:
	compact bool
}

@[inline]
pub fn HTMLDListElement.new(owner_document &Document) &HTMLDListElement {
	return &HTMLDListElement{
		owner_document: owner_document
		tag_name:       'dl'
	}
}
