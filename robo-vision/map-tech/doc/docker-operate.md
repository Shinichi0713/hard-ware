# Docker化

Pythonスクリプトを **Docker 上で動かしつつ、外部からフォルダパスと `-o` オプションを渡したい** ということですね。

典型的な実装手順を整理します。

---

## 1. Pythonスクリプト側の対応

まず、Python 側では `argparse` で `-o` やフォルダパスを受け取れるようにしておくと便利です。

```python
# app.py
import argparse
import os

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input_dir", help="入力フォルダのパス")
    parser.add_argument("-o", "--output", required=True, help="出力先のフォルダパス")
    args = parser.parse_args()

    print(f"入力フォルダ: {args.input_dir}")
    print(f"出力フォルダ: {args.output}")

    # 例: 入力フォルダ内のファイルを出力フォルダへコピー
    os.makedirs(args.output, exist_ok=True)
    for f in os.listdir(args.input_dir):
        print(f"処理中: {f}")
        # 実際の処理を書く

if __name__ == "__main__":
    main()
```

---

## 2. Dockerfile の作成

Python を実行できるイメージをベースにして、スクリプトをコピーしておきます。

```dockerfile
FROM python:3.10-slim

WORKDIR /app

# スクリプトをコンテナにコピー
COPY app.py .

# 依存ライブラリがあれば requirements.txt を使う
# COPY requirements.txt .
# RUN pip install -r requirements.txt

ENTRYPOINT ["python", "app.py"]
```

---

## 3. 実行時にフォルダをマウント

Docker の外のフォルダを中に渡すために **bind mount** を使います。

例えば、ホストの `./data` をコンテナの `/input` に渡して、出力を `./out` に保存する場合:

```bash
docker build -t myapp .

docker run --rm \
    -v $(pwd)/data:/input \
    -v $(pwd)/out:/output \
    myapp /input -o /output
```

---

## 4. ポイント

* `ENTRYPOINT` を使うと、`docker run myapp ...` の後の引数が `app.py` に渡ります。
* `-v` オプションでホストのフォルダをコンテナにマウントすることで、外部のファイルをそのまま扱えます。
* 出力もマウント先に書き出すと、ホスト側にファイルが残ります。

---

👉 これで「外部フォルダを入力にして、`-o` で出力先を指定」できる Docker コンテナになります。

---

ご希望は **フォルダの入力・出力を両方とも外部パス指定可能にしたい** 形ですか？



# 外部フォルダ固定

入力フォルダだけを外部から指定して、出力は常に決まった場所（例: `/output`）に固定する形にしますね。

---

## 1. Python スクリプト

出力先は固定 `/output` にしてしまいます。

ユーザは `-o` を指定する必要がありません。

```python
# app.py
import argparse
import os

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input_dir", help="入力フォルダのパス")
    args = parser.parse_args()

    output_dir = "/output"  # 固定
    os.makedirs(output_dir, exist_ok=True)

    print(f"入力フォルダ: {args.input_dir}")
    print(f"出力フォルダ: {output_dir}")

    # 処理例: 入力ファイル一覧を出力フォルダに記録
    files = os.listdir(args.input_dir)
    with open(os.path.join(output_dir, "files.txt"), "w") as f:
        for file in files:
            f.write(file + "\n")

if __name__ == "__main__":
    main()
```

---

## 2. Dockerfile

```dockerfile
FROM python:3.10-slim

WORKDIR /app
COPY app.py .

ENTRYPOINT ["python", "app.py"]
```

---

## 3. 実行方法

入力フォルダだけマウントすれば OK。出力は常に `/output` に固定してあるので、ここもホスト側とつなげばよいです。

```bash
docker build -t myapp .

docker run --rm \
    -v $(pwd)/data:/input \
    -v $(pwd)/out:/output \
    myapp /input
```

* `$(pwd)/data` … ホスト側の入力データ
* `$(pwd)/out` … ホスト側の出力先（固定）
* `/input` … コンテナ内での入力フォルダ
* `/output` … コンテナ内での出力フォルダ（固定）

---

これならユーザが毎回 `-o` を指定する必要がなくなり、常に決まった場所に出力されます。

---

❓質問ですが：

出力を固定する場合、ホスト側のフォルダも固定（例: `./out`）にしてしまってよいですか？

それとも `-v` のマウント先だけ変えて柔軟に使えるようにしたいですか？
