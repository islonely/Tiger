module dom

// https://html.spec.whatwg.org/multipage/embedded-content.html#htmlimageelement
pub struct HTMLImageElement {
	HTMLElement
pub mut:
	alt             string
	src             string
	srcset          string
	sizes           string
	cross_origin    ?string
	use_map         string
	is_map          bool
	width           u64
	height          u64
	natural_width   u64
	natural_height  u64
	complete        bool
	current_src     string
	referrer_policy string
	decoding        string
	loading         string
	fetch_priority  string
	// obsolete
	name      string
	lowsrc    string
	align     string
	hspace    u64
	vspace    u64
	long_desc string
	border    string
}

@[inline]
pub fn HTMLImageElement.new(owner_document &Document) &HTMLImageElement {
	return &HTMLImageElement{
		owner_document: owner_document
		tag_name:       'img'
	}
}
