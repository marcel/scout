module Scout
  # Wraps parsed xml document, providing sugar for extracting selectors.
  class Response
    attr_reader :doc
    def initialize(doc)
      @doc = doc
    end
    
    private
      def method_missing(method, *args, &block)
        if doc.respond_to?(method)
          doc.public_send(method, *args, &block)
        elsif Resource::RESOURCES.has_key?(method.to_sym)
          if selector = method.to_s[/(\w+)s$/, 1]
            doc.css(selector)
          else
            doc.at(method.to_s)
          end
        else
          super
        end
      end
  end
end