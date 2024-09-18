#!/bin/bash

# 备份目录
BACKUP_DIR="/nacos_backup"    # 备份文件存放路径
DATA_DIR="/nacos/data"        # data路径
LOGS_DIR="/nacos/logs"        # 日志路径
CONF_DIR="/nacos/conf"        # 配置文件路径
NACOS_NAME="nacos-server"     # 容器名称
# 获取当前时间，用于生成备份目录名称
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 创建备份目录
BACKUP_PATH="$BACKUP_DIR/$TIMESTAMP"
mkdir -p $BACKUP_PATH

# 检查Docker是否安装
if ! [ -x "$(command -v docker)" ]; then
  echo "Error: Docker is not installed." >&2
  exit 1
fi

# 停止Nacos容器
echo "停止Nacos服务中..."
docker stop $NACOS_NAME

# 复制数据、日志和配置文件到备份目录
echo "正在备份数据、日志和配置文件..."
cp -r $DATA_DIR $BACKUP_PATH
cp -r $LOGS_DIR $BACKUP_PATH
cp -r $CONF_DIR $BACKUP_PATH

# 检查备份是否成功
if [ $? -ne 0 ]; then
  echo "备份失败。"
  exit 1
else
  echo "备份完成，备份位置：$BACKUP_PATH"
fi

# 重启Nacos容器
echo "重启Nacos服务中..."
docker start $NACOS_NAME

echo "Nacos已成功备份并重新启动。"
