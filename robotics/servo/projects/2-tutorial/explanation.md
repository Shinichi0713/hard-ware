## 目的

この最初のチュートリアルの目的は、Webotsのユーザーインターフェースと基本的な概念に慣れることです。あなたは、シンプルな環境を含む初めてのシミュレーションを作成します。具体的には、床と壁のあるアリーナ、いくつかの箱、e-puckロボット、そしてそのロボットを動かすコントローラープログラムが含まれます。

## アリーナ改造

その `translation`（位置）を、`0 0 0.3`の代わりに `0 0 0.05`に変更します。もしくは、3Dビューに表示される青い矢印を使って、その `translation.z`フィールドを調整することもできます。

次に、**[Shift]**キーを押しながらマウスで3Dビュー内の箱をドラッグし、アリーナのどこかの隅に移動させます。

箱を選択し、`Ctrl-C`、`Ctrl-V`（Windows、Linux）または `⌘ command-C`、`⌘ command-V`（macOS）を押してコピー＆ペーストします。新しくできた箱を**[Shift]**キーを押しながらドラッグして、別の場所に移動させます。この方法で、3つ目の箱も作成します。

箱を移動させて、アリーナの中心に箱がないようにします。青い回転矢印を使って、箱を垂直軸に沿って回転させることもできます。これは、**[Shift]**キーを押しながらマウスの右ボタンをドラッグすることでも可能です。または、シーンツリーの `WoodenBox`ノードの `rotation`フィールドの角度を変更することもできます。

結果に満足したら、保存ボタンを使ってワールドを保存します。

## E-Puck登場

このロボには8つの距離センサがある。

このチュートリアルではホイールの制御のみを実行する。


![1760756352615](image/explanation/1760756352615.png)

# コントローラ

シンプルコントローラを使って、前方に進むように制御する。

ロボットの制御を行うのがコントローラ。

プログラム言語：C, C++, Java, Python, MATLAB, etc. C, C++

> The `controller` field of a `Robot` node specifies which controller is currently associated to the robot.

コントローラは使い分けが花王みたいです。

→動作しました！

## 参考

[Webots documentation: Tutorial 1: Your First Simulation in Webots (30 Minutes)](https://cyberbotics.com/doc/guide/tutorial-1-your-first-simulation-in-webots#:~:text=The%20objective%20of%20this%20first,end%20of%20the%20first%20tutorial.)
