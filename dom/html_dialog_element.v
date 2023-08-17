module dom

// https://html.spec.whatwg.org/multipage/interactive-elements.html#htmldialogelement
pub struct HTMLDialogElement {
	HTMLElement
pub mut:
	open         bool
	return_value string
}
