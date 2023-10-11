module dom

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#htmldataelement
pub struct HTMLDataElement {
	HTMLElement
pub mut:
	value string
}

[inline]
pub fn HTMLDataElement.new(owner_document &Document) &HTMLDataElement {
	return &HTMLDataElement{
		owner_document: owner_document
		local_name: 'data'
	}
}
