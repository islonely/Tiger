module dom

// https://html.spec.whatwg.org/multipage/scripting.html#htmltemplateelement
pub struct HTMLTemplateElement {
	HTMLElement
pub mut:
	content &DocumentFragment
}