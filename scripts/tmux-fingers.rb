#!/usr/bin/env ruby

require 'logger'
require_relative "./tmux"
require_relative "./input_socket"

class Fingers
  def initialize(phase:, input_method:, current_pane_id:, current_window_id:)
    @phase = phase
    @input_method = input_method
    @current_pane_id = current_pane_id
    @current_window = current_window_id
  end

  def run
    case phase
    when "init"
      init_phase
    when "fingers"
      require_relative './hinter'
      fingers_phase
    end
  end

  private

  attr_reader :input_method, :phase, :current_pane_id, :current_window_id

  def init_phase
    cmd =  "#{__FILE__} fingers #{input_method} #{current_pane_id} #{current_window_id}"

    # TODO check init_pane_cmd, HISTFILE=/dev/null and shit
    window_id, _ = tmux.create_window("[fingers]", "bash --norc --noprofile -c '#{cmd}'", 80, 24)
  end

  def fingers_phase
    begin
      hinter = Hinter.new(input: tmux.capture_pane(current_pane_id)[..-2])

      hinter.run

      tmux.swap_panes(ENV['TMUX_PANE'], current_pane_id)

      input_socket = InputSocket.new

      input_socket.on_input do |input|
        `tmux display-message "received #{input}"`
      end

    rescue StandardError => e
      puts "kaput"
      puts e
    end
    sleep 5
    tmux.swap_panes(ENV['TMUX_PANE'], current_pane_id)
  end

  def tmux
    @tmux ||= Tmux.instance
  end
end

Fingers.new(
  phase: ARGV[0],
  input_method: ARGV[1],
  current_pane_id: ARGV[2],
  current_window_id: ARGV[3]
).run
