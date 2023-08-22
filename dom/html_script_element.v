module dom

// https://html.spec.whatwg.org/multipage/scripting.html#htmlscriptelement
pub struct HTMLScriptElement {
	HTMLElement
pub mut:
	src             string
	@type           string
	no_module       bool
	async           bool
	@defer          bool
	cross_origin    ?string
	text            string
	integrity       string
	referrer_policy string
	blocking        []string
	fetch_priority  string
	// obsolete
	charset  string
	event    string
	html_for string
}

[inline]
pub fn HTMLScriptElement.new(owner_document &Document) &HTMLScriptElement {
	return &HTMLScriptElement{
		owner_document: owner_document
		local_name: 'script'
	}
}
