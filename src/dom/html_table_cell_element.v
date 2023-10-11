module dom

// https://html.spec.whatwg.org/multipage/tables.html#htmltablecellelement
pub struct HTMLTableCellElement {
	HTMLElement
pub mut:
	col_span   u64
	row_span   u64
	headers    string
	cell_index i64
	// only conforming for th elements
	scope string
	abbr  string
	// obsolete
	align    string
	axis     string
	height   string
	width    string
	ch       string
	ch_off   string
	no_wrap  bool
	v_align  string
	bg_color string
}

[inline]
pub fn HTMLTableCellElement.new(owner_document &Document) &HTMLTableCellElement {
	return &HTMLTableCellElement{
		owner_document: owner_document
		local_name: 'td'
	}
}
