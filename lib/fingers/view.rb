class Fingers::View
  def initialize(hinter:, state:)
    @hinter = hinter
    @state = state
  end

  def process_input(input)
    command, *args = input.gsub(/-/, '_').split(":")
    send("#{command}_message".to_sym, *args)
  end

  def render
    Fingers.logger.debug("rerendering")
    puts `clear`
    hide_cursor
    hinter.run
  end

  def run_action
    #TODO handle exit_message, no need to run action
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

  attr_reader :hinter, :state

  def hide_cursor
    print `tput civis`
  end

  def exit_message
    bail_out!
  end

  def toggle_help_message
    puts `clear`
    puts "Help message"
  end

  def toggle_compact_mode_message
  end

  def noop_message
  end

  def toggle_multi_mode_message
    prev_state = state.multi_mode
    state.multi_mode = !state.multi_mode
    current_state = state.multi_mode

    if prev_state == true && current_state == false
      state.result = state.multi_matches.join(' ')
      bail_out!
    end
  end

  # TODO better naming
  def hint_message(hint, modifier)
    state.input += hint
    state.modifier = modifier

    match = hinter.lookup(state.input)

    if match
      handle_match(match)
    end
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
