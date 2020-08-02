# frozen_string_literal: true

REDIS_VALUE = "hellow world".freeze

Benchmark.ips do |x|
  x.report "initialize redis connection every time" do |n|
    n.times do |i|
      key = "demo_v1_#{i}_time"
      redis_v1 = Redis.new
      redis_v1.set key, REDIS_VALUE
      redis_v1.get key
    end
  rescue => e
    p e.message
  end

  x.report "initialize single redis connection only" do |n|
    redis_v2 = Redis.new

    n.times do |i|
      key = "demo_v2_#{i}_time"
      redis_v2.set key, REDIS_VALUE
      redis_v2.get key
    end
  end

  x.report "initialize redis conection pool" do |n|
    redis_v3 = ConnectionPool.new { Redis.new }

    n.times do |i|
      key = "demo_v3_#{i}_time"
      redis_v3.with do |conn|
        conn.set key, REDIS_VALUE
        conn.get key
      end
    end
  end

  x.compare!
end
