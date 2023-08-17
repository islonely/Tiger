module dom

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#htmlanchorelement
struct HTMLAnchorElement {
	HTMLElement
	HTMLHyperlinkElementUtils
pub mut:
	target          string
	download        string
	ping            string
	rel             string
	rel_list        []string
	hreflang        string
	@type           string
	text            string
	referrer_policy string
	// obsolute fields
	coords  string
	charset string
	name    string
	rev     string
	shape   string
}
