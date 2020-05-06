require_relative "./base"

class Fingers::Command::Start < Fingers::Command::Base
  def run
    _, input_method, original_pane_id, original_window_id = args

    cmd = "#{cli} show_hints #{input_method} #{original_pane_id} #{original_window_id}"

    _window_id, pane_id = tmux.create_window("[fingers]", "bash --norc --noprofile -c '#{cmd}'", 80, 24)

    original_pane = tmux.pane_by_id(original_pane_id)

    tmux.resize_pane(
      pane_id,
      original_pane["pane_width"].to_i,
      original_pane["pane_height"].to_i,
    )
  end
end
