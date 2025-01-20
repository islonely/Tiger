module dom

// https://dom.spec.whatwg.org/#interface-text
pub interface TextInterface {
	CharacterDataInterface
mut:
	whole_text string
}

@[heap]
pub struct Text {
	CharacterData
pub mut:
	whole_text string
}

@[inline]
pub fn Text.new(owner_document &Document, data string) &Text {
	return &Text{
		data:           data
		node_type:      .cdata_section
		owner_document: owner_document
	}
}

// is_whitespace returns whether or not Text data contains only
// whitespace characters.
pub fn (text Text) is_whitespace() bool {
	for c in text.data {
		if c !in '\n\r\f\t '.bytes() {
			return false
		}
	}
	return true
}
