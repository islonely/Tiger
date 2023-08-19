module parser

import strings { Builder }
import term

// Used in `fn put` to write specific colors to screen.
const (
	notice  = term.bright_yellow('notice')
	warning = $if windows {
		term.bright_magenta('warning')
	} $else {
		term.rgb(285, 87, 51, 'warning')
	}
	fatal = $if windows {
		term.bright_red('fatal')
	} $else {
		term.rgb(212, 32, 32, 'error')
	}
)

// PrintType is different types of messages that can be
// printed to the screen for auto colorization and prefixing.
// Use none if no color or prefix is desired.
enum PrintType {
	// for printing normal lines; just use println
	@none
	// notice is for printing messages that have no
	// affect on the end user's experience
	notice
	// warning is for printing messages that pertain
	// to something that affects how the program
	// interacts with the end user
	warning
	// fatal is for printing messages that cause the
	// program to exit prematurely
	fatal
}

// PrintParams are the required parameters to print custom
// colorized messages to the terminal.
[params]
struct PrintParams {
	// text to be printed on the screen
	text string [required]
	// println vs print
	newline bool = true
	// print the text or return it as a string instead
	print bool = true
	// notice is something you should know
	// warning is an error that is not fatal
	// error is an error that results in the termination of the program
	typ PrintType = .warning
}

// put prints color messages, warnings, and errors to the
// terminal based on the provided parameters.
fn put(params PrintParams) string {
	subject := match params.typ {
		.@none { params.text }
		.notice { parser.notice + ': ${params.text}' }
		.warning { '' + parser.warning + ': ${params.text}' }
		.fatal { '' + parser.fatal + ': ${params.text}' }
	}
	if !params.print {
		return subject
	}
	if _likely_(params.newline) {
		println(subject)
	} else {
		print(subject)
	}
	return subject
}

// converts a-Z to a-z; no effect on anything else
fn rune_to_lower(r rune) rune {
	return if r >= 0x41 && r <= 0x5a {
		(r + 0x20)
	} else {
		r
	}
}

// builder_contents returns the value of a strings.Builder without
// terminating the builder like strings.Builder.str does.
[inline]
fn builder_contents(bldr Builder) string {
	return bldr.bytestr()
}

// is_surrogate returns whether or not a rune is a surrogate
// character.
[inline]
fn is_surrogate(r rune) bool {
	return if r >= 0xd800 && r <= 0xdfff {
		true
	} else {
		false
	}
}

// is_noncharacter returns whether or not a rune is a noncharacter.
[inline]
fn is_noncharacter(r rune) bool {
	// vfmt off
	return if (r >= 0xfdd0 && r <= 0xfdef) || r in [
		rune(0xfffe), 0xffff, 0x1fffe, 0x1ffff, 0x2fffe,
		0x2ffff, 0x3fffe, 0x3ffff, 0x4fffe, 0x4ffff, 0x5fffe,
		0x5ffff, 0x6fffe, 0x6ffff, 0x7fffe, 0x7ffff, 0x8fffe,
		0x8ffff, 0x9fffe, 0x9ffff, 0xafffe, 0xaffff, 0xbfffe,
		0xbffff, 0xcfffe, 0xcffff, 0xdfffe, 0xdffff, 0xefffe,
		0xeffff, 0xffffe, 0xfffff, 0x10fffe, 0x10ffff
	] {
		true
	} else {
		false
	}
	// vfmt on
}

// is_c0_control returns whether or not a rune is a C0 control
// character.
[inline]
fn is_c0_control(r rune) bool {
	return if r >= 0x0000 && r <= 0x001f {
		true
	} else {
		false
	}
}

// is_control returns whether or not a rune is a control character.
[inline]
fn is_control(r rune) bool {
	return if is_c0_control(r) || (r >= 0x007f && r <= 0x009f) {
		true
	} else {
		false
	}
}
