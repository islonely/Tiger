module components

import time

pub struct PipeCursor {
pub mut:
	pos              AnimationPos
	blink_visibility bool
	blink_stopwatch  time.StopWatch = time.new_stopwatch()
	blink_frequency  int            = 500
}

pub fn (mut cursor PipeCursor) update() {
	if cursor.blink_stopwatch.elapsed().milliseconds() > cursor.blink_frequency {
		cursor.blink_stopwatch.restart()
		cursor.blink_visibility = !cursor.blink_visibility
	}
}
