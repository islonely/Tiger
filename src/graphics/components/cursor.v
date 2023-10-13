module components

pub interface Cursor {
mut:
	set_x(x int)
	set_y(y int)
}

pub struct PipeCursor {
pub mut:
	pos AnimationPos
}
