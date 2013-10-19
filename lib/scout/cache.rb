module Scout
  class << self
    attr_accessor :cache
  end

  class Cache
    def enabled?
      !Rails.env.development?
    end

    def fetch(parts, *args, &block)
      if enabled? || (args.first.is_a?(Hash) && args.first.delete(:always_cache))
        Rails.cache.fetch(key(parts), *args, &block)
      else
        block.call
      end
    end

    private
      def key(parts)
        ActiveSupport::Cache.expand_cache_key(parts)
      end
  end

  self.cache ||= Cache.new
end