module Apolo
  # Provides the DSL used to configure Readers in Applications.
  class ReaderConfig
    attr_reader :options

    def initialize
      @options = {}
    end

    # Reads/writes any options. It will passed down to the Reader.
    # @param [Object] args Any argument that will be passed to the Reader.
    # return [Object] The associated option
    def options(args=nil)
      @options = args if args
      @options
    end
  end
end
