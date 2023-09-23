module dom

pub enum ScriptType {
	@none
	classic
	@module
	importmap
}

pub type ScriptResult = ImportMapParseResult | Script | string

// todo: implement import map parse
// https://html.spec.whatwg.org/multipage/webappapis.html#import-map-parse-result
pub struct ImportMapParseResult {
}

// todo: implement script
// https://html.spec.whatwg.org/multipage/webappapis.html#concept-script
pub struct Script {
}

// https://html.spec.whatwg.org/multipage/scripting.html#htmlscriptelement
pub struct HTMLScriptElement {
	HTMLElement
pub mut:
	already_started             bool
	delaying_the_load_event     bool
	src                         string
	no_module                   bool
	async                       bool
	force_async                 bool = true
	from_external_file          bool
	@defer                      bool
	cross_origin                ?string
	text                        string
	integrity                   string
	referrer_policy             string
	blocking                    []string
	fetch_priority              string
	parser_document             ?&Document
	preparation_time_document   ?&Document
	ready_to_be_parser_executed bool
	// result                      ?ScriptResult = 'uninitialized'
	@type ScriptType
	// obsolete
	charset  string
	event    string
	html_for string
}

[inline]
pub fn HTMLScriptElement.new(owner_document &Document) &HTMLScriptElement {
	return &HTMLScriptElement{
		owner_document: owner_document
		local_name: 'script'
	}
}
