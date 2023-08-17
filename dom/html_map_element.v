module dom

// https://html.spec.whatwg.org/multipage/image-maps.html#htmlmapelement
pub struct HTMLMapElement {
	HTMLElement
pub mut:
	name string
	// areas HTMLCollection
}