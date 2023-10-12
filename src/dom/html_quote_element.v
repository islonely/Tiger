module dom

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlquoteelement
pub struct HTMLQuoteElement {
	HTMLElement
pub mut:
	cite string
}

[inline]
pub fn HTMLQuoteElement.new(owner_document &Document) &HTMLQuoteElement {
	return &HTMLQuoteElement{
		owner_document: owner_document
		tag_name: 'quote'
	}
}
