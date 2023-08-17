module dom

// https://html.spec.whatwg.org/multipage/canvas.html#htmlcanvaselement
pub struct HTMLCanvasElement {
	HTMLElement
pub mut:
	width  u64
	height u64
}
