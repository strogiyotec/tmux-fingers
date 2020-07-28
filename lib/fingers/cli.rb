#!/usr/bin/env ruby

class Fingers::CLI
  def initialize(args, cli_path)
    @args = args
    @cli_path = cli_path
  end

  def run
    command_class = case ARGV[0]
                    when 'start'
                      Fingers::Command::Start
                    when 'show_hints'
                      Fingers::Command::ShowHints
                    when 'send_input'
                      Fingers::Command::SendInput
                    when 'load_config'
                      Fingers::Command::LoadConfig
                    when 'setup_fingers_mode_bindings'
                      Fingers::Command::SetupFingersModeBindings
                    else
                      raise "Unknown command #{ARGV[0]}"
              end

    begin
      command_class.new(args, cli_path).run
    rescue StandardError => e
      Fingers.logger.error e
    end
  end

  attr_reader :args, :cli_path
end
