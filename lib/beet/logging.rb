require 'logger'
module Beet
  module Logging

    def log(action, message = '')
      logger.debug("#{action}: #{message}")
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

  end
end
