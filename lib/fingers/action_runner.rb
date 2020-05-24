class Fingers::ActionRunner
  def initialize(modifier:, match:, hint:)
    @modifier = modifier
    @match = match
    @hint = hint
  end

  def run
    Tmux.instance.set_buffer(match)
    Fingers.logger.debug("final_shell_command #{final_shell_command}")

    return unless final_shell_command

    `tmux run-shell -b "#{final_shell_command}"`
  end

  private

  attr_accessor :match, :modifier, :hint

  def final_shell_command
    @final_shell_command ||= case action
                             when ':copy:'
                               copy
                             when ':open:'
                               open
                             when ':paste:'
                               paste
                             when nil
                             else
                               shell_action
                             end
  end

  def copy
    return unless system_copy_command
    %{printf "#{match.shellescape}" | #{system_copy_command}}
  end

  def open
    return unless system_open_command
    %{printf "#{match.shellescape}" | #{system_open_command}}
  end

  def paste
    "tmux paste-buffer"
  end

  def shell_action
    "printf \"#{match}\" | MODIFIER=#{modifier} HINT=#{hint} #{action}"
  end

  def action
    @action ||= Fingers.config.get_action(modifier)
  end

  def system_copy_command
    @system_copy_command ||= if program_exists?("pbcopy")
                                if program_exists?("reattach-to-user-namespace")
                                  "reattach-to-user-namespace"
                                else
                                  "pbcopy"
                                end
                             elsif program_exists?("clip.exe")
                               "cat | clip.exe"
                             elsif program_exists?("wl-copy")
                               "wl-copy"
                             elsif program_exists?("xclip")
                               "xclip -selection clipboard"
                             elsif program_exists?("putclip")
                               "putclip"
                             end
  end

  def system_open_command
    @system_open_command ||= if program_exists?("cygstart")
                                "xargs cygstart"
                             elsif program_exists?("xdg-open")
                               "xargs xdg-open"
                             elsif program_exists?("open")
                               "open"
                             end
  end

  def program_exists?(program)
    system("which #{program}")
  end
end
