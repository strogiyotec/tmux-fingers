require 'logger'

module Fingers
  def Fingers.logger
    return @logger if @logger

    @logger = Logger.new('/tmp/fingers.log')
    @logger.level = Logger.const_get(ENV.fetch('FINGERS_LOG_LEVEL', 'DEBUG'))
    @logger
  end
end

