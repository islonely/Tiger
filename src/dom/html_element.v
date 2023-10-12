module dom

type FloatingBoolString = bool | f64 | string

// https://html.spec.whatwg.org/multipage/dom.html#htmlelement
pub struct HTMLElement {
	Node // GlobalEventHandlers
	// ElementContentEditable
	// HTMLOrSVGElement
pub mut:
	// metadata
	title     string
	lang      string
	translate bool
	dir       string

	hidden           ?FloatingBoolString
	inert            bool
	access_key       string
	access_key_label string
	draggable        bool
	spellcheck       bool
	autocapitalize   string
	inner_text       string
	outer_text       string
	popover          ?string
	prefix           ?string
	local_name       string
	tag_name         string
	id               string
	class_name       string
	class_list       []string
	slot             string
	attributes       map[string]string
	namespace_uri    ?string
}

[inline]
pub fn HTMLElement.new(owner_document &Document, name string) &HTMLElement {
	return &HTMLElement{
		owner_document: owner_document
		tag_name: name
		namespace_uri: namespaces[NamespaceURI.html]
	}
}
