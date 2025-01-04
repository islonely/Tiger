module dom

// https://html.spec.whatwg.org/multipage/semantics.html#htmlhtmlelement
pub struct HTMLHtmlElement {
	HTMLElement
pub mut:
	// obsolete
	version string
}

@[inline]
pub fn HTMLHtmlElement.new(owner_document &Document) &HTMLHtmlElement {
	return &HTMLHtmlElement{
		owner_document: owner_document
		tag_name:       'html'
		namespace_uri:  namespace['html']
	}
}
