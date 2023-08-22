module dom

// https://html.spec.whatwg.org/multipage/interactive-elements.html#htmldialogelement
pub struct HTMLDialogElement {
	HTMLElement
pub mut:
	open         bool
	return_value string
}

[inline]
pub fn HTMLDialogElement.new(owner_document &Document) &HTMLDialogElement {
	return &HTMLDialogElement{
		owner_document: owner_document
		local_name: 'dialog'
	}
}
