module dom

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlquoteelement
pub struct HTMLQuoteElement {
	HTMLElement
pub mut:
	cite string
}