module dom

// https://html.spec.whatwg.org/multipage/embedded-content.html#htmlsourceelement
pub struct HTMLSourceElement {
	HTMLElement
pub mut:
	src    string
	@type  string
	srcset string
	sizes  string
	media  string
	width  u64
	height u64
}
