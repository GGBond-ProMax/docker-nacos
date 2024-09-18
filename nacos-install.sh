#!/bin/bash

# 设置Nacos版本
NACOS_VERSION="v2.4.2"

# 设置Nacos运行模式 standalone（单机模式） 或 cluster（集群模式）
NACOS_MODE="standalone"

# 镜像名称
NACOS_NAME="nacos-server"

# 设置Nacos数据目录和日志目录
NACOS_DIR="/nacos"           # 存放路径
DATA_DIR="$NACOS_DIR/data"   # data路径
LOGS_DIR="$NACOS_DIR/logs"   # 日志路径
CONF_DIR="$NACOS_DIR/conf"   # 配置文件路径

# 检查Docker是否安装
if ! [ -x "$(command -v docker)" ]; then
  echo "Error: Docker is not installed." >&2
  exit 1
fi

# 创建数据和日志目录
if [ ! -d "$DATA_DIR" ]; then
  sudo mkdir -p $DATA_DIR
fi

if [ ! -d "$LOGS_DIR" ]; then
  sudo mkdir -p $LOGS_DIR
fi

if [ ! -d "$CONF_DIR" ]; then
  sudo mkdir -p $CONF_DIR
fi

chmod -R 777 $NACOS_DIR

# 拉取Nacos镜像
echo "正在拉取nacos镜像，镜像版本为 $NACOS_VERSION..."
docker pull nacos/nacos-server:$NACOS_VERSION

# 启动Nacos容器（暂时不挂载配置文件）
echo "启动nacos测试镜像中..."
docker run -d --name temp-nacos-server \
  -e MODE=$NACOS_MODE \
  --privileged=true \
  nacos/nacos-server:$NACOS_VERSION

# 检查容器是否启动成功
if [ $(docker ps -q -f name=temp-nacos-server) ]; then
    echo "Nacos 容器正在运行中"
else
    echo "未找到启动容器"
    exit 1
fi

# 从容器复制配置文件到本地
echo "正在将nacos配置文件复制到本地 $CONF_DIR 路径中"
docker cp temp-nacos-server:/home/nacos/conf/ $NACOS_DIR

# 检查 docker cp 是否成功
if [ $? -ne 0 ]; then
  echo "复制配置文件失败。"
  exit 1
fi

# 停止并删除临时容器
echo "正在暂停Nacos测试镜像"
docker stop temp-nacos-server
echo "正在删除Nacos测试镜像"
docker rm temp-nacos-server

# 启动正式Nacos容器，并挂载本地配置文件
echo "Starting Nacos container with mounted configuration files..."
docker run -d --name $NACOS_NAME \
  -e MODE=$NACOS_MODE \
  --privileged=true \
  -p 8848:8848 \
  --restart=always \
  -v $DATA_DIR:/home/nacos/data \
  -v $LOGS_DIR:/home/nacos/logs \
  -v $CONF_DIR:/home/nacos/conf \
  nacos/nacos-server:$NACOS_VERSION

# 检查Nacos是否启动成功
if [ $(docker ps -q -f name=$NACOS_NAME) ]; then
    echo "Nacos is running at http://localhost:8848/nacos"
else
    echo "Nacos failed to start."
fi
