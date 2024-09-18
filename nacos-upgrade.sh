#!/bin/bash

# Nacos 升级的版本
NEW_NACOS_VERSION="v2.4.2"  # 你想升级到的 Nacos 版本

# 设置Nacos运行模式 standalone（单机模式） 或 cluster（集群模式）
NACOS_MODE="standalone"

# Nacos 路径
NACOS_NAME="nacos-server"     # 容器名称
NACOS_DIR="/nacos"            # 挂载内容主路径
DATA_DIR="$NACOS_DIR/data"    # data目录挂载路径
LOGS_DIR="$NACOS_DIR/logs"    # 日志目录挂载路径
CONF_DIR="$NACOS_DIR/conf"    # 配置文件挂载路径

# 检查Docker是否安装
if ! [ -x "$(command -v docker)" ]; then
  echo "Error: Docker is not installed." >&2
  exit 1
fi

# 拉取新的Nacos镜像
echo "拉取新版本Nacos镜像：$NEW_NACOS_VERSION..."
docker pull nacos/nacos-server:$NEW_NACOS_VERSION

# 删除旧容器
echo "删除旧的Nacos容器..."
docker rm -f $NACOS_NAME

# 启动新的Nacos容器
echo "启动新的Nacos容器，版本为 $NEW_NACOS_VERSION..."
docker run -d --name $NACOS_NAME \
  -e MODE=$NACOS_MODE \
  -p 8848:8848 \
  --restart=always \
  --privileged=true \
  -v $DATA_DIR:/home/nacos/data \
  -v $LOGS_DIR:/home/nacos/logs \
  -v $CONF_DIR:/home/nacos/conf \
  nacos/nacos-server:$NEW_NACOS_VERSION

# 检查Nacos是否启动成功
if [ $(docker ps -q -f name=nacos-server) ]; then
    echo "Nacos已升级并运行，访问地址为 http://localhost:8848/nacos"
else
    echo "Nacos启动失败，请检查日志。"
    exit 1
fi
