module dom

// https://html.spec.whatwg.org/multipage/image-maps.html#htmlareaelement
struct HTMLAreaElement {
	HTMLElement
	HTMLHyperlinkElementUtils
pub mut:
	alt             string
	coords          string
	shape           string
	taret           string
	download        string
	ping            string
	rel             string
	rel_list        []string
	referrer_policy string
	// obsolete
	no_href bool
}

pub fn HTMLAreaElement.new(owner_document &Document) &HTMLAreaElement {
	return &HTMLAreaElement{
		owner_document: owner_document
		tag_name: 'area'
	}
}
