require 'logger'
require 'json'
require 'singleton'
require 'socket'

module Fingers
end

class String
  def shellescape
    self.gsub('"', '\\"')
  end
end

require 'tmux'
require 'huffman'
require 'priority_queue'

require 'fingers/dirs'
require 'fingers/config'
require 'fingers/commands'
require 'fingers/commands/base'
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
require 'fingers/cli'
