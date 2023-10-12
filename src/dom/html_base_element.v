module dom

// https://html.spec.whatwg.org/multipage/semantics.html#htmlbaseelement
pub struct HTMLBaseElement {
	HTMLElement
pub mut:
	href   string
	target string
}

pub fn HTMLBaseElement.new(owner_document &Document) &HTMLBaseElement {
	return &HTMLBaseElement{
		owner_document: owner_document
		tag_name: 'base'
	}
}
