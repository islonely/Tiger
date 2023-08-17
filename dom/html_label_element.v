module dom

// https://html.spec.whatwg.org/multipage/forms.html#htmllabelelement
pub struct HTMLLabelElement {
	HTMLElement
pub mut:
	form     ?&HTMLFormElement
	html_for string
	control  ?&HTMLElement
}
