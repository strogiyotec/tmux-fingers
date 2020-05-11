class Fingers::BailOut < StandardError; end

class Fingers::Command::ShowHints < Fingers::Command::Base
  State = Struct.new(
    :show_help,
    :compact_mode,
    :multi_mode,
    :input,
    :modifier,
    :selected_hints,
    :selected_matches,
    :multi_matches,
    :result
  )

  def run
    _, _input_method, original_pane_id = args

    @original_pane_id = original_pane_id


    begin
      initialize_state!

      @hinter = ::Fingers::Hinter.new(
        input: tmux.capture_pane(original_pane_id).chomp,
        width: original_pane['pane_width'].to_i,
        state: state
      )
      @view = ::Fingers::View.new(hinter: @hinter, state: state)

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

  attr_reader :hinter, :state, :original_pane_id, :view, :state

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

  def initialize_state!
    @state = State.new

    @state.compact_mode = Fingers.config.compact_hints
    @state.multi_mode = false
    @state.show_help = false
    @state.input = ""
    @state.modifier = ""
    @state.selected_hints = []
    @state.selected_matches = []
    @state.multi_matches = []
  end
end
