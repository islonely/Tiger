module parser

import dom
import net.http

// DOCTYPE conditions; see `fn Parser.initial_insertion_mode()`
const public_id_matches = [
	'-//W3O//DTD W3 HTML Strict 3.0//EN//',
	'-/W3C/DTD HTML 4.0 Transitional/EN',
	'HTML',
]
const public_id_starts_with = [
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
const public_id_starts_with_if_system_id_missing = [
	'-//W3C//DTD HTML 4.01 Frameset//',
	'-//W3C//DTD HTML 4.01 Transitional//',
]

const formatting_tag_names = ['a', 'b', 'big', 'code', 'em', 'font', 'i', 'nobr', 's', 'small',
	'strike', 'strong', 'tt', 'u']

const implied_end_tag_names = ['dd', 'dt', 'li', 'optgroup', 'option', 'p', 'rb', 'rp', 'rt', 'rtc']
const implied_end_tag_names_thorough = ['caption', 'colgroup', 'dd', 'dt', 'li', 'optgroup', 'option',
	'p', 'rb', 'rp', 'rt', 'rtc', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr']

// todo: include mathml and svg tags
const special_tag_names = ['address', 'applet', 'area', 'article', 'aside', 'base', 'basefont',
	'bgsound', 'blockquote', 'body', 'br', 'button', 'caption', 'center', 'col', 'colgroup', 'dd',
	'details', 'dir', 'div', 'dl', 'dt', 'embed', 'fieldset', 'figcaption', 'figure', 'footer',
	'form', 'frame', 'frameset', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'header', 'hgroup',
	'hr', 'html', 'iframe', 'img', 'input', 'isindex', 'li', 'link', 'listing', 'main', 'marquee',
	'menu', 'meta', 'nav', 'noembed', 'noframes', 'noscript', 'object', 'ol', 'p', 'param',
	'plaintext', 'pre', 'script', 'section', 'select', 'source', 'style', 'summary', 'table', 'tbody',
	'td', 'template', 'textarea', 'tfoot', 'th', 'thead', 'title', 'tr', 'track', 'ul', 'wbr',
	'xmp']

// how far up the dom the parser should check for an open element
// before forcefully closing it.
// https://html.spec.whatwg.org/multipage/parsing.html#has-an-element-in-scope
const default_scope = ['applet', 'caption', 'html', 'table', 'td', 'th', 'marquee', 'object',
	'template']
const list_scope = ['ol', 'ul']
const button_scope = ['button']
const table_scope = ['html', 'table', 'template']
const select_scope = ['optgroup', 'option']

const adjusted_svg_attrs = {
	'attributename':       'attributeName'
	'attributetype':       'attributeType'
	'basefrequency':       'baseFrequency'
	'baseprofile':         'baseProfile'
	'calcmode':            'calcMode'
	'clippathunits':       'clipPathUnits'
	'diffuseconstant':     'diffuseConstant'
	'edgemode':            'edgeMode'
	'filterunits':         'filterUnits'
	'glyphref':            'glyphRef'
	'gradienttransform':   'gradientTransform'
	'gradientunits':       'gradientUnits'
	'kernelmatrix':        'kernelMatrix'
	'kernelunitlength':    'kernelUnitLength'
	'keypoints':           'keyPoints'
	'keysplines':          'keySplines'
	'keytimes':            'keyTimes'
	'lengthadjust':        'lengthAdjust'
	'limitingconeangle':   'limitingConeAngle'
	'markerheight':        'markerHeight'
	'markerunits':         'markerUnits'
	'markerwidth':         'markerWidth'
	'maskcontentunits':    'maskContentUnits'
	'maskunits':           'maskUnits'
	'numoctaves':          'numOctaves'
	'pathlength':          'pathLength'
	'patterncontentunits': 'patternContentUnits'
	'patterntransform':    'patternTransform'
	'patternunits':        'patternUnits'
	'pointsatx':           'pointsAtX'
	'pointsaty':           'pointsAtY'
	'pointsatz':           'pointsAtZ'
	'preservealpha':       'preserveAlpha'
	'preserveaspectratio': 'preserveAspectRatio'
	'primitiveunits':      'primitiveUnits'
	'refx':                'refX'
	'refy':                'refY'
	'repeatcount':         'repeatCount'
	'repeatdur':           'repeatDur'
	'requiredextensions':  'requiredExtensions'
	'requiredfeatures':    'requiredFeatures'
	'specularconstant':    'specularConstant'
	'specularexponent':    'specularExponent'
	'spreadmethod':        'spreadMethod'
	'startoffset':         'startOffset'
	'stddeviation':        'stdDeviation'
	'stitchtiles':         'stitchTiles'
	'surfacescale':        'surfaceScale'
	'systemlanguage':      'systemLanguage'
	'tablevalues':         'tableValues'
	'targetx':             'targetX'
	'targety':             'targetY'
	'textlength':          'textLength'
	'viewport':            'viewBox'
	'viewtarget':          'viewTarget'
	'xchannelselector':    'xChannelSelector'
	'ychannelselector':    'yChannelSelector'
	'zoomandpan':          'zoomAndPan'
}

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

// OpenElements is a stack of open elements.
pub type OpenElements = []&dom.NodeInterface

// has_by_tag_name searches the open elements for a tag with the given tag name
// and returns true if it's found; false if not.
pub fn (mut open_elements OpenElements) has_by_tag_name(tag_names ...string) bool {
	for mut element in open_elements {
		if mut element is dom.HTMLElement {
			if element.tag_name in tag_names {
				return true
			}
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

// https://html.spec.whatwg.org/multipage/parsing.html#the-list-of-active-formatting-elements
@[heap]
pub struct ActiveFormattingElement {
	dom.HTMLElement
	is_marker bool
	token     TagToken
}

// Parser parses the tokens emitted from the Tokenizer and creates
// a document tree which is returned from `fn (mut Parser) parse`.
@[heap]
struct Parser {
mut:
	tokenizer                      Tokenizer
	insertion_mode                 InsertionMode = .initial
	original_insertion_mode        InsertionMode = .@none
	frameset_ok                    bool          = true
	template_insertion_modes       []InsertionMode
	open_elements                  OpenElements
	active_formatting_elements     []&ActiveFormattingElement
	active_speculative_html_parser ?&Parser
	doc                            &dom.Document = dom.Document.new()
	last_token                     Token
	current_token                  Token
	next_token                     Token
	reconsume_token                bool
}

// Parser.from_string instantiates a Parser from the source string.
@[inline]
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
	p.current_token = p.tokenizer.emit_token()
	p.next_token = p.tokenizer.emit_token()
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
			.@none { return p.doc }
			.after_after_body { p.after_after_body_insertion_mode() }
			.after_after_frameset {}
			.after_body { p.after_body_insertion_mode() }
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

	$if print_tree ? {
		p.doc.pretty_print()
	}

	return p.doc
}

// consume_token sets the current token to the next token
// and gets the next token from the tokenizer.
@[inline]
fn (mut p Parser) consume_token() {
	p.last_token, p.current_token, p.next_token = p.current_token, p.next_token, p.tokenizer.emit_token()
}

// after_after_body_insertion_mode is the mode the parser is in after the
// parser has handled an end body tag (</body>).
// https://html.spec.whatwg.org/multipage/parsing.html#the-after-after-body-insertion-mode
fn (mut p Parser) after_after_body_insertion_mode() {
	anything_else := fn [mut p] () {
		put(
			typ:  .warning
			text: 'Unexpected token: ${p.current_token}'
		)
		p.insertion_mode = .in_body
	}

	match mut p.current_token {
		CommentToken {
			p.insert_comment()
		}
		DoctypeToken {
			p.in_body_insertion_mode()
		}
		CharacterToken {
			if p.current_token in whitespace {
				p.in_body_insertion_mode()
				return
			}
			anything_else()
		}
		TagToken {
			if p.current_token.name() == 'html' && p.current_token.is_start {
				p.in_body_insertion_mode()
				return
			}

			anything_else()
		}
		EOFToken {
			p.insertion_mode = .@none
		}
	}
}

// after_body_insertion_mode is the mode the parser is in after the parser
// has encountered an end body tag (</body>).
// https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-afterbody
fn (mut p Parser) after_body_insertion_mode() {
	anything_else := fn [mut p] () {
		put(
			typ:  .warning
			text: 'Unexpected token: ${p.current_token}'
		)
		p.insertion_mode = .in_body
		p.reconsume_token = true
	}

	match mut p.current_token {
		CharacterToken {
			if p.current_token in whitespace {
				p.in_body_insertion_mode()
				return
			}
			anything_else()
		}
		DoctypeToken {
			put(
				typ:  .warning
				text: 'Ignoring token: ${p.current_token}'
			)
		}
		TagToken {
			tag_name := p.current_token.name()
			if tag_name == 'html' {
				if p.current_token.is_start {
					p.in_body_insertion_mode()
					return
				}

				// if the parser was created as part of the HTML fragment
				// parsing algorithm, this is a parse error; ignore the token.
				// otherwise:
				p.insertion_mode = .after_after_body
				return
			}
			anything_else()
		}
		EOFToken {
			p.insertion_mode = .@none
		}
		else {
			anything_else()
		}
	}
}

// before_html_insertion_mode is the mode the parser is in when
// `Parser.next_token` is an open tag HTML tag (<html>).
// https://html.spec.whatwg.org/multipage/parsing.html#the-before-html-insertion-mode
fn (mut p Parser) before_html_insertion_mode() {
	anything_else := fn [mut p] () {
		mut child := dom.HTMLElement.new(p.doc, 'html')
		p.open_elements << child
		p.insertion_mode = .before_head
		p.reconsume_token = true
	}
	match mut p.current_token {
		DoctypeToken {
			put(
				typ:  .notice
				text: 'Ignoring DOCTYPE token.'
			)
		}
		CommentToken {
			mut child := dom.CommentNode.new(p.doc, p.current_token.data())
			p.doc.append_child(child)
		}
		CharacterToken {
			if p.current_token !in whitespace {
				anything_else()
			}
		}
		TagToken {
			if p.current_token.is_start {
				if _likely_(p.current_token.name() == 'html') {
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
						typ:  .notice
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
				node_type:      .document_type
				name:           p.current_token.name.str()
				public_id:      p.current_token.public_identifier.str()
				system_id:      p.current_token.system_identifier.str()
				owner_document: p.doc
			}
			p.doc.append_child(doctype)
			p.doc.doctype = doctype

			// if p.doc is not iframe srcdoc documetn && !p.doc.parser_cannot_change_mode
			if !p.doc.parser_cannot_change_mode
				&& (p.current_token.force_quirks || doctype.name != 'html') {
				p.doc.mode = .quirks
			}
			if doctype.public_id in public_id_matches {
				p.doc.mode = .quirks
			}
			for val in public_id_starts_with {
				if doctype.public_id.starts_with(val) {
					p.doc.mode = .quirks
					break
				}
			}
			for val in public_id_starts_with_if_system_id_missing {
				if p.current_token.system_identifier == doctype_missing
					&& doctype.public_id.starts_with(val) {
					p.doc.mode = .quirks
					break
				}
			}
			if p.doc.mode != .quirks {
				// p.doc is not iframe srcdoc document && !p.doc.parser_cannot_change_mode
				if !p.doc.parser_cannot_change_mode
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
			// p.doc is not iframe srcdoc document && !p.doc.parser_cannot_change_mode
			if !p.doc.parser_cannot_change_mode {
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
		mut last := p.open_elements.last()
		last.append_child(child)
		p.insertion_mode = .in_head
		return
	}
	match mut p.current_token {
		CharacterToken {
			if p.current_token in whitespace {
				return
			}

			anything_else()
		}
		CommentToken {
			p.insert_comment()
		}
		DoctypeToken {
			put(
				typ:  .notice
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
				typ:  .notice
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
		p.open_elements.pop()
		p.insertion_mode = .after_head
		p.reconsume_token = true
	}

	match mut p.current_token {
		CharacterToken {
			if p.current_token in whitespace {
				p.insert_text(p.current_token.str())
			} else {
				anything_else()
			}
		}
		CommentToken {
			p.insert_comment()
		}
		DoctypeToken {
			put(
				typ:  .notice
				text: 'Invalid DOCTYPE token. Ignoring token.'
			)
		}
		TagToken {
			mut last_opened_elem := p.open_elements.last()
			tag_name := p.current_token.name()
			if p.current_token.is_start {
				if tag_name == 'html' {
					p.in_body_insertion_mode()
				} else if tag_name in ['base', 'basefont', 'bgsound', 'link'] {
					p.insert_html_element()
					// Spec says to immediately pop it.
					// https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inhead
					p.open_elements.pop()
				} else if tag_name == 'meta' {
					p.insert_html_element()
					p.open_elements.pop()

					// todo: implement substeps 1 and 2 from
					// https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inhead
				} else if tag_name == 'title' {
					// https://html.spec.whatwg.org/multipage/parsing.html#generic-rcdata-element-parsing-algorithm
					p.insert_html_element()
					p.tokenizer.state = .rcdata
					p.original_insertion_mode = p.insertion_mode
					p.insertion_mode = .text
				} else if (tag_name == 'noscript' && p.doc.scripting)
					|| tag_name in ['noframes', 'style'] {
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
					p.open_elements << child
					p.tokenizer.state = .script_data
					p.original_insertion_mode = p.insertion_mode
					p.insertion_mode = .text
				} else if tag_name == 'template' {
					p.insert_html_element()
					p.active_formatting_elements << &ActiveFormattingElement{
						HTMLElement: &(p.open_elements[p.open_elements.len - 1] as dom.HTMLElement)
						is_marker:   true
						token:       p.current_token as TagToken
					}
					p.frameset_ok = false
					p.insertion_mode = .in_template
					p.template_insertion_modes << .in_template
				} else if tag_name == 'head' {
					put(
						typ:  .warning
						text: 'Unexpected head tag <head>: ignoring token.'
					)
				} else {
					anything_else()
				}
			} else { // end tag
				if tag_name == 'head' {
					_ := p.open_elements.pop()
					p.insertion_mode = .after_head
					return
				} else if tag_name in ['body', 'html', 'br'] {
					anything_else()
					return
				} else if tag_name == 'template' {
					if !p.open_elements.has_by_tag_name('template') {
						put(
							typ:  .warning
							text: 'Unexpected </template> tag token; ingoring token.'
						)
						return
					}

					p.generate_all_implied_end_tags_thorougly()
					if p.open_elements.len == 0 {
						put(
							typ:  .warning
							text: 'Unexpected </template> tag token; ignoring token.'
						)
						return
					}
					mut template_element := p.open_elements.last()
					if (template_element as dom.HTMLElement).tag_name != 'template' {
						put(
							typ:  .warning
							text: 'Current node is not a <template> tag.'
						)
					}
					for (template_element as dom.HTMLElement).tag_name != 'template' {
						if p.open_elements.len == 0 {
							put(
								typ:  .warning
								text: "There were no <template> tags in the parser's stack of open elements."
							)
							break
						}
						template_element = p.open_elements.pop()
					}
					p.clear_afe_to_last_marker()
					if p.template_insertion_modes.len != 0 {
						p.template_insertion_modes.pop()
					} else {
						put(
							typ:  .warning
							text: "There were no items on the parer's stack of template insertion modes."
						)
					}
					p.reset_insertion_mode_appropriately()
				} else {
					put(
						typ:  .warning
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
			typ:  .warning
			text: 'Parse error: ${p.insertion_mode}'
		)
		// Should be a noscript element and the last item in p.open_elements
		// should now be the head element.
		p.open_elements.pop()
		p.insertion_mode = .in_head
		p.reconsume_token = true
	}

	match mut p.current_token {
		DoctypeToken {
			put(
				typ:  .warning
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
						typ:  .warning
						text: 'Unexpected start tag <${tag_name}>: ignoring token.'
					)
				}
			} else {
				if tag_name == 'noscript' {
					// Should be a noscript element and the last item in p.open_elements
					// should now be the head element.
					p.open_elements.pop()
					p.insertion_mode = .in_head
				} else if tag_name == 'br' {
					anything_else()
				} else {
					put(
						typ:  .warning
						text: 'Unexpected end tag </${tag_name}>: ignoring token.'
					)
				}
			}
		}
		CharacterToken {
			if p.current_token in whitespace {
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
		mut last_opened_element := p.open_elements.last()
		last_opened_element.append_child(child)
		p.open_elements << child
		p.insertion_mode = .in_body
	}

	match mut p.current_token {
		CharacterToken {
			if p.current_token in whitespace {
				p.insert_text(p.current_token.str())
			}
		}
		CommentToken {
			p.insert_comment()
		}
		DoctypeToken {
			put(
				typ:  .warning
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
					p.doc.body = &dom.HTMLBodyElement(p.open_elements.last())
					p.frameset_ok = false
					p.insertion_mode = .in_body
				} else if tag_name == 'frameset' {
					p.insert_html_element()
					p.insertion_mode = .in_frameset
				} else if tag_name in ['base', 'basefont', 'bgsound', 'link', 'meta', 'noframes',
					'script', 'style', 'template', 'title'] {
					put(
						typ:  .warning
						text: 'Unexpected start tag <${tag_name}>: ignoring token.'
					)
					if head := p.doc.head {
						p.open_elements << head
						p.in_head_insertion_mode()
						for p.open_elements.len > 0 {
							if voidptr(p.open_elements.last()) == voidptr(head) {
								p.open_elements.pop()
								break
							}
						}
						put(
							typ:  .warning
							text: 'No head element found in document.'
						)
					} else {
						put(
							typ:  .warning
							text: 'No head element found in document.'
						)
					}
				} else if tag_name == 'head' {
					put(
						typ:  .warning
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
						typ:  .warning
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
					typ:  .warning
					text: 'Unexpected null character token: ignoring token.'
				)
			}
			p.reconstruct_afe()
			p.insert_text(p.current_token.str())
			if p.current_token !in whitespace {
				p.frameset_ok = false
			}
		}
		CommentToken {
			p.insert_comment()
		}
		DoctypeToken {
			put(
				typ:  .warning
				text: 'Unexpected doctype token: ignoring token.'
			)
		}
		TagToken {
			tag_name := p.current_token.name()
			if p.current_token.is_start {
				match tag_name {
					'html' {
						put_prefix := put(
							typ:     .warning
							text:    'Unexpected start tag <html>'
							newline: false
							print:   false
						)
						if p.open_elements.has_by_tag_name('template') {
							put(
								typ:  .warning
								text: '${put_prefix}: ignoring token.'
							)
						} else {
							put(
								typ:  .warning
								text: '${put_prefix}.'
							)
							// Adam: I've got to be misunderstanding something here. There's no way we're supposed
							// to just copy the attributes from an html start tag to the last opened element, right?
							//
							// Otherwise, for each attribute on the token, check to see if the attribute is
							// already present on the top element of the stack of open elements. If it is not,
							// add the attribute and its corresponding value to that element.
							for mut attr in p.current_token.attributes {
								if p.open_elements.len > 0 {
									mut last_opened_elem := &(p.open_elements[p.open_elements.len - 1] as dom.HTMLElement)
									last_opened_elem.attributes[attr.name.str()] = attr.value.str()
								}
							}
						}
					}
					'base', 'basefont', 'bgsound', 'link', 'meta', 'noframes', 'script', 'style',
					'template', 'title' {
						p.in_head_insertion_mode()
					}
					'body' {
						put_prefix := put(
							typ:     .warning
							text:    'Unexpected start tag <body>'
							newline: false
							print:   false
						)
						second_elem_is_body := (p.open_elements[1] or {
							put(
								typ:  .warning
								text: '${put_prefix}: ignoring token.'
							)
							return
						} as dom.HTMLElement).tag_name == 'body'
						if p.open_elements.len == 1 || !second_elem_is_body
							|| p.open_elements.has_by_tag_name('template') {
							put(
								typ:  .warning
								text: '${put_prefix}: ignoring token.'
							)
						} else {
							// Otherwise, set the frameset-ok flag to "not ok"; then, for each attribute on the token,
							// check to see if the attribute is already present on the body element (the second
							// element) on the stack of open elements, and if it is not, add the attribute and its
							// corresponding value to that element.
							p.frameset_ok = false
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
							typ:     .warning
							text:    'Unexpected start tag <frameset>'
							newline: false
							print:   false
						)
						second_elem_is_body := (p.open_elements[1] or {
							put(
								typ:  .warning
								text: '${put_prefix}: ignoring token.'
							)
							return
						} as dom.HTMLElement).tag_name == 'body'
						if p.open_elements.len == 1 || !second_elem_is_body
							|| p.frameset_ok == false {
							put(
								typ:  .warning
								text: '${put_prefix}: ignoring token.'
							)
						} else {
							// 1) Remove the second element on the stack of open elements from its parent node, if it has one.
							if p.open_elements.len >= 2 {
								p.open_elements.delete(1)
							}
							// 2) Pop all the nodes from the bottom of the stack of open elements, from the current node up to,
							// but not including, the root html element.
							for p.open_elements.len > 0 {
								if (p.open_elements.last() as dom.HTMLElement).tag_name == 'html' {
									break
								}
								_ := p.open_elements.pop()
							}
							// 3) Insert an HTML element for the token.
							mut child := dom.HTMLElement.new(p.doc, 'frameset')
							p.open_elements << child
							// 4) Switch the insertion mode to "in frameset".
							p.insertion_mode = .in_frameset
						}
					}
					'address', 'article', 'aside', 'blockquote', 'center', 'details', 'dialog',
					'dir', 'div', 'dl', 'fieldset', 'figcaption', 'figure', 'footer', 'header',
					'hgroup', 'main', 'menu', 'nav', 'ol', 'p', 'section', 'summary', 'ul' {
						if p.has_element_in_button_scope('p') {
							p.close_p_element()
						}
						p.insert_html_element()
					}
					'h1', 'h2', 'h3', 'h4', 'h5', 'h6' {
						if p.has_element_in_button_scope('p') {
							p.close_p_element()
						}
						if p.open_elements.len > 0 {
							if (p.open_elements.last() as dom.HTMLElement).tag_name in [
								'h1',
								'h2',
								'h3',
								'h4',
								'h5',
								'h6',
							] {
								put(
									typ:  .warning
									text: 'Unexpected start tag <${tag_name}>'
								)
								_ := p.open_elements.pop()
							}
						}
						p.insert_html_element()
					}
					'pre', 'listing' {
						// todo: has_element_in_scope
						if p.has_element_in_button_scope('p') {
							p.close_p_element()
						}
						p.insert_html_element()
						if mut p.next_token is CharacterToken {
							linefeed := rune(0x000a)
							if p.next_token == linefeed {
								p.consume_token()
							}
						}
						p.frameset_ok = false
					}
					'form' {
						if p.doc.form != none {
							put(
								typ:  .warning
								text: 'Unexpected start tag <form>: ignoring token.'
							)
						} else {
							if p.has_element_in_button_scope('p') {
								p.close_p_element()
							}
							p.insert_html_element()
							if !p.open_elements.has_by_tag_name('template') {
								p.doc.form = &dom.HTMLFormElement(p.open_elements.last())
							}
						}
					}
					'li' {
						p.frameset_ok = false
						mut i := p.open_elements.len - 1
						for i >= 0 {
							mut node := &(p.open_elements[i] as dom.HTMLElement)
							if node.tag_name == 'li' {
								p.generate_implied_end_tags(exclude: ['li'])
								last_opened_elem := p.open_elements.last() as dom.HTMLElement
								if last_opened_elem.tag_name != 'li' {
									put(
										typ:  .warning
										text: 'Expected to be in <li>; we are not.'
									)
								}
								p.pop_open_elems_until('li')
								break
							}
							is_node_in_special_category := node.tag_name in special_tag_names
								&& node.tag_name !in ['address', 'div', 'p']
							if is_node_in_special_category {
								break
							}
							i--
						}
						if p.has_element_in_button_scope('p') {
							p.close_p_element()
						}
						p.insert_html_element()
					}
					'dd', 'dt' {
						p.frameset_ok = false
						mut i := p.open_elements.len - 1
						for i >= 0 {
							mut node := &(p.open_elements[i] as dom.HTMLElement)
							if node.tag_name in ['dd', 'dt'] {
								p.generate_implied_end_tags(exclude: [node.tag_name])
								last_opened_elem := p.open_elements.last() as dom.HTMLElement
								if last_opened_elem.tag_name != node.tag_name {
									put(
										typ:  .warning
										text: 'Expected to be in <${node.tag_name}>; we are not.'
									)
								}
								p.pop_open_elems_until(node.tag_name)
								break
							}
							is_node_in_special_category := node.tag_name in special_tag_names
								&& node.tag_name !in ['address', 'div', 'p']
							if is_node_in_special_category {
								break
							}
							i--
						}
						if p.has_element_in_button_scope('p') {
							p.close_p_element()
						}
						p.insert_html_element()
					}
					'plaintext' {
						if p.has_element_in_button_scope('p') {
							p.close_p_element()
						}
						p.insert_html_element()
						p.tokenizer.state = .plaintext
					}
					'button' {
						if p.has_element_in_scope('button') {
							put(
								typ:  .warning
								text: 'Invalid <button>. There is already a <button> in scope.'
							)
							p.generate_implied_end_tags()
							p.pop_open_elems_until('button')
						}
						p.reconstruct_afe()
						p.insert_html_element()
						p.frameset_ok = false
					}
					'a' {
						if p.afe_contains_after_last_marker('a') {
							put(
								typ:  .warning
								text: 'unexpected <a> element; there is already an open <a> element.'
							)
							p.adoption_agency_algo()
						}
						p.reconstruct_afe()
						p.insert_html_element()
						p.insert_last_element_into_afe()
					}
					'b', 'big', 'code', 'em', 'font', 'i', 's', 'small', 'strike', 'strong', 'tt',
					'u' {
						p.reconstruct_afe()
						p.insert_last_element_into_afe()
					}
					'nobr' {
						p.reconstruct_afe()
						if p.has_element_in_scope('nobr') {
							put(
								typ:  .warning
								text: 'Invalid <nobr>; already inside <nobr> element.'
							)
							p.adoption_agency_algo()
							p.reconstruct_afe()
						}
						p.insert_html_element()
						p.insert_last_element_into_afe()
					}
					'applet', 'marquee', 'object' {
						p.reconstruct_afe()
						p.insert_html_element()
						p.active_formatting_elements << &ActiveFormattingElement{
							HTMLElement: &(p.open_elements[p.open_elements.len - 1] as dom.HTMLElement)
							is_marker:   true
							token:       p.current_token as TagToken
						}
						p.frameset_ok = false
					}
					'table' {
						if p.doc.mode == .quirks && p.has_element_in_button_scope('p') {
							p.close_p_element()
						}
						p.insert_html_element()
						p.frameset_ok = false
						p.insertion_mode = .in_table
					}
					'area', 'br', 'embed', 'img', 'keygen', 'wbr' {
						p.reconstruct_afe()
						p.insert_html_element()
						_ := p.open_elements.pop()
						// acknowledge self-closing flag
						p.frameset_ok = false
					}
					'input' {
						input_elem := p.insert_html_element()
						_ := p.open_elements.pop()
						// acknowledge self-closing flag
						if 'type' !in input_elem.attributes {
							p.frameset_ok = false
						} else if input_elem.attributes['type'].to_lower() != 'hidden' {
							p.frameset_ok = false
						}
					}
					'param', 'source', 'track' {
						p.insert_html_element()
						_ := p.open_elements.pop()
						// acknowledge self-closing flag
					}
					'hr' {
						if p.has_element_in_button_scope('p') {
							p.close_p_element()
						}
						p.insert_html_element()
						_ := p.open_elements.pop()
						// acknowledge self-closing flag
						p.frameset_ok = false
					}
					'image' {
						put(
							typ:  .warning
							text: 'Invalid element <image>; use <img> instead.'
						)
						p.current_token.name = 'img'.bytes()
						p.reconsume_token = true
					}
					'textarea' {
						p.insert_html_element()
						// consume and ignore line feeds
						for {
							if mut p.next_token is CharacterToken {
								if p.next_token == rune(0x000A) {
									p.consume_token()
									continue
								}
							}
							break
						}
						p.tokenizer.state = .rcdata
						p.original_insertion_mode = p.insertion_mode
						p.frameset_ok = false
						p.insertion_mode = .text
					}
					'xmp' {
						if p.has_element_in_button_scope('p') {
							p.close_p_element()
						}
						p.reconstruct_afe()
						p.frameset_ok = false
						p.generic_raw_text_element_algo(.rawtext)
					}
					'iframe' {
						p.frameset_ok = false
						p.generic_raw_text_element_algo(.rawtext)
					}
					'noembed' {
						p.generic_raw_text_element_algo(.rawtext)
					}
					'noscript' {
						if p.doc.scripting {
							p.generic_raw_text_element_algo(.rawtext)
						}
					}
					'select' {
						p.reconstruct_afe()
						p.insert_html_element()
						p.frameset_ok = false
						p.insertion_mode = .in_select
					}
					'optgroup', 'option' {
						if (p.open_elements.last() as dom.HTMLElement).tag_name == 'option' {
							_ := p.open_elements.pop()
						}
						p.reconstruct_afe()
						p.insert_html_element()
					}
					'rb', 'rtc' {
						if p.has_element_in_scope('ruby') {
							p.generate_implied_end_tags()
							if (p.open_elements.last() as dom.HTMLElement).tag_name == 'ruby' {
								put(
									typ:  .warning
									text: 'Unexpected <ruby> element.'
								)
							}
						}
						p.insert_html_element()
					}
					'rp', 'rt' {
						if p.has_element_in_scope('ruby') {
							p.generate_implied_end_tags(exclude: ['rtc'])
							last_tag_name := (p.open_elements.last() as dom.HTMLElement).tag_name
							if last_tag_name in ['ruby', 'rtc'] {
								put(
									typ:  .warning
									text: 'Unexpected <${last_tag_name}> element.'
								)
							}
						}
						p.insert_html_element()
					}
					'math' {
						p.reconstruct_afe()
						p.adjust_mathml_attrs()
						p.insert_foreign_element(dom.NamespaceURI.mathml, false,
							adjust_foreign_attrs: true
						)
						if p.current_token.self_closing {
							_ := p.open_elements.pop()
						}
						// acknowledge self-closing flag
					}
					'svg' {
						p.reconstruct_afe()
						p.adjust_svg_attrs()
						p.insert_foreign_element(dom.NamespaceURI.svg, false,
							adjust_foreign_attrs: true
						)
						if p.current_token.self_closing {
							_ := p.open_elements.pop()
						}
						// acknowledge self-closing flag
					}
					'caption', 'col', 'colgroup', 'frame', 'head', 'tbody', 'td', 'tfoot', 'th',
					'thead', 'tr' {
						put(
							typ:  .warning
							text: 'Unexpected <${p.current_token.name()}>.'
						)
					}
					else {
						p.reconstruct_afe()
						p.insert_html_element()
					}
				}
			} else { // end tag
				match tag_name {
					'template' {
						p.in_head_insertion_mode()
					}
					'body' {
						if !p.has_element_in_scope('body') {
							put(
								typ:  .warning
								text: 'Unexpected end tag </body>.'
							)
						}
						for mut open_elem in p.open_elements {
							if mut open_elem is dom.HTMLElement {
								open_tag_name := open_elem.tag_name
								if open_tag_name !in ['dd', 'dt', 'li', 'optgroup', 'option', 'p',
									'rb', 'rp', 'rt', 'rtc', 'tbody', 'td', 'tfoot', 'th', 'thead',
									'tr', 'body', 'html'] {
									put(
										typ:  .warning
										text: '<${open_tag_name}> has no end tag; expected </${open_tag_name}>'
									)
								}
							}
						}
						p.insertion_mode = .after_body
					}
					'html' {
						if !p.has_element_in_scope('body') {
							put(
								typ:  .warning
								text: 'Unexpected end tag </body>.'
							)
						}
						for mut open_elem in p.open_elements {
							if mut open_elem is dom.HTMLElement {
								open_tag_name := open_elem.tag_name
								if open_tag_name !in ['dd', 'dt', 'li', 'optgroup', 'option', 'p',
									'rb', 'rp', 'rt', 'rtc', 'tbody', 'td', 'tfoot', 'th', 'thead',
									'tr', 'body', 'html'] {
									put(
										typ:  .warning
										text: '<${open_tag_name}> has no end tag; expected </${open_tag_name}>'
									)
								}
							}
						}
						p.insertion_mode = .after_body
						p.reconsume_token = true
					}
					'address', 'article', 'aside', 'blockquote', 'button', 'center', 'details',
					'dialog', 'dir', 'div', 'dl', 'fieldset', 'figcaption', 'figure', 'footer',
					'header', 'hgroup', 'listing', 'main', 'menu', 'nav', 'ol', 'pre', 'search',
					'section', 'summary', 'ul' {
						if !p.has_element_in_scope(tag_name) {
							put(
								typ:  .warning
								text: 'Unexpected </${tag_name}>; there is open <${tag_name}> elements.'
							)
							return
						}

						p.generate_implied_end_tags()
						last_opened_tag_name := (p.open_elements[p.open_elements.len - 1] as dom.HTMLElement).tag_name
						if last_opened_tag_name != tag_name {
							put(
								typ:  .warning
								text: 'Unexpected </${tag_name}>; expecting </${last_opened_tag_name}>.'
							)
						}
						p.pop_open_elems_until(tag_name)
					}
					'form' {
						if !p.has_element_in_scope('form') {
							put(
								typ:  .warning
								text: 'Unexpected </form>; there is no open <form> element.'
							)
							return
						}
						p.generate_implied_end_tags()
						last_opened_tag_name := (p.open_elements[p.open_elements.len - 1] as dom.HTMLElement).tag_name
						if last_opened_tag_name != 'form' {
							put(
								typ:  .warning
								text: 'Unexpected </form>; expecting </${last_opened_tag_name}>.'
							)
						}
						if p.has_open_element('template') {
							p.pop_open_elems_until('form')
							return
						}

						if p.doc.form == none {
							put(
								typ:  .warning
								text: 'Unexpected </form>; there is no open <form> element.'
							)
							return
						}
						form := p.open_elements.pop()
						if form !is dom.HTMLFormElement {
							put(
								typ:  .warning
								text: 'Expected to pop <form> element; got this instead: ${form}'
							)
						}
					}
					'p' {
						if !p.has_element_in_button_scope('p') {
							put(
								typ:  .warning
								text: 'Unexpected </p>; there is no open <p> element in scope.'
							)
							p.insert_foreign_element(dom.NamespaceURI.html, false, tag_name: 'p')
						}
						p.close_p_element()
					}
					'li' {
						if !p.has_element_in_list_scope('li') {
							put(
								typ:  .warning
								text: 'Unexpected </li>; there is no open <li> element in scope.'
							)
							return
						}

						p.generate_implied_end_tags(exclude: ['li'])
						last_opened_tag_name := (p.open_elements[p.open_elements.len - 1] as dom.HTMLElement).tag_name
						if last_opened_tag_name != tag_name {
							put(
								typ:  .warning
								text: 'Unexpected </li>; expecting </${last_opened_tag_name}>.'
							)
						}
						p.pop_open_elems_until('li')
					}
					'dd', 'dt' {
						if !p.has_element_in_scope(tag_name) {
							put(
								typ:  .warning
								text: 'Unexpected </${tag_name}>; there is no open <${tag_name}> element in scope.'
							)
							return
						}
						p.generate_implied_end_tags(exclude: [tag_name])
						last_opened_tag_name := (p.open_elements[p.open_elements.len - 1] as dom.HTMLElement).tag_name
						if last_opened_tag_name != tag_name {
							put(
								typ:  .warning
								text: 'Unexpected </${tag_name}>; expecting </${last_opened_tag_name}>'
							)
						}
						p.pop_open_elems_until(tag_name)
					}
					'h1', 'h2', 'h3', 'h4', 'h5', 'h6' {
						if !p.has_element_in_scope(tag_name) {
							put(
								typ:  .warning
								text: 'Unexpected </${tag_name}>; there is no open <${tag_name}> element in scope.'
							)
							return
						}
						p.generate_implied_end_tags(exclude: [tag_name])
						last_opened_tag_name := (p.open_elements[p.open_elements.len - 1] as dom.HTMLElement).tag_name
						if last_opened_tag_name != tag_name {
							put(
								typ:  .warning
								text: 'Unexpected </${tag_name}>; expecting </${last_opened_tag_name}>'
							)
						}
						// You would think you should pop until `tag_name` is reached like we did above for <dd> and <dt> tags.
						// But the spec says to do it this way:
						p.pop_open_elems_until('h1', 'h2', 'h3', 'h4', 'h5', 'h6')
					}
					'sarcasm' {
						println('Take a deep breath and relax for a moment. Look away from your screen for at least 30 seconds before returning.')
					}
					'a', 'b', 'big', 'code', 'em', 'font', 'i', 'nobr', 's', 'small', 'strike',
					'strong', 'tt', 'u' {
						p.adoption_agency_algo()
						_ := p.open_elements.pop() // should remove this once adoption_agency_algo is implemented
					}
					'applet', 'marquee', 'object' {
						if !p.has_element_in_scope(tag_name) {
							put(
								typ:  .warning
								text: 'Unexpected </${tag_name}>; there is no open <${tag_name}> element in scope.'
							)
							return
						}

						p.generate_implied_end_tags()
						last_opened_tag_name := (p.open_elements[p.open_elements.len - 1] as dom.HTMLElement).tag_name
						if last_opened_tag_name != tag_name {
							put(
								typ:  .warning
								text: 'Unexpected </${tag_name}>; expecting </${last_opened_tag_name}>'
							)
						}
						p.pop_open_elems_until(tag_name)
						p.clear_afe_to_last_marker()
					}
					else {
						// todo: this is not spec compliant. It assumes well-formed HTML.
						_ := p.open_elements.pop()
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

				// not_these_elements := !p.open_elements.has_by_tag_name('dd', 'dt', 'li', 'optgroup', 'option', 'p', 'rb', 'rp', 'rt', 'rtc', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'body', 'html')
				not_these_elements := false
				if p.open_elements.len > 1 && not_these_elements {
					put(
						typ:  .warning
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
		typ:  .warning
		text: 'todo: implement in_template_insertion_mode'
	)
}

// https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-incdata
fn (mut p Parser) text_insertion_mode() {
	anything_else := fn [mut p] () {
		// put(
		// 	typ:  .warning
		// 	text: 'Unexpected token: cannot continue parsing.'
		// )
		// p.insertion_mode = .@none
		p.insertion_mode = p.original_insertion_mode
		p.original_insertion_mode = .@none
	}

	match mut p.current_token {
		CharacterToken {
			p.insert_text(p.current_token.str())
		}
		EOFToken {
			put(
				typ:  .warning
				text: 'Unexpected EOF token.'
			)
			if (p.open_elements.last() as dom.HTMLElement).tag_name == 'script' {
				mut script := &dom.HTMLScriptElement(p.open_elements.pop())
				script.already_started = true
			}
		}
		TagToken {
			if p.current_token.is_start {
				anything_else()
			} else { // end tag
				if p.current_token.name() == 'script' {
					// todo: end tag script in text insertion mode
					_ := p.open_elements.pop()
				} else {
					_ := p.open_elements.pop()
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

fn (mut p Parser) adoption_agency_algo() {
	put(
		typ:  .warning
		text: 'adoption agency algorithm not implemented'
	)
}

// afe_find_after_last_marker checks if the list of active formatting elements contains
// a tag that matches the provided name and returns it if it matches.
fn (mut p Parser) afe_find_after_last_marker(target_tag_name string) ?&ActiveFormattingElement {
	for i := p.active_formatting_elements.len - 1; i >= 0; i-- {
		afe_item := p.active_formatting_elements[i]
		if afe_item.is_marker {
			return none
		}
		if afe_item.tag_name == target_tag_name {
			return afe_item
		}
	}
	return none
}

// afe_contains_after_last_marker checks if the list of active formatting elements
// contains a <target_tag_name> element after the last marker.
fn (mut p Parser) afe_contains_after_last_marker(target_tag_name string) bool {
	for i := p.active_formatting_elements.len - 1; i >= 0; i-- {
		afe_item := p.active_formatting_elements[i]
		if afe_item.is_marker {
			return false
		}
		if afe_item.tag_name == target_tag_name {
			return true
		}
	}
	return false
}

// insert_afe
fn (mut p Parser) insert_last_element_into_afe() {
	mut afe := &ActiveFormattingElement{
		HTMLElement: &(p.open_elements[p.open_elements.len - 1] as dom.HTMLElement)
		token:       p.current_token as TagToken
	}
	// 1.If there are already three elements in the list of active formatting elements
	// after the last marker, if any, or anywhere in the list if there are no markers,
	// that have the same tag name, namespace, and attributes as element, then remove
	// the earliest such element from the list of active formatting elements. For
	// these purposes, the attributes must be compared as they were when the elements
	// were created by the parser; two elements have the same attributes if all their
	// parsed attributes can be paired such that the two attributes in each pair have
	// identical names, namespaces, and values (the order of the attributes does not
	// matter).
	mut count := 0
	for i := p.active_formatting_elements.len - 1; i >= 0; i-- {
		mut afe_item := p.active_formatting_elements[i]
		if afe_item.is_marker {
			break
		}

		is_same_elem := afe_item.tag_name == afe.tag_name && afe_item.namespace_uri or { '' } == afe.namespace_uri or {
			''
		} && p.has_same_attributes(afe_item.HTMLElement, afe.HTMLElement)
		if is_same_elem {
			count++
		}
		if count == 3 {
			p.active_formatting_elements.delete(i)
			break
		}
	}
	p.active_formatting_elements << afe
}

// has_same_attributes compares two elements and returns whether or no they have the same
// attributes and values.
//
// "For these purposes, the attributes must be compared as they were when the elements
// were created by the parser; two elements have the same attributes if all their
// parsed attributes can be paired such that the two attributes in each pair have
// identical names, namespaces, and values (the order of the attributes does not matter)."
// https://html.spec.whatwg.org/multipage/parsing.html#push-onto-the-list-of-active-formatting-elements
fn (mut p Parser) has_same_attributes(elem1 dom.HTMLElement, elem2 dom.HTMLElement) bool {
	if elem1.attributes.len != elem2.attributes.len {
		return false
	}
	for key, elem1_val in elem1.attributes {
		elem2_val := elem2.attributes[key] or { return false }
		if elem1_val != elem2_val {
			return false
		}
	}
	return true
}

// https://html.spec.whatwg.org/multipage/parsing.html#insert-an-html-element
@[inline]
fn (mut p Parser) insert_html_element() &dom.ElementInterface {
	return p.insert_foreign_element(dom.NamespaceURI.html, false)
}

@[params]
struct InsertElemParams {
mut:
	adjust_foreign_attrs bool
	tag_name             ?string
}

// https://html.spec.whatwg.org/multipage/parsing.html#insert-a-foreign-element
fn (mut p Parser) insert_foreign_element(namespace_uri dom.NamespaceURI, only_add_to_elem_stack bool, params InsertElemParams) &dom.ElementInterface {
	mut tag_token := p.current_token as TagToken
	name := params.tag_name or { tag_token.name() }
	mut child := dom.HTMLElement.new(p.doc, name)
	child.namespace_uri = dom.namespaces[namespace_uri]
	child.node_type = .element
	if params.adjust_foreign_attrs {
		// for attribute in tag_token.attributes {
		// 	if attribute.name() in dom.foreign_attrs {
		// 		child.attributes < dom.Attribute.adjusted_foreign(attribute.name(), attribute.val())
		// 	}
		// }
		println('adjust foreign attributes not implemented')
	} else {
		for attribute in tag_token.attributes {
			child.attributes[attribute.name()] = attribute.value()
		}
	}
	if p.open_elements.len > 0 {
		mut last_opened_elem := p.open_elements.last()
		last_opened_elem.append_child(child)
	} else {
		p.doc.append_child(child)
	}
	p.open_elements << child
	return child
}

// insert_comment adds a comment to the last opened element (and always assumes
// an element is open).
// https://html.spec.whatwg.org/multipage/parsing.html#insert-a-comment
fn (mut p Parser) insert_comment() {
	if mut p.current_token is CommentToken {
		mut child := dom.CommentNode.new(p.doc, p.current_token.data())
		mut last := p.open_elements.last()
		last.append_child(child)
		return
	}

	put(
		typ:  .warning
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
	if p.open_elements.len == 0 {
		put(
			typ:  .notice
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
	mut last_elem := p.open_elements.last()
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

@[params]
pub struct GenerateImpliedTagsParams {
__global:
	exclude []string // exclude is the list of tags which will not have end tag generated.
}

// https://html.spec.whatwg.org/multipage/parsing.html#generate-implied-end-tags
fn (mut p Parser) generate_implied_end_tags(params GenerateImpliedTagsParams) {
	if p.open_elements.len == 0 {
		return
	}

	mut node := (p.open_elements[p.open_elements.len - 1] as dom.HTMLElement)
	for node.tag_name in implied_end_tag_names && node.tag_name !in params.exclude {
		node = p.open_elements.pop() as dom.HTMLElement
	}
}

// https://html.spec.whatwg.org/multipage/parsing.html#closing-elements-that-have-implied-end-tags
fn (mut p Parser) generate_all_implied_end_tags_thorougly() {
	if p.open_elements.len == 0 {
		return
	}

	mut node := &(p.open_elements[p.open_elements.len - 1] as dom.HTMLElement)
	for node.tag_name in implied_end_tag_names_thorough {
		_ := p.open_elements.pop()
	}
}

// https://html.spec.whatwg.org/multipage/parsing.html#clear-the-list-of-active-formatting-elements-up-to-the-last-marker
fn (mut p Parser) clear_afe_to_last_marker() {
	for p.active_formatting_elements.len > 0 {
		if p.active_formatting_elements.pop().is_marker {
			break
		}
	}
}

// todo: This is definitely no doing what it is supposed to
// https://html.spec.whatwg.org/multipage/parsing.html#reconstruct-the-active-formatting-elements
fn (mut p Parser) reconstruct_afe() {
	mut i := if p.active_formatting_elements.len > 0 {
		p.active_formatting_elements.len - 1
	} else {
		return
	}
	mut entry := p.active_formatting_elements[i]
	if entry.is_marker || p.open_elements.has(entry.HTMLElement) {
		return
	}
	for i > 0 {
		i--
		entry = p.active_formatting_elements[i]
		if entry.is_marker || p.open_elements.has(entry.HTMLElement) {
			break
		}
	}
	for i < p.active_formatting_elements.len {
		i++
		// p.open_elements << entry.HTMLElement
	}
}

// https://html.spec.whatwg.org/multipage/parsing.html#reset-the-insertion-mode-appropriately
fn (mut p Parser) reset_insertion_mode_appropriately() {
	mut last := false
	mut node_index := p.open_elements.len - 1
	mut node := p.open_elements[node_index]
	for {
		// V bug doesn't allow this without voidptr:
		// https://github.com/vlang/v/issues/19441
		if voidptr(node) == voidptr(p.open_elements.first()) {
			last = true
			// if the parser was created as part of the HTML fragment parsing algorithm
			// set the node to the context element passed to that algorithm
		}

		if mut node is dom.HTMLSelectElement {
			if last {
				p.insertion_mode = .in_select
				return
			}
			ancestor := p.open_elements.first()
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

		html_node := node as dom.HTMLElement
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
		node = p.open_elements[node_index]
	}
}

// close_p_element closes an open <p> element.
// https://html.spec.whatwg.org/multipage/parsing.html#close-a-p-element
fn (mut p Parser) close_p_element() {
	p.generate_implied_end_tags(exclude: ['p'])
	if p.open_elements.len > 0 {
		tag_name := (p.open_elements.last() as dom.HTMLElement).tag_name
		if tag_name != 'p' {
			put(
				typ:  .warning
				text: 'Expected current_node to be <p>; got opened <${tag_name}>.'
			)
		}
		p.pop_open_elems_until('p')
	} else {
		put(
			typ:  .warning
			text: 'No opened <p> elements.'
		)
	}
}

// pop_open_elems_until continues to pop the last element from `p.open_elements`
// until `tag_name` has been popped or the `p.open_elements` is emptied.
fn (mut p Parser) pop_open_elems_until(target_tag_names ...string) {
	mut popped_tag_name := ''
	for p.open_elements.len > 0 {
		popped_elem := p.open_elements.pop()
		popped_tag_name = (popped_elem as dom.HTMLElement).tag_name
		if popped_tag_name in target_tag_names {
			break
		}
	}
}

// has_element_in_scope_of checks if `target_tag_name` is opened somewhere in the stack
// until either the scope boundary is met (`scope`) or the end of the open
// elements has been reached.
// https://html.spec.whatwg.org/multipage/parsing.html#has-an-element-in-scope
fn (mut p Parser) has_element_in_scope_of(target_tag_name string, scope []string) bool {
	for i := p.open_elements.len - 1; i >= 0; i-- {
		open_tag_name := (p.open_elements[i] as dom.HTMLElement).tag_name
		if open_tag_name in scope || open_tag_name == target_tag_name {
			return true
		}
	}
	return false
}

// has_element_in_scope checks if `target_tag_name` is opened somewhere in the stack
// until either the scope boundary is met (`const default_scope`) or the end of the
// open elements has been reached.
@[inline]
fn (mut p Parser) has_element_in_scope(target_tag_name string) bool {
	return p.has_element_in_scope_of(target_tag_name, default_scope)
}

// has_element_in_list_scope checks if `target_tag_name` is opened somewhere in the
// stack until either the scope boundary is met (`const default_scope`) or the end of
// the open elements has been reached.
@[inline]
fn (mut p Parser) has_element_in_list_scope(target_tag_name string) bool {
	return p.has_element_in_scope_of(target_tag_name, list_scope)
}

// has_element_in_button_scope checks if `target_tag_name` is opened somewhere in the
// stack until either the scope boundary is met (`const default_scope`) or the end of
// the open elements has been reached.
@[inline]
fn (mut p Parser) has_element_in_button_scope(target_tag_name string) bool {
	return p.has_element_in_scope_of(target_tag_name, button_scope)
}

// has_element_in_table_scope checks if `target_tag_name` is opened somewhere in the
// stack until either the scope boundary is met (`const default_scope`) or the end of
// the open elements has been reached.
@[inline]
fn (mut p Parser) has_element_in_table_scope(target_tag_name string) bool {
	return p.has_element_in_scope_of(target_tag_name, table_scope)
}

// has_element_in_select_scope checks if `target_tag_name` is opened somewhere in the
// stack until either the scope boundary is met (`const select_scope`) or the end of
// the open elements has been reached.
@[inline]
fn (mut p Parser) has_element_in_select_scope(target_tag_name string) bool {
	return p.has_element_in_scope_of(target_tag_name, select_scope)
}

// has_open_element checks if there is an open element on the stack with the same
// name as the one provided.
@[inline]
fn (mut p Parser) has_open_element(target_tag_name string) bool {
	return p.has_element_in_scope_of(target_tag_name, [])
}

// generic_raw_text_element_algo
fn (mut p Parser) generic_raw_text_element_algo(state TokenizerState) {
	_ := p.insert_html_element()
	p.tokenizer.state = state
	p.original_insertion_mode = p.insertion_mode
	p.insertion_mode = .text
}

// adjust_mathml_attrs changes the case of attribute names to the correct value
// if wrong.
fn (mut p Parser) adjust_mathml_attrs() {
	mut tag_token := p.current_token as TagToken
	for i, attr in tag_token.attributes {
		if attr.name() == 'definitionurl' {
			tag_token.attributes[i].name = 'definitionURL'.bytes()
		}
	}
	p.current_token = tag_token
}

// adjust_svg_attrs changes the case of attribute names to the correct value
// if wrong.
fn (mut p Parser) adjust_svg_attrs() {
	mut tag_token := p.current_token as TagToken
	for i, attr in tag_token.attributes {
		if attr.name() in adjusted_svg_attrs {
			tag_token.attributes[i].name = adjusted_svg_attrs[attr.name()].bytes()
		}
	}
	p.current_token = tag_token
}
