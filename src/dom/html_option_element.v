module dom

// https://html.spec.whatwg.org/multipage/form-elements.html#htmloptionelement
pub struct HTMLOptionElement {
	HTMLElement
pub mut:
	disabled         bool
	form             ?&HTMLFormElement
	label            string
	default_selected bool
	selected         bool
	value            string
	text             string
	index            i64
}

[inline]
pub fn HTMLOptionElement.new(owner_document &Document) &HTMLOptionElement {
	return &HTMLOptionElement{
		owner_document: owner_document
		local_name: 'option'
	}
}
