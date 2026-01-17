このCコードは、**Webots（ウェボッツ）シミュレータ上で動作する自律移動ロボットの制御プログラム**です。

主に「障害物を検知して回避しながら走行する」簡単なロボットの動きを実現しています。

## ロボットを動作させるコード

1. センサとモータの場所(パス)を設定する
2. センサとモータを初期化
3. (while文以降に)ロボットの動作コードを書いていく

### 🔍 全体の概要

* 使用しているデバイス：

  * **距離センサー（distance sensor）** × 8個
  * **左右モーター（motor）** × 2個
* 動作内容：

  ロボットは前進し、

  距離センサーで前方左右に障害物を検知すると、

  障害物のある方向とは**反対方向へ旋回**して回避します。

---

### 🧩 コードの構造と処理内容

#### ① 初期化

```cpp
wb_robot_init();
```

Webots のロボットAPIを初期化。

（この行がないとWebotsシミュレーション環境と通信できません。）

---

#### ② センサーとモーターの設定

```cpp
for (i = 0; i < 8 ; i++) {
  ps[i] = wb_robot_get_device(ps_names[i]);
  wb_distance_sensor_enable(ps[i], TIME_STEP);
}
```

* 8個の距離センサー `ps0`〜`ps7` を取得し、有効化。
* 距離センサーは赤外線などで障害物との距離を測る。

```cpp
WbDeviceTag left_motor = wb_robot_get_device("left wheel motor");
WbDeviceTag right_motor = wb_robot_get_device("right wheel motor");
wb_motor_set_position(left_motor, INFINITY);
wb_motor_set_position(right_motor, INFINITY);
```

* 左右のモーターを取得し、「 **速度制御モード** 」に設定。

  （位置無限大 = 回転し続けられるようにする。）

---

#### ③ メインループ（制御ループ）

```cpp
while (wb_robot_step(TIME_STEP) != -1) {
```

シミュレーションを1ステップずつ進めながら、

ロボットの行動を更新します。

---

#### ④ センサー値の読み取り

```cpp
for (i = 0; i < 8 ; i++)
  ps_values[i] = wb_distance_sensor_get_value(ps[i]);
```

8個の距離センサーから現在の距離値を取得します。

---

#### ⑤ 障害物の検出

```cpp
bool right_obstacle = ps_values[0] > 80.0 || ps_values[1] > 80.0 || ps_values[2] > 80.0;
bool left_obstacle  = ps_values[5] > 80.0 || ps_values[6] > 80.0 || ps_values[7] > 80.0;
```

* センサーの値が **80以上** の場合を「障害物あり」と判断。
* 右側・左側のセンサー群をそれぞれまとめて判定。

---

#### ⑥ 速度制御による回避動作

```cpp
if (left_obstacle) {
  // turn right
  left_speed  = 0.5 * MAX_SPEED;
  right_speed = -0.5 * MAX_SPEED;
}
else if (right_obstacle) {
  // turn left
  left_speed  = -0.5 * MAX_SPEED;
  right_speed = 0.5 * MAX_SPEED;
}
```

* 左側に障害物 → 右へ旋回
* 右側に障害物 → 左へ旋回
* 障害物なし → まっすぐ前進

---

#### ⑦ モーターへの出力

```cpp
wb_motor_set_velocity(left_motor, left_speed);
wb_motor_set_velocity(right_motor, right_speed);
```

モーターに速度を与えて動かします。

---

### ⚙️ 結果

このプログラムをWebots上で実行すると、ロボットは：

1. 通常は前進する
2. 左右の距離センサーで障害物を検知
3. 障害物がある側を避けるように旋回する
4. 障害物がなくなると再び前進する

という**単純な障害物回避行動**を取ります。

---

### 💡まとめ

| 要素     | 内容                                                       |
| -------- | ---------------------------------------------------------- |
| センサー | ps0〜ps7の距離センサー（障害物検知）                       |
| モーター | 左右のホイールを制御                                       |
| 処理内容 | 前進 → 障害物検知 → 回避旋回                             |
| 制御方式 | 差動二輪ロボットの速度制御（右・左のモーター速度差で旋回） |

---

希望があれば、このロボットを**線追従ロボットやPID制御付きモデル**に拡張する例も示せます。

そうした発展も見てみますか？
