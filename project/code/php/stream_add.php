<?php
/**
 * Created by PhpStorm.
 * User: lenovo
 * Date: 2019/12/30
 * Time: 15:08
 */
$redis=new \RedisCluster(null,["140.143.16.122:6390","140.143.16.122:6391","140.143.16.122:6392","140.143.16.122:6393","140.143.16.122:6394","140.143.16.122:6395"],$timeout = null, 0, $true,"sixstar");
$res = $redis->xAdd('mystream', '*', ['shop' => 'info']);
var_dump($res);