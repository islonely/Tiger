module dom

// https://html.spec.whatwg.org/multipage/form-elements.html#htmldatalistelement
pub struct HTMLDataListElement {
	HTMLElement
pub mut:
	options map[string]&Element
}

@[inline]
pub fn HTMLDataListElement.new(owner_document &Document) &HTMLDataListElement {
	return &HTMLDataListElement{
		owner_document: owner_document
		tag_name:       'datalist'
	}
}
