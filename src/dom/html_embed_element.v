module dom

// https://html.spec.whatwg.org/multipage/iframe-embed-object.html#htmlembedelement
pub struct HTMLEmbedElement {
	HTMLElement
pub mut:
	src    string
	@type  string
	width  string
	height string
	// obsolete
	align string
	name  string
}

@[inline]
pub fn HTMLEmbedElement.new(owner_document &Document) &HTMLEmbedElement {
	return &HTMLEmbedElement{
		owner_document: owner_document
		tag_name:       'embed'
	}
}
