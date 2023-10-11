module dom

// type MediaProvider = MediaStream | MediaSource | Blob

// https://html.spec.whatwg.org/multipage/media.html#mediaerror
enum MediaError {
	aborted = 1
	network
	decode
	src_not_supported
}

enum NetworkState {
	empty
	idle
	loading
	no_source
}

enum ReadyState {
	have_nothing
	have_metadata
	have_current_data
	have_future_data
	have_enough_data
}

// https://html.spec.whatwg.org/multipage/media.html#htmlmediaelement
pub struct HTMLMediaElement {
	HTMLElement
pub mut:
	error ?MediaError
	src   string
	// src_object ?&MediaProvider
	current_src   string
	cross_origin  ?string
	network_state NetworkState
	preload       string
	// buffered TimeRanges
	ready_state           ReadyState
	seeking               bool
	current_time          f64
	duration              f64
	paused                bool
	default_playback_rate f64
	playback_rate         f64
	preserves_pitch       bool
	// played TimeRanges
	// seekable TimeRanges
	ended         bool
	autoplay      bool
	loop          bool
	controls      bool
	volume        f64
	muted         bool
	default_muted bool
	// audio_tracks AudioTrackList
	// video_tracks VideoTrackList
	// text_tracks TextTrackList
}
