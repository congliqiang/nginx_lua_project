<?php
/**
 * Created by PhpStorm.
 * User: lenovo
 * Date: 2019/12/28
 * Time: 10:17
 */
class Unique {
    const PUSH='
        local setName=KEYS[1]
        local jobName=ARGV[1]
        local res=redis.call("SADD",setName,jobName)
        if res==1 then
            return redis.call("LPUSH",jobName,ARGV[2])
        end
        return 0
    ';
    const POP='
        local setName=KEYS[1]
        local jobName=ARGV[1]
        local res=redis.call("RPOP",jobName)
        if type(res)== "boolean" then
             return 0
        end
        if redis.call("SREM",setName,jobName) then
            return res
        else
        redis.call("LPUSH",jobName,ARGV[2])
        return 0
        end
        return res
    ';
    public function __construct($redis)
    {
        $this->redis=$redis;
    }

    public function push($setName,$queueName,$jobData){
        return $this->redis->eval(self::PUSH,[$setName,$queueName,$jobData],1);
    }

    public function pop($setName, $jobName){
       return $this->redis->eval(self::POP,[$setName,$jobName],1);
    }
}
