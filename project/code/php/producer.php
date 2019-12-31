<?php
/**
 * Created by PhpStorm.
 * User: lenovo
 * Date: 2019/12/28
 * Time: 10:21
 */

require 'unique.php';

$redis=new \RedisCluster(null,["140.143.16.122:6390","140.143.16.122:6391","140.143.16.122:6392","140.143.16.122:6393","140.143.16.122:6394","140.143.16.122:6395"],$timeout = null, $readTimeout = null, $persistent = false,"sixstar");

$config=[
  '1_20000'=>'{queue_1_20000}',
    '20001_40000'=>'{queue_20000_40000}'
];

//一次性做两个操作,要么都成功,要么都不成功,用lua脚本(redis集群环境)

$setName="{queue_1_2000}:update_queue"; //集合key
$queueName="{queue_1_2000}:product_image_1"; //任务

try{
    //先判断当前的id是否有更新任务,没有再添加,如果 有更新任务了,等待获取
    $unique = new Unique($redis);
    flag:
    $res=$unique->redis->sIsMember($setName,$queueName);
    $retry=3;
    $sleep=1;
    if ($res){
        //等待任务完成返回结果,查询是否有数据
        while ($retry--){
            $ok=$unique->redis->get("product_image_1");
            if($ok){
                echo $ok.PHP_EOL;
                break;
            }
            sleep(1); //阻塞进程的
            var_dump("等待获取数据");
        }
    }else{
        $job=json_encode(["method"=>"updateCacheImage","data"=>["id"=>1,"info"=>""]]);
        //生成任务
        if ($unique->push($setName,$queueName,$job)){
            echo "更新缓存的任务添加成功".PHP_EOL;
        }
        goto flag;
        //第一次任务放入到队列当中,并没有获得结果
    }
}catch (Exception $e){

}

