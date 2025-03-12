# Configuración global de Redis usando ConnectionPool
require "redis"
require "connection_pool"

$redis = ConnectionPool.new(size: 5, timeout: 5) do
  Redis.new(url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/0" })
end
