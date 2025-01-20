module dom

import term

const term_colors = [term_red, term_orange, term_yellow, term_green, term_blue, term_violet,
	term_magenta]

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

@[inline]
fn term_red(str string) string {
	return term.rgb(255, 90, 90, str)
}

@[inline]
fn term_orange(str string) string {
	return term.rgb(255, 160, 100, str)
}

@[inline]
fn term_yellow(str string) string {
	return term.rgb(255, 255, 80, str)
}

@[inline]
fn term_green(str string) string {
	return term.rgb(120, 255, 170, str)
}

@[inline]
fn term_blue(str string) string {
	return term.rgb(0, 128, 255, str)
}

@[inline]
fn term_violet(str string) string {
	return term.rgb(160, 100, 255, str)
}

@[inline]
fn term_magenta(str string) string {
	return term.rgb(255, 100, 160, str)
}

@[inline]
fn term_gray(str string) string {
	return term.rgb(170, 170, 170, str)
}
