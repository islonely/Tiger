module tiger

import datatypes { Stack }
import strings { new_builder }

const null = rune(0)
const replacement_token = CharacterToken(0xfffd)

const whitespace = [rune(0x0009), 0x000a, 0x000c, 0x000d, 0x0020]
const ascii_alpha = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.runes()
const ascii_alphanumeric = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.runes()
const decimal_digits = '0123456789'.runes()
const hex_digits_lower = '0123456789abcdef'.runes()
const hex_digits_upper = '01234566789ABCDEF'.runes()

struct Tokenizer {
	source []rune
mut:
	pos  int
	char rune

	state        TokenizerState = .data
	return_state TokenizerState = .@none

	token         Token = EOFToken{}
	attr          Attribute
	buffer        strings.Builder = new_builder(50)
	open_tags     Stack[string]
	char_ref_code rune
	token_buffer  []Token
}

// https://html.spec.whatwg.org/multipage/parsing.html#tokenization
enum TokenizerState {
	@none
	after_attribute_name
	after_attribute_value_quoted
	after_doctype_name
	after_doctype_public_identifier
	after_doctype_public_keyword
	after_doctype_system_identifier
	after_doctype_system_keyword
	ambiguous_ampersand
	attribute_name
	attribute_value_double_quoted
	attribute_value_single_quoted
	attribute_value_unquoted
	before_attribute_name
	before_attribute_value
	before_doctype_name
	before_doctype_public_identifier
	before_doctype_system_identifier
	between_doctype_public_and_system_identifiers
	bogus_comment
	bogus_doctype
	cdata_section
	cdata_section_bracket
	cdata_section_end
	character_reference
	comment
	comment_end
	comment_end_bang
	comment_end_dash
	comment_less_than_sign
	comment_less_than_sign_bang
	comment_less_than_sign_bang_dash
	comment_less_than_sign_bang_dash_dash
	comment_start
	comment_start_dash
	data
	decimal_character_reference
	decimal_character_reference_start
	doctype
	doctype_name
	doctype_public_identifier_double_quoted
	doctype_public_identifier_single_quoted
	doctype_system_identifier_double_quoted
	doctype_system_identifier_single_quoted
	end_tag_open
	eof
	hexadecimal_character_reference
	hexadecimal_character_reference_start
	markup_declaration_open
	named_character_reference
	numeric_character_reference
	numeric_character_reference_end
	plaintext
	rawtext
	rawtext_end_tag_name
	rawtext_end_tag_open
	rawtext_less_than_sign
	rcdata
	rcdata_end_tag_name
	rcdata_end_tag_open
	rcdata_less_than_sign
	script_data
	script_data_end_tag_name
	script_data_end_tag_open
	script_data_escape_start
	script_data_escape_start_dash
	script_data_escaped
	script_data_escaped_dash
	script_data_escaped_dash_dash
	script_data_escaped_end_tag_name
	script_data_escaped_end_tag_open
	script_data_escaped_less_than_sign
	script_data_double_escape_start
	script_data_double_escaped
	script_data_double_escaped_dash
	script_data_double_escaped_dash_dash
	script_data_double_escaped_less_than_sign
	script_data_double_escape_end
	script_data_less_than_sign
	self_closing_start_tag
	tag_name
	tag_open
}

// reconsume moves the cursor position back one space, so that the
// consume function will not change t.char.
@[inline]
fn (mut t Tokenizer) reconsume() {
	t.pos--
}

// consume returns the next value in buffer and moves the
// cursor forward once.
fn (mut t Tokenizer) consume() ? {
	if t.pos >= t.source.len {
		return none
	}

	t.char = t.source[t.pos]
	t.pos++
}

// peek returns the next value in buffer without moving the cursor.
fn (mut t Tokenizer) peek() ?rune {
	return if t.pos >= t.source.len {
		none
	} else {
		t.source[t.pos]
	}
}

// look_ahead returns the next value in buffer without moving the
// cursor forward.
fn (mut t Tokenizer) look_ahead(look_for string, case_sensitive bool) bool {
	if t.pos + look_for.len > t.source.len - 1 {
		return false
	}

	if case_sensitive {
		if t.source[t.pos..(t.pos + look_for.len)].string() == look_for {
			for _ in 0 .. look_for.len {
				t.consume() or { return false }
			}
			return true
		} else {
			return false
		}
	} else {
		if t.source[t.pos..(t.pos + look_for.len)].string().to_lower() == look_for.to_lower() {
			for _ in 0 .. look_for.len {
				t.consume() or { return false }
			}
			return true
		} else {
			return false
		}
	}
}

// flush_codepoints adds all the characters in the buffer to either the
// current attribute or emits them as CharacterTokens.
fn (mut t Tokenizer) flush_codepoints() []Token {
	if t.return_state in [
		.attribute_value_double_quoted,
		.attribute_value_single_quoted,
		.attribute_value_unquoted,
	] {
		mut tok := &(t.token as TagToken)
		mut attr := &(tok.attributes[tok.attributes.len - 1])
		attr.value.write_string(t.buffer.bytestr())
		return []Token{}
	} else {
		return string_to_tokens(t.buffer.bytestr())
	}
}

// is_token_appropriate_end_tag returns whether or not the current token
// is an end tag that corresponds to the last tag pushed to the open
// tags stack.
fn (mut t Tokenizer) is_token_appropriate_end_tag() bool {
	tag := t.token as TagToken
	if tag.is_start {
		return false
	}

	if start_tag := t.open_tags.peek() {
		return if start_tag == tag.name() {
			true
		} else {
			false
		}
	}

	return false
}

// emit_token returns the next token(s) from the Tokenizer
fn (mut t Tokenizer) emit_token() Token {
	for t.token_buffer.len == 0 {
		t.token_buffer << match t.state {
			.after_attribute_name {
				t.after_attribute_name_state()
			}
			.after_attribute_value_quoted {
				t.after_attribute_value_quoted_state()
			}
			.after_doctype_name {
				t.after_doctype_name_state()
			}
			.after_doctype_public_identifier {
				t.after_doctype_public_identifier_state()
			}
			.after_doctype_public_keyword {
				t.after_doctype_public_keyword_state()
			}
			.after_doctype_system_identifier {
				t.after_doctype_system_identifier_state()
			}
			.after_doctype_system_keyword {
				t.after_doctype_system_keyword_state()
			}
			.ambiguous_ampersand {
				t.ambiguous_ampersand_state()
			}
			.attribute_name {
				t.attribute_name_state()
			}
			.attribute_value_double_quoted {
				t.attribute_value_double_quoted_state()
			}
			.attribute_value_single_quoted {
				t.attribute_value_single_quoted_state()
			}
			.attribute_value_unquoted {
				t.attribute_value_unquoted_state()
			}
			.before_attribute_name {
				t.before_attribute_name_state()
			}
			.before_attribute_value {
				t.before_attribute_value_state()
			}
			.before_doctype_name {
				t.before_doctype_name_state()
			}
			.before_doctype_public_identifier {
				t.before_doctype_public_identifier_state()
			}
			.before_doctype_system_identifier {
				t.before_doctype_system_identifier_state()
			}
			.between_doctype_public_and_system_identifiers {
				t.between_doctype_public_and_system_identifiers_state()
			}
			.bogus_comment {
				t.bogus_comment_state()
			}
			.bogus_doctype {
				t.bogus_doctype_state()
			}
			.cdata_section {
				t.cdata_section_state()
			}
			.cdata_section_bracket {
				t.cdata_section_bracket_state()
			}
			.cdata_section_end {
				t.cdata_section_end_state()
			}
			.character_reference {
				t.character_reference_state()
			}
			.comment {
				t.comment_state()
			}
			.comment_end {
				t.comment_end_state()
			}
			.comment_end_bang {
				t.comment_end_bang_state()
			}
			.comment_end_dash {
				t.comment_end_dash_state()
			}
			.comment_less_than_sign {
				t.comment_less_than_sign_state()
			}
			.comment_less_than_sign_bang {
				t.comment_less_than_sign_bang_state()
			}
			.comment_less_than_sign_bang_dash {
				t.comment_less_than_sign_bang_dash_state()
			}
			.comment_less_than_sign_bang_dash_dash {
				t.comment_less_than_sign_bang_dash_dash_state()
			}
			.comment_start {
				t.comment_start_state()
			}
			.comment_start_dash {
				t.comment_start_dash_state()
			}
			.data {
				t.data_state()
			}
			.decimal_character_reference {
				t.decimal_character_reference_state()
			}
			.decimal_character_reference_start {
				t.decimal_character_reference_start_state()
			}
			.doctype {
				t.doctype_state()
			}
			.doctype_name {
				t.doctype_name_state()
			}
			.doctype_public_identifier_double_quoted {
				t.doctype_public_identifier_double_quoted_state()
			}
			.doctype_public_identifier_single_quoted {
				t.doctype_public_identifier_single_quoted_state()
			}
			.doctype_system_identifier_double_quoted {
				t.doctype_system_identifier_double_quoted_state()
			}
			.doctype_system_identifier_single_quoted {
				t.doctype_system_identifier_single_quoted_state()
			}
			.end_tag_open {
				t.end_tag_open_state()
			}
			.hexadecimal_character_reference {
				t.hexadecimal_character_reference_state()
			}
			.hexadecimal_character_reference_start {
				t.hexadecimal_character_reference_start_state()
			}
			.markup_declaration_open {
				t.markup_declaration_open_state()
			}
			.named_character_reference {
				t.named_character_reference_state()
			}
			.numeric_character_reference {
				t.numeric_character_reference_state()
			}
			.numeric_character_reference_end {
				t.numeric_character_reference_end_state()
			}
			.plaintext {
				t.plaintext_state()
			}
			.rawtext {
				t.rawtext_state()
			}
			.rawtext_end_tag_name {
				t.rawtext_end_tag_name_state()
			}
			.rawtext_end_tag_open {
				t.rawtext_end_tag_open_state()
			}
			.rawtext_less_than_sign {
				t.rawtext_less_than_sign_state()
			}
			.rcdata {
				t.rcdata_state()
			}
			.rcdata_end_tag_name {
				t.rcdata_end_tag_name_state()
			}
			.rcdata_end_tag_open {
				t.rcdata_end_tag_open_state()
			}
			.rcdata_less_than_sign {
				t.rcdata_less_than_sign_state()
			}
			.script_data {
				t.script_data_state()
			}
			.script_data_end_tag_name {
				t.script_data_end_tag_name_state()
			}
			.script_data_end_tag_open {
				t.script_data_end_tag_open_state()
			}
			.script_data_escape_start {
				t.script_data_escape_start_state()
			}
			.script_data_escape_start_dash {
				t.script_data_escape_start_dash_state()
			}
			.script_data_escaped {
				t.script_data_escaped_state()
			}
			.script_data_escaped_dash {
				t.script_data_escaped_dash_state()
			}
			.script_data_escaped_dash_dash {
				t.script_data_escaped_dash_dash_state()
			}
			.script_data_escaped_end_tag_name {
				t.script_data_escaped_end_tag_name_state()
			}
			.script_data_escaped_end_tag_open {
				t.script_data_escaped_end_tag_open_state()
			}
			.script_data_escaped_less_than_sign {
				t.script_data_escaped_less_than_sign_state()
			}
			.script_data_double_escape_start {
				t.script_data_double_escape_start_state()
			}
			.script_data_double_escaped {
				t.script_data_double_escaped_state()
			}
			.script_data_double_escaped_dash {
				t.script_data_double_escaped_dash_state()
			}
			.script_data_double_escaped_dash_dash {
				t.script_data_double_escaped_dash_dash_state()
			}
			.script_data_double_escaped_less_than_sign {
				t.script_data_double_escaped_less_than_sign_state()
			}
			.script_data_double_escape_end {
				t.script_data_double_escape_end_state()
			}
			.script_data_less_than_sign {
				t.script_data_less_than_sign_state()
			}
			.self_closing_start_tag {
				t.self_closing_start_tag_state()
			}
			.tag_name {
				t.tag_name_state()
			}
			.tag_open {
				t.tag_open_state()
			}
			else {
				println('State not implemented (${t.state}).')
				[]Token{}
			}
		}
	}

	tok := t.token_buffer.first()
	t.token_buffer.delete(0)
	return tok
}

// data_state follows the spec 13.2.5.1 at https://html.spec.whatwg.org/multipage/parsing.html#data-state
fn (mut t Tokenizer) data_state() []Token {
	t.consume() or {
		t.state = .eof
		return [EOFToken{}]
	}

	if t.char == `&` {
		t.return_state = .data
		t.state = .character_reference
		return t.character_reference_state()
	}

	if t.char == `<` {
		t.state = .tag_open
		return t.tag_open_state()
	}

	if t.char == null {
		// parse error: unexpected null character
		println('Unexpected Null Character')
	}

	return [CharacterToken(t.char)]
}

// rcdata_state follows the spec 13.2.5.2 at https://html.spec.whatwg.org/multipage/parsing.html#rcdata-state
fn (mut t Tokenizer) rcdata_state() []Token {
	t.consume() or {
		t.state = .eof
		return [EOFToken{}]
	}

	if t.char == `&` {
		t.return_state = .rcdata
		t.state = .character_reference
		return t.character_reference_state()
	}

	if t.char == `<` {
		t.state = .rcdata_less_than_sign
		return t.rcdata_less_than_sign_state()
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		return [replacement_token]
	}

	return [CharacterToken(t.char)]
}

// rawtext_state follows the spec 13.2.5.3 at https://html.spec.whatwg.org/multipage/parsing.html#rawtext-state
fn (mut t Tokenizer) rawtext_state() []Token {
	t.consume() or {
		t.state = .eof
		return [EOFToken{}]
	}

	if t.char == `<` {
		t.state = .rawtext_less_than_sign
		return t.rawtext_less_than_sign_state()
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		return [replacement_token]
	}

	return [CharacterToken(t.char)]
}

// script_data_state follows the spec 13.2.5.4 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-state
fn (mut t Tokenizer) script_data_state() []Token {
	t.consume() or {
		t.state = .eof
		return [EOFToken{}]
	}

	if t.char == `<` {
		t.state = .script_data_less_than_sign
		return t.script_data_less_than_sign_state()
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		return [replacement_token]
	}

	return [CharacterToken(t.char)]
}

// plaintext_state follows the spec 13.2.5.5 at https://html.spec.whatwg.org/multipage/parsing.html#plaintext-state
fn (mut t Tokenizer) plaintext_state() []Token {
	t.consume() or {
		t.state = .eof
		return [EOFToken{}]
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		return [replacement_token]
	}

	return [CharacterToken(t.char)]
}

// tag_open_state follows the spec 13.2.5.6 at https://html.spec.whatwg.org/multipage/parsing.html#tag-open-state
fn (mut t Tokenizer) tag_open_state() []Token {
	t.consume() or {
		println(ParseError.eof_before_tag_name)
		t.state = .eof
		return [
			CharacterToken(`<`),
			EOFToken{
				mssg: ParseError.eof_before_tag_name.str()
			},
		]
	}

	if t.char == `!` {
		t.state = .markup_declaration_open
		return t.markup_declaration_open_state()
	}

	if t.char == `/` {
		t.state = .end_tag_open
		return t.end_tag_open_state()
	}

	if t.char in ascii_alpha {
		t.token = TagToken{}
		t.reconsume()
		t.state = .tag_name
		return t.tag_name_state()
	}

	if t.char == `?` {
		println(ParseError.unexpected_question_makr_instead_of_tag_name)
		t.token = CommentToken{}
		t.reconsume()
		t.state = .bogus_comment
		return t.bogus_comment_state()
	}

	println(ParseError.invalid_first_character_of_tag_name)
	t.reconsume()
	t.state = .data
	return [CharacterToken(`<`)]
}

// end_tag_open_state follows the spec 13.2.5.7 at https://html.spec.whatwg.org/multipage/parsing.html#end-tag-open-state
fn (mut t Tokenizer) end_tag_open_state() []Token {
	t.consume() or {
		println(ParseError.eof_before_tag_name)
		t.state = .eof
		return [
			CharacterToken(`<`),
			CharacterToken(`/`),
			EOFToken{
				mssg: ParseError.eof_before_tag_name.str()
			},
		]
	}

	if t.char in ascii_alpha {
		t.token = TagToken{
			is_start: false
		}
		t.reconsume()
		t.state = .tag_name
		return t.tag_name_state()
	}

	if t.char == `>` {
		println(ParseError.missing_end_tag_name)
		t.state = .data
		return t.data_state()
	}

	println(ParseError.invalid_first_character_of_tag_name)
	t.token = CommentToken{}
	t.reconsume()
	t.state = .bogus_comment
	return t.bogus_comment_state()
}

// tag_name_state follows the spec 13.2.5.8 at https://html.spec.whatwg.org/multipage/parsing.html#tag-name-state
fn (mut t Tokenizer) tag_name_state() []Token {
	t.consume() or {
		println(ParseError.eof_in_tag)
		t.state = .eof
		return [EOFToken{
			mssg: ParseError.eof_in_tag.str()
		}]
	}

	if t.char in whitespace {
		t.state = .before_attribute_name
		return t.before_attribute_name_state()
	}

	if t.char == `/` {
		t.state = .self_closing_start_tag
		return t.self_closing_start_tag_state()
	}

	if t.char == `>` {
		if (t.token as TagToken).is_start {
			t.open_tags.push((t.token as TagToken).name())
		}
		t.state = .data
		return [t.token]
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		mut tok := &(t.token as TagToken)
		tok.name.write_rune(0xfffd)
		return t.tag_name_state()
	}

	mut tok := &(t.token as TagToken)
	tok.name.write_rune(t.char)
	return t.tag_name_state()
}

// rcdata_less_than_sign_state follows the spec 13.2.5.9 at https://html.spec.whatwg.org/multipage/parsing.html#rcdata-less-than-sign-state
fn (mut t Tokenizer) rcdata_less_than_sign_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .rcdata
		return [CharacterToken(`<`)]
	}

	t.consume() or { return anything_else() }

	if t.char == `/` {
		t.buffer = new_builder(50)
		t.state = .rcdata_end_tag_open
		return t.rcdata_end_tag_open_state()
	}

	return anything_else()
}

// rcdata_end_tag_open_state follows the spec 13.2.5.10 at https://html.spec.whatwg.org/multipage/parsing.html#rcdata-end-tag-open-state
fn (mut t Tokenizer) rcdata_end_tag_open_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .rcdata
		return string_to_tokens('</')
	}

	t.consume() or { return anything_else() }

	if t.char in ascii_alpha {
		t.token = TagToken{
			is_start: false
		}
		t.reconsume()
		t.state = .rcdata_end_tag_name
		return t.rcdata_end_tag_name_state()
	}

	return anything_else()
}

// rcdata_end_tag_name_state follows the spec 13.2.5.11 at https://html.spec.whatwg.org/multipage/parsing.html#rcdata-end-tag-name-state
fn (mut t Tokenizer) rcdata_end_tag_name_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .rcdata
		return string_to_tokens('</' + t.buffer.str())
	}

	t.consume() or { return anything_else() }

	if t.char in whitespace {
		if t.is_token_appropriate_end_tag() {
			t.state = .before_attribute_name
			return t.before_attribute_name_state()
		}

		return anything_else()
	}

	if t.char == `/` {
		if t.is_token_appropriate_end_tag() {
			t.state = .self_closing_start_tag
			return t.self_closing_start_tag_state()
		}

		return anything_else()
	}

	if t.char == `>` {
		if t.is_token_appropriate_end_tag() {
			t.state = .data
			return [t.token]
		}

		return anything_else()
	}

	if t.char in ascii_alpha {
		mut tok := &(t.token as TagToken)
		tok.name.write_rune(rune_to_lower(t.char))
		t.buffer.write_rune(t.char)
		return t.rcdata_end_tag_name_state()
	}

	return anything_else()
}

// rawtext_less_than_sign_state follows the spec 13.2.5.12 at https://html.spec.whatwg.org/multipage/parsing.html#rawtext-less-than-sign-state
fn (mut t Tokenizer) rawtext_less_than_sign_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .rawtext
		return [CharacterToken(`<`)]
	}

	t.consume() or { return anything_else() }

	if t.char == `/` {
		t.buffer = new_builder(50)
		t.state = .rawtext_end_tag_open
		return t.rawtext_end_tag_open_state()
	}

	return anything_else()
}

// rawtext_end_tag_open_state follows the spec 13.2.5.13 at https://html.spec.whatwg.org/multipage/parsing.html#rawtext-end-tag-open-state
fn (mut t Tokenizer) rawtext_end_tag_open_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .rawtext
		return string_to_tokens('</')
	}

	t.consume() or { return anything_else() }

	if t.char in ascii_alpha {
		t.token = TagToken{
			is_start: false
		}
		t.reconsume()
		t.state = .rawtext_end_tag_name
		return t.rawtext_end_tag_name_state()
	}

	return anything_else()
}

// rawtext_end_tag_name_state follows the spec 13.2.5.14 at https://html.spec.whatwg.org/multipage/parsing.html#rawtext-end-tag-name-state
fn (mut t Tokenizer) rawtext_end_tag_name_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .rawtext
		return string_to_tokens('</' + t.buffer.str())
	}

	t.consume() or { return anything_else() }

	if t.char in whitespace {
		if t.is_token_appropriate_end_tag() {
			t.state = .before_attribute_name
			return t.before_attribute_name_state()
		}

		return anything_else()
	}

	if t.char == `/` {
		if t.is_token_appropriate_end_tag() {
			t.state = .self_closing_start_tag
			return t.self_closing_start_tag_state()
		}

		return anything_else()
	}

	if t.char == `>` {
		if t.is_token_appropriate_end_tag() {
			t.state = .data
			return [t.token]
		}

		return anything_else()
	}

	if t.char in ascii_alpha {
		mut tok := &(t.token as TagToken)
		tok.name.write_rune(rune_to_lower(t.char))
		t.buffer.write_rune(t.char)
		return t.rawtext_end_tag_name_state()
	}

	return anything_else()
}

// script_data_less_than_sign_state follows the spec 13.2.5.15 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-less-than-sign-state
fn (mut t Tokenizer) script_data_less_than_sign_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .script_data
		return [CharacterToken(`<`)]
	}

	t.consume() or { return anything_else() }

	if t.char == `/` {
		t.buffer = new_builder(50)
		t.state = .script_data_end_tag_open
		return t.script_data_end_tag_open_state()
	}

	if t.char == `!` {
		t.state = .script_data_escape_start
		return string_to_tokens('<!')
	}

	return anything_else()
}

// script_data_end_tag_open_state follows the spec 13.2.5.16 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-end-tag-open-state
fn (mut t Tokenizer) script_data_end_tag_open_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .script_data
		return string_to_tokens('</')
	}

	t.consume() or { return anything_else() }

	if t.char in ascii_alpha {
		t.token = TagToken{
			is_start: false
		}
		t.reconsume()
		t.state = .script_data_end_tag_name
		return t.script_data_end_tag_name_state()
	}

	return anything_else()
}

// script_data_end_tag_name_state follows the spec 13.2.5.17 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-end-tag-name-state
fn (mut t Tokenizer) script_data_end_tag_name_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .script_data
		return string_to_tokens('</' + t.buffer.str())
	}

	t.consume() or { return anything_else() }

	if t.char in whitespace {
		if t.is_token_appropriate_end_tag() {
			t.state = .before_attribute_name
			return t.before_attribute_name_state()
		}

		return anything_else()
	}

	if t.char == `/` {
		if t.is_token_appropriate_end_tag() {
			t.state = .self_closing_start_tag
			return t.self_closing_start_tag_state()
		}

		return anything_else()
	}

	if t.char == `>` {
		if t.is_token_appropriate_end_tag() {
			t.state = .data
			return [t.token]
		}

		return anything_else()
	}

	if t.char in ascii_alpha {
		mut tok := &(t.token as TagToken)
		tok.name.write_rune(rune_to_lower(t.char))
		t.buffer.write_rune(t.char)
		return t.script_data_end_tag_name_state()
	}

	return anything_else()
}

// script_data_escape_start_state follows the spec 13.2.5.18 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-escape-start-state
fn (mut t Tokenizer) script_data_escape_start_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .script_data
		return t.script_data_state()
	}

	t.consume() or { return anything_else() }

	if t.char == `-` {
		t.state = .script_data_escape_start_dash
		return [CharacterToken(`-`)]
	}

	return anything_else()
}

// script_data_escape_start_dash_state follows the spec 13.2.5.19 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-escape-start-dash-state
fn (mut t Tokenizer) script_data_escape_start_dash_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .script_data
		return t.script_data_state()
	}

	t.consume() or { return anything_else() }

	if t.char == `-` {
		t.state = .script_data_escaped_dash_dash
		return [CharacterToken(`-`)]
	}

	return anything_else()
}

// script_data_escaped_state follows the spec 13.2.5.20 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-escaped-state
fn (mut t Tokenizer) script_data_escaped_state() []Token {
	t.consume() or {
		t.state = .eof
		return [
			EOFToken{
				mssg: ParseError.eof_in_script_comment_like_text.str()
			},
		]
	}

	if t.char == `-` {
		t.state = .script_data_escaped_dash
		return [CharacterToken(`-`)]
	}

	if t.char == `<` {
		t.state = .script_data_escaped_less_than_sign
		return t.script_data_escaped_less_than_sign_state()
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		return [replacement_token]
	}

	return [CharacterToken(t.char)]
}

// script_data_escaped_dash_state follows the spec 13.2.5.21 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-escaped-dash-state
fn (mut t Tokenizer) script_data_escaped_dash_state() []Token {
	t.consume() or {
		t.state = .eof
		return [
			EOFToken{
				mssg: ParseError.eof_in_script_comment_like_text.str()
			},
		]
	}

	if t.char == `-` {
		t.state = .script_data_escaped_dash_dash
		return [CharacterToken(`-`)]
	}

	if t.char == `<` {
		t.state = .script_data_escaped_less_than_sign
		return t.script_data_escaped_less_than_sign_state()
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		return [replacement_token]
	}

	t.state = .script_data_escaped
	return [CharacterToken(t.char)]
}

// script_data_escaped_dash_dash_state follows the spec 13.2.5.22 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-escaped-dash-dash-state
fn (mut t Tokenizer) script_data_escaped_dash_dash_state() []Token {
	t.consume() or {
		t.state = .eof
		return [
			EOFToken{
				mssg: ParseError.eof_in_script_comment_like_text.str()
			},
		]
	}

	if t.char == `-` {
		return [CharacterToken(`-`)]
	}

	if t.char == `<` {
		t.state = .script_data_escaped_less_than_sign
		return t.script_data_escaped_less_than_sign_state()
	}

	if t.char == `>` {
		t.state = .script_data
		return [CharacterToken(`>`)]
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		return [replacement_token]
	}

	t.state = .script_data_escaped
	return [CharacterToken(t.char)]
}

// script_data_escaped_less_than_sign_state follows the spec 13.2.5.23 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-escaped-less-than-sign-state
fn (mut t Tokenizer) script_data_escaped_less_than_sign_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .script_data_escaped
		return [CharacterToken(`<`)]
	}

	t.consume() or { return anything_else() }

	if t.char == `/` {
		t.buffer = new_builder(50)
		t.state = .script_data_escaped_end_tag_open
		return t.script_data_escaped_end_tag_open_state()
	}

	if t.char in ascii_alpha {
		t.buffer = new_builder(50)
		t.reconsume()
		t.state = .script_data_double_escape_start
		return [CharacterToken(`<`)]
	}

	return anything_else()
}

// script_data_escaped_end_tag_open_state follows the spec 13.2.5.24 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-escaped-end-tag-open-state
fn (mut t Tokenizer) script_data_escaped_end_tag_open_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .script_data_escaped
		return string_to_tokens('</')
	}

	t.consume() or { return anything_else() }

	if t.char in ascii_alpha {
		t.token = TagToken{}
		t.reconsume()
		t.state = .script_data_escaped_end_tag_name
		return t.script_data_escaped_end_tag_open_state()
	}

	return anything_else()
}

// script_data_escaped_end_tag_name_state follows the spec 13.2.5.25 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-escaped-end-tag-name-state
fn (mut t Tokenizer) script_data_escaped_end_tag_name_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .script_data_escaped
		return string_to_tokens('</' + t.buffer.str())
	}

	t.consume() or { return anything_else() }

	if t.char in whitespace {
		if t.is_token_appropriate_end_tag() {
			t.state = .before_attribute_name
			return t.before_attribute_name_state()
		}

		return anything_else()
	}

	if t.char == `/` {
		if t.is_token_appropriate_end_tag() {
			t.state = .self_closing_start_tag
			return t.self_closing_start_tag_state()
		}

		return anything_else()
	}

	if t.char == `>` {
		if t.is_token_appropriate_end_tag() {
			t.state = .data
			return [t.token]
		}

		return anything_else()
	}

	if t.char in ascii_alpha {
		mut tok := &(t.token as TagToken)
		tok.name.write_rune(rune_to_lower(t.char))
		t.buffer.write_rune(t.char)
		return t.script_data_escaped_end_tag_name_state()
	}

	return anything_else()
}

// script_data_double_escape_start_state follows the spec 13.2.5.26 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-double-escape-start-state
fn (mut t Tokenizer) script_data_double_escape_start_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .script_data_escaped
		return t.script_data_escaped_state()
	}

	t.consume() or { return anything_else() }

	if t.char in whitespace || t.char in [`/`, `>`] {
		if t.buffer.bytestr() == 'script' {
			t.state = .script_data_double_escaped
			return t.script_data_double_escaped_state()
		} else {
			t.state = .script_data_escaped
			return [CharacterToken(t.char)]
		}
	}

	if t.char in ascii_alpha {
		t.buffer.write_rune(t.char)
		return t.script_data_double_escape_start_state()
	}

	return anything_else()
}

// script_data_double_escaped_state follows the spec 13.2.5.27 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-double-escaped-state
fn (mut t Tokenizer) script_data_double_escaped_state() []Token {
	t.consume() or {
		t.state = .eof
		return [
			EOFToken{
				mssg: ParseError.eof_in_script_comment_like_text.str()
			},
		]
	}

	if t.char == `-` {
		t.state = .script_data_double_escaped_dash
		return [CharacterToken(`-`)]
	}

	if t.char == `<` {
		t.state = .script_data_double_escaped_less_than_sign
		return [CharacterToken(`<`)]
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		return [replacement_token]
	}

	return [CharacterToken(t.char)]
}

// script_data_double_escaped_dash_state follows the spec 13.2.5.28 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-double-escaped-dash-state
fn (mut t Tokenizer) script_data_double_escaped_dash_state() []Token {
	t.consume() or {
		t.state = .eof
		return [
			EOFToken{
				mssg: ParseError.eof_in_script_comment_like_text.str()
			},
		]
	}

	if t.char == `-` {
		t.state = .script_data_double_escaped_dash_dash
		return [CharacterToken(`-`)]
	}

	if t.char == `<` {
		t.state = .script_data_double_escaped_less_than_sign
		return [CharacterToken(`<`)]
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		t.state = .script_data_double_escaped
		return [replacement_token]
	}

	t.state = .script_data_double_escaped
	return [CharacterToken(t.char)]
}

// script_data_double_escaped_dash_dash_state follows the spec 13.2.5.29 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-double-escaped-dash-dash-state
fn (mut t Tokenizer) script_data_double_escaped_dash_dash_state() []Token {
	t.consume() or {
		t.state = .eof
		return [
			EOFToken{
				mssg: ParseError.eof_in_script_comment_like_text.str()
			},
		]
	}

	if t.char == `-` {
		return [CharacterToken(`-`)]
	}

	if t.char == `<` {
		t.state = .script_data_double_escaped_less_than_sign
		return [CharacterToken(`<`)]
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		t.state = .script_data_double_escaped
		return [replacement_token]
	}

	t.state = .script_data_double_escaped
	return [CharacterToken(t.char)]
}

// script_data_double_escaped_less_than_sign_state follows the spec 13.2.5.30 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-double-escaped-less-than-sign-state
fn (mut t Tokenizer) script_data_double_escaped_less_than_sign_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .script_data_double_escaped
		return t.script_data_double_escaped_state()
	}

	t.consume() or { return anything_else() }

	if t.char == `/` {
		t.buffer = new_builder(50)
		t.state = .script_data_double_escape_end
		return [CharacterToken(`/`)]
	}

	return anything_else()
}

// script_data_double_escape_end_state follows the spec 13.2.5.31 at https://html.spec.whatwg.org/multipage/parsing.html#script-data-double-escape-end-state
fn (mut t Tokenizer) script_data_double_escape_end_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .script_data_double_escaped
		return t.script_data_double_escaped_state()
	}

	t.consume() or { return anything_else() }

	if t.char in whitespace || t.char in [`/`, `>`] {
		if t.buffer.bytestr() == 'script' {
			t.state = .script_data_escaped
			return t.script_data_escaped_state()
		} else {
			t.state = .script_data_double_escaped
			return [CharacterToken(t.char)]
		}
	}

	if t.char in ascii_alpha {
		t.buffer.write_rune(rune_to_lower(t.char))
		return [CharacterToken(t.char)]
	}

	return anything_else()
}

// before_attribute_name_state follows the spec 13.2.5.32 at https://html.spec.whatwg.org/multipage/parsing.html#before-attribute-name-state
fn (mut t Tokenizer) before_attribute_name_state() []Token {
	t.consume() or {
		t.reconsume()
		t.state = .after_attribute_name
		return t.after_attribute_name_state()
	}

	if t.char in whitespace {
		return t.before_attribute_name_state()
	}

	if t.char in [`/`, `>`] {
		t.reconsume()
		t.state = .after_attribute_name
		return t.after_attribute_name_state()
	}

	if t.char == `=` {
		println(ParseError.unexpected_equals_sign_before_attribute_name)
		mut tok := &(t.token as TagToken)
		tok.attributes << Attribute{}
		mut attr := &(tok.attributes[tok.attributes.len - 1])
		attr.name.write_rune(t.char)
		t.state = .attribute_name
		return t.before_attribute_name_state()
	}

	mut tok := &(t.token as TagToken)
	tok.attributes << Attribute{}
	t.reconsume()
	t.state = .attribute_name
	return t.attribute_name_state()
}

// attribute_name_state follows the spec 13.2.5.33 at https://html.spec.whatwg.org/multipage/parsing.html#attribute-name-state
fn (mut t Tokenizer) attribute_name_state() []Token {
	ws := fn [mut t] () []Token {
		t.reconsume()
		t.state = .after_attribute_name
		return t.after_attribute_name_state()
	}

	anything_else := fn [mut t] () []Token {
		mut tok := &(t.token as TagToken)
		mut attr := &(tok.attributes[tok.attributes.len - 1])
		attr.name.write_rune(rune_to_lower(t.char))
		return t.attribute_name_state()
	}

	t.consume() or { return ws() }

	if t.char in whitespace || t.char in [`/`, `>`] {
		return ws()
	}

	if t.char == `=` {
		t.state = .before_attribute_value
		return t.before_attribute_value_state()
	}

	// if t.char in ascii_alpha_upper {
	// 	mut tok := &(t.token as TagToken)
	// 	mut attr := &(tok.attributes[tok.attributes.len-1])
	// 	attr.name.write_rune(rune_to_lower(t.char))
	// 	return t.emit_token()
	// }

	if t.char == null {
		println(ParseError.unexpected_null_character)
		mut tok := &(t.token as TagToken)
		mut attr := &(tok.attributes[tok.attributes.len - 1])
		attr.name.write_rune(0xfffd)
	}

	if t.char in [`'`, `"`, `<`] {
		println(ParseError.unexpected_character_in_attribute_name)
		return anything_else()
	}

	return anything_else()
}

// after_attribute_name_state follows the spec 13.2.5.34 at https://html.spec.whatwg.org/multipage/parsing.html#after-attribute-name-state
fn (mut t Tokenizer) after_attribute_name_state() []Token {
	t.consume() or {
		t.state = .eof
		return [EOFToken{
			mssg: ParseError.eof_in_tag.str()
		}]
	}

	if t.char in whitespace {
		return t.after_attribute_name_state()
	}

	if t.char == `/` {
		t.state = .self_closing_start_tag
		return t.self_closing_start_tag_state()
	}

	if t.char == `=` {
		t.state = .before_attribute_value
		return t.before_attribute_value_state()
	}

	if t.char == `>` {
		if (t.token as TagToken).is_start {
			t.open_tags.push((t.token as TagToken).name())
		}
		t.state = .data
		return [t.token]
	}

	mut tok := &(t.token as TagToken)
	tok.attributes << Attribute{}
	t.reconsume()
	t.state = .attribute_name
	return t.attribute_name_state()
}

// before_attribute_value_state follows the spec 13.2.5.35 at https://html.spec.whatwg.org/multipage/parsing.html#before-attribute-value-state
fn (mut t Tokenizer) before_attribute_value_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .attribute_value_unquoted
		return t.attribute_value_unquoted_state()
	}

	t.consume() or { return anything_else() }

	if t.char in whitespace {
		return t.before_attribute_value_state()
	}

	if t.char == `"` {
		t.state = .attribute_value_double_quoted
		return t.attribute_value_double_quoted_state()
	}

	if t.char == `'` {
		t.state = .attribute_value_single_quoted
		return t.attribute_value_single_quoted_state()
	}

	if t.char == `>` {
		println(ParseError.missing_attribute_value)
		if (t.token as TagToken).is_start {
			t.open_tags.push((t.token as TagToken).name())
		}
		t.state = .data
		return [t.token]
	}

	return anything_else()
}

// attribute_value_double_quoted_state follows the spec 13.2.5.36 at https://html.spec.whatwg.org/multipage/parsing.html#attribute-value-(double-quoted)-state
fn (mut t Tokenizer) attribute_value_double_quoted_state() []Token {
	t.consume() or {
		t.state = .eof
		return [EOFToken{
			mssg: ParseError.eof_in_tag.str()
		}]
	}

	if t.char == `"` {
		t.state = .after_attribute_value_quoted
		return t.after_attribute_value_quoted_state()
	}

	if t.char == `&` {
		t.return_state = .attribute_value_double_quoted
		t.state = .character_reference
		return t.character_reference_state()
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		mut tok := &(t.token as TagToken)
		mut attr := &(tok.attributes[tok.attributes.len - 1])
		attr.value.write_rune(0xfffd)
	}

	mut tok := &(t.token as TagToken)
	mut attr := &(tok.attributes[tok.attributes.len - 1])
	attr.value.write_rune(t.char)
	return t.attribute_value_double_quoted_state()
}

// attribute_value_single_quoted_state follows the spec 13.2.5.37 at https://html.spec.whatwg.org/multipage/parsing.html#attribute-value-(single-quoted)-state
fn (mut t Tokenizer) attribute_value_single_quoted_state() []Token {
	t.consume() or {
		t.state = .eof
		return [EOFToken{
			mssg: ParseError.eof_in_tag.str()
		}]
	}

	if t.char == `'` {
		t.state = .after_attribute_value_quoted
		return t.after_attribute_value_quoted_state()
	}

	if t.char == `&` {
		t.return_state = .attribute_value_single_quoted
		t.state = .character_reference
		return t.character_reference_state()
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		mut tok := &(t.token as TagToken)
		mut attr := &(tok.attributes[tok.attributes.len - 1])
		attr.value.write_rune(0xfffd)
	}

	mut tok := &(t.token as TagToken)
	mut attr := &(tok.attributes[tok.attributes.len - 1])
	attr.value.write_rune(t.char)
	return t.attribute_value_single_quoted_state()
}

// attribute_value_unquoted_state follows the spec 13.2.5.38 at https://html.spec.whatwg.org/multipage/parsing.html#attribute-value-(unquoted)-state
fn (mut t Tokenizer) attribute_value_unquoted_state() []Token {
	anything_else := fn [mut t] () []Token {
		mut tok := &(t.token as TagToken)
		mut attr := &(tok.attributes[tok.attributes.len - 1])
		attr.value.write_rune(0xfffd)
		return t.attribute_value_unquoted_state()
	}

	t.consume() or {
		t.state = .eof
		return [EOFToken{
			mssg: ParseError.eof_in_tag.str()
		}]
	}

	if t.char in whitespace {
		t.state = .before_attribute_name
		return t.before_attribute_name_state()
	}

	if t.char == `&` {
		t.return_state = .attribute_value_unquoted
		t.state = .character_reference
		return t.character_reference_state()
	}

	if t.char == `>` {
		if (t.token as TagToken).is_start {
			t.open_tags.push((t.token as TagToken).name())
		}
		t.state = .data
		return [t.token]
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		mut tok := &(t.token as TagToken)
		mut attr := &(tok.attributes[tok.attributes.len - 1])
		attr.value.write_rune(0xfffd)
	}

	if t.char in [`'`, `"`, `=`, `<`, `\``] {
		println(ParseError.unexpected_character_in_unquoted_attribute_value)
		return anything_else()
	}

	return anything_else()
}

// after_attribute_value_quoted_state follows the spec 13.2.5.39 at https://html.spec.whatwg.org/multipage/parsing.html#after-attribute-value-(quoted)-state
fn (mut t Tokenizer) after_attribute_value_quoted_state() []Token {
	t.consume() or {
		t.state = .eof
		return [EOFToken{
			mssg: ParseError.eof_in_tag.str()
		}]
	}

	if t.char in whitespace {
		t.state = .before_attribute_name
		return t.before_attribute_name_state()
	}

	if t.char == `/` {
		t.state = .self_closing_start_tag
		return t.self_closing_start_tag_state()
	}

	if t.char == `>` {
		if (t.token as TagToken).is_start {
			t.open_tags.push((t.token as TagToken).name())
		}
		t.state = .data
		return [t.token]
	}

	println(ParseError.missing_whitespace_between_attributes)
	t.reconsume()
	t.state = .before_attribute_name
	return t.before_attribute_name_state()
}

// self_closing_start_tag_state follows the spec 13.2.5.40 at https://html.spec.whatwg.org/multipage/parsing.html#self-closing-start-tag-state
fn (mut t Tokenizer) self_closing_start_tag_state() []Token {
	t.consume() or {
		t.state = .eof
		return [EOFToken{
			mssg: ParseError.eof_in_tag.str()
		}]
	}

	if t.char == `>` {
		mut tok := &(t.token as TagToken)
		tok.self_closing = true
		t.state = .data
		return [t.token]
	}

	println(ParseError.unexpected_solidus_in_tag)
	t.reconsume()
	t.state = .before_attribute_name
	return t.before_attribute_name_state()
}

// bogus_comment_state follows the spec 13.2.5.41 at https://html.spec.whatwg.org/multipage/parsing.html#bogus-comment-state
fn (mut t Tokenizer) bogus_comment_state() []Token {
	t.consume() or {
		t.state = .eof
		return [t.token, EOFToken{}]
	}

	if t.char == `>` {
		t.state = .data
		return [t.token]
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		mut tok := &(t.token as CommentToken)
		tok.data.write_rune(0xfffd)
	}

	mut tok := &(t.token as CommentToken)
	tok.data.write_rune(t.char)
	return t.bogus_comment_state()
}

// markup_declaration_open_state follows the spec 13.2.5.42 at https://html.spec.whatwg.org/multipage/parsing.html#markup-declaration-open-state
fn (mut t Tokenizer) markup_declaration_open_state() []Token {
	if t.look_ahead('--', true) {
		t.token = CommentToken{}
		t.state = .comment_start
		return t.comment_start_state()
	}

	if t.look_ahead('DOCTYPE', false) {
		t.state = .doctype
		return t.doctype_state()
	}

	// not sure I understand what the adjusted current NodeBase is
	if t.look_ahead('[CDATA[', true) {
		// Consume those characters. If there is an adjusted current
		// NodeBase and it is not an element in the HTML namespace, then
		// switch to the CDATA section state. Otherwise, this is a
		// cdata-in-html-content parse error. Create a comment token
		// whose data is the "[CDATA[" string. Switch to the bogus
		// comment state.
		t.state = .bogus_comment
		return t.bogus_comment_state()
	}

	println(ParseError.incorrectly_opened_comment)
	t.token = CommentToken{}
	t.state = .bogus_comment
	return t.bogus_comment_state()
}

// comment_start_state follows the spec 13.2.5.43 at https://html.spec.whatwg.org/multipage/parsing.html#comment-start-state
fn (mut t Tokenizer) comment_start_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .comment
		return t.comment_state()
	}

	t.consume() or { return anything_else() }

	if t.char == `-` {
		t.state = .comment_start_dash
		return t.comment_start_dash_state()
	}

	if t.char == `>` {
		println(ParseError.abrupt_closing_of_empty_comment)
		t.state = .data
		return [t.token]
	}

	return anything_else()
}

// comment_start_dash_state follows the spec 13.2.5.44 at https://html.spec.whatwg.org/multipage/parsing.html#comment-start-dash-state
fn (mut t Tokenizer) comment_start_dash_state() []Token {
	t.consume() or {
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_comment.str()
		}]
	}

	if t.char == `-` {
		t.state = .comment_end
		return t.comment_end_state()
	}

	if t.char == `>` {
		println(ParseError.abrupt_closing_of_empty_comment)
		t.state = .data
		return [t.token]
	}

	mut tok := &(t.token as CommentToken)
	tok.data.write_rune(`-`)
	t.reconsume()
	t.state = .comment
	return t.comment_state()
}

// comment_state follows the spec 13.2.5.45 at https://html.spec.whatwg.org/multipage/parsing.html#comment-state
fn (mut t Tokenizer) comment_state() []Token {
	t.consume() or {
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_comment.str()
		}]
	}

	if t.char == `<` {
		mut tok := &(t.token as CommentToken)
		tok.data.write_rune(`<`)
		t.state = .comment_less_than_sign
		return t.comment_less_than_sign_state()
	}

	if t.char == `-` {
		t.state = .comment_end_dash
		return t.comment_end_dash_state()
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		mut tok := &(t.token as CommentToken)
		tok.data.write_rune(0xfffd)
		return t.comment_state()
	}

	mut tok := &(t.token as CommentToken)
	tok.data.write_rune(t.char)
	return t.comment_state()
}

// comment_less_than_sign_state follows the spec 13.2.5.46 at https://html.spec.whatwg.org/multipage/parsing.html#comment-less-than-sign-state
fn (mut t Tokenizer) comment_less_than_sign_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .comment
		return t.comment_state()
	}

	t.consume() or { return anything_else() }

	if t.char == `!` {
		mut tok := &(t.token as CommentToken)
		tok.data.write_rune(`!`)
		t.state = .comment_less_than_sign_bang
		return t.comment_less_than_sign_bang_state()
	}

	if t.char == `<` {
		mut tok := &(t.token as CommentToken)
		tok.data.write_rune(`<`)
		return t.comment_less_than_sign_state()
	}

	return anything_else()
}

// comment_less_than_sign_bang_state follows the spec 13.2.5.47 at https://html.spec.whatwg.org/multipage/parsing.html#comment-less-than-sign-bang-state
fn (mut t Tokenizer) comment_less_than_sign_bang_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .comment
		return t.comment_state()
	}

	t.consume() or { return anything_else() }

	if t.char == `-` {
		t.state = .comment_less_than_sign_bang_dash
		return t.comment_less_than_sign_bang_dash_state()
	}

	return anything_else()
}

// comment_less_than_sign_bang_dash_state follows the spec 13.2.5.48 at https://html.spec.whatwg.org/multipage/parsing.html#comment-less-than-sign-bang-dash-state
fn (mut t Tokenizer) comment_less_than_sign_bang_dash_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .comment_end_dash
		return t.comment_end_dash_state()
	}

	t.consume() or { return anything_else() }

	if t.char == `-` {
		t.state = .comment_less_than_sign_bang_dash_dash
		return t.comment_less_than_sign_bang_dash_dash_state()
	}

	return anything_else()
}

// comment_less_than_sign_bang_dash_dash_state follows the spec 13.2.5.49 at https://html.spec.whatwg.org/multipage/parsing.html#comment-less-than-sign-bang-dash-dash-state
fn (mut t Tokenizer) comment_less_than_sign_bang_dash_dash_state() []Token {
	gteof := fn [mut t] () []Token {
		t.reconsume()
		t.state = .comment_end
		return t.comment_end_state()
	}

	t.consume() or { return gteof() }

	if t.char == `>` {
		return gteof()
	}

	println(ParseError.nested_comment)
	t.reconsume()
	t.state = .comment_end
	return t.comment_end_state()
}

// comment_end_dash_state follows the spec 13.2.5.50 at https://html.spec.whatwg.org/multipage/parsing.html#comment-end-dash-state
fn (mut t Tokenizer) comment_end_dash_state() []Token {
	t.consume() or {
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_comment.str()
		}]
	}

	if t.char == `-` {
		t.state = .comment_end
		return t.comment_end_state()
	}

	mut tok := &(t.token as CommentToken)
	tok.data.write_rune(`-`)
	t.reconsume()
	t.state = .comment
	return t.comment_state()
}

// comment_end_state follows the spec 13.2.5.51 at https://html.spec.whatwg.org/multipage/parsing.html#comment-end-state
fn (mut t Tokenizer) comment_end_state() []Token {
	t.consume() or {
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_comment.str()
		}]
	}

	if t.char == `>` {
		t.state = .data
		return [t.token]
	}

	if t.char == `!` {
		t.state = .comment_end_bang
		return t.comment_end_bang_state()
	}

	if t.char == `-` {
		mut tok := &(t.token as CommentToken)
		tok.data.write_rune(`-`)
		return t.comment_end_state()
	}

	mut tok := &(t.token as CommentToken)
	tok.data.write_string('--')
	t.reconsume()
	t.state = .comment
	return t.comment_state()
}

// comment_end_bang_state follows the spec 13.2.5.52 at https://html.spec.whatwg.org/multipage/parsing.html#comment-end-bang-state
fn (mut t Tokenizer) comment_end_bang_state() []Token {
	t.consume() or {
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_comment.str()
		}]
	}

	if t.char == `>` {
		println(ParseError.incorrectly_closed_comment)
		t.state = .data
		return [t.token]
	}

	mut tok := &(t.token as CommentToken)
	tok.data.write_string('--!')
	t.reconsume()
	t.state = .comment
	return t.comment_state()
}

// doctype_state follows the spec 13.2.5.53 at https://html.spec.whatwg.org/multipage/parsing.html#doctype-state
fn (mut t Tokenizer) doctype_state() []Token {
	t.consume() or {
		t.token = DoctypeToken{}
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_doctype.str()
		}]
	}

	if t.char in whitespace {
		t.state = .before_doctype_name
		return t.before_doctype_name_state()
	}

	if t.char == `>` {
		t.reconsume()
		t.state = .before_doctype_name
		return t.before_doctype_name_state()
	}

	println(ParseError.missing_whitespace_before_doctype_name)
	t.reconsume()
	t.state = .before_doctype_name
	return t.before_doctype_name_state()
}

// before_doctype_name_state follows the spec 13.2.5.54 at https://html.spec.whatwg.org/multipage/parsing.html#before-doctype-name-state
fn (mut t Tokenizer) before_doctype_name_state() []Token {
	t.consume() or {
		t.token = DoctypeToken{}
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_doctype.str()
		}]
	}

	if t.char in whitespace {
		return t.before_doctype_name_state()
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		t.token = DoctypeToken{}
		mut tok := &(t.token as DoctypeToken)
		tok.name = new_builder(50)
		tok.name.write_rune(0xfffd)
		t.state = .doctype_name
		return t.doctype_name_state()
	}

	if t.char == `>` {
		println(ParseError.missing_doctype_name)
		t.token = DoctypeToken{}
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .data
		return [t.token]
	}

	t.token = DoctypeToken{}
	mut tok := &(t.token as DoctypeToken)
	tok.name = new_builder(50)
	tok.name.write_rune(rune_to_lower(t.char))
	t.state = .doctype_name
	return t.doctype_name_state()
}

// doctype_name_state follows the spec 13.2.5.55 at https://html.spec.whatwg.org/multipage/parsing.html#doctype-name-state
fn (mut t Tokenizer) doctype_name_state() []Token {
	t.consume() or {
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_doctype.str()
		}]
	}

	if t.char in whitespace {
		t.state = .after_doctype_name
		return t.after_doctype_name_state()
	}

	if t.char == `>` {
		t.state = .data
		return [t.token]
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		mut tok := &(t.token as DoctypeToken)
		tok.name.write_rune(0xfffd)
		return t.doctype_name_state()
	}

	mut tok := &(t.token as DoctypeToken)
	tok.name.write_rune(rune_to_lower(t.char))
	return t.doctype_name_state()
}

// after_doctype_name_state follows the spec 13.2.5.56 at https://html.spec.whatwg.org/multipage/parsing.html#after-doctype-name-state
fn (mut t Tokenizer) after_doctype_name_state() []Token {
	t.consume() or {
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_doctype.str()
		}]
	}

	if t.char in whitespace {
		return t.after_doctype_name_state()
	}

	if t.char == `>` {
		t.state = .data
		return [t.token]
	}

	if t.look_ahead('PUBLIC', false) {
		t.state = .after_doctype_public_keyword
		return t.after_doctype_public_keyword_state()
	}

	if t.look_ahead('SYSTEM', false) {
		t.state = .after_doctype_system_keyword
		return t.after_doctype_system_keyword_state()
	}

	println(ParseError.invalid_character_sequence_after_doctype_name)
	mut tok := &(t.token as DoctypeToken)
	tok.force_quirks = true
	t.reconsume()
	t.state = .bogus_doctype
	return t.bogus_doctype_state()
}

// after_doctype_public_keyword_state follows the spec 13.2.5.57 at https://html.spec.whatwg.org/multipage/parsing.html#after-doctype-public-keyword-state
fn (mut t Tokenizer) after_doctype_public_keyword_state() []Token {
	t.consume() or {
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_doctype.str()
		}]
	}

	if t.char in whitespace {
		t.state = .before_doctype_public_identifier
		return t.before_doctype_public_identifier_state()
	}

	if t.char == `"` {
		println(ParseError.missing_whitespace_after_doctype_public_keyword)
		mut tok := &(t.token as DoctypeToken)
		tok.public_identifier = new_builder(50)
		t.state = .doctype_public_identifier_double_quoted
		return t.doctype_public_identifier_double_quoted_state()
	}

	if t.char == `'` {
		println(ParseError.missing_whitespace_after_doctype_public_keyword)
		mut tok := &(t.token as DoctypeToken)
		tok.public_identifier = new_builder(50)
		t.state = .doctype_public_identifier_single_quoted
		return t.doctype_public_identifier_single_quoted_state()
	}

	if t.char == `>` {
		println(ParseError.missing_doctype_public_identifier)
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .data
		return [t.token]
	}

	println(ParseError.missing_quote_before_doctype_public_identifier)
	mut tok := &(t.token as DoctypeToken)
	tok.force_quirks = true
	t.reconsume()
	t.state = .bogus_doctype
	return t.bogus_doctype_state()
}

// before_doctype_public_identifier_state follows the spec 13.2.5.58 at https://html.spec.whatwg.org/multipage/parsing.html#before-doctype-public-identifier-state
fn (mut t Tokenizer) before_doctype_public_identifier_state() []Token {
	t.consume() or {
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_doctype.str()
		}]
	}

	if t.char in whitespace {
		return t.before_doctype_public_identifier_state()
	}

	if t.char == `"` {
		mut tok := &(t.token as DoctypeToken)
		tok.public_identifier = new_builder(50)
		t.state = .doctype_public_identifier_double_quoted
		return t.doctype_public_identifier_double_quoted_state()
	}

	if t.char == `'` {
		mut tok := &(t.token as DoctypeToken)
		tok.public_identifier = new_builder(50)
		t.state = .doctype_public_identifier_single_quoted
		return t.doctype_public_identifier_single_quoted_state()
	}

	if t.char == `>` {
		println(ParseError.missing_doctype_public_identifier)
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .data
		return [t.token]
	}

	println(ParseError.missing_quote_before_doctype_public_identifier)
	mut tok := &(t.token as DoctypeToken)
	tok.force_quirks = true
	t.reconsume()
	t.state = .bogus_doctype
	return t.bogus_doctype_state()
}

// doctype_public_identifier_double_quoted_state follows the spec 13.2.5.59 at https://html.spec.whatwg.org/multipage/parsing.html#doctype-public-identifier-(double-quoted)-state
fn (mut t Tokenizer) doctype_public_identifier_double_quoted_state() []Token {
	t.consume() or {
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_doctype.str()
		}]
	}

	if t.char == `"` {
		t.state = .after_doctype_public_identifier
		return t.after_doctype_public_identifier_state()
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		mut tok := &(t.token as DoctypeToken)
		tok.public_identifier.write_rune(0xfffd)
		return t.doctype_public_identifier_double_quoted_state()
	}

	if t.char == `>` {
		println(ParseError.abrupt_doctype_public_identifier)
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .data
		return [t.token]
	}

	mut tok := &(t.token as DoctypeToken)
	tok.public_identifier.write_rune(t.char)
	return t.doctype_public_identifier_double_quoted_state()
}

// doctype_public_identifier_single_quoted_state follows the spec 13.2.5.60 at https://html.spec.whatwg.org/multipage/parsing.html#doctype-public-identifier-(single-quoted)-state
fn (mut t Tokenizer) doctype_public_identifier_single_quoted_state() []Token {
	t.consume() or {
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_doctype.str()
		}]
	}

	if t.char == `'` {
		t.state = .after_doctype_public_identifier
		return t.after_doctype_public_identifier_state()
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		mut tok := &(t.token as DoctypeToken)
		tok.public_identifier.write_rune(0xfffd)
		return t.doctype_public_identifier_single_quoted_state()
	}

	if t.char == `>` {
		println(ParseError.abrupt_doctype_public_identifier)
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .data
		return [t.token]
	}

	mut tok := &(t.token as DoctypeToken)
	tok.public_identifier.write_rune(t.char)
	return t.doctype_public_identifier_single_quoted_state()
}

// after_doctype_public_identifier_state follows the spec 13.2.5.61 at https://html.spec.whatwg.org/multipage/parsing.html#after-doctype-public-identifier-state
fn (mut t Tokenizer) after_doctype_public_identifier_state() []Token {
	t.consume() or {
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_doctype.str()
		}]
	}

	if t.char in whitespace {
		t.state = .between_doctype_public_and_system_identifiers
		return t.between_doctype_public_and_system_identifiers_state()
	}

	if t.char == `>` {
		t.state = .data
		return [t.token]
	}

	if t.char == `"` {
		println(ParseError.missing_whitespace_between_doctype_public_and_system_identifiers)
		mut tok := &(t.token as DoctypeToken)
		tok.system_identifier = new_builder(50)
		t.state = .doctype_system_identifier_double_quoted
		return t.doctype_system_identifier_double_quoted_state()
	}

	if t.char == `'` {
		println(ParseError.missing_whitespace_between_doctype_public_and_system_identifiers)
		mut tok := &(t.token as DoctypeToken)
		tok.system_identifier = new_builder(50)
		t.state = .doctype_system_identifier_single_quoted
		return t.doctype_system_identifier_single_quoted_state()
	}

	println(ParseError.missing_quote_before_doctype_system_identifier)
	mut tok := &(t.token as DoctypeToken)
	tok.force_quirks = true
	t.reconsume()
	t.state = .bogus_doctype
	return t.bogus_doctype_state()
}

// between_doctype_public_and_system_identifiers_state follows the spec 13.2.5.62 at https://html.spec.whatwg.org/multipage/parsing.html#between-doctype-public-and-system-identifiers-state
fn (mut t Tokenizer) between_doctype_public_and_system_identifiers_state() []Token {
	t.consume() or {
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_doctype.str()
		}]
	}

	if t.char in whitespace {
		return t.between_doctype_public_and_system_identifiers_state()
	}

	if t.char == `>` {
		t.state = .data
		return [t.token]
	}

	if t.char == `"` {
		mut tok := &(t.token as DoctypeToken)
		tok.system_identifier = new_builder(50)
		t.state = .doctype_system_identifier_double_quoted
		return t.doctype_system_identifier_double_quoted_state()
	}

	if t.char == `'` {
		mut tok := &(t.token as DoctypeToken)
		tok.system_identifier = new_builder(50)
		t.state = .doctype_system_identifier_single_quoted
		return t.doctype_system_identifier_single_quoted_state()
	}

	println(ParseError.missing_quote_before_doctype_system_identifier)
	mut tok := &(t.token as DoctypeToken)
	tok.force_quirks = true
	t.reconsume()
	t.state = .bogus_doctype
	return t.bogus_doctype_state()
}

// after_doctype_system_keyword_state follows the spec 13.2.5.63 at https://html.spec.whatwg.org/multipage/parsing.html#after-doctype-system-keyword-state
fn (mut t Tokenizer) after_doctype_system_keyword_state() []Token {
	t.consume() or {
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_doctype.str()
		}]
	}

	if t.char in whitespace {
		t.state = .before_doctype_system_identifier
		return t.before_doctype_system_identifier_state()
	}

	if t.char == `"` {
		println(ParseError.missing_whitespace_between_doctype_system_keyword_and_system_identifier)
		mut tok := &(t.token as DoctypeToken)
		tok.system_identifier = new_builder(50)
		t.state = .doctype_system_identifier_double_quoted
		return t.doctype_system_identifier_double_quoted_state()
	}

	if t.char == `'` {
		println(ParseError.missing_whitespace_between_doctype_system_keyword_and_system_identifier)
		mut tok := &(t.token as DoctypeToken)
		tok.system_identifier = new_builder(50)
		t.state = .doctype_system_identifier_single_quoted
		return t.doctype_system_identifier_single_quoted_state()
	}

	if t.char == `>` {
		println(ParseError.missing_doctype_system_identifier)
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .data
		return [t.token]
	}

	println(ParseError.missing_quote_before_doctype_system_identifier)
	mut tok := &(t.token as DoctypeToken)
	tok.force_quirks = true
	t.reconsume()
	t.state = .bogus_doctype
	return t.bogus_doctype_state()
}

// before_doctype_system_identifier_state follows the spec 13.2.5.64 at https://html.spec.whatwg.org/multipage/parsing.html#before-doctype-system-identifier-state
fn (mut t Tokenizer) before_doctype_system_identifier_state() []Token {
	t.consume() or {
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_doctype.str()
		}]
	}

	if t.char in whitespace {
		return t.before_doctype_system_identifier_state()
	}

	if t.char == `"` {
		mut tok := &(t.token as DoctypeToken)
		tok.system_identifier = new_builder(50)
		t.state = .doctype_system_identifier_double_quoted
		return t.doctype_system_identifier_double_quoted_state()
	}

	if t.char == `'` {
		mut tok := &(t.token as DoctypeToken)
		tok.system_identifier = new_builder(50)
		t.state = .doctype_system_identifier_single_quoted
		return t.doctype_system_identifier_single_quoted_state()
	}

	if t.char == `>` {
		println(ParseError.missing_doctype_system_identifier)
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .data
		return [t.token]
	}

	println(ParseError.missing_quote_before_doctype_system_identifier)
	mut tok := &(t.token as DoctypeToken)
	tok.force_quirks = true
	t.reconsume()
	t.state = .bogus_doctype
	return t.bogus_doctype_state()
}

// doctype_system_identifier_double_quoted_state follows the spec 13.2.5.65 at https://html.spec.whatwg.org/multipage/parsing.html#doctype-system-identifier-(double-quoted)-state
fn (mut t Tokenizer) doctype_system_identifier_double_quoted_state() []Token {
	t.consume() or {
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_doctype.str()
		}]
	}

	if t.char == `"` {
		t.state = .after_doctype_system_identifier
		return t.after_doctype_system_identifier_state()
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		mut tok := &(t.token as DoctypeToken)
		tok.system_identifier.write_rune(0xfffd)
		return t.doctype_system_identifier_double_quoted_state()
	}

	if t.char == `>` {
		println(ParseError.abrupt_doctype_system_identifier)
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .data
		return [t.token]
	}

	mut tok := &(t.token as DoctypeToken)
	tok.system_identifier.write_rune(t.char)
	return t.doctype_system_identifier_double_quoted_state()
}

// doctype_system_identifier_single_quoted_state follows the spec 13.2.5.66 at https://html.spec.whatwg.org/multipage/parsing.html#doctype-system-identifier-(single-quoted)-state
fn (mut t Tokenizer) doctype_system_identifier_single_quoted_state() []Token {
	t.consume() or {
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_doctype.str()
		}]
	}

	if t.char == `'` {
		t.state = .after_doctype_system_identifier
		return t.after_doctype_system_identifier_state()
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		mut tok := &(t.token as DoctypeToken)
		tok.system_identifier.write_rune(0xfffd)
		return t.doctype_system_identifier_single_quoted_state()
	}

	if t.char == `>` {
		println(ParseError.abrupt_doctype_system_identifier)
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .data
		return [t.token]
	}

	mut tok := &(t.token as DoctypeToken)
	tok.system_identifier.write_rune(t.char)
	return t.doctype_system_identifier_single_quoted_state()
}

// after_doctype_system_identifier_state follows the spec 13.2.5.67 at https://html.spec.whatwg.org/multipage/parsing.html#after-doctype-system-identifier-state
fn (mut t Tokenizer) after_doctype_system_identifier_state() []Token {
	t.consume() or {
		mut tok := &(t.token as DoctypeToken)
		tok.force_quirks = true
		t.state = .eof
		return [t.token, EOFToken{
			mssg: ParseError.eof_in_doctype.str()
		}]
	}

	if t.char in whitespace {
		return t.after_doctype_system_identifier_state()
	}

	if t.char == `>` {
		t.state = .data
		return [t.token]
	}

	println(ParseError.unexpected_character_after_doctype_system_identifier)
	t.reconsume()
	t.state = .bogus_doctype
	return t.bogus_doctype_state()
}

// bogus_doctype_state follows the spec 13.2.5.68 at https://html.spec.whatwg.org/multipage/parsing.html#bogus-doctype-state
fn (mut t Tokenizer) bogus_doctype_state() []Token {
	t.consume() or {
		t.state = .eof
		return [t.token, EOFToken{}]
	}

	if t.char == `>` {
		t.state = .data
		return [t.token]
	}

	if t.char == null {
		println(ParseError.unexpected_null_character)
		return t.bogus_doctype_state()
	}

	return t.bogus_doctype_state()
}

// cdata_section_state follows the spec 13.2.5.69 at https://html.spec.whatwg.org/multipage/parsing.html#cdata-section-state
fn (mut t Tokenizer) cdata_section_state() []Token {
	t.consume() or {
		println(ParseError.eof_in_cdata)
		t.state = .eof
		return [EOFToken{}]
	}

	if t.char == `]` {
		t.state = .cdata_section_bracket
		return t.cdata_section_bracket_state()
	}

	return [CharacterToken(t.char)]
}

// cdata_section_bracket_state follows the spec 13.2.5.70 at https://html.spec.whatwg.org/multipage/parsing.html#cdata-section-bracket-state
fn (mut t Tokenizer) cdata_section_bracket_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .cdata_section
		return [Token(CharacterToken(`]`))]
	}

	t.consume() or { return anything_else() }

	if t.char == `]` {
		t.state = .cdata_section_end
		return t.cdata_section_end_state()
	}

	return anything_else()
}

// cdata_section_end_state follows the spec 13.2.5.71 at https://html.spec.whatwg.org/multipage/parsing.html#cdata-section-end-state
fn (mut t Tokenizer) cdata_section_end_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = .cdata_section_bracket
		return [Token(CharacterToken(`]`))]
	}

	t.consume() or { return anything_else() }

	if t.char == `]` {
		return [CharacterToken(`]`)]
	}

	if t.char == `>` {
		t.state = .data
		return t.data_state()
	}

	return anything_else()
}

// character_reference_state follows the spec 13.2.5.72 at https://html.spec.whatwg.org/multipage/parsing.html#character-reference-state
fn (mut t Tokenizer) character_reference_state() []Token {
	anything_else := fn [mut t] () []Token {
		toks := t.flush_codepoints()
		t.reconsume()
		t.state = t.return_state
		t.return_state = .@none
		return if toks.len == 0 {
			return []
		} else {
			toks
		}
	}

	t.consume() or { return anything_else() }

	if t.char in ascii_alphanumeric {
		t.reconsume()
		t.state = .named_character_reference
		return t.named_character_reference_state()
	}

	if t.char == `#` {
		t.buffer.write_rune(t.char)
		t.state = .numeric_character_reference
		return t.numeric_character_reference_state()
	}

	return anything_else()
}

// named_character_reference_state follows the spec 13.2.5.73 at https://html.spec.whatwg.org/multipage/parsing.html#named-character-reference-state
// NOTE: this is not implemented according to spec. I don't
// quite understand what exactly it wants me to do.
fn (mut t Tokenizer) named_character_reference_state() []Token {
	mut char_ref := new_builder(50)
	char_ref.write_rune(`&`)

	anything_else := fn [mut t] () []Token {
		toks := t.flush_codepoints()
		t.state = .ambiguous_ampersand
		return if toks.len > 0 { toks } else { t.ambiguous_ampersand_state() }
	}

	for {
		t.consume() or { return anything_else() }

		if t.char !in ascii_alpha {
			break
		}
		char_ref.write_rune(t.char)
	}

	if t.char in whitespace {
		println(ParseError.missing_semicolon_after_character_reference)
		t.char_ref_code = named_char_ref[char_ref.bytestr()] or {
			t.state = .ambiguous_ampersand
			return t.ambiguous_ampersand_state()
		}
		t.buffer.write_rune(t.char_ref_code)
		toks := t.flush_codepoints()
		t.state = t.return_state
		t.return_state = .@none
		return if toks.len > 0 { toks } else { []Token{} }
	}

	if t.char == `;` {
		char_ref.write_rune(`;`)
		t.char_ref_code = named_char_ref[char_ref.bytestr()] or {
			t.state = .ambiguous_ampersand
			return t.ambiguous_ampersand_state()
		}
		t.buffer.write_rune(t.char_ref_code)
		toks := t.flush_codepoints()
		t.state = t.return_state
		t.return_state = .@none
		return if toks.len > 0 { toks } else { []Token{} }
	}

	return anything_else()
}

// ambiguous_ampersand_state follows the spec 13.2.5.74 at https://html.spec.whatwg.org/multipage/parsing.html#ambiguous-ampersand-state
fn (mut t Tokenizer) ambiguous_ampersand_state() []Token {
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		t.state = t.return_state
		t.return_state = .@none
		return []
	}

	t.consume() or { return anything_else() }

	if t.char in ascii_alphanumeric {
		if t.return_state in [
			.attribute_value_double_quoted,
			.attribute_value_single_quoted,
			.attribute_value_unquoted,
		] {
			mut tok := &(t.token as TagToken)
			mut attr := &(tok.attributes[tok.attributes.len - 1])
			attr.value.write_rune(t.char)
			return t.ambiguous_ampersand_state()
		} else {
			return [CharacterToken(t.char)]
		}
	}

	if t.char == `;` {
		println(ParseError.unknown_named_character_reference)
		// t.reconsume()
		// t.state = t.return_state
		// t.return_state = .@none
		// return t.emit_token()
	}

	return anything_else()
}

// numeric_character_reference_state follows the spec 13.2.5.75 at https://html.spec.whatwg.org/multipage/parsing.html#numeric-character-reference-state
fn (mut t Tokenizer) numeric_character_reference_state() []Token {
	t.char_ref_code = 0
	anything_else := fn [mut t] () []Token {
		t.reconsume()
		return t.decimal_character_reference_start_state()
	}

	t.consume() or { return anything_else() }

	if t.char in [`x`, `X`] {
		t.buffer.write_rune(t.char)
		t.state = .hexadecimal_character_reference_start
		return t.hexadecimal_character_reference_start_state()
	}

	return anything_else()
}

// hexadecimal_character_reference_start_state follows the spec 13.2.5.76 at https://html.spec.whatwg.org/multipage/parsing.html#hexadecimal-character-reference-start-state
fn (mut t Tokenizer) hexadecimal_character_reference_start_state() []Token {
	anything_else := fn [mut t] () []Token {
		println(ParseError.absence_of_digits_in_numeric_character_reference)
		toks := t.flush_codepoints()
		t.reconsume()
		t.state = t.return_state
		t.return_state = .@none
		return if toks.len > 0 { toks } else { []Token{} }
	}

	t.consume() or { return anything_else() }

	if t.char in hex_digits_lower || t.char in hex_digits_upper {
		t.reconsume()
		t.state = .hexadecimal_character_reference
		return t.hexadecimal_character_reference_state()
	}

	return anything_else()
}

// decimal_character_reference_start_state follows the spec 13.2.5.77 at https://html.spec.whatwg.org/multipage/parsing.html#decimal-character-reference-start-state
fn (mut t Tokenizer) decimal_character_reference_start_state() []Token {
	anything_else := fn [mut t] () []Token {
		println(ParseError.absence_of_digits_in_numeric_character_reference)
		toks := t.flush_codepoints()
		t.reconsume()
		t.state = t.return_state
		t.return_state = .@none
		return if toks.len > 0 { toks } else { []Token{} }
	}

	t.consume() or { return anything_else() }

	if t.char in decimal_digits {
		t.reconsume()
		t.state = .decimal_character_reference
		return t.decimal_character_reference_state()
	}

	return anything_else()
}

// hexadecimal_character_reference_state follows the spec 13.2.5.78 at https://html.spec.whatwg.org/multipage/parsing.html#hexadecimal-character-reference-state
fn (mut t Tokenizer) hexadecimal_character_reference_state() []Token {
	anything_else := fn [mut t] () []Token {
		println(ParseError.missing_semicolon_after_character_reference)
		t.reconsume()
		t.state = .numeric_character_reference
		return t.numeric_character_reference_state()
	}

	t.consume() or { return anything_else() }

	if t.char in decimal_digits {
		t.char_ref_code *= 16
		t.char_ref_code += t.char - 0x0030
		return t.hexadecimal_character_reference_state()
	}

	if t.char in hex_digits_upper {
		t.char_ref_code *= 16
		t.char_ref_code += t.char - 0x0037
		return t.hexadecimal_character_reference_state()
	}

	if t.char in hex_digits_lower {
		t.char_ref_code *= 16
		t.char_ref_code += t.char - 0x0057
		return t.hexadecimal_character_reference_state()
	}

	if t.char == `;` {
		t.state = .numeric_character_reference_end
		return t.numeric_character_reference_end_state()
	}

	return anything_else()
}

// decimal_character_reference_state follows the spec 13.2.5.79 at https://html.spec.whatwg.org/multipage/parsing.html#decimal-character-reference-state
fn (mut t Tokenizer) decimal_character_reference_state() []Token {
	anything_else := fn [mut t] () []Token {
		println(ParseError.missing_semicolon_after_character_reference)
		t.reconsume()
		t.state = .numeric_character_reference_end
		return t.numeric_character_reference_end_state()
	}

	t.consume() or { return anything_else() }

	if t.char in decimal_digits {
		t.char_ref_code *= 10
		t.char_ref_code += t.char - 0x0030
		return t.decimal_character_reference_state()
	}

	if t.char == `;` {
		t.state = .numeric_character_reference_end
		return t.numeric_character_reference_end_state()
	}

	return anything_else()
}

// numeric_character_reference_end_state follows the spec 13.2.5.80 at https://html.spec.whatwg.org/multipage/parsing.html#numeric-character-reference-end-state
fn (mut t Tokenizer) numeric_character_reference_end_state() []Token {
	if t.char_ref_code == 0x00 {
		println(ParseError.null_character_reference)
		t.char_ref_code = 0xfffd
	} else if t.char_ref_code > 0x10ffff {
		println(ParseError.character_reference_outside_unicode_range)
		t.char_ref_code = 0xfffd
	} else if is_surrogate(t.char_ref_code) {
		println(ParseError.surrogate_character_reference)
		t.char_ref_code = 0xfffd
	} else if is_noncharacter(t.char_ref_code) {
		println(ParseError.noncharacter_character_reference)
	} else if t.char_ref_code == 0x0d
		|| (is_control(t.char_ref_code) && t.char_ref_code !in whitespace) {
		println(ParseError.control_character_reference)
		table := {
			rune(0x80): rune(0x20ac)
			0x82:       0x201a
			0x83:       0x0192
			0x84:       0x201e
			0x85:       0x2026
			0x86:       0x2020
			0x87:       0x2021
			0x88:       0x02c6
			0x89:       0x2030
			0x8a:       0x0160
			0x8b:       0x2039
			0x8c:       0x0152
			0x8e:       0x017d
			0x91:       0x2018
			0x92:       0x2019
			0x93:       0x201c
			0x94:       0x201d
			0x95:       0x2022
			0x96:       0x2013
			0x97:       0x2014
			0x98:       0x02dc
			0x99:       0x2122
			0x9a:       0x0161
			0x9b:       0x203a
			0x9c:       0x0153
			0x9e:       0x017e
			0x9f:       0x0178
		}
		t.char_ref_code = table[t.char_ref_code] or { t.char_ref_code }
	}

	t.buffer = new_builder(10)
	t.buffer.write_rune(t.char_ref_code)
	toks := t.flush_codepoints()
	t.state = t.return_state
	t.return_state = .@none
	return if toks.len > 0 { toks } else { []Token{} }
}
