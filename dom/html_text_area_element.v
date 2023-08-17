module dom

// https://html.spec.whatwg.org/multipage/form-elements.html#htmltextareaelement
pub struct HTMLTextAreaElement {
	HTMLElement
pub mut:
	autocomplete        string
	cols                u64
	dir_name            string
	disabled            bool
	form                ?&HTMLFormElement
	max_length          i64
	min_length          i64
	name                string
	placeholder         string
	read_only           bool
	required            bool
	rows                u64
	wrap                string
	@type               string
	default_value       string
	value               string
	text_length         u64
	will_validate       bool
	validity            ValidityState
	validation_message  string
	labels              []&Node
	selection_start     u64
	selection_end       u64
	selection_direction string
}
