class Fingers::BailOut < StandardError; end

class Fingers::Command::ShowHints < Fingers::Command::Base
  def run
    _, _input_method, original_pane_id = args

    @original_pane_id = original_pane_id

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
      @hinter = ::Fingers::Hinter.new(
        input: tmux.capture_pane(original_pane_id).chomp,
        width: original_pane['pane_width'].to_i
      )
      @view = ::Fingers::View.new(hinter: @hinter)

      @view.render

      set_pane_was_zoomed!

      tmux.swap_panes(ENV['TMUX_PANE'], original_pane_id)
      tmux.zoom_pane(ENV['TMUX_PANE']) if pane_was_zoomed?

      input_socket = InputSocket.new

      tmux.set_key_table "fingers"

      input_socket.on_input do |input|
        @view.process_input(input)
      end
    rescue ::Fingers::BailOut => e
      # noop
    rescue StandardError => e
      Fingers.logger.error(e)
    ensure
      teardown
    end

  end

  private

  attr_reader :hinter, :state, :original_pane_id, :view

  def original_pane
    tmux.pane_by_id(original_pane_id)
  end

  def pane_was_zoomed?
    @pane_was_zoomed
  end

  def set_pane_was_zoomed!
    return @pane_was_zoomed unless @pane_was_zoomed.nil?

    pane = tmux.pane_by_id(original_pane_id)
    return false unless pane

    @pane_was_zoomed = pane['window_zoomed_flag'] == '1'
  end

  def teardown
    tmux.set_key_table "root"
    tmux.swap_panes(ENV['TMUX_PANE'], original_pane_id)
    tmux.zoom_pane(original_pane_id) if pane_was_zoomed?

    view.run_action
    # TODO restore all other options
  end
end
