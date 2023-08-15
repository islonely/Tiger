module parser

import dom
import net.http

enum InsertionMode {
	@none
	after_after_body
	after_after_frameset
	after_body
	after_frameset
	after_head
	before_head
	before_html
	initial
	in_body
	in_caption
	in_cell
	in_column_group
	in_frameset
	in_head
	in_head_no_script
	in_row
	in_select
	in_select_in_table
	in_table
	in_table_body
	in_table_text
	in_template
	text
}

// Parser parses the tokens emitted from the Tokenizer.
struct Parser {
	source []rune
mut:
	tokenizer                Tokenizer
	insertion_mode           InsertionMode = .initial
	original_insertion_mode  InsertionMode = .@none
	template_insertion_modes []InsertionMode
	open_elems               dom.ElementStack
	doc                      ?&dom.Document
	// adjusted_current_node    &dom.Node
	curr_tok				 Token
	next_tok 				 Token
}

// new instantiates a Parser
pub fn new(src []rune) Parser {
	return Parser{
		source: src
		tokenizer: Tokenizer{
			source: src
		}
	}
}

pub fn new_url(url string) Parser {
	src := http.get_text(url).runes()
	return new(src)
}

// parse parses the tokens emitted from the Tokenizer.
pub fn (mut p Parser) parse() {
	p.curr_tok = p.tokenizer.emit_token()
	p.next_tok = p.tokenizer.emit_token()
	for p.tokenizer.state != .eof {
		print(p.curr_tok.html())
		if p.open_elems.len == 0 {

		} // else if p.adjusted_current_node is an element in the HTML namespace {
		// } else if p.adjusted_current_node is a MathML text integration point and the token is a start tag whose tag name is neither "mglyph" nor "malignmark" {
		// } else if p.adjusted_current_node is a MathML text integration point and the token is a character token {
		// } else if p.adjusted_current_node is a MathML annotation-xml element and the token is a start tag whose tag name is "svg" {
		// } else if p.adjusted_current_node is an HTML integration point and the token is a start tag {
		// } else if p.adjusted_current_node is an HTML integration point and the token is a character token {
		// }
		else if p.curr_tok is EOFToken {
			p.parse_eof_token()
		} else {

		}
		p.curr_tok = p.next_tok
		p.next_tok = p.tokenizer.emit_token()
	}
}

// parse_character_token parses CharacterToken's emitted from the Tokenizer.
fn (mut p Parser) parse_character_token() {
}

// parse_comment_token parses CommentToken's emitted from the Tokenizer.
fn (mut p Parser) parse_comment_token() {
}

// parse_doctype_token parses DoctypeToken's emitted from the Tokenizer.
fn (mut p Parser) parse_doctype_token() {
}

// parse_tag_token parses TagToken's emitted from the Tokenizer.
fn (mut p Parser) parse_tag_token() {
}

// parse_eof_token parses EOFToken's emitted from the Tokenizer.
fn (mut p Parser) parse_eof_token() {
}

// parse_foreign_content
fn (mut p Parser) parse_foreign_content() {
}
