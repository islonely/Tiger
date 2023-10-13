module components

import gg
import gx
import strings

// TextField is a component that displays a text field.
pub struct TextField {
__global:
	global_x         int
	global_y         int
	width            int
	height           int                 = 50
	padding          Padding             = Padding.xy(15, 10)
	radius           int                 = 5
	font_size        int                 = 18
	font_color       gx.Color            = gx.hex(0xEEEEEEFF)
	bg_color         gx.Color            = gx.hex(0x333333FF)
	placeholder      ?string             = 'https://example.com'
	value            strings.Builder     = strings.new_builder(500)
	vertical_align   VerticalAlignment   = .middle
	horizontal_align HorizontalAlignment = .left
}

// text_pos generates the X and Y position for the text based on the alignment
// and padding of the field.
fn (field TextField) text_pos(mut context gg.Context, text string) (int, int) {
	x := match field.horizontal_align {
		.left { int(field.global_x + field.padding.left) }
		.center { int(field.global_x + field.width / 2 - context.text_width(text) / 2) }
		.right { int(field.global_x + field.width - field.padding.right - context.text_width(text)) }
	}
	y := match field.vertical_align {
		.top { int(field.global_y + field.padding.top) }
		.middle { int(field.global_y + field.height / 2 - context.text_height(text) / 2) }
		.bottom { int(field.global_y + field.height - field.padding.bottom - context.text_height(text)) }
	}
	return x, y
}

// draw draws the text field to the context.
pub fn (mut field TextField) draw(mut context gg.Context) {
	context.draw_rounded_rect_filled(field.global_x, field.global_y, field.width, field.height,
		field.radius, field.bg_color)

	context.set_text_cfg(size: field.font_size)
	if placeholder := field.placeholder {
		if field.value.len == 0 {
			field_x, field_y := field.text_pos(mut context, placeholder)
			context.draw_text(field_x, field_y, placeholder,
				size: field.font_size
				color: field.font_color
			)
		}
	}
}
