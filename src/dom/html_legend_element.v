module dom

// https://html.spec.whatwg.org/multipage/form-elements.html#htmllegendelement
pub struct HTMLLegendElement {
	HTMLElement
pub mut:
	form ?&HTMLFormElement
	// obsolete
	align string
}

[inline]
pub fn HTMLLegendElement.new(owner_document &Document) &HTMLLegendElement {
	return &HTMLLegendElement{
		owner_document: owner_document
		local_name: 'legend'
	}
}
