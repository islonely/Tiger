module dom

// https://dom.spec.whatwg.org/#interface-documenttype
pub struct DocumentType {
	Node
pub mut:
	name      string
	public_id string
	system_id string
}