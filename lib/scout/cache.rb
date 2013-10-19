require 'lrucache'

module Scout
  class << self
    attr_accessor :cache
  end

  class Cache
    attr_reader :lookaside_cache
    def initialize
      @fetch_count = 0
      @lookaside_miss_count = 0
      @memcached_miss_count = 0
      @eviction_count       = 0
      @lookaside_cache = LRUCache.new(
        ttl: 5.minutes,
        max_size: 10_000,
        eviction_handler: ->(value) { @eviction_count += 1 }
      )
    end

    def enabled?
      !Rails.env.development?
    end

    def fetch(parts, *args, &block)
      if enabled? || (args.first.is_a?(Hash) && args.first.delete(:always_cache))
        cache_key = key(parts)
        @fetch_count += 1
        lookaside_cache.fetch(cache_key) do
          @lookaside_miss_count += 1
          Rails.cache.fetch(cache_key, *args) do
            @memcached_miss_count += 1
            block.call
          end
        end
      else
        block.call
      end
    end

    private
      def cache_stats
        {
          lookaside_keys: lookaside_cache.size,
          fetch_count: @fetch_count,
          lookaside_miss_count: @lookaside_miss_count,
          memcached_miss_count: @memcached_miss_count,
          eviction_count: @eviction_count
        }
      end

      def key(parts)
        ActiveSupport::Cache.expand_cache_key(parts)
      end
  end

  self.cache ||= Cache.new
end