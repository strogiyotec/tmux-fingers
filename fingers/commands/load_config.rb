require_relative '../lib/config'
require_relative '../lib/tmux'

class Fingers::Command::LoadConfig < Fingers::Command::Base
  DEFAULT_PATTERNS = {
    "ip": "\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}",
    "uuid": "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
    "sha": "[0-9a-f]{7,128}",
    "digit": "[0-9]{4,}",
    "url": "((https?://|git@|git://|ssh://|ftp://|file:///)[^ ]+)",
    "path": "(([.\\w\\-~\\$@]+)?(/[.\\w\\-@]+)+/?)",
  }

  ALPHABET_MAP = {
    "qwerty": "asdfqwerzxcvjklmiuopghtybn",
    "qwerty-homerow": "asdfjklgh",
    "qwerty-left-hand": "asdfqwerzcxv",
    "qwerty-right-hand": "jkluiopmyhn",
    "azerty": "qsdfazerwxcvjklmuiopghtybn",
    "azerty-homerow": "qsdfjkmgh",
    "azerty-left-hand": "qsdfazerwxcv",
    "azerty-right-hand": "jklmuiophyn",
    "qwertz": "asdfqweryxcvjkluiopmghtzbn",
    "qwertz-homerow": "asdfghjkl",
    "qwertz-left-hand": "asdfqweryxcv",
    "qwertz-right-hand": "jkluiopmhzn",
    "dvorak": "aoeuqjkxpyhtnsgcrlmwvzfidb",
    "dvorak-homerow": "aoeuhtnsid",
    "dvorak-left-hand": "aoeupqjkyix",
    "dvorak-right-hand": "htnsgcrlmwvz",
    "colemak": "arstqwfpzxcvneioluymdhgjbk",
    "colemak-homerow": "arstneiodh",
    "colemak-left-hand": "arstqwfpzxcv",
    "colemak-right-hand": "neioluymjhk"
  }

  def run
    parse_tmux_conf
    setup_bindings
  end

  private

  def parse_tmux_conf
    options = shell_safe_options

    user_defined_patterns = []

    Fingers.reset_config

    options.each do |pair|
      option, value = pair

      option = option.tr('-', '_')

      case
      when option.match(/pattern/)
        user_defined_patterns.push(value)
      when option.match(/format/)
        puts "parsing #{value}"
        Fingers.config.send("#{option}=".to_sym, Tmux.instance.parse_format(value))
      when option == "compact_hints"
        Fingers.config.compact_hints = to_bool(value)
      else
        Fingers.config.send("#{option}=".to_sym, value)
      end
    end

    Fingers.config.patterns = clean_up_patterns([
      *enabled_default_patterns,
      *user_defined_patterns
    ])

    puts Fingers.config.patterns

    puts Fingers.config.keyboard_layout

    Fingers.config.alphabet = ALPHABET_MAP[Fingers.config.keyboard_layout.to_sym].split('')

    Fingers.save_config
  end

  def clean_up_patterns(patterns)
    patterns.select do |pattern|
      pattern.length > 0
    end
  end

  def setup_bindings
    input_mode = "fingers-mode"

    if input_mode == "fingers-mode"
      `tmux run -b "#{cli} setup_fingers_mode_bindings"`
    end

    `tmux bind-key "#{Fingers.config.key}" run-shell "#{cli} start '#{input_mode}' '\#{pane_id}' '\#{window_id}'"`
  end

  def enabled_default_patterns
    DEFAULT_PATTERNS.values
  end

  def to_bool(input)
    input == "1"
  end

  def shell_safe_options
    finger_option_names = `tmux show-options -g | grep ^@fingers`.split("\n").map { |line| line.split(" ")[0] }

    options = {}
    finger_option_names.each do |option|
      options[option.gsub(/^@fingers-/, '')] = `tmux show-option -gv #{option}`.chomp
    end

    options
  end
end
