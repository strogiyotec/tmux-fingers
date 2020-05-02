require_relative '../lib/hinter'
require_relative '../lib/input_socket'

class Fingers::Command::ShowHints < Fingers::Command::Base
  def run
    _, input_method, current_pane_id, current_window_id = args

    begin
      hinter = Hinter.new(input: tmux.capture_pane(current_pane_id)[..-2])

      hinter.run
      hide_cursor

      tmux.swap_panes(ENV['TMUX_PANE'], current_pane_id)

      input_socket = InputSocket.new

      tmux.set_key_table "fingers"

      input_socket.on_input do |input|
        raise StandardError if input == "exit"
        `tmux display-message "received #{input}"`
      end

    rescue StandardError => e
      tmux.set_key_table "root"
    end

    tmux.set_key_table "root"
    tmux.swap_panes(ENV['TMUX_PANE'], current_pane_id)
  end

  private

  def hide_cursor
    print `tput civis`
  end
end
