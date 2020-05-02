#!/usr/bin/env ruby

require 'logger'
require_relative "./fingers"
require_relative "./commands/start"
require_relative "./commands/show_hints"
require_relative "./commands/send_input"

class Fingers::CLI
  def run
    command_class = case ARGV[0]
              when "start"
                Fingers::Command::Start
              when "show_hints"
                Fingers::Command::ShowHints
              when "send_input"
                Fingers::Command::SendInput
              end

    command_class.new(ARGV, __FILE__).run
  end
end

Fingers::CLI.new.run
