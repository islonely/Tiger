module dom

// https://html.spec.whatwg.org/multipage/form-elements.html#htmlbuttonelement
pub struct HTMLButtonElement {
	HTMLElement // PopoverInvokerElement
pub mut:
	disabled bool
	// form ?&HTMLFormElement
	form_action        string
	form_enctype       string
	form_method        string
	form_no_validate   bool
	form_target        string
	name               string
	@type              string
	value              string
	will_validate      bool
	validity           ValidityState
	validation_message string
	labels             []&Node
}

[inline]
pub fn HTMLButtonElement.new(owner_document &Document) &HTMLButtonElement {
	return &HTMLButtonElement{
		owner_document: owner_document
		local_name: 'button'
	}
}
