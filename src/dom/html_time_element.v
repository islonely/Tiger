module dom

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#htmltimeelement
pub struct HTMLTimeElement {
	HTMLElement
pub mut:
	date_time string
}

[inline]
pub fn HTMLTimeElement.new(owner_document &Document) &HTMLTimeElement {
	return &HTMLTimeElement{
		owner_document: owner_document
		tag_name: 'time'
	}
}
