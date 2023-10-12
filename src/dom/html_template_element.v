module dom

// https://html.spec.whatwg.org/multipage/scripting.html#htmltemplateelement
pub struct HTMLTemplateElement {
	HTMLElement
pub mut:
	content &DocumentFragment = unsafe { nil }
}

[inline]
pub fn HTMLTemplateElement.new(owner_document &Document) &HTMLTemplateElement {
	return &HTMLTemplateElement{
		owner_document: owner_document
		tag_name: 'template'
	}
}
