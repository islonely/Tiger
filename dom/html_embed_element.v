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
