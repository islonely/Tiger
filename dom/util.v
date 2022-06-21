module dom

// TODO: Replace this once `Struct Foo { child ?Foo }` (optional
// structure properties) is implemented.
fn ptr_optional<T>(ref &T) ?&T {
	unsafe {
		if ref == 0 {
			return none
		}

		return ref
	}
}
