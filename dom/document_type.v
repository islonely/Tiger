module dom

import strings

const doctype_missing = '\0\0\0\0\0\0\0\0'

// https://dom.spec.whatwg.org/#interface-documenttype
pub struct DocumentType {
	Node
pub mut:
	name      string
	public_id string
	system_id string
}

// to_html converts the DocumentType into an HTML DOCTYPE tag.
pub fn (doctype DocumentType) to_html() string {
	mut builder := strings.new_builder(200)
	builder.write_string('<!DOCTYPE ${doctype.name}')
	if doctype.public_id.len > 0 && doctype.public_id != dom.doctype_missing {
		builder.write_string(' PUBLIC ${doctype.public_id}')
	}
	if doctype.system_id.len > 0 && doctype.system_id != dom.doctype_missing {
		builder.write_string(' SYSTEM ${doctype.system_id}')
	}
	builder.writeln('>')
	return builder.str()
}
