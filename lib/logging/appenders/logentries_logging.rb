require 'socket'
require 'openssl'
require 'thread'
require 'timeout'

module Logging
  module Appenders

    # Accessor / Factory for the Logentries appender.
    def self.logentries_logging( *args )
      return ::Logging::Appenders::LogentriesLogging if args.empty?
      ::Logging::Appenders::LogentriesLogging.new(*args)
    end

    # Provides an appender that can send log messages to loggly

    class LogentriesLogging < ::Logging::Appender
      attr_accessor :token, :levels
      def initialize( name, opts = {} )
        opts[:header] = false
        super(name, opts)
        # customer token for logentries
        self.token = opts.fetch(:token)
        raise ArgumentError, 'Must specify token' if @token.nil?
        self.layout.items = %w(timestamp level logger message pid hostname thread_id mdc)
        self.levels = Logging::LEVELS.invert
      end

      # SSL socket setup/closing pulled from https://github.com/logentries/le_ruby
      def open_connection
        host = 'api.logentries.com'
        socket = TCPSocket.new(host, 20000)

        cert_store = OpenSSL::X509::Store.new
        cert_store.set_default_paths

        ssl_context = OpenSSL::SSL::SSLContext.new()
        ssl_context.cert_store = cert_store

        ssl_version_candidates = [:TLSv1_2, :TLSv1_1, :TLSv1]
        ssl_version_candidates = ssl_version_candidates.select { |version| OpenSSL::SSL::SSLContext::METHODS.include? version }
        if ssl_version_candidates.empty?
          raise "Could not find suitable TLS version"
        end
        # currently we only set the version when we have no choice
        ssl_context.ssl_version = ssl_version_candidates[0] if ssl_version_candidates.length == 1
        ssl_context.verify_mode = OpenSSL::SSL::VERIFY_PEER
        ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
        ssl_socket.hostname = host if ssl_socket.respond_to?(:hostname=)
        ssl_socket.sync_close = true
        Timeout::timeout(10) do
          ssl_socket.connect
        end
        ssl_socket
      end

      def close_connection
        if @logentries.respond_to?(:sysclose)
          @logentries.sysclose
        elsif @logentries.respond_to?(:close)
          @logentries.close
        end

        @logentries = nil
      end
      alias_method :reopen, :close_connection

      def logentries
        @logentries ||= open_connection
      end

      def write(event)
        data = "#{@token} #{self.layout.format(event)} \n"
        logentries.write(data)
      rescue
        close_connection
        logentries.write(data)
      end

      def close( *args )
        close_connection
        super(false)
      end
    end
  end
end
