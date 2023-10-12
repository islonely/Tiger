module dom

// https://html.spec.whatwg.org/multipage/forms.html#htmllabelelement
pub struct HTMLLabelElement {
	HTMLElement
pub mut:
	form     ?&HTMLFormElement
	html_for string
	control  ?&HTMLElement
}

[inline]
pub fn HTMLLabelElement.new(owner_document &Document) &HTMLLabelElement {
	return &HTMLLabelElement{
		owner_document: owner_document
		tag_name: 'label'
	}
}
