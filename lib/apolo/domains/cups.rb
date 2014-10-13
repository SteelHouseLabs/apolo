require 'cupsffi'

module Apolo
  module Domains
    # Get data from Cups server
    #
    # @author Efren Fuentes <efrenfuentes@gmail.com>
    # @author Thomas Vincent <thomasvincent@steelhouselabs.com>
    class Cups
      attr_accessor :jobs_count, :minutes, :job
      def initialize(printer_name)
        if printer_name.nil?
          printer = CupsPrinter.new(printers.first)
          @printer_name = printer.name
        else
          @printer_name = printer_name
        end

        get_data
      end

      def printers
        CupsPrinter.get_all_printer_names
      end

      def get_data
        pointer = FFI::MemoryPointer.new :pointer
        @jobs_count = CupsFFI::cupsGetJobs(pointer, @printer_name, 0, CupsFFI::CUPS_WHICHJOBS_ACTIVE)
        @job = CupsFFI::CupsJobS.new(pointer.get_pointer(0))

        if @jobs_count > 0
          @minutes = (Time.now - Time.at(@job[:creation_time])).to_i / 60
        else
          @minutes = 0
        end
      end
    end
  end
end