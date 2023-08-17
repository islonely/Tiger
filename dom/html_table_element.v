module dom

// https://html.spec.whatwg.org/multipage/tables.html#htmltableelement
pub struct HTMLTableElement {
	HTMLElement
pub mut:
	caption ?&HTMLTableCaptionElement
	t_head  ?&HTMLTableSectionElement
	t_foot  ?&HTMLTableSectionElement
	// t_bodies HTMLCollection
	// rows HTMLCollection
	// obsolete
	align        string
	border       string
	frame        string
	rules        string
	summary      string
	width        string
	bg_color     string
	cell_padding string
	cell_spacing string
}
