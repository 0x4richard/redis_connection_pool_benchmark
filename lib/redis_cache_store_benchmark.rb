# frozen_string_literal: true

# https://edgeguides.rubyonrails.org/caching_with_rails.html#connection-pool-options

REDIS_VALUE = "hellow world".freeze

cache_v1 = ActiveSupport::Cache.lookup_store :redis_cache_store
cache_v2 = ActiveSupport::Cache.lookup_store :redis_cache_store, {
  pool_size: 5,
  pool_timeout: 5
}

pool_v1 = Concurrent::FixedThreadPool.new(5)
pool_v2 = Concurrent::FixedThreadPool.new(5)

Benchmark.ips do |x|
  x.report "rails default redis_cache_store" do |n|
    n.times do |i|
      pool_v1.post do
        key = "redis_cache_demo_v1_#{i}"

        cache_v1.fetch(key) { REDIS_VALUE }
        cache_v1.fetch(key) { REDIS_VALUE }
      end
    end
  end

  x.report "rails redis_cache_store with connection_pool" do |n|
    n.times do |i|
      pool_v2.post do
        key = "redis_cache_demo_v2_#{i}"

        cache_v2.fetch(key) { REDIS_VALUE }
        cache_v2.fetch(key) { REDIS_VALUE }
      end
    end
  end

  x.compare!
end
