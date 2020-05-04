class Fingers::Command::LoadConfig < Fingers::Command::Base
  def run
    options = shell_safe_options

  end

  private

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

