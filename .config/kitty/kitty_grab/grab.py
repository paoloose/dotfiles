from typing import Any, Dict, List

from kittens.tui.handler import result_handler
from kitty.typing import BossType

import _grab_ui

# This is a wrapper around the grab kitten
# It is used to pass the window content, dimensions and cursor position to _grab_ui.py

def main(args: List[str]) -> None:
    pass

@result_handler(no_ui=True)
def handle_result(args: List[str], data: Dict[str, Any], target_window_id: int, boss: BossType) -> None:
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return

    # An instance of Grab is already running
    # (not very elegant, but works)
    if "Grab" in window.title:
        return

    content = window.as_text(
        as_ansi=True, add_history=True,
        add_wrap_markers=True
    )
    content = content.replace('\r\n', '\n').replace('\r', '\n')
    n_lines = content.count('\n')
    top_line = (n_lines - (window.screen.lines - 1) - window.screen.scrolled_by)

    boss.run_kitten_with_metadata(_grab_ui.__file__, args=[
        '--title={}'.format(window.title),
        '--cursor-x={}'.format(window.screen.cursor.x),
        '--cursor-y={}'.format(window.screen.cursor.y),
        '--top-line={}'.format(top_line)],
        input_data=content.encode('utf-8'),
        window=window
    )
