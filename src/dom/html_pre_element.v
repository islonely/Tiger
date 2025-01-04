module dom

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlpreelement
pub struct HTMLPreElement {
	HTMLElement
pub mut:
	// obsolete
	width i64
}

@[inline]
pub fn HTMLPreElement.new(owner_document &Document) &HTMLPreElement {
	return &HTMLPreElement{
		owner_document: owner_document
		tag_name:       'pre'
	}
}
