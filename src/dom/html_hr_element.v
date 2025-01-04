module dom

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlhrelement
pub struct HTMLHRElement {
	HTMLElement
pub mut:
	// obsolete
	align    string
	color    string
	no_shade bool
	size     string
	width    string
}

@[inline]
pub fn HTMLHRElement.new(owner_document &Document) &HTMLHRElement {
	return &HTMLHRElement{
		owner_document: owner_document
		tag_name:       'hr'
	}
}
