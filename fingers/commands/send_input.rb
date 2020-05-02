require_relative '../lib/input_socket'

class Fingers::Command::SendInput < Fingers::Command::Base
  def run
    InputSocket.new.send(args[1])
  end
end
