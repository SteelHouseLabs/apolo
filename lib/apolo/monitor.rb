module Apolo
  class Monitor
    class << self
      def reader_templates
        @reader_templates || []
      end

      def notifier_templates
        @notifier_templates || []
      end

      def name_template
        @name_template || self.to_s
      end

      def running_template
        @running_template
      end

      # Set the name of the app. Can be used by notifiers in order to have
      # a better description of the service in question.
      #
      # @param [String, #read] name The name to be given to a Apolo-based
      #   class.
      def name(val = nil)
        @name_template = val if val
        @name_template
      end

      # Register a reader in the list of readers.
      #
      # @param [Hash{Scout => String}, #read] reader_description A hash
      #   containing Reader class as key and its description as a value.
      #
      # @yield Block to be evaluated to configure the current {Reader}.
      def using(reader_description, &block)
        @reader_templates ||= []
        @reader_templates << {
            :reader_description => reader_description,
            :block => block
        }
      end

      # Register a notifier class in the list of notifications.
      #
      # @param [Class, #read] class A class that will be used to issue
      #   a notification. The class must accept a configuration hash in the
      #   constructor and also implement a #notify method that will receive an
      #   outpost instance. See {Apolo::Notifiers::Console} for an example.
      #
      # @param [Hash, #read] options Options that will be used to configure the
      #   notification class.
      def notify(notifier, options={})
        @notifier_templates ||= []
        @notifier_templates << {:notifier => notifier, :options => options}
      end

      def run(&block)
        @running_template = block
      end
    end

    # Returns all the registered readers.
    attr_reader :readers

    # Returns all the registered notifiers.
    attr_reader :notifiers

    # Reader/setter for the name of this monitor
    attr_accessor :name

    # New instance of a Application-based class.
    def initialize
      @readers    = Hash.new { |h, k| h[k] = [] }
      @notifiers  = {}
      @name       = self.class.name_template
      @running    = self.class.running_template

      # Register readers
      self.class.reader_templates.each do |template|
        add_reader(template[:reader_description], &template[:block])
      end

      self.class.notifier_templates.each do |template|
        add_notifier(template[:notifier], template[:options])
      end
    end

    # @see Monitor#using
    def add_reader(reader_description, &block)
      config = ReaderConfig.new
      config.instance_exec(&block) if block

      reader_description.each do |reader, description|
        @readers[reader] << {
            :description => description,
            :config => config
        }
      end
    end

    # @see Monitor#notify
    def add_notifier(notifier_name, options)
      @notifiers[notifier_name] = options
    end

    def run
      instance_exec &@running
    end

    def notify(data)
      message = data[:message]
      value = data[:value]

      unless message && value
        raise ArgumentError, 'You need to set :message and :value to send notify.'
      end

      @notifiers.each do |notifier, options|
        # .dup is NOT reliable
        options_copy = Marshal.load(Marshal.dump(options))
        notifier.new(options_copy).notify(@name, message, value)
      end
    end

    def get_data(reader_exec)
      @readers.each do |reader, configurations|
        if configurations.first[:description] == reader_exec
          return run_reader(reader, configurations.last[:config])
        end
      end
      raise ArgumentError, "Can't found #{reader_exec} reader."
    end

    private

    def run_reader(reader, config)
      reader_instance = reader.new(config)

      reader_instance.execute
    end
  end
end
