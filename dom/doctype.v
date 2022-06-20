module dom

[heap]
pub struct Doctype {
	AbstractNode
__global:
	name      string
	public_id string
	system_id string
}
