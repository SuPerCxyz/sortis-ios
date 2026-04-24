#!/usr/bin/env bash

set -euo pipefail

if ! command -v xtool >/dev/null 2>&1; then
    echo "xtool 未安装"
    exit 1
fi

if [ ! -f "xtool.yml" ] || [ ! -f "Package.swift" ]; then
    echo "请在仓库根目录运行此脚本"
    exit 1
fi

xtool dev build --configuration release --ipa
