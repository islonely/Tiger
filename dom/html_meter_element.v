module dom

// https://html.spec.whatwg.org/multipage/form-elements.html#htmlmeterelement
pub struct HTMLMeterElement {
	HTMLElement
pub mut:
	value   f64
	min     f64
	max     f64
	low     f64
	high    f64
	optimum f64
	labels  []&Node
}
