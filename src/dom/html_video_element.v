module dom

// https://html.spec.whatwg.org/multipage/media.html#htmlvideoelement
pub struct HTMLVideoElement {
	HTMLMediaElement
pub mut:
	width        u64
	height       u64
	video_width  u64
	video_height u64
	poster       string
	plays_inline bool
}

@[inline]
pub fn HTMLVideoElement.new(owner_document &Document) &HTMLVideoElement {
	return &HTMLVideoElement{
		owner_document: owner_document
		tag_name:       'video'
	}
}
