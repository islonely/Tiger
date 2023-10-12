module dom

// https://html.spec.whatwg.org/multipage/form-elements.html#htmloptgroupelement
pub struct HTMLOptGroupElement {
	HTMLElement
pub mut:
	disabled bool
	label    string
}

[inline]
pub fn HTMLOptGroupElement.new(owner_document &Document) &HTMLOptGroupElement {
	return &HTMLOptGroupElement{
		owner_document: owner_document
		tag_name: 'optgroup'
	}
}
