class Fingers::View
  def initialize(hinter:)
    @hinter = hinter
    # TODO extract this to a class, share it with hinter so it can know which
    # hints to highlight in multi mode
    @state = {
      "pane_was_zoomed": nil,
      "show_help": false,
      "compact_mode": false, # read from config
      "multi_mode": false,
      "input": "",
      "modifier": "",
      "selected_hints": [],
      "selected_matches": [],
      "multi_matches": []
    }

  end

  def process_input(input)
    command, *args = input.gsub(/-/, '_').split(":")
    send("#{command}_message".to_sym, *args)
  end

  def render
    hide_cursor
    hinter.run
  end

  def run_action
    #TODO handle exit_message, no need to run action
    Fingers::ActionRunner.new(
      hint: state[:input],
      modifier: state[:modifier],
      match: state[:result]
    ).run
  end

  def result
    state[:result]
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
    prev_state = state[:multi_mode]
    state[:multi_mode] = !state[:multi_mode]
    current_state = state[:multi_mode]

    if prev_state == true && current_state == false
      state[:result] = state[:multi_matches].join(' ')
      bail_out!
    end
  end

  # TODO better naming
  def hint_message(hint, modifier)
    state[:input] = state[:input] + hint
    state[:modifier] = modifier

    match = hinter.lookup(state[:input])

    if match
      handle_match(match)
    end
  end

  def handle_match(match)
    if state[:multi_mode]
      state[:multi_matches] << match
      state[:input] = ''
    else
      state[:result] = match
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
