module dom

// https://html.spec.whatwg.org/multipage/scripting.html#htmltemplateelement
pub struct HTMLTemplateElement {
	HTMLElement
pub mut:
	content &DocumentFragment
}

[inline]
pub fn HTMLTemplateElement.new(owner_document &Document, doc_fragment &DocumentFragment) &HTMLTemplateElement {
	return &HTMLTemplateElement{
		owner_document: owner_document
		local_name: 'template'
		content: doc_fragment
	}
}
