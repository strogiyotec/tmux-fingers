class Fingers::BailOut < StandardError; end

class PanePrinter
  def initialize(pane_tty)
    @pane_tty = pane_tty
    @file = File.open(@pane_tty, 'w')
  end

  def print(msg)
    @file.write(msg)
  end
end

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
    :result,
    :exiting
  )

  def run
    _, _input_method, original_pane_id, _original_window, benchmark_id, pane_tty, fingers_pane_id = args

    @original_pane_id = original_pane_id
    @fingers_pane_id = fingers_pane_id

    pane_printer = PanePrinter.new(pane_tty)

    Fingers.logger.debug("fingers_pane_id #{@fingers_pane_id}")
    Fingers.logger.debug("original_pane_id #{@original_pane_id}")

    begin
      initialize_state!
      store_options

      @hinter = ::Fingers::Hinter.new(
        input: tmux.capture_pane(original_pane_id).chomp,
        width: original_pane['pane_width'].to_i,
        state: state,
        output: pane_printer
      )
      @view = ::Fingers::View.new(hinter: @hinter, state: state, output: pane_printer)

      @view.render

      tmux.swap_panes(fingers_pane_id, original_pane_id)

      input_socket = InputSocket.new

      tmux.disable_prefix
      tmux.set_key_table 'fingers'

      Fingers.logger.debug("benchmark:end[#{benchmark_id}] #{Time.now.to_f * 1000}")
      input_socket.on_input do |input|
        @view.process_input(input)
      end
    # TODO: exceptions for flow control, not cool
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

  def store_options
    @original_options = {}

    options_to_preserve.each do |option|
      value = tmux.get_global_option(option)
      @original_options[option] = value
      Fingers.logger.debug("[store] Setting #{option} to #{value}")
    end
  end

  def restore_options
    Fingers.logger.debug('restoring options or at least trying')
    @original_options.each do |option, value|
      Fingers.logger.debug("[restore] Setting #{option} to #{value}")
      tmux.set_global_option(option, value)
    end
  end

  def options_to_preserve
    %w[prefix]
  end

  def original_pane
    tmux.pane_by_id(original_pane_id)
  end

  def pane_was_zoomed?
    @pane_was_zoomed
  end

  def teardown
    tmux.set_key_table 'root'
    Fingers.logger.debug("should kill pane #{@fingers_pane_id}")
    tmux.swap_panes(@fingers_pane_id, @original_pane_id)
    tmux.kill_pane(@fingers_pane_id)

    restore_options
    view.run_action unless state.exiting
  end

  def initialize_state!
    @state = State.new

    @state.compact_mode = Fingers.config.compact_hints
    @state.multi_mode = false
    @state.show_help = false
    @state.input = ''
    @state.modifier = ''
    @state.selected_hints = []
    @state.selected_matches = []
    @state.multi_matches = []
    @state.exiting = false
  end
end
