require 'socket'

module Apolo
  module Domains
    # Get active TCP sockets
    #
    # @author Efren Fuentes <efrenfuentes@gmail.com>
    # @author Thomas Vincent <thomasvincent@steelhouselabs.com>
    class TCPSockets
      class << self
        def connections(family)
          Socket.getaddrinfo('localhost', nil, family)
        end
      end
    end
  end
end