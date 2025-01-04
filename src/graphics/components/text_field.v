module components

import gg
import gx

const valid_keys_lower = {
	gg.KeyCode._0:  u8(`0`)
	._1:            `1`
	._2:            `2`
	._3:            `3`
	._4:            `4`
	._5:            `5`
	._6:            `6`
	._7:            `7`
	._8:            `8`
	._9:            `9`
	.apostrophe:    `0`
	.comma:         `,`
	.minus:         `-`
	.period:        `.`
	.slash:         `/`
	.semicolon:     `;`
	.equal:         `=`
	.a:             `a`
	.b:             `b`
	.c:             `c`
	.d:             `d`
	.e:             `e`
	.f:             `f`
	.g:             `g`
	.h:             `h`
	.i:             `i`
	.j:             `j`
	.k:             `k`
	.l:             `l`
	.m:             `m`
	.n:             `n`
	.o:             `o`
	.p:             `p`
	.q:             `q`
	.r:             `r`
	.s:             `s`
	.t:             `t`
	.u:             `u`
	.v:             `v`
	.w:             `w`
	.x:             `x`
	.y:             `y`
	.z:             `z`
	.left_bracket:  `[`
	.backslash:     `\\`
	.right_bracket: `]`
	.grave_accent:  `\``
	.space:         ` `
}
const valid_keys_upper = {
	gg.KeyCode._0:  u8(`)`)
	._1:            `!`
	._2:            `@`
	._3:            `#`
	._4:            `$`
	._5:            `%`
	._6:            `^`
	._7:            `&`
	._8:            `*`
	._9:            `(`
	.apostrophe:    `"`
	.comma:         `<`
	.minus:         `_`
	.period:        `>`
	.slash:         `?`
	.semicolon:     `:`
	.equal:         `+`
	.a:             `A`
	.b:             `B`
	.c:             `C`
	.d:             `D`
	.e:             `E`
	.f:             `F`
	.g:             `G`
	.h:             `H`
	.i:             `I`
	.j:             `J`
	.k:             `K`
	.l:             `L`
	.m:             `M`
	.n:             `N`
	.o:             `O`
	.p:             `P`
	.q:             `Q`
	.r:             `R`
	.s:             `S`
	.t:             `T`
	.u:             `U`
	.v:             `V`
	.w:             `W`
	.x:             `X`
	.y:             `Y`
	.z:             `Z`
	.left_bracket:  `{`
	.backslash:     `|`
	.right_bracket: `}`
	.grave_accent:  `~`
	.space:         ` `
}

// TextField is a component that displays a text field.
pub struct TextField {
__global:
	global_x         int
	global_y         int
	width            int
	height           int      = 50
	padding          Padding  = Padding.all(10)
	radius           int      = 5
	font_size        int      = 18
	font_color       gx.Color = gx.hex(0xEEEEEE)
	bg_color         gx.Color = gx.hex(0x333333)
	value            string
	vertical_align   VerticalAlignment   = .middle
	horizontal_align HorizontalAlignment = .left
	cursor           PipeCursor
	has_focus        bool = true
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

fn (field TextField) cursor_pos(mut context gg.Context) (int, int) {
	text_x, text_y := field.text_pos(mut context, field.value)
	cursor_x := text_x + context.text_width(field.value)
	cursor_y := text_y - if field.value.len == 0 { field.font_size / 2 } else { 0 }
	return cursor_x, cursor_y
}

// draw draws the text field to the context.
pub fn (mut field TextField) draw(mut context gg.Context) {
	context.draw_rounded_rect_filled(field.global_x, field.global_y, field.width, field.height,
		field.radius, field.bg_color)

	context.set_text_cfg(size: field.font_size)
	field_x, field_y := field.text_pos(mut context, field.value)
	context.draw_text(field_x, field_y, field.value,
		size:  field.font_size
		color: field.font_color
	)

	field.cursor.update()
	if field.has_focus {
		if field.cursor.blink_visibility {
			// draw cursor
			x, y := field.cursor_pos(mut context)
			w := 2
			h := field.font_size
			context.draw_rect_filled(x, y, w, h, gx.hex(0x7489FF))
		}
	}
}

pub fn (mut field TextField) write_key_code(key_code gg.KeyCode, modifiers gg.Modifier) {
	match key_code {
		.backspace {
			if field.value.len == 0 {
				return
			}
			field.value = field.value[..field.value.len - 1]
		}
		else {
			if key_code !in valid_keys_lower {
				return
			}

			ch := if modifiers.has(.shift) {
				valid_keys_upper[key_code]
			} else {
				valid_keys_lower[key_code]
			}

			field.value += ch.ascii_str()
		}
	}
}
