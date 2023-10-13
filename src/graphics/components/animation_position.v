module components

// AnimationPos is a component that holds the start, end and current position of an animation.
pub struct AnimationPos {
pub mut:
	start struct {
	pub mut:
		x int
		y int
	}

	end struct {
	pub mut:
		x int
		y int
	}

	current struct {
	pub mut:
		x int
		y int
	}
}
