# frozen_string_literal: true

require 'logger'
require 'json'
require 'singleton'
require 'socket'

# Top level fingers namespace
module Fingers
end

# Monkey patching string to add shellscape method, maybe remove.
class String
  def shellescape
    gsub('"', '\\"')
  end
end

class Time
  def to_ms
    (to_f * 1000.0).to_i
  end
end

require 'tmux'
require 'huffman'
require 'priority_queue'

require 'fingers/dirs'
require 'fingers/config'
require 'fingers/commands'
require 'fingers/commands/base'

# dynamically require command?
require 'fingers/commands/load_config'
require 'fingers/commands/send_input'
require 'fingers/commands/setup_fingers_mode_bindings'
require 'fingers/commands/show_hints'
require 'fingers/commands/start'
require 'fingers/action_runner'
require 'fingers/hinter'
require 'fingers/input_socket'
require 'fingers/logger'
require 'fingers/view'
require 'fingers/match_formatter'
require 'fingers/cli'
