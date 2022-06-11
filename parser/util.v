module parser

import strings { Builder }

// converts A-Z to a-z; no effect on anything else
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
	return bldr.bytestr() + '\0'
}