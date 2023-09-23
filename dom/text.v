module dom

// https://dom.spec.whatwg.org/#interface-text
pub struct Text {
	CharacterData
pub mut:
	whole_text string
}

[inline]
pub fn Text.new(owner_document &Document, data string) &Text {
	return &Text{
		data: data
		owner_document: owner_document
	}
}
