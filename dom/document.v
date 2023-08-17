module dom

enum DocumentReadyState {
	loading
	inertactive
	complete
}

enum DocumentVisibilityState {
	visible
	hidden
}

// type HTMLOrSVGScriptElement = HTMLScriptElement | SVGScriptElement

// https://html.spec.whatwg.org/multipage/dom.html#document
pub struct Document {
pub mut:
	location      ?Location
	domain        string
	referrer      string
	cookie        string
	last_modified string
	ready_state   DocumentReadyState
	title         string
	dir           string
	body          ?&HTMLElement
	head ?&HTMLHeadElement
	// images HTMLCollection
	// embeds HTMLCollection
	// plugins HTMLCollection
	// links HTMLCollection
	// forms HTMLCollection
	// scripts HTMLCollection
	// current_script HTMLOrSVGScriptElement
	design_mode      string
	hidden           bool
	visibility_state DocumentVisibilityState
	// onreadystatechange EventHandler
	// onvisibilitychange EventHandler
}
