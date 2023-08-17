module dom

// https://html.spec.whatwg.org/multipage/sections.html#htmlbodyelement
pub struct HTMLBodyElement {
	HTMLElement
	// WindowEventHandlers
pub mut:
	// obsolete
	text       string
	link       string
	v_link     string
	a_link     string
	bg_color   string
	background string
}
