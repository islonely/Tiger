module dom

// https://html.spec.whatwg.org/multipage/semantics.html#htmlmetaelement
pub struct HTMLMetaElement {
	HTMLElement
pub mut:
	name       string
	http_equiv string
	content    string
	media      string
	// obsolete
	scheme string
}
