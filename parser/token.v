module parser

import strings { Builder, new_builder }

// Token is all available tokens the tokenizer can emit.
type Token = DoctypeToken | TagToken | CommentToken | CharacterToken | EOFToken

// html returns the HTML code representation of a Token.
fn (tok Token) html() string {
	return match tok {
		CharacterToken { tok.str() }
		CommentToken { tok.html() }
		DoctypeToken { tok.html() }
		TagToken { tok.html() }
		EOFToken { 'EOF' }
	}
}

// According to the HTML spec, doctype missing is distinct from an
// empty string. Since V doesn't have null, we're using this since
// it should never show up in an HTML doctype tag.
//
// https://html.spec.whatwg.org/multipage/parsing.html#tokenization
const doctype_missing = Builder('\0\0\0\0\0\0\0\0'.bytes())

// DoctypeToken represents the occurence of <!DOCTYPE ...> in an
// HTML documents.
struct DoctypeToken {
mut:
	name Builder = doctype_missing
	public_identifier Builder = doctype_missing
	system_identifier Builder = doctype_missing
	force_quirks bool
}

// name gets the contents of DoctypeToken.name string builder.
[inline]
pub fn (tok DoctypeToken) name() string {
	return builder_contents(tok.name)
}

// public_identifier gets the contents of DoctypeToken.public_identifier string builder.
[inline]
pub fn (tok DoctypeToken) public_identifier() string {
	return builder_contents(tok.name)
}

// system_identifier gets the contents of DoctypeToken.system_identifier string builder.
[inline]
pub fn (tok DoctypeToken) system_identifier() string {
	return builder_contents(tok.name)
}

// html returns the HTML code reprensentation of the DoctypeToken.
[inline]
pub fn (tok DoctypeToken) html() string {
	return '<!DOCTYPE $tok.name' + if tok.public_identifier != doctype_missing {'public="$tok.public_identifier()"'} else {''} + if tok.system_identifier != doctype_missing {' system="$tok.system_identifier()"'} else {''} + '>'
}

// TagToken represents the occurence of <tag attribute="value"></tag>
// in an HTML document.
struct TagToken {
	is_start bool = true
mut:
	self_closing bool
	// <blockquote> is the longest (10 characters) HTML tag name.
	name Builder = strings.new_builder(10)
	attributes []Attribute
}

// name gets the contents of TagToken.name string builder.
[inline]
pub fn (tok TagToken) name() string {
	return builder_contents(tok.name)
}

// html returns the HTML code representation of the TagToken.
[inline]
pub fn (tok TagToken) html() string {
	mut bldr := new_builder(100)
	if !tok.is_start {
		return '</' + tok.name() + '>'
	}
	bldr.write_string('<$tok.name()')
	for attr in tok.attributes {
		bldr.write_string(' $attr.name()="$attr.value()"')
	}
	bldr.write_string(if tok.self_closing {' />'} else {'>'})
	return bldr.str()
}

// Attribute represents the occurence of tag attributes in an HTML
// document.
struct Attribute {
mut:
	// onloadedmetadata is the longest (16 characters) vanilla HTML
	// attribute.
	name Builder = strings.new_builder(16)
	value Builder = strings.new_builder(100)
}

// name gets the contents of the Attribute.name string builder.
[inline]
pub fn (attr Attribute) name() string {
	return builder_contents(attr.name)
}

// value gets the content of the Attribute.value string builder.
[inline]
pub fn (attr Attribute) value() string {
	return builder_contents(attr.value)
}

// to_map converts an array of Attribute to a `map[string]string` where
// Attribute.name is the map key and Attribute.value is the map value.
pub fn (attrs []Attribute) to_map() map[string]string {
	mut ret := map[string]string{}
	for a in attrs {
		ret[a.name()] = a.value()
	}
	return ret
}

// CommentToken represents the characters inside a comment in an HTML
// document.
struct CommentToken {
mut:
	data Builder = strings.new_builder(50)
}

// data gets the contents of the CommentToken.data string builder.
[inline]
pub fn (tok CommentToken) data() string {
	return builder_contents(tok.data)
}

// html returns the HTML code representation of the CommentToken.
[inline]
pub fn (tok CommentToken) html() string {
	return '<!--' + builder_contents(tok.data) + '-->'
}

// CharacterToken represents a single character in an HTML document.
type CharacterToken = rune

// string_to_tokens converts a string into an array of CharacterTokens.
fn string_to_tokens(str string) []Token {
	mut toks := []Token{cap: str.runes().len}
	for r in str.runes() {
		toks << CharacterToken(r)
	}
	return toks
}

// NOTE: It makes more sense to me to combine all consecutive
// characters into one token. I assume the spec would've taken
// this into account, but I wrote this just in case I decide
// to use it later.

// // CharacterToken represents consecutive characters in an HTML
// // document.
// struct CharacterToken {
// mut:
// 	data Builder = strings.new_builder(50)
// }

// [inline]
// pub fn (tok CharacterToken) data() string {
// 	return builder_contents(tok.data)
// }

// EOFToken is the token emitted when the end of a file is reached.
struct EOFToken {
	name string = 'EOF'
	mssg string = 'End of file.'
}