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
__global:
	already_started                       bool
	async                                 bool
	blocking                              []string
	cross_origin                          ?string
	@defer                                bool
	delaying_the_load_event               bool
	fetch_priority                        string
	force_async                           bool = true
	from_external_file                    bool
	integrity                             string
	no_module                             bool
	parser_document                       ?&Document
	preparation_time_document             ?&Document
	referrer_policy                       string
	ready_to_be_parser_executed           bool
	result                                ?ScriptResult = 'uninitialized'
	src                                   string
	steps_to_run_when_the_result_is_ready ?fn (mut HTMLScriptElement)
	text                                  string
	@type                                 ScriptType
	// obsolete
	charset  string
	event    string
	html_for string
}

@[inline]
pub fn HTMLScriptElement.new(owner_document &Document) &HTMLScriptElement {
	return &HTMLScriptElement{
		owner_document: owner_document
		tag_name:       'script'
	}
}

@[params]
pub struct ScriptMarkAsReadyParams {
__global:
	script_result ?ScriptResult
}

// https://html.spec.whatwg.org/multipage/scripting.html#script-processing-model
pub fn (mut script_element HTMLScriptElement) mark_as_ready(params ScriptMarkAsReadyParams) {
	script_element.result = params.script_result
	if steps_to_run := script_element.steps_to_run_when_the_result_is_ready {
		steps_to_run(mut script_element)
	}
	script_element.steps_to_run_when_the_result_is_ready = none
	script_element.delaying_the_load_event = false
}
