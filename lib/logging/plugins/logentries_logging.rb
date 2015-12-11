module Logging
  module Plugins
    module LogentriesLogging
      extend self

      VERSION = '0.0.5'.freeze

      def initialize_logentries_logging
        require File.expand_path('../../appenders/logentries_logging', __FILE__)
      end
    end
  end
end
