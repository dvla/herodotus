module DVLA
  module Herodotus
    class ProcWriter
      attr_accessor :scenario
      def initialize(proc)
        @proc = proc
      end

      def write(*args)
        output_file = File.open(self.instance_exec(&@proc), 'a')
        output_file.write(args[0])
        output_file.close
      end

      def close
        # Nothing to close but we want to maintain consistency with other ways Herodotus can output
      end
    end
  end
end
