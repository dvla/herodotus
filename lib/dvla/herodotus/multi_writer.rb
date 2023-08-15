module DVLA
  module Herodotus
    class MultiWriter
      def initialize(*targets)
        @targets = *targets
      end

      def write(*args)
        @targets.each { |t| t.write(*args) }
      end

      def close
        @targets.each(&:close)
      end
    end
  end
end