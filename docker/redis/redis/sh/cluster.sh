echo " cluster-announce-ip  $REALIP
       cluster-announce-port $PORT 
      cluster-announce-bus-port $PORT2
" >> /usr/src/redis/conf/redis.conf
redis-server /usr/src/redis/conf/redis.conf  --loadmodule /usr/src/module/RedisBloom/redisbloom.so
