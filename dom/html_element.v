module dom

type FloatingBoolString = bool | f64 | string

// https://html.spec.whatwg.org/multipage/dom.html#htmlelement
pub struct HTMLElement {
	Element
pub mut:
	// metadata
	title     string
	lang      string
	translate bool
	dir       string

	hidden           ?FloatingBoolString
	inert            bool
	access_key       string
	access_key_label string
	draggable        bool
	spellcheck       bool
	autocapitalize   string
	inner_text       string
	outer_text       string
	popover          ?string
}
