module dom

// https://html.spec.whatwg.org/multipage/media.html#htmlaudioelement
pub struct HTMLAudioElement {
	HTMLMediaElement
}

pub fn HTMLAudioElement.new(owner_document &Document) &HTMLAudioElement {
	return &HTMLAudioElement{
		owner_document: owner_document
		tag_name: 'audio'
	}
}
