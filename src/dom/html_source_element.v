module dom

// https://html.spec.whatwg.org/multipage/embedded-content.html#htmlsourceelement
pub struct HTMLSourceElement {
	HTMLElement
pub mut:
	src    string
	@type  string
	srcset string
	sizes  string
	media  string
	width  u64
	height u64
}

[inline]
pub fn HTMLSourceElement.new(owner_document &Document) &HTMLSourceElement {
	return &HTMLSourceElement{
		owner_document: owner_document
		tag_name: 'source'
	}
}
