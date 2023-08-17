module dom

// https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#validitystate
struct ValidityState {
	value_missing    bool
	type_mismatch    bool
	pattern_mismatch bool
	too_long         bool
	too_short        bool
	range_underflow  bool
	range_overflow   bool
	step_mismatch    bool
	bad_input        bool
	custom_error     bool
	valid            bool
}

// https://html.spec.whatwg.org/multipage/forms.html#htmlformelement
pub struct HTMLFormElement {
	HTMLElement
pub mut:
	accept_charset string
	action         string
	autocomplete   string
	enctype        string
	encoding       string
	method         string
	name           string
	no_validate    bool
	target         string
	rel            string
	rel_list       []string
	// elements HTMLFormControlsCollection
	length u64
}
