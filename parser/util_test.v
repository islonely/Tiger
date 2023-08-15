module parser

import strings

fn test_rune_to_lower() {
	assert rune_to_lower(`A`) == `a`
	assert rune_to_lower(`a`) == `a`
	assert rune_to_lower(`💀`) == `💀`
}

fn test_builder_contents() {
	mut bldr := strings.new_builder(50)
	assert builder_contents(bldr) == ''
	bldr.write_string('hello')
	assert builder_contents(bldr) == 'hello'
	bldr.write_rune(`🫨`)
	assert builder_contents(bldr) == 'hello🫨'
}

fn test_is_surrogate() {
	for i in 0xd800..(0xdfff + 1) {
		assert is_surrogate(rune(i)) == true
	}
	assert is_surrogate(rune(0xd7ff)) == false
	assert is_surrogate(rune(0xe000)) == false
}

fn test_is_noncharacter() {
	arr := [
		rune(0xfffe), 0xffff, 0x1fffe, 0x1ffff, 0x2fffe,
		0x2ffff, 0x3fffe, 0x3ffff, 0x4fffe, 0x4ffff, 0x5fffe,
		0x5ffff, 0x6fffe, 0x6ffff, 0x7fffe, 0x7ffff, 0x8fffe,
		0x8ffff, 0x9fffe, 0x9ffff, 0xafffe, 0xaffff, 0xbfffe,
		0xbffff, 0xcfffe, 0xcffff, 0xdfffe, 0xdffff, 0xefffe,
		0xeffff, 0xffffe, 0xfffff, 0x10fffe, 0x10ffff
	]
	for r in arr {
		assert is_noncharacter(r) == true
	}
	for r in 0xfdd0..(0xfdef + 1) {
		assert is_noncharacter(r) == true
	}
	assert is_noncharacter(0xffffffff) == false
	assert is_noncharacter(0xfdcf) == false
}

fn test_is_c0_control() {
	for i in 0x0000..(0x001f + 1) {
		assert is_c0_control(rune(i)) == true
	}
	assert is_c0_control(rune(0x0020)) == false
}

fn test_is_control() {
	for i in 0x007f..(0x009f + 1) {
		assert is_control(rune(i)) == true
	}
	assert is_control(rune(0x0100)) == false
}