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

// Parser.from_runes instantiates a Parser from the source rune array.
pub fn Parser.from_runes(src []rune) Parser {
	return Parser{
		source: src
		tokenizer: Tokenizer{
			source: src
		}
	}
}

// Parser.from_url instantiates a Parser from the contents at the provided URL
// or returns an error upon network failure or status code other than 200.
pub fn Parser.from_url(url string) !Parser {
	res := http.get(url)!
	if res.status_code != 200 {
		return error('URL get request returned status code ${res.status_code}: ${res.status_msg}')
	}
	return Parser.from_runes(res.body.runes())
}

// parse parses the tokens emitted from the Tokenizer.
pub fn (mut p Parser) parse() {
	p.curr_tok = p.tokenizer.emit_token()
	p.next_tok = p.tokenizer.emit_token()
	for p.tokenizer.state != .eof {
		print(p.curr_tok.html())
		
		match p.insertion_mode {
			.@none {}
			.after_after_body {}
			.after_after_frameset {}
			.after_body {}
			.after_frameset {}
			.after_head {}
			.before_head {}
			.before_html { p.before_html_insertion_mode() }
			.initial {}
			.in_body {}
			.in_caption {}
			.in_cell {}
			.in_column_group {}
			.in_frameset {}
			.in_head {}
			.in_head_no_script {}
			.in_row {}
			.in_select {}
			.in_select_in_table {}
			.in_table {}
			.in_table_body {}
			.in_table_text {}
			.in_template {}
			.text {}
		}
		
		p.consume_token()
	}
}

// consume_token sets the current token to the next token
// and gets the next token from the tokenizer.
fn (mut p Parser) consume_token() {
	p.curr_tok = p.next_tok
	p.next_tok = p.tokenizer.emit_token()
}

fn (mut p Parser) before_html_insertion_mode() {

}