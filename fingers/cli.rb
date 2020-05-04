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

    begin
      command_class.new(ARGV, __FILE__).run
    rescue StandardError => e
      logger.error e
    end
  end

  # TODO global logger would be cool
  def logger
    @logger ||= Logger.new('/tmp/fingers.log')
  end
end

Fingers::CLI.new.run
