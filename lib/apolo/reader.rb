module Apolo
  # Readers are responsible for gathering data about a something specific that is
  # a part of your system.
  class Reader
    attr_reader :data

    # @param [Hash, #read] config A hash containing any number of
    #   configurations that will be passed to the #setup method
    def initialize(config)
      @config = config
      @data = {}

      setup(config.options)
    end

    # Called when the reader object is being constructed. Arguments can be
    # everything the developer set in the creation of Reader.
    #
    # @raise [NotImplementedError] raised when method is not overriden.
    def setup(*args)
      raise NotImplementedError, 'You must implement the setup method for Reader to work correctly.'
    end

    # Called when the Reader must take action and gather all the data needed to
    # be analyzed.
    #
    # @raise [NotImplementedError] raised when method is not overriden.
    def execute(*args)
      raise NotImplementedError, 'You must implement the execute method for Reader to work correctly.'
    end
  end
end
