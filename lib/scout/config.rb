module Scout
  # TODO Maybe use Hashie
  class ApiConfig
    attr_reader :path
    attr_accessor :attributes
    
    def initialize(path)
      @path = path
      load
    end
    
    def [](attribute)
      attributes[attribute]
    end
    
    def update(updates)
      attributes.merge!(updates)
      File.open(path, 'w') do |file|
        file.write(YAML.dump(attributes))
      end
    end
    
    def load
      @attributes ||= begin
        YAML.load_file(path) 
        rescue Errno::ENOENT 
          {} 
        end
    end
  end
end