#!/bin/sh

# 引脚定义
PIN_RED=13
PIN_YELLOW=14
PIN_BLUE=15

# 初始化GPIO：导出+设为输出（仅首次执行生效，重复执行报错忽略）
gpio_init() {
    for pin in $PIN_RED $PIN_YELLOW $PIN_BLUE; do
        echo $pin > /sys/class/gpio/export 2>/dev/null
        echo out > /sys/class/gpio/gpio${pin}/direction
    done
}

# 关闭所有灯
led_off(){
    gpio_init
    echo 0 > /sys/class/gpio/gpio${PIN_RED}/value
    echo 1 > /sys/class/gpio/gpio${PIN_YELLOW}/value
    echo 1 > /sys/class/gpio/gpio${PIN_BLUE}/value
}

# 纯红灯
led_red(){
    led_off
    echo 1 > /sys/class/gpio/gpio${PIN_RED}/value
}

# 纯黄灯
led_yellow(){
    led_off
    echo 1 > /sys/class/gpio/gpio${PIN_YELLOW}/value
}

# 纯蓝灯
led_blue(){
    led_off
    echo 1 > /sys/class/gpio/gpio${PIN_BLUE}/value
}

case "$1" in
    red)
        led_red;;
    yellow)
        led_yellow;;
    blue)
        led_blue;;
    -OFF)
        led_off;;
    -ON)
        server_to_ping=`nvram get di_addr5`
        if [ "$server_to_ping" = "" ]; then
            server_to_ping="8.8.8.8"
        fi
        ping -c 1 -W 1 $server_to_ping >/dev/null
        if [ $? = 0 ]; then
            led_blue
        else
            led_yellow
        fi;;
    *)
        echo "LED control utitlity"
        echo "Usage: $0 red | yellow | blue | -OFF | -ON  [message]"
        echo "red: Turn LED to red color"
        echo "yellow: Turn LED to yellow color"
        echo "blue: Turn LED to blue color"
        echo "-OFF: Turn LED off"
        echo "-ON: Turn LED on, blue if internet ready, otherwise yellow"
        echo "If message provided, log it to syslog"
        exit 1;;
esac

# 输出日志
if [ -n "$2" ]; then
    logger -t "指示灯" "$2"
fi
