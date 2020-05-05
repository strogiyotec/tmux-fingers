require_relative './tmux'

module Fingers
  ConfigStruct = Struct.new(
    :key,
    :keyboard_layout,
    :patterns,
    :alphabet,
    :main_action,
    :ctrl_action,
    :alt_action,
    :shift_action,
    :compact_hints,
    :hint_position,
    :hint_position_nocompact,
    :hint_format,
    :selected_hint_format,
    :selected_highlight_format,
    :highlight_format,
    :hint_format_nocompact,
    :selected_hint_format_nocompact,
    :selected_highlight_format_nocompact,
    :highlight_format_nocompact
  ) do
    def initialize(
      key = 'F',
      keyboard_layout = 'qwerty',
      alphabet = [],
      patterns = [],
      main_action = ':copy:',
      ctrl_action = ':open:',
      alt_action = '',
      shift_action = ':paste:',
      compact_hints = true,
      hint_position = 'left',
      hint_position_nocompact = 'right',
      hint_format = Tmux.instance.parse_format("#[fg=yellow,bold]%s"),
      selected_hint_format = Tmux.instance.parse_format("#[fg=yellow,bold]%s"),
      selected_highlight_format = Tmux.instance.parse_format("#[fg=green,nobold,dim]%s"),
      highlight_format = Tmux.instance.parse_format("#[fg=yellow,nobold,dim]%s"),
      hint_format_nocompact = Tmux.instance.parse_format("#[fg=yellow,bold][%s]"),
      selected_hint_format_nocompact = Tmux.instance.parse_format("#[fg=green,bold][%s]"),
      selected_highlight_format_nocompact = Tmux.instance.parse_format("#[fg=green,nobold,dim][%s]"),
      highlight_format_nocompact = Tmux.instance.parse_format("#[fg=yellow,nobold,dim]%s")
    )
      super
    end
  end

  def Fingers.config
    begin
      $config ||= Fingers.load_from_cache
    rescue StandardError
      $config ||= ConfigStruct.new
    end
  end

  def Fingers.reset_config
    $config = ConfigStruct.new
  end

  def Fingers.save_config
    puts "saving config"
    File.open('/tmp/fingers.config', 'w') do |f|
      f.write(Marshal.dump(Fingers.config))
    end
  end

  def Fingers.load_from_cache
    Marshal.load(File.open('/tmp/fingers.config'))
  end
end
