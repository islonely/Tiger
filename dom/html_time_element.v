module dom

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#htmltimeelement
pub struct HTMLTimeElement {
	HTMLElement
pub mut:
	date_time string
}