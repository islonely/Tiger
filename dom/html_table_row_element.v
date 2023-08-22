module dom

// https://html.spec.whatwg.org/multipage/tables.html#htmltablerowelement
pub struct HTMLTableRowElement {
	HTMLElement
pub mut:
	row_index         i64
	section_row_index i64
	// cells HTMLCollection
	// obsolete
	align    string
	ch       string
	ch_off   string
	v_align  string
	bg_color string
}

[inline]
pub fn HTMLTableRowElement.new(owner_document &Document) &HTMLTableRowElement {
	return &HTMLTableRowElement{
		owner_document: owner_document
		local_name: 'tr'
	}
}
