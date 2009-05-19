module Beet
  module Logging

    def log(action, message = '')
      logger.log(action, message)
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

  end
end
