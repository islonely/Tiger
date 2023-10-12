module parser

import dom
import net.http

// DOCTYPE conditions; see `fn Parser.initial_insertion_mode()`
const (
	public_id_matches                          = [
		'-//W3O//DTD W3 HTML Strict 3.0//EN//',
		'-/W3C/DTD HTML 4.0 Transitional/EN',
		'HTML',
	]
	public_id_starts_with                      = [
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
	public_id_starts_with_if_system_id_missing = [
		'-//W3C//DTD HTML 4.01 Frameset//',
		'-//W3C//DTD HTML 4.01 Transitional//',
	]
)

const implied_end_tag_names = ['caption', 'colgroup', 'dd', 'li', 'optgroup', 'option',
	'p', 'rb', 'rp', 'rt', 'rtc', 'tbody', 'td', 'tfoot', 'th', 'thead']

// todo: include mathml and svg tags
const special_tag_names = ['address', 'applet', 'area', 'article', 'aside', 'base',
	'basefont', 'bgsound', 'blockquote', 'body', 'br', 'button', 'caption', 'center',
	'col', 'colgroup', 'dd', 'details', 'dir', 'div', 'dl', 'dt', 'embed', 'fieldset',
	'figcaption', 'figure', 'footer', 'form', 'frame', 'frameset', 'h1', 'h2', 'h3',
	'h4', 'h5', 'h6', 'head', 'header', 'hgroup', 'hr', 'html', 'iframe', 'img',
	'input', 'isindex', 'li', 'link', 'listing', 'main', 'marquee', 'menu', 'meta',
	'nav', 'noembed', 'noframes', 'noscript', 'object', 'ol', 'p', 'param', 'plaintext',
	'pre', 'script', 'section', 'select', 'source', 'style', 'summary', 'table', 'tbody',
	'td', 'template', 'textarea', 'tfoot', 'th', 'thead', 'title', 'tr', 'track',
	'ul', 'wbr', 'xmp']

// InsertionMode is the mode the parser will parse the token in.
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

// https://html.spec.whatwg.org/multipage/parsing.html#the-list-of-active-formatting-elements
pub enum AFEMarker {
	applet
	object
	marquee
	template
	td
	th
	caption
}

pub type ActiveFormattingElements = AFEMarker | dom.HTMLElement

// https://html.spec.whatwg.org/multipage/parsing.html#other-parsing-state-flags
pub enum ScriptingFlag {
	enabled
	disabled
}

// https://html.spec.whatwg.org/multipage/parsing.html#other-parsing-state-flags
pub enum FramesetOKFlag {
	ok
	not_ok
}

// OpenElements is a stack of open elements.
pub type OpenElements = []&dom.NodeInterface

// has_by_tag_name searches the open elements for a tag with the given tag name
// and returns true if it's found; false if not.
pub fn (open_elements OpenElements) has_by_tag_name(tag_names ...string) bool {
	for element in open_elements {
		el := &dom.HTMLElement(element)
		// todo: THIS FUNCTION DOES NOT WORK!
		// println(term.bright_bg_green(el.tag_name))
		if el.tag_name in tag_names {
			return true
		}
	}
	return false
}

// has searches the open elements for the given element and returns true
// if it's found; false if not.
pub fn (open_elements OpenElements) has(looking_for voidptr) bool {
	for element in open_elements {
		if voidptr(element) == looking_for {
			return true
		}
	}
	return false
}

// Parser parses the tokens emitted from the Tokenizer and creates
// a document tree which is returned from `fn (mut Parser) parse`.
[heap]
struct Parser {
mut:
	tokenizer                Tokenizer
	insertion_mode           InsertionMode = .initial
	original_insertion_mode  InsertionMode = .@none
	scripting                ScriptingFlag = .disabled
	frameset_ok              FramesetOKFlag = .ok
	template_insertion_modes []InsertionMode
	open_elems               OpenElements
	active_formatting_elems  []&ActiveFormattingElements
	active_speculative_html_parser ?&Parser
	doc                      &dom.Document = dom.Document.new()
	// adjusted_current_NodeBase    &dom.NodeBase
	last_token      Token
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
	mut p := Parser.from_runes(res.body.runes())
	p.doc.base_uri = url
	return p
}

// parse parses the tokens emitted from the Tokenizer and returns
// the document tree of the parsed content or `none`.
pub fn (mut p Parser) parse() &dom.Document {
	for p.tokenizer.state != .eof {
		match p.insertion_mode {
			.@none { return p.doc}
			.after_after_body {}
			.after_after_frameset {}
			.after_body { p.in_body_insertion_mode() }
			.after_frameset {}
			.after_head { p.after_head_insertion_mode() }
			.before_head { p.before_head_insertion_mode() }
			.before_html { p.before_html_insertion_mode() }
			.initial { p.initial_insertion_mode() }
			.in_body { p.in_body_insertion_mode() }
			.in_caption {}
			.in_cell {}
			.in_column_group {}
			.in_frameset {}
			.in_head { p.in_head_insertion_mode() }
			.in_head_no_script { p.in_head_no_script_insertion_mode() }
			.in_row {}
			.in_select {}
			.in_select_in_table {}
			.in_table {}
			.in_table_body {}
			.in_table_text {}
			.in_template { p.in_template_insertion_mode() }
			.text { p.text_insertion_mode() }
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
	p.last_token, p.current_token, p.next_token = p.current_token, p.next_token, p.tokenizer.emit_token()
}

// before_html_insertion mode is the mode the parser is in when
// `Parser.next_token` is an open tag HTML tag (<html>).
// https://html.spec.whatwg.org/multipage/parsing.html#the-before-html-insertion-mode
fn (mut p Parser) before_html_insertion_mode() {
	anything_else := fn [mut p] () {
		mut child := dom.HTMLElement.new(p.doc, 'html')
		p.open_elems << child
		p.insertion_mode = .before_head
		p.reconsume_token = true
	}
	match mut p.current_token {
		DoctypeToken {
			put(
				typ: .notice,
				text: 'Ignoring DOCTYPE token.'
			)
		}
		CommentToken {
			mut child := dom.CommentNode.new(p.doc, p.current_token.data())
			p.doc.append_child(child)
		}
		CharacterToken {
			if p.current_token in whitespace {
			} else {
				anything_else()
			}
		}
		TagToken {
			if p.current_token.is_start {
				if p.current_token.name() == 'html' {
					p.insert_html_element()
					p.insertion_mode = .before_head
				} else {
					anything_else()
				}
			} else {
				if p.current_token.name() in ['head', 'body', 'html', 'br'] {
					anything_else()
				} else {
					put(
						typ: .notice,
						text: 'Ignoring end tag token: ${p.current_token.html}'
					)
				}
			}
		}
		else {
			anything_else()
		}
	}
}

// initial_insertion_mode is the mode that the parser starts in. From
// here it goes to another mode and should never return to this mode.
// https://html.spec.whatwg.org/multipage/parsing.html#the-initial-insertion-mode
fn (mut p Parser) initial_insertion_mode() {
	match mut p.current_token {
		CharacterToken {
			if p.current_token in whitespace {
				return
			}
		}
		CommentToken {
			mut child := dom.CommentNode.new(p.doc, p.current_token.data())
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
				node_type: .document_type
				name: p.current_token.name.str()
				public_id: p.current_token.public_identifier.str()
				system_id: p.current_token.system_identifier.str()
				owner_document: p.doc
			}
			p.doc.append_child(doctype)
			p.doc.doctype = doctype

			if /* p.doc is not iframe srcdoc document && */ !p.doc.parser_cannot_change_mode
				&& (p.current_token.force_quirks || doctype.name != 'html') {
				p.doc.mode = .quirks
			}
			if doctype.public_id in parser.public_id_matches {
				p.doc.mode = .quirks
			}
			for val in parser.public_id_starts_with {
				if doctype.public_id.starts_with(val) {
					p.doc.mode = .quirks
					break
				}
			}
			for val in parser.public_id_starts_with_if_system_id_missing {
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

// before_head_insertion_mode
// https://html.spec.whatwg.org/multipage/parsing.html#the-before-head-insertion-mode
fn (mut p Parser) before_head_insertion_mode() {
	anything_else := fn [mut p] () {
		mut child := dom.HTMLHeadElement.new(p.doc)
		p.doc.head = child
		mut last := p.open_elems.last()
		last.append_child(child)
		p.insertion_mode = .in_head
		return
	}
	match mut p.current_token {
		CharacterToken {
			if p.current_token in parser.whitespace {
				return
			}

			anything_else()
		}
		CommentToken {
			p.insert_comment()
		}
		DoctypeToken {
			put(
				typ: .notice
				text: 'Invalid DOCTYPE token. Ignoring token.'
			)
		}
		TagToken {
			if p.current_token.is_start {
				if p.current_token.name() == 'html' {
					p.in_body_insertion_mode()
					return
				}

				if p.current_token.name() == 'head' {
					p.insert_html_element()
					p.insertion_mode = .in_head
					return
				}

				anything_else()
				return
			}
			
			if p.current_token.name() in ['head', 'body', 'html', 'br'] {
				anything_else()
				return
			}

			put(
				typ: .notice
				text: 'Invalid end tag token. Ignoring token.'
			)
		}
		else {
			anything_else()
		}
	}
}

// in_head_insertion_mode
// https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inhead
fn (mut p Parser) in_head_insertion_mode() {
	anything_else := fn [mut p] () {
		// popped item should be head element
		p.open_elems.pop()
		p.insertion_mode = .after_head
		p.reconsume_token = true
	}

	match mut p.current_token {
		CharacterToken {
			if p.current_token in parser.whitespace {
				p.insert_text(p.current_token.str())
			}
		}
		CommentToken {
			p.insert_comment()
		}
		DoctypeToken {
			put(
				typ: .notice
				text: 'Invalid DOCTYPE token. Ignoring token.'
			)
		}
		TagToken {
			mut last_opened_elem := p.open_elems.last()
			tag_name := p.current_token.name()
			if p.current_token.is_start {
				if tag_name == 'html' {
					p.in_body_insertion_mode()
				} else if tag_name in ['base', 'basefont', 'bgsound', 'link'] {
					p.insert_html_element()
					// Spec says to immediately pop it.
					// https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inhead
					p.open_elems.pop()
				} else if tag_name == 'meta' {
					p.insert_html_element()
					p.open_elems.pop()

					// todo: implement substeps 1 and 2 from
					// https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inhead
				} else if tag_name == 'title' {
					// https://html.spec.whatwg.org/multipage/parsing.html#generic-rcdata-element-parsing-algorithm
					p.insert_html_element()
					p.tokenizer.state = .rcdata
					p.original_insertion_mode = p.insertion_mode
					p.insertion_mode = .text
				} else if (tag_name == 'noscript' && p.doc.scripting) || tag_name in ['noframes', 'style'] {
					p.insert_html_element()
					p.tokenizer.state = .rawtext
					p.original_insertion_mode = p.insertion_mode
					p.insertion_mode = .text
				} else if tag_name == 'noscript' && !p.doc.scripting {
					p.insert_html_element()
					p.insertion_mode = .in_head_no_script
				} else if tag_name == 'script' {
					mut child := dom.HTMLScriptElement.new(p.doc)
					child.namespace_uri = dom.namespaces[dom.NamespaceURI.html]
					child.force_async = false
					// "if the parser was created as part of the HTML fragment parsing algorithm
					// then set the script element's already started to true"
					// "If the parser was invoked via the document.write() or document.writeln()
					// methods, then optionally set the script element's already started to true.
					// (For example, the user agent might use this clause to prevent execution of
					// cross-origin scripts inserted via document.write() under slow network conditions,
					// or when the page has already taken a long time to load.)"
					last_opened_elem.append_child(child)
					for attribute in p.current_token.attributes {
						child.attributes[attribute.name()] = attribute.value()
					}
					p.open_elems << child
					p.tokenizer.state = .script_data
					p.original_insertion_mode = p.insertion_mode
					p.insertion_mode = .text
				} else if tag_name == 'template' {
					p.insert_html_element()
					p.active_formatting_elems << AFEMarker.template
					p.frameset_ok = .not_ok
					p.insertion_mode = .in_template
					p.template_insertion_modes << .in_template
				} else if tag_name == 'head' {
					put(
						typ: .warning
						text: 'Unexpected head tag <head>: ignoring token.'
					)
				} else {
					anything_else()
				}
			} else { // end tag
				if tag_name == 'head' {
					_ := p.open_elems.pop()
					p.insertion_mode = .after_head
					return
				} else if tag_name in ['body', 'html', 'br'] {
					anything_else()
					return
				} else if tag_name == 'template' {
					if !p.open_elems.has_by_tag_name('template') {
						put(
							typ: .warning
							text: 'Unexpected </template> tag token; ingoring token.'
						)
						return
					}

					p.generate_all_implied_end_tags_thorougly()
					if p.open_elems.len == 0 {
						put(
							typ: .warning
							text: 'Unexpected </template> tag token; ignoring token.'
						)
						return
					}
					mut template_element := p.open_elems.last()
					if &dom.HTMLElement(template_element).tag_name != 'template' {
						put(
							typ: .warning
							text: 'Current node is not a <template> tag.'
						)
					}
					for &dom.HTMLElement(template_element).tag_name != 'template' {
						if p.open_elems.len == 0 {
							put(
								typ: .warning
								text: 'There were no <template> tags in the parser\'s stack of open elements.'
							)
							break
						}
						template_element = p.open_elems.pop()
					}
					p.clear_active_formatting_elements_to_last_marker()
					if p.template_insertion_modes.len != 0 {
						p.template_insertion_modes.pop()
					} else {
						put(
							typ: .warning
							text: 'There were no items on the parer\'s stack of template insertion modes.'
						)
					}
					p.reset_insertion_mode_appropriately()
				} else {
					put(
						typ: .warning
						text: 'Unexpected end tag </${tag_name}>: ignoring token.'
					)
				}
			}
		}
		else {
			anything_else()
		}
	}
}

// https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inheadnoscript
fn (mut p Parser) in_head_no_script_insertion_mode() {
	anything_else := fn [mut p] () {
		put(
			typ: .warning
			text: 'Parse error: ${p.insertion_mode}'
		)
		// Should be a noscript element and the last item in p.open_elems
		// should now be the head element.
		p.open_elems.pop()
		p.insertion_mode = .in_head
		p.reconsume_token = true
	}

	match mut p.current_token {
		DoctypeToken {
			put(
				typ: .warning
				text: 'Unexpected doctype tag: ignoring token.'
			)
		}
		TagToken {
			tag_name := p.current_token.name()
			if p.current_token.is_start {
				if tag_name == 'html' {
					p.in_body_insertion_mode()
				} else if tag_name in ['basefont', 'bgsound', 'link', 'meta', 'noframes', 'style'] {
					p.in_head_insertion_mode()
				} else if tag_name in ['head', 'noscript'] {
					put(
						typ: .warning
						text: 'Unexpected start tag <${tag_name}>: ignoring token.'
					)
				}
			} else {
				if tag_name == 'noscript' {
					// Should be a noscript element and the last item in p.open_elems
					// should now be the head element.
					p.open_elems.pop()
					p.insertion_mode = .in_head
				} else if tag_name == 'br' {
					anything_else()
				} else {
					put(
						typ: .warning
						text: 'Unexpected end tag </${tag_name}>: ignoring token.'
					)
				}
			}
		}
		CharacterToken {
			if p.current_token in parser.whitespace {
				p.in_head_insertion_mode()
			}
		}
		CommentToken {
			p.in_head_insertion_mode()
		}
		else {
			anything_else()
		}
	}
}

// https://html.spec.whatwg.org/multipage/parsing.html#the-after-head-insertion-mode
fn (mut p Parser) after_head_insertion_mode() {
	anything_else := fn [mut p] () {
		mut child := dom.HTMLElement.new(p.doc, 'body')
		p.doc.body = &dom.HTMLBodyElement(child)
		mut last_opened_element := p.open_elems.last()
		last_opened_element.append_child(child)
		p.open_elems << child
		p.insertion_mode = .in_body
	}

	match mut p.current_token {
		CharacterToken {
			if p.current_token in parser.whitespace {
				p.insert_text(p.current_token.str())
			}
		}
		CommentToken {
			p.insert_comment()
		}
		DoctypeToken {
			put(
				typ: .warning
				text: 'Unexpected doctype token: ignoring token.'
			)
		}
		TagToken {
			tag_name := p.current_token.name()
			if p.current_token.is_start {
				if tag_name == 'html' {
					p.in_body_insertion_mode()
				} else if tag_name == 'body' {
					p.insert_html_element()
					p.doc.body = &dom.HTMLBodyElement(p.open_elems.last())
					p.frameset_ok = .not_ok
					p.insertion_mode = .in_body
				} else if tag_name == 'frameset' {
					p.insert_html_element()
					p.insertion_mode = .in_frameset
				} else if tag_name in ['base', 'basefont', 'bgsound', 'link', 'meta', 'noframes', 'script', 'style', 'template', 'title'] {
					put(
						typ: .warning
						text: 'Unexpected start tag <${tag_name}>: ignoring token.'
					)
					if head := p.doc.head {
						p.open_elems << head
						p.in_head_insertion_mode()
						for p.open_elems.len > 0 {
							if voidptr(p.open_elems.last()) == voidptr(head) {
								p.open_elems.pop()
								break
							}
						}
						put(
							typ: .warning
							text: 'No head element found in document.'
						)
					} else {
						put(
							typ: .warning
							text: 'No head element found in document.'
						)
					}
				} else if tag_name == 'head' {
					put(
						typ: .warning
						text: 'Unexpected start tag <head>: ignoring token.'
					)
				} else {
					anything_else()
				}
				
			} else { // end tag
				if tag_name == 'template' {
					p.in_head_insertion_mode()
				} else if tag_name in ['body', 'html', 'br'] {
					anything_else()
				} else {
					put(
						typ: .warning
						text: 'Unexpected end tag </${tag_name}>: ignoring token.'
					)
				}
			}
		}
		else {
			anything_else()
		}
	}
}

// https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inbody
fn (mut p Parser) in_body_insertion_mode() {
	match mut p.current_token {
		CharacterToken {
			if p.current_token == rune(0) {
				put(
					typ: .warning
					text: 'Unexpected null character token: ignoring token.'
				)
			} else if p.current_token in parser.whitespace {
				p.reconstruct_active_formatting_elements()
				p.insert_text(p.current_token.str())
			} else {
				p.reconstruct_active_formatting_elements()
				p.insert_text(p.current_token.str())
				p.frameset_ok = .not_ok
			}
		}
		CommentToken {
			p.insert_comment()
		}
		DoctypeToken {
			put(
				typ: .warning
				text: 'Unexpected doctype token: ignoring token.'
			)
		}
		TagToken {
			tag_name := p.current_token.name()
			if p.current_token.is_start {
				match tag_name {
					'html' {
						put_prefix := put(
							typ: .warning
							text: 'Unexpected start tag <html>'
							newline: false
							print: false
						)
						if p.open_elems.has_by_tag_name('template') {
							put(
								typ: .warning
								text: '${put_prefix}: ignoring token.'
							)
						} else {
							put(
								typ: .warning
								text: '${put_prefix}.'
							)
							// Adam: I've got to be misunderstanding something here. There's no way we're supposed
							// to just copy the attributes from an html start tag to the last opened element, right?
							//
							// Otherwise, for each attribute on the token, check to see if the attribute is
							// already present on the top element of the stack of open elements. If it is not,
							// add the attribute and its corresponding value to that element.
							for mut attr in p.current_token.attributes {
								if p.open_elems.len > 0 {
									mut last_opened_elem := &dom.HTMLElement(p.open_elems.last())
									last_opened_elem.attributes[attr.name.str()] = attr.value.str()
								}
							}
						}
					}
					'base', 'basefont', 'bgsound', 'link', 'meta', 'noframes', 'script', 'style', 'template', 'title' {
						p.in_head_insertion_mode()
					}
					'body' {
						put_prefix := put(
							typ: .warning
							text: 'Unexpected start tag <body>'
							newline: false
							print: false
						)
						second_elem_is_body := &dom.HTMLElement(p.open_elems[1] or {
							put(
								typ: .warning
								text: '${put_prefix}: ignoring token.'
							)
							return
						}).tag_name == 'body'
						if p.open_elems.len == 1 || !second_elem_is_body || p.open_elems.has_by_tag_name('template') {
							put(
								typ: .warning
								text: '${put_prefix}: ignoring token.'
							)
						} else {
							// Otherwise, set the frameset-ok flag to "not ok"; then, for each attribute on the token,
							// check to see if the attribute is already present on the body element (the second
							// element) on the stack of open elements, and if it is not, add the attribute and its
							// corresponding value to that element.
							p.frameset_ok = .not_ok
							for mut attr in p.current_token.attributes {
								if mut body := p.doc.body {
									attr_name := attr.name.str()
									if attr_name !in body.attributes {
										body.attributes[attr_name] = attr.value.str()
									}
								}
							}
						}
					}
					'frameset' {
						put_prefix := put(
							typ: .warning
							text: 'Unexpected start tag <frameset>'
							newline: false
							print: false
						)
						second_elem_is_body := &dom.HTMLElement(p.open_elems[1] or {
							put(
								typ: .warning
								text: '${put_prefix}: ignoring token.'
							)
							return
						}).tag_name == 'body'
						if p.open_elems.len == 1 || !second_elem_is_body || p.frameset_ok == .not_ok {
							put(
								typ: .warning
								text: '${put_prefix}: ignoring token.'
							)
						} else {
							// 1) Remove the second element on the stack of open elements from its parent node, if it has one.
							if p.open_elems.len >= 2 {
								p.open_elems.delete(1)
							}
							// 2) Pop all the nodes from the bottom of the stack of open elements, from the current node up to,
							// but not including, the root html element.
							for p.open_elems.len > 0 {
								if &dom.HTMLElement(p.open_elems.last()).tag_name == 'html' {
									break
								}
								_ := p.open_elems.pop()
							}
							// 3) Insert an HTML element for the token.
							mut child := dom.HTMLElement.new(p.doc, 'frameset')
							p.open_elems << child
							// 4) Switch the insertion mode to "in frameset".
							p.insertion_mode = .in_frameset
						}
					}
					'address', 'article', 'aside', 'blockquote', 'center', 'details', 'dialog', 'dir', 'div', 'dl', 'fieldset', 'figcaption', 'figure', 'footer', 'header', 'hgroup', 'main', 'menu', 'nav', 'ol', 'p', 'section', 'summary', 'ul' {
						// todo: has_element_in_scope
						// if p.has_element_in_button_scope('p') {
						// 	p.close_element('p')
						// }
						p.insert_html_element()
					}
					'h1', 'h2', 'h3', 'h4', 'h5', 'h6' {
						// todo: has_element_in_scope
						// if p.has_element_in_button_scope('p') {
						// 	p.close_element('p')
						// }
						if p.open_elems.len > 0 {
							if &dom.HTMLElement(p.open_elems.last()).tag_name in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'] {
								put(
									typ: .warning
									text: 'Unexpected start tag <${tag_name}>'
								)
								_ := p.open_elems.pop()
							}
						}
						p.insert_html_element()
					}
					'pre', 'listing' {
						// todo: has_element_in_scope
						// if p.has_element_in_button_scope('p') {
						// 	p.close_element('p')
						// }
						p.insert_html_element()
						if mut p.next_token is CharacterToken {
							linefeed := rune(0x000a)
							if p.next_token == linefeed {
								p.consume_token()
							}
						}
						p.frameset_ok = .not_ok
					}
					'form' {
						if p.doc.form != none {
							put(
								typ: .warning
								text: 'Unexpected start tag <form>: ignoring token.'
							)
						} else {
							// todo: has_element_in_scope
							// if p.has_element_in_button_scope('p') {
							// 	p.close_element('p')
							// }
							p.insert_html_element()
							if !p.open_elems.has_by_tag_name('template') {
								p.doc.form = &dom.HTMLFormElement(p.open_elems.last())
							}
						}
					}
					'li' {
						// Adam: I did not understand the documentation for this at all. So this may or may not work.
						p.frameset_ok = .not_ok
						mut i := p.open_elems.len - 1
						mut node := p.open_elems[i]
						node_name := &dom.HTMLElement(node).tag_name
						done := fn [mut p] () {
							// todo: has_element_in_scope
							// if p.has_element_in_button_scope('p') {
							// 	p.close_element('p')
							// }
							_ := p // this is just a placeholder to get rid of the warning the p is unused
						}
						// "if node is in the special category, but is not an address, div or p element, then jump to done step"
						node_in_special_category := tag_name in parser.special_tag_names && node_name !in ['address', 'div', 'p']
						if node_in_special_category {
							done()
						} else {
							i--
							node = p.open_elems[i]
							for {
								p.generate_implied_end_tags(exclude: ['li'])
								if &dom.HTMLElement(p.open_elems.last()).tag_name != 'li' {
									put(
										typ: .warning
										text: 'Unexpected start tag <li>.'
									)
								}
								for p.open_elems.len > 0 {
									if &dom.HTMLElement(p.open_elems.last()).tag_name == 'li' {
										break
									}
									_ := p.open_elems.pop()
								}
								i = p.open_elems.len - i - 1
								node = p.open_elems[i]
								break
							}
						}
						p.insert_html_element()
					}
					else {
						p.reconstruct_active_formatting_elements()
						p.insert_html_element()
					}
				}
			} else { // end tag
				match tag_name {
					'template' {
						p.in_head_insertion_mode()
					}
					'body' {
						// inline comment below is what this should actually be checking for.
						if false /* !p.has_element_in_scope('body') */ {
							put(
								typ: .warning
								text: 'Unexpected end tag </body>: ignoring token.'
							)
						} else {
							// Otherwise, if there is a node in the stack of open elements that is not either a dd element,
							// a dt element, an li element, an optgroup element, an option element, a p element, an rb element,
							// an rp element, an rt element, an rtc element, a tbody element, a td element, a tfoot element, a
							// th element, a thead element, a tr element, the body element, or the html element, then this is
							// a parse error.

							// not_these_elements := !p.open_elems.has_by_tag_name('dd', 'dt', 'li', 'optgroup', 'option', 'p', 'rb', 'rp', 'rt', 'rtc', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'body', 'html')
							not_these_elements := false
							if p.open_elems.len > 1 && not_these_elements {
								put(
									typ: .warning
									text: 'Unexpected end tag </body>.'
								)
							} else {
								p.insertion_mode = .after_body
							}
						}
					}
					'html' {
						if false /* !p.has_element_in_scope('body') */ {
							put(
								typ: .warning
								text: 'Unexpected end tag </html>: ignoring token.'
							)
						} else {
							// Otherwise, if there is a node in the stack of open elements that is not either a dd element,
							// a dt element, an li element, an optgroup element, an option element, a p element, an rb element,
							// an rp element, an rt element, an rtc element, a tbody element, a td element, a tfoot element, a
							// th element, a thead element, a tr element, the body element, or the html element, then this is
							// a parse error.

							// not_these_elements := !p.open_elems.has_by_tag_name('dd', 'dt', 'li', 'optgroup', 'option', 'p', 'rb', 'rp', 'rt', 'rtc', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'body', 'html')
							not_these_elements := false
							if p.open_elems.len > 1 && not_these_elements {
								put(
									typ: .warning
									text: 'Unexpected end tag </html>.'
								)
							} else {
								p.insertion_mode = .after_body
							}
							p.reconsume_token = true
						}
					}
					else {
						// todo: this is not spec compliant. It assumes well-formed HTML.
						_ := p.open_elems.pop()
					}
				}
			}
		}
		EOFToken {
			if p.template_insertion_modes.len > 1 {
				p.in_template_insertion_mode()
			} else {
				// 1) If there is a node in the stack of open elements that is not either a dd element, a dt element, an
				// li element, a p element, a tbody element, a td element, a tfoot element, a th element, a thead element,
				// a tr element, the body element, or the html element, then this is a parse error.

				// not_these_elements := !p.open_elems.has_by_tag_name('dd', 'dt', 'li', 'optgroup', 'option', 'p', 'rb', 'rp', 'rt', 'rtc', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'body', 'html')
				not_these_elements := false
				if p.open_elems.len > 1 && not_these_elements {
					put(
						typ: .warning
						text: 'Unexpected EOF token.'
					)
				}

				// 2) Stop Parsing
				return
			}
		}
	}
}

fn (mut p Parser) in_template_insertion_mode() {
	put(
		typ: .warning
		text: 'todo: implement in_template_insertion_mode'
	)
}

// https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-incdata
fn (mut p Parser) text_insertion_mode() {
	anything_else := fn [mut p] () {
		put(
			typ: .warning
			text: 'Unexpected token: cannot continue parsing.'
		)
		p.insertion_mode = .@none
	}

	match mut p.current_token {
		CharacterToken {
			p.insert_text(p.current_token.str())
		}
		EOFToken {
			put(
				typ: .warning
				text: 'Unexpected EOF token.'
			)
			if &dom.HTMLElement(p.open_elems.last()).tag_name == 'script' {
				mut script := &dom.HTMLScriptElement(p.open_elems.pop())
				script.already_started = true
			}
		}
		TagToken {
			if p.current_token.is_start {
				anything_else()
			} else { // end tag
				if p.current_token.name() == 'script' {
					// todo: end tag script in text insertion mode
					_ := p.open_elems.pop()
				} else {
					_ := p.open_elems.pop()
					p.insertion_mode = p.original_insertion_mode
					p.original_insertion_mode = .@none
				}
			}
		}
		else {
			anything_else()
		}
	}
}

// https://html.spec.whatwg.org/multipage/parsing.html#insert-an-html-element
[inline]
fn (mut p Parser) insert_html_element() &dom.Element {
	return p.insert_foreign_element(dom.NamespaceURI.html)
}

// https://html.spec.whatwg.org/multipage/parsing.html#insert-a-foreign-element
fn (mut p Parser) insert_foreign_element(namespace_uri dom.NamespaceURI) &dom.Element {
	mut tag_token := p.current_token as TagToken
	mut child := dom.HTMLElement.new(p.doc, tag_token.name())
	child.namespace_uri = dom.namespaces[namespace_uri]
	for attribute in tag_token.attributes {
		child.attributes[attribute.name()] = attribute.value()
	}
	if p.open_elems.len > 0 {
		mut last_opened_elem := p.open_elems.last()
		last_opened_elem.append_child(child)
	} else {
		p.doc.append_child(child)
	}
	p.open_elems << child
	return &dom.Element(child)
}

// insert_comment adds a comment to the last opened element (and always assumes
// an element is open).
// https://html.spec.whatwg.org/multipage/parsing.html#insert-a-comment
fn (mut p Parser) insert_comment() {
	if mut p.current_token is CommentToken {
		mut child := dom.CommentNode.new(p.doc, p.current_token.data())
		mut last := p.open_elems.last()
		last.append_child(child)
		return
	}

	put(
		typ: .warning
		text: 'Current token is not a comment.'
	)
}

// insert_text inserts a string into a dom.Text node or creates a new
// one and adds it to the last opened element.
//
// NOTE: Skipping steps 1 and 2 right now.
// https://html.spec.whatwg.org/multipage/parsing.html#insert-a-character
fn (mut p Parser) insert_text(text string) {
	// Step 3:
	// "If the adjusted insertion location is in a Document node, then return.
	// The DOM will not let Document nodes have Text node children, so they are
	// dropped on the floor."
	if p.open_elems.len == 0 {
		put(
			typ: .notice
			text: 'Text nodes cannot be inserted in DOM root. They must go inside an open element. Ignoring token.'
		)
		return
	}

	// Step 4:
	// "If there is a Text node immediately before the adjusted insertion location, then
	// append data to that Text node's data. Otherwise, create a new Text node whose
	// data is data and whose node document is the same as that of the element in which
	// the adjusted insertion location finds itself, and insert the newly created node
	// at the adjusted insertion location."
	mut last_elem := p.open_elems.last()
	insert_text_node := fn [mut p, mut last_elem, text] () {
		mut text_node := dom.Text.new(p.doc, text)
		last_elem.append_child(text_node)
	}

	if last_elem.has_child_nodes() {
		if mut last_elems_last_child := last_elem.last_child {
			if mut last_elems_last_child is dom.Text {
				last_elems_last_child.data += text
				return
			}
			insert_text_node()
			return
		}
		insert_text_node()
		return
	}

	insert_text_node()
}

[params]
pub struct GenerateImpliedTagsParams {
__global:
	exclude []string
}

// https://html.spec.whatwg.org/multipage/parsing.html#generate-implied-end-tags
fn (mut p Parser) generate_implied_end_tags(params GenerateImpliedTagsParams) {
	if p.open_elems.len == 0 {
		return
	}

	mut node := &dom.HTMLElement(p.open_elems.last())
	for node.tag_name in ['dd', 'dt', 'li', 'optgroup', 'option', 'p', 'rb', 'rp', 'rt', 'rtc']
		&& node.tag_name !in params.exclude {
		_ := p.open_elems.pop()
	}
}

// https://html.spec.whatwg.org/multipage/parsing.html#closing-elements-that-have-implied-end-tags
fn (mut p Parser) generate_all_implied_end_tags_thorougly() {
	if p.open_elems.len == 0 {
		return
	}

	mut node := &dom.HTMLElement(p.open_elems.last())
	for node.tag_name in ['caption', 'colgroup', 'dd', 'dt', 'li', 'optgroup', 'option', 'p', 'rb', 'rp', 'rt', 'rtc', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr'] {
		_ := p.open_elems.pop()
	}
}

// https://html.spec.whatwg.org/multipage/parsing.html#clear-the-list-of-active-formatting-elements-up-to-the-last-marker
fn (mut p Parser) clear_active_formatting_elements_to_last_marker() {
	for p.active_formatting_elems.len > 0 {
		if p.active_formatting_elems.pop() is AFEMarker {
			break
		}
	}
}

// https://html.spec.whatwg.org/multipage/parsing.html#reconstruct-the-active-formatting-elements
fn (mut p Parser) reconstruct_active_formatting_elements() {
	// 1) If there are no entries in the list of active formatting elements, then there is nothing
	// to reconstruct; stop this algorithm.
	if p.active_formatting_elems.len == 0 {
		return
	}
	// 2) If the last (most recently added) entry in the list of active formatting elements is a
	// marker, or if it is an element that is in the stack of open elements, then there is nothing
	// to reconstruct; stop this algorithm.
	if p.active_formatting_elems.last() is AFEMarker || p.open_elems.has(p.active_formatting_elems.last()) {
		return
	}
	// 3) Let entry be the last (most recently added) element in the list of active formatting
	// elements.
	mut i := p.active_formatting_elems.len - 1
	mut entry := p.active_formatting_elems[i]
	// 4) Rewind: If there are no entries before entry in the list of active formatting elements,
	// then jump to the step labeled create.
	rewind:
	if p.active_formatting_elems.len > 1 {
		unsafe { goto create }
	}
	// 5) Let entry be the entry one earlier than entry in the list of active formatting elements.
	i--
	entry = p.active_formatting_elems[i]
	// 6) If entry is neither a marker nor an element that is also in the stack of open elements,
	// go to the step labeled rewind.
	if entry !is AFEMarker && !p.open_elems.has(entry) {
		unsafe { goto rewind }
	}
	// 7) Advance: Let entry be the element one later than entry in the list of active formatting
	// elements.
	advance:

	// 8) Create: Insert an HTML element for the token for which the element entry was created,
	// to obtain new element.
	create:
	mut last_opened_elem := p.open_elems.last()
	last_opened_elem.append_child(entry as dom.HTMLElement)
	p.open_elems << entry as dom.HTMLElement
	// 9) Replace the entry for entry in the list with an entry for new element.
	// We stored the entry as a dom.HTMLElement and not a token, so there is no need to replace
	// it since the element we added to open_elems above is a reference to the same entry element.
	// 10) If the entry for new element in the list of active formatting elements is not the last
	// entry in the list, return to the step labeled advance.
	if p.active_formatting_elems.len > 1 {
		unsafe { goto advance }
	}
}

// https://html.spec.whatwg.org/multipage/parsing.html#reset-the-insertion-mode-appropriately
fn (mut p Parser) reset_insertion_mode_appropriately() {
	mut last := false
	mut node_index := p.open_elems.len - 1
	mut node := p.open_elems[node_index]
	for {
		// V bug doesn't allow this without voidptr:
		// https://github.com/vlang/v/issues/19441
		if voidptr(node) == voidptr(p.open_elems.first()) {
			last = true
			// if the parser was created as part of the HTML fragment parsing algorithm
			// set the node to the context element passed to that algorithm
		}
		
		if mut node is dom.HTMLSelectElement {
			if last {
				p.insertion_mode = .in_select
				return
			}
			ancestor := p.open_elems.first()
			if ancestor is dom.HTMLTemplateElement {
				p.insertion_mode = .in_select
				return
			}
			if ancestor is dom.HTMLTableElement {
				p.insertion_mode = .in_select_in_table
				return
			}
			continue
		}

		html_node := &dom.HTMLElement(node)
		// todo: this should actually test with
		// `if html_node is dom.HTMLBodyElement` instead
		// of comparing the local name.
		if html_node.tag_name in ['td', 'th'] && !last {
			p.insertion_mode = .in_cell
			return
		}
		if html_node.tag_name == 'tr' {
			p.insertion_mode = .in_row
			return
		}
		if html_node.tag_name in ['tbody', 'thead', 'tfoot'] {
			p.insertion_mode = .in_table_body
			return
		}
		if html_node.tag_name == 'caption' {
			p.insertion_mode = .in_caption
			return
		}
		if html_node.tag_name == 'colgroup' {
			p.insertion_mode = .in_column_group
			return
		}
		if html_node.tag_name == 'table' {
			p.insertion_mode = .in_table
			return
		}
		if html_node.tag_name == 'template' {
			p.insertion_mode = p.template_insertion_modes.last()
			return
		}
		if html_node.tag_name == 'head' {
			p.insertion_mode = .in_head
			return
		}
		if html_node.tag_name == 'body' {
			p.insertion_mode = .in_body
			return
		}
		if html_node.tag_name == 'frameset' {
			p.insertion_mode = .in_frameset
			return
		}
		if html_node.tag_name == 'html' {
			p.insertion_mode = if p.doc.head == none {
				.before_head
			} else {
				.after_head
			}
			return
		}
		if last {
			p.insertion_mode = .in_body
			return
		}

		node_index--
		node = p.open_elems[node_index]
	}
}