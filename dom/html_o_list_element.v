module dom

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlolistelement
pub struct HTMLOListElement {
	HTMLElement
pub mut:
	reversed bool
	start    i64
	@type    string
	// obsolete
	compact bool
}
