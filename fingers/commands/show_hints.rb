class Fingers::BailOut < StandardError; end

require_relative '../lib/hinter'
require_relative '../lib/view'
require_relative '../lib/input_socket'


class Fingers::Command::ShowHints < Fingers::Command::Base
  def run
    _, input_method, current_pane_id, _current_window_id = args

    @state = {
      "pane_was_zoomed": nil,
      "show_help": false,
      "compact_mode": false, # read from config
      "multi_mode": false,
      "input": "",
      "modifier": "",
      "selected_hints": [],
      "selected_matches": []
    }

    begin
      @hinter = ::Fingers::Hinter.new(input: tmux.capture_pane(current_pane_id)[..-2])
      @view = ::Fingers::View.new(hinter: @hinter)

      @view.render

      tmux.swap_panes(ENV['TMUX_PANE'], current_pane_id)

      input_socket = InputSocket.new

      tmux.set_key_table "fingers"

      input_socket.on_input do |input|
        @view.process_input(input)
      end

    rescue ::Fingers::BailOut => e
      teardown
    end

    tmux.set_key_table "root"
    tmux.swap_panes(ENV['TMUX_PANE'], current_pane_id)
  end

  private

  attr_reader :hinter, :state

  def teardown
    tmux.set_key_table "root"

    # TODO restore all other options
  end
end
