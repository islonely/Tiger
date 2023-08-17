module dom

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#htmldataelement
pub struct HTMLDataElement {
	HTMLElement
pub mut:
	value string
}