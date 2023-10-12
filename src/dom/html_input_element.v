module dom

// https://html.spec.whatwg.org/multipage/input.html#htmlinputelement
pub struct HTMLInputElement {
	HTMLElement
	PopoverInvokerElement
pub mut:
	accept          string
	alt             string
	autocomplete    string
	default_checked bool
	checked         bool
	dir_name        string
	disabled        bool
	form            ?&HTMLFormElement
	// files ?file_api.FileList
	form_action      string
	form_enctype     string
	form_method      string
	forn_no_validate bool
	form_target      string
	height           u64
	indeterminate    bool
	list             ?&HTMLDataListElement
	max              string
	max_length       i64
	min              string
	min_length       i64
	multiple         bool
	name             string
	pattern          string
	placeholder      string
	read_only        bool
	required         bool
	size             u64
	src              string
	step             string
	@type            string
	default_value    string
	value            string
	// value_as_date ?object
	value_as_number     f64
	width               u64
	will_validate       bool
	validity            ValidityState
	validation_message  string
	labels              []&Node
	selection_start     ?u64
	selection_end       ?u64
	selection_direction ?string
	// obsolete
	align   string
	use_map string
}

[inline]
pub fn HTMLInputElement.new(owner_document &Document) &HTMLInputElement {
	return &HTMLInputElement{
		owner_document: owner_document
		tag_name: 'input'
	}
}
