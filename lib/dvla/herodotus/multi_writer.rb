module DVLA
  module Herodotus
    class MultiWriter
      attr_reader :targets

      def initialize(*targets, config: nil)
        @config = config
        @targets = *targets
      end

      def write(*args)
        @targets.each do |target|
          # If we're writing to a file we remove the colour
          if target != $stdout && args[0].respond_to?(:strip_colour)
            target.write(args[0].strip_colour, *args[1..])
          else
            target.write(*args)
          end
        end
      end

      def close
        @targets.each do |t|
          t.close unless t.eql? $stdout
        end
      end
    end
  end
end
