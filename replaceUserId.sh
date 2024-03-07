#!/bin/bash

# ユーザーからの入力を促す
echo "ユーザーIDを入力してください:"
read userId

# ./mta.yaml ファイル内の 'sap00' をユーザーIDで置換し、変更を同じファイルに保存
sed -i "s/sap00/$userId/g" ./mta.yaml

echo "ユーザーIDの置換が完了しました。"
