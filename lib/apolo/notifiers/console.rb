require 'date'


    # @author Efren Fuentes <efrenfuentes@gmail.com>
    # @author Thomas Vincent <thomasvincent@steelhouselabs.com>
    
module Apolo
  module Notifiers
    class Console
      def initialize(options = {})
        @show_date = options[:show_date]
      end

      def notify(monitor, message, value)
        output = "#{monitor} #{message} #{value}"
        unless @show_date.nil?
          output = "#{DateTime.now} #{output}"
        end
        puts output
      end
    end
  end
end
