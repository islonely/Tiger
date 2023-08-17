module dom

// https://html.spec.whatwg.org/multipage/tables.html#htmltablesectionelement
pub struct HTMLTableSectionElement {
	HTMLElement
pub mut:
	// rows HTMLCollection
	// obsolete
	align   string
	ch      string
	ch_off  string
	v_align string
}
