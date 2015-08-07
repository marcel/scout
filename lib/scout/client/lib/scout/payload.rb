module Scout
  class Payload
    class Data < ::Hash
      include Hashie::Extensions::MergeInitializer
      include Hashie::Extensions::MethodAccess

      def method_missing(method, *args, &block)
        if predicate = method.to_s[/(\w+)\?$/, 1]
          !self[predicate].nil?
        else
          super
        end
      end
    end

    class << self
      def contains(name, klass = name.to_s.capitalize, attribute = name)
        class_eval(<<-EVAL)
          def #{name}
            @#{name} ||= #{klass}.new(doc.at('#{attribute}'.to_s))
          end
        EVAL
      end
    end

    attr_reader :doc, :data
    def initialize(doc)
      @doc = doc
      doc.instance_eval do
        def inspect; '...' end
      end
      @data = Data.new(XmlParser.parse(doc.to_xml))
    end

    # N.B. So pretty print doesn't display huge xml doc
    def pretty_print_instance_variables
      super - [:@doc]
    end

    def method_missing(method, *args, &block)
      if data.respond_to?(method)
        data.public_send(method, *args, &block)
      elsif predicate = method.to_s[/(\w+)\?$/, 1]
        !self[predicate].nil?
      else
        super
      end
    end
    
    class Games < Payload
    end
    
    class Manager < Payload
    end

    class Stat < Payload
    end

    class Game < Payload
    end

    class League < Payload
    end

    class Team < Payload
      contains :manager
    end

    class Standings < Payload
    end

    class MatchUp < Payload
    end

    class Transaction < Payload
      # N.B. Work around since the attribute is a built in method on Object
      def type
        data['type']
      end

      def players
        doc.css('player').map do |player|
          Player.new(player)
        end
      end
    end

    class Player < Payload
      def offense?
        position_type == "O"
      end

      def defense?
        !offense?
      end
    end

    class Roster < Payload
    end
  end
end