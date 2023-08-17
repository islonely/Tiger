module dom

[params]
struct AssignedNodesOptions {
	flatten bool
}

// https://html.spec.whatwg.org/multipage/scripting.html#htmlslotelement
pub struct HTMLSlotElement {
	HTMLElement
pub mut:
	name string
}