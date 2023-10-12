module dom

// https://html.spec.whatwg.org/multipage/form-elements.html#htmlfieldsetelement
pub struct HTMLFieldSetElement {
	HTMLElement
pub mut:
	disabled           bool
	form               ?&HTMLFormElement
	name               string
	@type              string
	elements           map[string]&HTMLElement
	will_validate      bool
	validity           ValidityState
	validation_message string
}

[inline]
pub fn HTMLFieldSetElement.new(owner_document &Document) &HTMLFieldSetElement {
	return &HTMLFieldSetElement{
		owner_document: owner_document
		tag_name: 'fieldset'
	}
}
