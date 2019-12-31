<?php
/**
 * Created by PhpStorm.
 * User: lenovo
 * Date: 2019/12/30
 * Time: 13:57
 */
ini_set("default_socket_timeout",-1); //socket连接不超时
$redis=new \RedisCluster(null,["140.143.16.122:6390","140.143.16.122:6391","140.143.16.122:6392","140.143.16.122:6393","140.143.16.122:6394","140.143.16.122:6395"],$timeout = null, 0, $true,"sixstar");
$redis->publish("cacheUpdate","hello world");
$redis->publish("sixstar:news","1");
$redis->publish("sixstar:music","2");
