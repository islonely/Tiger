module dom

// ElementStack is an array of Element references.
// Stack[&Element]{} seems to be producing an error.
type ElementStack = []&Element

// pop returns the last value added to the ElementStack and removes
// said value from the stack or returns none if the stack is empty.
fn (mut stack ElementStack) pop() ?&Element {
	if stack.len > 0 {
		ret := stack[stack.len-1]
		stack.delete(stack.len-1)
		return ret
	} else {
		return none
	}
}

// peek returns the last value added to the ElementStack
// or returns none if the stack is empty.
fn (mut stack ElementStack) peek() ?&Element {
	return if stack.len > 0 {
		stack[stack.len-1]
	} else {
		none
	}
}