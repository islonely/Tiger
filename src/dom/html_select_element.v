module dom

// https://html.spec.whatwg.org/multipage/form-elements.html#htmlselectelement
pub struct HTMLSelectElement {
	HTMLElement
pub mut:
	autocomplete string
	disabled     bool
	form         ?&HTMLFormElement
	multiple     bool
	name         string
	required     bool
	size         u64
	@type        string
	// options HTMLOptionsCollection
	length u64
	// selected_options HTMLCollection
	selected_index     i64
	value              string
	will_validate      bool
	validity           ValidityState
	validation_message string
	labels             []&Node
}

@[inline]
pub fn HTMLSelectElement.new(owner_document &Document) &HTMLSelectElement {
	return &HTMLSelectElement{
		owner_document: owner_document
		tag_name:       'select'
	}
}
