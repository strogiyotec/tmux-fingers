require 'logger'

module Fingers
  def Fingers.logger
    return @logger if @logger

    @logger = Logger.new(
       Fingers::Dirs::LOG_PATH
    )
    @logger.level = Logger.const_get(ENV.fetch('FINGERS_LOG_LEVEL', 'DEBUG'))
    @logger
  end
end

