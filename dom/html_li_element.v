module dom

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmllielement
pub struct HTMLLIElement {
	HTMLElement
pub mut:
	value i64
	// obsolete
	@type string
}