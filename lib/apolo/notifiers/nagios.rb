require 'date'

# @author Efren Fuentes <efrenfuentes@gmail.com>
# @author Thomas Vincent <thomasvincent@steelhouselabs.com>
    
module Apolo
  module Notifiers
    NAGIOS_OK = 0
    NAGIOS_WARNING = 1
    NAGIOS_CRITICAL = 2
    NAGIOS_UNKNOW = 3
    class Nagios
      def initialize(options = {})
        @file     = options[:file]
        @host     = options[:host]
        @service  = options[:service]
        @warning  = options[:warning]
        @critical = options[:critical]

        unless @file && @host && @service
          raise ArgumentError, 'You need to set :file, :host and :service to use nagios notify.'
        end
      end

      def critical?(value)
        unless @critical
          return false
        end
        if value >= @critical
          return true
        else
          return false
        end
      end

      def warning?(value)
        unless @warning
          return false
        end
        if value >= @warning
          return true
        else
          return false
        end
      end

      def ok?(value)
        if @critical && @warning
          return true
        else
          return false
        end
      end

      def notify(monitor, message, value)
        status = NAGIOS_UNKNOW
        status = NAGIOS_OK if ok?(value)
        status = NAGIOS_WARNING if warning?(value)
        status = NAGIOS_CRITICAL if critical?(value)

        output = "#{DateTime.now.strftime('%s')}  PROCESS_HOST_CHECK_RESULT;"
        output += "#{@host};#{@service};#{status};#{message}"
        open(@file, 'a') { |f| f.puts output }
      end
    end
  end
end