class Fingers::View
  def initialize(hinter:, state:, output:)
    @hinter = hinter
    @state = state
    @output = output
  end

  def process_input(input)
    command, *args = input.gsub(/-/, '_').split(':')
    send("#{command}_message".to_sym, *args)
  end

  def render
    # TODO: default printer?
    output.print `clear`
    hide_cursor
    hinter.run
  end

  def run_action
    # TODO: handle exit_message, no need to run action
    Fingers::ActionRunner.new(
      hint: state.input,
      modifier: state.modifier,
      match: state.result
    ).run
  end

  def result
    state.result
  end

  private

  attr_reader :hinter, :state, :output

  def hide_cursor
    output.print `tput civis`
  end

  def exit_message
    state.exiting = true
    bail_out!
  end

  def toggle_help_message
    output.print `clear`
    output.print 'Help message'
  end

  def toggle_compact_mode_message
    state.compact_mode = !state.compact_mode
    render
  end

  def noop_message; end

  def toggle_multi_mode_message
    prev_state = state.multi_mode
    state.multi_mode = !state.multi_mode
    current_state = state.multi_mode

    if prev_state == true && current_state == false
      state.result = state.multi_matches.join(' ')
      bail_out!
    end
  end

  # TODO: better naming
  def hint_message(hint, modifier)
    state.input += hint
    state.modifier = modifier

    match = hinter.lookup(state.input)

    handle_match(match) if match
  end

  def handle_match(match)
    if state.multi_mode
      state.multi_matches << match
      state.selected_hints << state.input
      state.input = ''
      render
    else
      state.result = match
      bail_out!
    end
  end

  def bail_out!
    raise ::Fingers::BailOut
  end

  def tmux
    @tmux ||= ::Tmux.instance
  end
end
