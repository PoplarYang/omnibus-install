<?php
/**
 * pcntl test
 * @author: xxxx
 */

set_time_limit(0);

//如果找不到pcntl_fork函数，直接退出
if (! function_exists('pcntl_fork')) 
    echo "PCNTL functions is not available on this PHP installation\n";
else
    echo "PCNTL functions is available on this PHP installation\n</br>";
//脚本运行开始
$start =  time();
echo "\nSCRIT RUN AT: ", date('Y-m-d H:i:s', $start), "\n";

//从CLI取参数
//默认跑10个进程
$pmax = empty($argv[1]) ? 10 : $argv[1];
//父进程pid
$ppid = getmypid(); 
for ($i = 1; $i <= $pmax; ++$i) {
    //开始产生子进程
    $pid = pcntl_fork();
    switch ($pid) {
    case -1:
        // fork失败
        echo "Fork failed!\n";
        break;
    case 0:
        // fork成功，并且子进程会进入到这里
        sleep(1);
        $cpid = getmypid(); //用getmypid()函数获取当前进程的PID
        echo "FORK: Child #{$i} #{$cpid} is running...\n";
        //子进程要exit否则会进行递归多进程，父进程不要exit否则终止多进程
        exit($i);
        break;
    default:
        // fork成功，并且父进程会进入到这里
        if ($i == 1) {
            echo "Parent #{$ppid} is running...\n";
        }
        break;
   }
}

//父进程利用while循环，并且通过pcntl_waitpid函数来等待所有子进程完成后才继续向下进行
while (pcntl_waitpid(0, $status) != -1) {
    //pcntl_wexitstatus返回一个中断的子进程的返回代码，由此可判断是哪一个子进程完成了
    $status = pcntl_wexitstatus($status); 
    echo "Child $status has completed!\n";
}

echo "Parent #{$ppid} has completed!\n";

echo "\nSCRIT END AT: ", date('Y-m-d H:i:s', $start), "\n";
echo "TOTAL TIMEEEE: " . (time() - $start)/60;
echo "\n++++++++++++++++++++++++++++++++++++++++++++OK++++++++++++++++++++++++++++++++++++++++++++++++++\n";
?>
