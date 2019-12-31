<?php
/**
 * Created by PhpStorm.
 * User: lenovo
 * Date: 2019/12/28
 * Time: 11:27
 */

require 'unique.php';
ini_set("default_socket_timeout",-1); //socket连接不超时
$redis=new \RedisCluster(null,["140.143.16.122:6390","140.143.16.122:6391","140.143.16.122:6392","140.143.16.122:6393","140.143.16.122:6394","140.143.16.122:6395"],$timeout = null, 0, $true,"sixstar");
$unique = new Unique($redis);

//一次性做两个操作,要么都成功,要么都不成功,用lua脚本(redis集群环境)
$setName="{queue_1_2000}:update_queue"; //集合key
try{
    while (true) {
        $data = $unique->redis->SMembers($setName);
        if (!empty($data)) {
            foreach ($data as $queueName) {
                //弹出任务
                $jobData = $unique->pop($setName, $queueName);
                if (!empty($jobData)) {
                    $job=json_decode($jobData, true);
                    //mysql IO 操作
                    switch ($job['method']){
                        case 'updateCacheImage':
                            //从数据库当中去除数据,写入到缓存当中
                            sleep(0.2);
                            if($unique->redis->set('product_image_'.$job['data']['id'],'images:'.$job['data ']['id'])){
                                echo "缓存更新成功";
                                $data=['type'=>'product_1_image',"data"=>["xxxxx"]];
                                $unique->redis->publish("cacheUpdate",json_encode($data));
                            }else{
                                throw new Exception("fail");
                            }
                            break;
                    }
                }
            }
        }
        usleep(100000);
    }
}catch (Exception $e){
    //连接重试
    if ($e->getMessage() == 'fail'){
       //记录日志,记录尝试次数
    }
    //重试或者说再次调用push,写入到队列当中
}
