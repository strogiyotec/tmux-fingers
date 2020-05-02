require_relative "./base"

class Fingers::Command::Start < Fingers::Command::Base
  def run
    _, input_method, current_pane_id, current_window_id = args

    cmd =  "#{cli} show_hints #{input_method} #{current_pane_id} #{current_window_id}"

    # TODO check init_pane_cmd, HISTFILE=/dev/null and shit
    tmux.create_window("[fingers]", "bash --norc --noprofile -c '#{cmd}'", 80, 24)
  end
end
