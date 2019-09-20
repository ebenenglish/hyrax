# frozen_string_literal: true

module Hyrax
  ##
  # @api private
  #
  # This is a simple yaml config-driven schema loader
  #
  # @see config/metadata/basic_metadata.yaml for an example configuration
  class SimpleSchemaLoader
    ##
    # @param [Symbol] schema
    def attributes_for(schema:)
      attributes = schema_config(schema)['attributes']

      attributes.each_with_object({}) do |(name, config), hash|
        wrapper = config['multiple'] ? Valkyrie::Types::Array : NullWrapper

        hash[name.to_sym] = wrapper.of(type_for(config['type']))
      end
    end

    ##
    # @api private
    class NullWrapper
      def self.of(content_type)
        content_type
      end
    end

    private

      def type_for(type)
        case type
        when 'uri'
          Valkyrie::Types::URI
        when 'date_time'
          Valkyrie::Types::DateTime
        else
          "Valkyrie::Types::#{type.capitalize}".constantize
        end
      end

      def schema_config(schema_name)
        raise(ArgumentError, "No schema defined: #{schema_name}") unless
          File.exist?(config_path(schema_name))

        YAML.safe_load(File.open(config_path(schema_name)))
      end

      def config_path(schema_name)
        "config/metadata/#{schema_name}.yaml"
      end
  end
end
