module dom

// https://html.spec.whatwg.org/multipage/form-elements.html#htmllegendelement
pub struct HTMLLegentElement {
	HTMLElement
pub mut:
	form ?&HTMLFormElement
	// obsolete
	align string
}