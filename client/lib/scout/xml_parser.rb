module Scout
  class XmlParser < Hash
    attr_reader :body, :xml_in, :root
    
    class << self
      def parse(xml)
        new(xml)
      end
    end

    def initialize(body)
      @body = body
      unless body.strip.empty?
        parse
        set_root
        typecast_xml_in
      end
    end

    private
      def parse
        @xml_in = FasterXmlSimple.xml_in(body, parsing_options)
      end

      def parsing_options
        {
          # Includes the enclosing tag as the top level key
          'keeproot' => true, 
          # # Makes tag value available via the '__content__' key
          'contentkey'    => '__content__', 
          # Always parse tags into a hash, even when there are no attributes 
          # (unless there is also no value, in which case it is nil)
          'forcecontent'  => true,
          # If a tag is empty, makes its content nil
          'suppressempty' => nil,
          # Force nested elements to be put into an array, even if there is only one of them
          'forcearray'    => []
        }
      end
      
      def set_root
        @root = @xml_in.keys.first
      end
      
      def typecast(object)
        case object
        when Hash
          typecast_hash(object)
        when Array
          object.map {|element| typecast(element)}
        when String
          CoercibleString.coerce(object)
        else
          object
        end
      end

      def typecast_hash(hash)
        if content = hash['__content__']  
          typecast(content)
        else
          keys   = hash.keys.map {|key| key.underscore}
          values = hash.values.map {|value| typecast(value)}
          Scout::Payload::Data.new(
            keys.inject({}) do |new_hash, key|
              new_hash[key] = values.slice!(0)
              new_hash
            end
          )
        end
      end

      def typecast_xml_in
        typecast_xml = {}

        @xml_in.dup.each do |key, value| # Some typecasting is destructive so we dup
          typecast_xml[key.underscore] = typecast(value)
        end

        # An empty body will try to update with a string so only update if the result is a hash
        update(typecast_xml[root]) if typecast_xml[root].is_a?(Hash)
      end
      
      class CoercibleString < String
        class << self
          def coerce(string)
            new(string).coerce
          end
        end

        def coerce
          case self
          when 'true';         true
          when 'false';         false
          # Don't coerce numbers that start with zero
          when  /^([1-9]+\d*|0)$/;   Integer(self)
          when datetime_format; Time.parse(self)
          else
            self
          end
        end

        private
          # Lame hack since Date._parse is so accepting. S3 dates are of the form: '2006-10-29T23:14:47.000Z'
          # so unless the string looks like that, don't even try, otherwise it might convert an object's
          # key from something like '03 1-2-3-Apple-Tree.mp3' to Sat Feb 03 00:00:00 CST 2001.
          def datetime_format
            /^\d{4}-\d{2}-\d{2}\w\d{2}:\d{2}:\d{2}/
          end
      end
  end
end