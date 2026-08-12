module DVLA
  module Herodotus
    module SemanticColours
      DEFAULT_COLOURS = {
        config: :brown,
        step: :magenta,
        success: :green,
        warning: :yellow,
        data: :blue
      }.freeze

      class << self
        def colours
          @colours ||= DEFAULT_COLOURS.dup
        end

        def configure
          yield(self) if block_given?
        end

        def reset!
          @colours = DEFAULT_COLOURS.dup
        end

        DEFAULT_COLOURS.keys.each do |semantic_type|
          define_method(semantic_type) do
            colours[semantic_type]
          end

          define_method("#{semantic_type}=") do |colour|
            colours[semantic_type] = colour
          end
        end
      end
    end
  end
end
