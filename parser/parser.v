module parser

import datatypes { Stack }

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

struct Parser {
	source []rune
mut:
	tokenizer Tokenizer
	insertion_mode InsertionMode = .initial
	original_insertion_mode InsertionMode = .@none
	template_insertion_modes Stack<InsertionMode>
}

pub fn new(src []rune) Parser {
	return Parser{
		source: src
		tokenizer: Tokenizer{source: src}
	}
}

pub fn (mut p Parser) run() {
	for p.tokenizer.state != .eof {
		tokens := p.tokenizer.emit_token()
		for tok in tokens {
			match tok {
				CharacterToken {
					print(tok)
				}
				CommentToken {
					println(tok)
				}
				DoctypeToken {
					println(tok)
				}
				TagToken {
					println(tok)
				}
				EOFToken {
					println(tok)
				}
			}
		}
	}
}