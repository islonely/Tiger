module dom

// https://html.spec.whatwg.org/multipage/semantics.html#htmlstyleelement
pub struct HTMLStyleElement {
	HTMLElement // LinkStyle
pub mut:
	disabled bool
	media    string
	blocking []string
	// obsolete
	@type string
}

[inline]
pub fn HTMLStyleElement.new(owner_document &Document) &HTMLStyleElement {
	return &HTMLStyleElement{
		owner_document: owner_document
		local_name: 'style'
	}
}
