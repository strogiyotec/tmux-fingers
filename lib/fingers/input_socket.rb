class InputSocket
  SOCKET_PATH = Fingers::Dirs::SOCKET_PATH

  def on_input
    remove_socket_file

    while true
      socket = server.accept
      yield socket.readline
    end
  end

  def send(cmd)
    socket = UNIXSocket.new(SOCKET_PATH)
    socket.write(cmd)
    socket.close
  end

  def close
    server.close
    remove_socket_file
  end

  private

  def server
    @server ||= UNIXServer.new(SOCKET_PATH)
  end

  def remove_socket_file
    `rm -rf #{SOCKET_PATH}`
  end
end
