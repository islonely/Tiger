module dom

// https://html.spec.whatwg.org/multipage/tables.html#htmltablecolelement
pub struct HTMLTableColElement {
	HTMLElement
pub mut:
	span u64
	// obsolete
	align   string
	ch      string
	ch_off  string
	v_align string
	width   string
}
