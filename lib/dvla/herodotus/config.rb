module DVLA
  module Herodotus
    class Config
      LOGGER_ATTRIBUTES = %i[display_pid main prefix_colour].freeze

      attr_accessor(*LOGGER_ATTRIBUTES)

      SemanticColours::DEFAULT_COLOURS.keys.each do |semantic_type|
        define_method(semantic_type) do
          SemanticColours.send(semantic_type)
        end

        define_method("#{semantic_type}=") do |colour|
          SemanticColours.send("#{semantic_type}=", colour)
        end
      end

      def reset_colours!
        SemanticColours.reset!
      end
    end
  end
end
