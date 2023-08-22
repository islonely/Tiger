module dom

// https://html.spec.whatwg.org/multipage/embedded-content.html#htmlpictureelement
pub struct HTMLPictureElement {
	HTMLElement
}

[inline]
pub fn HTMLPictureElement.new(owner_document &Document) &HTMLPictureElement {
	return &HTMLPictureElement{
		owner_document: owner_document
		local_name: 'picture'
	}
}
