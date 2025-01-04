module dom

// https://html.spec.whatwg.org/multipage/iframe-embed-object.html#htmlobjectelement
pub struct HTMLObjectElement {
	HTMLElement
pub mut:
	data             string
	@type            string
	name             string
	form             ?&HTMLFormElement
	width            string
	height           string
	content_document ?&Document
	// content_window ?&WindowProxy
	will_validate      bool
	validity           ValidityState
	validation_message string
	// obsolete
	align     string
	archive   string
	code      string
	declare   bool
	hspace    u64
	standby   string
	vspace    u64
	code_base string
	code_type string
	use_map   string
	border    string
}

@[inline]
pub fn HTMLObjectElement.new(owner_document &Document) &HTMLObjectElement {
	return &HTMLObjectElement{
		owner_document: owner_document
		tag_name:       'object'
	}
}
