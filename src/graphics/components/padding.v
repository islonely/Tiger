module components

// Padding is the space between the content and the edge of a component.
pub struct Padding {
__global:
	top    f32
	right  f32
	bottom f32
	left   f32
}

// Padding.x returns a Padding with the left and right fields set to `x`.
pub fn Padding.x(x f32) Padding {
	return Padding{0, x, 0, x}
}

// Padding.y returns a Padding with the top and bottom fields set to `y`.
pub fn Padding.y(y f32) Padding {
	return Padding{y, 0, y, 0}
}

// Padding.xy returns a Padding with the top and bottom fields set to `y` and
// the left and right fields set to `x`.
pub fn Padding.xy(x f32, y f32) Padding {
	return Padding{y, x, y, x}
}

// Padding.all returns a Padding with all fields set to `size`.
pub fn Padding.all(size f32) Padding {
	return Padding{size, size, size, size}
}

// Padding.sum_x returns the sum of the left and right fields.
pub fn (padding Padding) sum_x() f32 {
	return padding.left + padding.right
}

// Padding.sum_y returns the sum of the top and bottom fields.
pub fn (padding Padding) sum_y() f32 {
	return padding.top + padding.bottom
}

// Padding.sum returns the sum of the top, right, bottom, and left fields.
pub fn (padding Padding) sum() f32 {
	return padding.top + padding.right + padding.bottom + padding.left
}
