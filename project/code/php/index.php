<?php
//require "lock.php";
//$redis=new Redis();
//$redis->connect("140.143.16.122", 6391);
//$redis->auth("sixstar");
//
//$redis = new Lock($redis);
//$key='key';
//$res = $redis->lock($key, 3, 1, 10); // 等待获取锁
//
//if ($res) {
//    sleep(3); //业务逻辑
//    var_dump("执行任务");
//    $redis->unlock($key);
//    return;
//}
var_dump("等到超时");