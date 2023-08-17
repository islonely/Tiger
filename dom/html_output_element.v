module dom

// https://html.spec.whatwg.org/multipage/form-elements.html#htmloutputelement
pub struct HTMLOutputElement {
	HTMLElement
pub mut:
	html_for           []string
	form               ?&HTMLFormElement
	name               string
	@type              string
	default_value      string
	value              string
	will_validate      bool
	validity           ValidityState
	validation_message string
	labels             []&Node
}
