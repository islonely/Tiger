module dom

// https://html.spec.whatwg.org/multipage/image-maps.html#htmlmapelement
pub struct HTMLMapElement {
	HTMLElement
pub mut:
	name string
	// areas HTMLCollection
}

[inline]
pub fn HTMLMapElement.new(owner_document &Document) &HTMLMapElement {
	return &HTMLMapElement{
		owner_document: owner_document
		tag_name: 'map'
	}
}
