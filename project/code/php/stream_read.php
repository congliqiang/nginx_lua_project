<?php
/**
 * Created by PhpStorm.
 * User: lenovo
 * Date: 2019/12/30
 * Time: 15:09
 */
$redis=new \RedisCluster(null,["140.143.16.122:6390","140.143.16.122:6391","140.143.16.122:6392","140.143.16.122:6393","140.143.16.122:6394","140.143.16.122:6395"],$timeout = null, 0, $true,"sixstar");
//$res = $redis->xRead(['mystream'=>'$'],1,0);
//业务逻辑
$res=$redis->xdel("mystream",["1577690054648-0"]);
var_dump($res);