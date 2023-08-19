module dom

enum TrackReadyState {
	@none
	loading
	last_modified
	error
}

// https://html.spec.whatwg.org/multipage/media.html#htmltrackelement
pub struct HTMLTrackElement {
	HTMLElement
pub mut:
	kind        string
	src         string
	src_lang    string
	label       string
	default     bool
	ready_state TrackReadyState
	// track TextTrack
}
