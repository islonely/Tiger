module dom

// https://html.spec.whatwg.org/multipage/form-elements.html#htmldatalistelement
pub struct HTMLDataListElement {
	HTMLElement
pub mut:
	options map[string]&Element
}