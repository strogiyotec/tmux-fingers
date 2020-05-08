class Fingers::Command::SetupFingersModeBindings < Fingers::Command::Base
  DISALLOWED_CHARS = /cimq/

  def run
    ('a'..'z').to_a.each do |char|
      next if char.match(DISALLOWED_CHARS)

      fingers_bind(char, "hint:#{char}:main")
      fingers_bind(char.upcase, "hint:#{char}:shift")
      fingers_bind("C-#{char}", "hint:#{char}:ctrl")
      fingers_bind("M-#{char}", "hint:#{char}:alt")
    end

    fingers_bind("C-c", "exit")
    fingers_bind("q", "exit")
    fingers_bind("Escape", "exit")

    fingers_bind("?", "toggle-help")
    fingers_bind("Space", "toggle_compact_mode")

    fingers_bind("Enter", "noop")
    fingers_bind("Tab", "toggle_multi_mode")

    fingers_bind("Any", "noop")
  end

  private

  def fingers_bind(key, command)
    `tmux bind-key -Tfingers "#{key}" run-shell -b "#{cli} send_input #{command}"`
  end
end
