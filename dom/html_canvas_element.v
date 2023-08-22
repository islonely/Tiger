module dom

// https://html.spec.whatwg.org/multipage/canvas.html#htmlcanvaselement
pub struct HTMLCanvasElement {
	HTMLElement
pub mut:
	width  u64
	height u64
}

[inline]
pub fn HTMLCanvasElement.new(owner_document &Document) &HTMLCanvasElement {
	return &HTMLCanvasElement{
		owner_document: owner_document
		local_name: 'canvas'
	}
}
