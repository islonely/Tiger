module dom

// https://html.spec.whatwg.org/multipage/edits.html#htmlmodelement
pub struct HTMLModElement {
	HTMLElement
pub mut:
	cite      string
	date_time string
}

@[inline]
pub fn HTMLModElement.new(owner_document &Document) &HTMLModElement {
	return &HTMLModElement{
		owner_document: owner_document
		tag_name:       'mod'
	}
}
