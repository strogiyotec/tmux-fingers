module Fingers::Dirs
  ROOT = File.expand_path('../../', File.dirname(__FILE__))
  CACHE = File.expand_path('.cache', ROOT)

  LOG_PATH = File.expand_path('fingers.log', ROOT)
  CONFIG_PATH = File.expand_path('fingers.config', CACHE)
  SOCKET_PATH = File.expand_path('fingers.sock', CACHE)
end
