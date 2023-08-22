module dom

// https://html.spec.whatwg.org/multipage/sections.html#htmlheadingelement
pub struct HTMLHeadingElement {
	HTMLElement
pub mut:
	// obsolete
	align string
}

// size should only be 1 through 6
[inline]
pub fn HTMLHeadingElement.new(owner_document &Document, size int) &HTMLHeadingElement {
	return &HTMLHeadingElement{
		owner_document: owner_document
		local_name: 'h${size}'
	}
}
