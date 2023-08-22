module dom

// https://html.spec.whatwg.org/multipage/sections.html#htmlbodyelement
pub struct HTMLBodyElement {
	HTMLElement
	// WindowEventHandlers
pub mut:
	// obsolete
	text       string
	link       string
	v_link     string
	a_link     string
	bg_color   string
	background string
}

[inline]
pub fn HTMLBodyElement.new(owner_document &Document) &HTMLBodyElement {
	return &HTMLBodyElement{
		owner_document: owner_document
		local_name: 'body'
	}
}
