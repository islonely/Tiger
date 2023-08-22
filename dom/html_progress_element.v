module dom

// https://html.spec.whatwg.org/multipage/form-elements.html#htmlprogresselement
pub struct HTMLProgressElement {
	HTMLElement
pub mut:
	value    f64
	max      f64
	position f64
	labels   []&Node
}

[inline]
pub fn HTMLProgressElement.new(owner_document &Document) &HTMLProgressElement {
	return &HTMLProgressElement{
		owner_document: owner_document
		local_name: 'progress'
	}
}
