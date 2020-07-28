class Fingers::Command::Start < Fingers::Command::Base
  def run
    _, input_method, original_pane_id, original_window_id, benchmark_id = args

    cmd = "ruby --disable-gems #{cli} show_hints #{input_method} #{original_pane_id} #{original_window_id} #{benchmark_id}"

    cmd = 'cat'

    # TODO: why can't we create window with size directly?

    window_id, pane_id, pane_tty = tmux.create_window('[fingers]', cmd, 80, 24)

    original_pane = tmux.pane_by_id(original_pane_id)

    tmux.resize_window(
      window_id,
      original_pane['pane_width'].to_i,
      original_pane['pane_height'].to_i
    )

    show_hints = Fingers::Command::ShowHints.new(
      ['show_hints', input_method, original_pane_id, original_window_id, benchmark_id, pane_tty, pane_id],
      cli
    )

    show_hints.run
  end
end
