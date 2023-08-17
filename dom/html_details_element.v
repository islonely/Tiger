module dom

// https://html.spec.whatwg.org/multipage/interactive-elements.html#htmldetailselement
pub struct HTMLDetailsElement {
	HTMLElement
pub mut:
	open bool
}