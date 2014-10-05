require 'socket'

module Apolo
  module Domains
    class TCPSockets
      class << self
        def connections(family)
          Socket.getaddrinfo('localhost', nil, family)
        end
      end
    end
  end
end