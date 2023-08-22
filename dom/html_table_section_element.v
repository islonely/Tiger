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

[inline]
pub fn HTMLTableSectionElement.new(owner_document &Document, name string) &HTMLTableSectionElement {
	return &HTMLTableSectionElement{
		owner_document: owner_document
		local_name: name
	}
}
