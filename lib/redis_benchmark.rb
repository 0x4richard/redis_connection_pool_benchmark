# frozen_string_literal: true

REDIS_VALUE = "hellow world".freeze

redis_v2 = Redis.new
redis_v3 = ConnectionPool.new { Redis.new }

pool_v1 = Concurrent::FixedThreadPool.new(5)
pool_v2 = Concurrent::FixedThreadPool.new(5)
pool_v3 = Concurrent::FixedThreadPool.new(5)

Benchmark.ips do |x|
  x.report "initialize redis connection every time" do |n|
    n.times do |i|
      pool_v1.post do
        key = "demo_v1_#{i}_time"
        redis_v1 = Redis.new
        redis_v1.set key, REDIS_VALUE
        redis_v1.get key
      end
    end
  end

  x.report "initialize single redis connection only" do |n|
    n.times do |i|
      pool_v2.post do
        key = "demo_v2_#{i}_time"
        redis_v2.set key, REDIS_VALUE
        redis_v2.get key
      end
    end
  end

  x.report "initialize redis conection pool" do |n|
    n.times do |i|
      pool_v3.post do
        key = "demo_v3_#{i}_time"
        redis_v3.with do |conn|
          conn.set key, REDIS_VALUE
          conn.get key
        end
      end
    end
  end

  x.compare!
end
