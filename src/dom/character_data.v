module dom

@[heap]
pub struct CharacterData {
	Node
pub mut:
	data   string
	length u64
}

@[inline]
pub fn CharacterData.new(owner_document &Document, data string) &CharacterData {
	return &CharacterData{
		owner_document: owner_document
		data:           data
	}
}
