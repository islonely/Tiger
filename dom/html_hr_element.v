module dom

// https://html.spec.whatwg.org/multipage/grouping-content.html#htmlhrelement
pub struct HTMLHRElement {
	HTMLElement
pub mut:
	// obsolete
	align    string
	color    string
	no_shade bool
	size     string
	width    string
}
