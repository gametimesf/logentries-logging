module Logging
  module Plugins
    module LogentriesLogging
      extend self

      VERSION = '1.0.0'.freeze

      def initialize_logentries_logging
        require File.expand_path('../../appenders/logentries_logging', __FILE__)
      end
    end
  end
end
