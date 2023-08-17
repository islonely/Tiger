module dom

// https://html.spec.whatwg.org/multipage/semantics.html#htmlbaseelement
pub struct HTMLBaseElement {
	HTMLElement
pub mut:
	href   string
	target string
}
