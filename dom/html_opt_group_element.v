module dom

// https://html.spec.whatwg.org/multipage/form-elements.html#htmloptgroupelement
pub struct HTMLOptGroupElement {
	HTMLElement
pub mut:
	disabled bool
	label    string
}
