module dom

// https://html.spec.whatwg.org/multipage/iframe-embed-object.html#htmliframeelement
pub struct HTMLIframeElement {
	HTMLElement
pub mut:
	src              string
	srcdoc           string
	name             string
	sandbox          []string
	allow            string
	allow_fullscreen bool
	width            string
	height           string
	referrer_policy  string
	loading          string
	content_document ?&Document
	// content_window ?&WindowProxy
	// obsolete
	align         string
	scrolling     string
	frame_border  string
	long_desc     string
	margin_height string
	margin_width  string
}

@[inline]
pub fn HTMLIframeElement.new(owner_document &Document) &HTMLIframeElement {
	return &HTMLIframeElement{
		owner_document: owner_document
		tag_name:       'iframe'
	}
}
