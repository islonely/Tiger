module dom

// https://html.spec.whatwg.org/multipage/popover.html#popoverinvokerelement
pub struct PopoverInvokerElement {
pub mut:
	popover_target_element ?&Element
	popover_target_action  string
}
