module dom

// ElementInterfaceStack is an array of ElementInterface references.
// Stack[&ElementInterface]{} seems to be producing an error.
type ElementInterfaceStack = []&ElementInterface

// pop returns the last value added to the ElementInterfaceStack and removes
// said value from the stack or returns none if the stack is empty.
fn (mut stack ElementInterfaceStack) pop() ?&ElementInterface {
	if stack.len > 0 {
		ret := stack.last()
		stack.delete(stack.len - 1)
		return ret
	} else {
		return none
	}
}

// peek returns the last value added to the ElementInterfaceStack
// or returns none if the stack is empty.
fn (mut stack ElementInterfaceStack) peek() ?&ElementInterface {
	return if stack.len > 0 {
		stack.last()
	} else {
		none
	}
}
