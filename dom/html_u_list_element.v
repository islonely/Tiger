module dom

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlulistelement
pub struct HTMLUListElement {
	HTMLElement
pub mut:
	// obsolete
	compact bool
	@type   string
}
