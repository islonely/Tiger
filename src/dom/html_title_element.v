module dom

// https://html.spec.whatwg.org/multipage/semantics.html#htmltitleelement
pub struct HTMLTitleElement {
	HTMLElement
pub mut:
	text string
}

@[inline]
pub fn HTMLTitleElement.new(owner_document &Document, title string) &HTMLTitleElement {
	return &HTMLTitleElement{
		owner_document: owner_document
		tag_name:       'title'
		text:           title
	}
}
