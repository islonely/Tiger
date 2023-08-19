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

// Parser parses the tokens emitted from the Tokenizer and creates
// a document tree which is returned from `fn (mut Parser) parse`.
struct Parser {
mut:
	tokenizer                Tokenizer
	insertion_mode           InsertionMode = .initial
	original_insertion_mode  InsertionMode = .@none
	template_insertion_modes []InsertionMode
	open_elems               dom.ElementStack
	doc                      &dom.Document = &dom.Document{}
	// adjusted_current_NodeBase    &dom.NodeBase
	current_token   Token
	next_token      Token
	reconsume_token bool
}

// Parser.from_string instantiates a Parser from the source string.
[inline]
pub fn Parser.from_string(src string) Parser {
	return Parser.from_runes(src.runes())
}

// Parser.from_runes instantiates a Parser from the source rune array.
pub fn Parser.from_runes(src []rune) Parser {
	mut p := Parser{
		tokenizer: Tokenizer{
			source: src
		}
	}
	p.current_token, p.next_token = p.tokenizer.emit_token(), p.tokenizer.emit_token()
	return p
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

// parse parses the tokens emitted from the Tokenizer and returns
// the document tree of the parsed content or `none`.
pub fn (mut p Parser) parse() &dom.Document {
	for p.tokenizer.state != .eof {
		match p.insertion_mode {
			.@none {}
			.after_after_body {}
			.after_after_frameset {}
			.after_body {}
			.after_frameset {}
			.after_head {}
			.before_head {}
			.before_html { p.before_html_insertion_mode() }
			.initial { p.initial_insertion_mode() }
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

		if p.reconsume_token {
			p.reconsume_token = false
		} else {
			p.consume_token()
		}
	}

	return p.doc
}

// consume_token sets the current token to the next token
// and gets the next token from the tokenizer.
[inline]
fn (mut p Parser) consume_token() {
	p.current_token, p.next_token = p.next_token, p.tokenizer.emit_token()
}

// before_html_insertion mode is the mode the parser is in when
// `Parser.next_token` is an open tag HTML tag (<html>).
fn (mut p Parser) before_html_insertion_mode() {
}

// initial_insertion_mode is the mode that the parser starts in. From
// here it goes to another mode and should never return to this mode.
fn (mut p Parser) initial_insertion_mode() {
	match mut p.current_token {
		CharacterToken {
			if p.current_token in whitespace {
				return
			}
		}
		CommentToken {
			t := p.current_token as CommentToken
			mut child := &dom.CommentNode{
				text: t.data()
				owner_document: p.doc
			}
			p.doc.append_child(child)
		}
		DoctypeToken {
			if p.current_token.name() != 'html' {
				put(text: 'invalid doctype name: ${p.current_token.html()}')
			}
			if p.current_token.public_identifier != doctype_missing {
				put(text: 'public identifier is not missing: ${p.current_token.html()}')
			}
			if p.current_token.system_identifier !in [doctype_missing, 'about:legacy-compat'.bytes()] {
				put(
					text: 'system identifier is not missing or "about:legacy-compat": ${p.current_token.html()}'
				)
			}

			mut doctype := &dom.DocumentType{
				name: p.current_token.name.str()
				public_id: p.current_token.public_identifier.str()
				system_id: p.current_token.system_identifier.str()
				owner_document: p.doc
			}
			p.doc.append_child(doctype)
			p.doc.doctype = doctype

			pid_matches := [
				'-//W3O//DTD W3 HTML Strict 3.0//EN//',
				'-/W3C/DTD HTML 4.0 Transitional/EN',
				'HTML',
			]
			pid_starts_with := [
				'+//Silmaril//dtd html Pro v0r11 19970101//',
				'-//AS//DTD HTML 3.0 asWedit + extensions//',
				'-//AdvaSoft Ltd//DTD HTML 3.0 asWedit + extensions//',
				'-//IETF//DTD HTML 2.0 Level 1//',
				'-//IETF//DTD HTML 2.0 Level 2//',
				'-//IETF//DTD HTML 2.0 Strict Level 1//',
				'-//IETF//DTD HTML 2.0 Strict Level 2//',
				'-//IETF//DTD HTML 2.0 Strict//',
				'-//IETF//DTD HTML 2.0//',
				'-//IETF//DTD HTML 2.1E//',
				'-//IETF//DTD HTML 3.0//',
				'-//IETF//DTD HTML 3.2 Final//',
				'-//IETF//DTD HTML 3.2//',
				'-//IETF//DTD HTML 3//',
				'-//IETF//DTD HTML Level 0//',
				'-//IETF//DTD HTML Level 1//',
				'-//IETF//DTD HTML Level 2//',
				'-//IETF//DTD HTML Level 3//',
				'-//IETF//DTD HTML Strict Level 0//',
				'-//IETF//DTD HTML Strict Level 1//',
				'-//IETF//DTD HTML Strict Level 2//',
				'-//IETF//DTD HTML Strict Level 3//',
				'-//IETF//DTD HTML Strict//',
				'-//IETF//DTD HTML//',
				'-//Metrius//DTD Metrius Presentational//',
				'-//Microsoft//DTD Internet Explorer 2.0 HTML Strict//',
				'-//Microsoft//DTD Internet Explorer 2.0 HTML//',
				'-//Microsoft//DTD Internet Explorer 2.0 Tables//',
				'-//Microsoft//DTD Internet Explorer 3.0 HTML Strict//',
				'-//Microsoft//DTD Internet Explorer 3.0 HTML//',
				'-//Microsoft//DTD Internet Explorer 3.0 Tables//',
				'-//Netscape Comm. Corp.//DTD HTML//',
				'-//Netscape Comm. Corp.//DTD Strict HTML//',
				"-//O'Reilly and Associates//DTD HTML 2.0//",
				"-//O'Reilly and Associates//DTD HTML Extended 1.0//",
				"-//O'Reilly and Associates//DTD HTML Extended Relaxed 1.0//",
				'-//SQ//DTD HTML 2.0 HoTMetaL + extensions//',
				'-//SoftQuad Software//DTD HoTMetaL PRO 6.0::19990601::extensions to HTML 4.0//',
				'-//SoftQuad//DTD HoTMetaL PRO 4.0::19971010::extensions to HTML 4.0//',
				'-//Spyglass//DTD HTML 2.0 Extended//',
				'-//Sun Microsystems Corp.//DTD HotJava HTML//',
				'-//Sun Microsystems Corp.//DTD HotJava Strict HTML//',
				'-//W3C//DTD HTML 3 1995-03-24//',
				'-//W3C//DTD HTML 3.2 Draft//',
				'-//W3C//DTD HTML 3.2 Final//',
				'-//W3C//DTD HTML 3.2//',
				'-//W3C//DTD HTML 3.2S Draft//',
				'-//W3C//DTD HTML 4.0 Frameset//',
				'-//W3C//DTD HTML 4.0 Transitional//',
				'-//W3C//DTD HTML Experimental 19960712//',
				'-//W3C//DTD HTML Experimental 970421//',
				'-//W3C//DTD W3 HTML//',
				'-//W3O//DTD W3 HTML 3.0//',
				'-//WebTechs//DTD Mozilla HTML 2.0//',
				'-//WebTechs//DTD Mozilla HTML//',
			]
			pid_starts_with_if_sysid_missing := [
				'-//W3C//DTD HTML 4.01 Frameset//',
				'-//W3C//DTD HTML 4.01 Transitional//',
			]
			if /* p.doc is not iframe srcdoc document && */ !p.doc.parser_cannot_change_mode
				&& (p.current_token.force_quirks || doctype.name != 'html') {
				p.doc.mode = .quirks
			}
			if doctype.public_id in pid_matches {
				p.doc.mode = .quirks
			}
			for val in pid_starts_with {
				if doctype.public_id.starts_with(val) {
					p.doc.mode = .quirks
					break
				}
			}
			for val in pid_starts_with_if_sysid_missing {
				if p.current_token.system_identifier == doctype_missing
					&& doctype.public_id.starts_with(val) {
					p.doc.mode = .quirks
					break
				}
			}
			if p.doc.mode != .quirks {
				if /* p.doc is not iframe srcdoc document && */ !p.doc.parser_cannot_change_mode
					&& (doctype.public_id.starts_with('-//W3C//DTD XHTML 1.0 Frameset//')
					|| doctype.public_id.starts_with('-//W3C//DTD XHTML 1.0 Transitional//')
					|| (p.current_token.system_identifier == doctype_missing
					&& doctype.public_id.starts_with('-//W3C//DTD HTML 4.01 Frameset//'))
					|| (p.current_token.system_identifier == doctype_missing
					&& doctype.public_id.starts_with('-//W3C//DTD HTML 4.01 Transitional//'))) {
					p.doc.mode = .limited_quirks
				}
			}
			p.insertion_mode = .before_html
		}
		else {
			if /* p.doc is not iframe srcdoc document && */ !p.doc.parser_cannot_change_mode {
				p.doc.mode = .quirks
				// parse error if no iframe srcdoc document
			}
			p.insertion_mode = .before_html
		}
	}
}
