module dom

// https://html.spec.whatwg.org/multipage/obsolete.html#frameset
pub struct HTMLFrameSetElement {
	HTMLElement
pub mut:
	cols string
	rows string
}

[inline]
pub fn HTMLFrameSetElement.new(owner_document &Document) &HTMLFrameSetElement {
	return &HTMLFrameSetElement{
		owner_document: owner_document
		local_name: 'frameset'
	}
}
