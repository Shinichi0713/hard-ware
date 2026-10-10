ロボットの制御にはセンシングが欠かせません。
そして、センシング勉強着手仕立ては何を勉強すべきか把握しておきたいです。
センシングの分野で押さえるべき知識を、基礎から応用まで体系的にまとめます。大学のシラバスや専門書の内容を参考に、実践的な観点も含めて整理しました。

## 1. センサの基本概念

### センサとは何か
- **センサ（Sensor）**: 物理量・化学量・生物量などを電気信号に変換するデバイス
- **トランスデューサ（Transducer）**: 一種のエネルギーを別の形に変換する装置（センサはその一種）
- **アクチュエータとの違い**: センサは「測る」、アクチュエータは「動かす」

### センサの5要素
[立命館大学のセンサ工学講義](https://www.ritsumei.ac.jp/~hirai/edu/2024/sensors/sensors-j.html)にもあるように、センサは以下の要素で構成されます。

1. **検出素子**: 被測定量を検出する部分
2. **後段回路**: 信号変換・増幅回路
3. **電源**: 動作に必要な電力
4. **筐体・構造**: 環境保護・取り付け
5. **インターフェース**: 外部との接続（UART, I2C, SPI等）


## 2. センサの種類と原理（物理量別）

### 主要な物理量と対応センサ

| 物理量 | 代表センサ | 原理の要点 |
|--------|-----------|-----------|
| **温度** | 熱電対、サーミスタ、RTD、IC温度センサ | 熱起電力、抵抗変化、バンドギャップ |
| **光** | フォトダイオード、フォトトランジスタ、CCD/CMOS | 光電効果、内部光電効果 |
| **力・圧力** | 歪みゲージ、圧電素子、圧力センサ | 抵抗変化（ピエゾ抵抗効果）、圧電効果 |
| **変位・距離** | ポテンショメータ、LVDT、超音波、ToF | 抵抗変化、電磁誘導、音波の往復時間 |
| **加速度** | MEMS加速度センサ、圧電型 | 質量の慣性力による変位検出 |
| **角速度** | MEMSジャイロ、FOG、振動ジャイロ | コリオリの力、サグナック効果 |
| **磁気** | ホール素子、MRセンサ、磁気抵抗素子 | ホール効果、磁気抵抗効果 |
| **湿度** | 静電容量式、抵抗式 | 吸湿材料の誘電率・抵抗変化 |
| **ガス・化学** | 半導体式ガスセンサ、電気化学式 | ガス吸着による抵抗変化、電気化学反応 |
| **画像** | CMOSイメージセンサ、LiDAR | 光電変換、ToF測距 |


## 3. 信号処理・後段回路の知識

### [センサ後段回路](https://www.ritsumei.ac.jp/~hirai/edu/2024/sensors/sensors-j.html)

- **アンプ回路**: 微弱信号の増幅（オペアンプの基礎）
- **バッファ回路**: インピーダンス変換
- **I-V変換回路**: 電流信号を電圧信号に変換
- **フィルタ**: ノイズ除去（LPF, HPF, BPF）
- **ACカップリング**: DC成分を除去して変動成分のみ抽出
- **ゼロドリフトアンプ**: 温度変化によるドリフトを抑制

### 信号処理の基礎
- **サンプリング定理**: サンプリング周波数は信号の最大周波数の2倍以上必要
- **アンチエイリアシングフィルタ**: サンプリング前の高周波ノイズ除去
- **A/D変換**: 分解能（ビット数）、変換速度、量子化誤差
- **キャリブレーション**: センサの零点・感度補正

## 4. センサ特性と評価指標

### 静的特性
| 特性 | 意味 |
|------|------|
| **感度（Sensitivity）** | 入力変化に対する出力変化の比 |
| **分解能（Resolution）** | 検出可能な最小変化量 |
| **精度（Accuracy）** | 真値との一致度 |
| **直線性（Linearity）** | 入出力特性の直線性 |
| **ヒステリシス** | 入力を増加・減少させたときの出力の不一致 |
| **再現性（Repeatability）** | 同条件で何度も測定したときのばらつき |

### 動的特性
| 特性 | 意味 |
|------|------|
| **応答時間** | 入力変化から出力が安定するまでの時間 |
| **時定数** | 1次遅れ系の応答速度を表す指標 |
| **周波数応答** | どの周波数帯域まで追従できるか |
| **立ち上がり時間** | 10%から90%に達する時間 |

## 5. ノイズ対策

センサ信号は微弱でノイズに弱いため、以下の知識が重要です。

- **外来ノイズの種類**: 電磁誘導ノイズ、静電結合ノイズ、共通インピーダンス結合
- **対策手法**:
  - シールド（Shielding）
  - グラウンド（接地）の設計
  - 差動伝送（Differential signaling）
  - フィルタリング
  - ケーブルの選定と配線

## 6. 通信プロトコル・インターフェース

センサとマイコン/PCを接続するための知識です。

| プロトコル | 特徴 | 用途例 |
|-----------|------|--------|
| **UART** | 非同期、2線（TX/RX）、簡単 | GPSモジュール、シリアル通信 |
| **I2C** | 同期、2線（SDA/SCL）、複数デバイス | 温度・湿度センサ、EEPROM |
| **SPI** | 同期、4線、高速 | IMU、SDカード、ディスプレイ |
| **1-Wire** | 1線で通信・電源供給 | 温度センサ（DS18B20） |
| **Analog（ADC）** | 電圧値を直接読む | 光センサ、距離センサ（アナログ） |
| **PWM** | デューティ比で情報伝達 | 超音波距離センサ（Echo） |


## 7. センサフュージョン・データ統合

複数センサを組み合わせて高精度な情報を得る技術です。

- **相補フィルタ**: 加速度とジャイロの融合（例: 姿勢推定）
- **カルマンフィルタ**: ノイズを考慮した最適推定
- **センサフュージョン**: 複数センサの情報を統合して認識精度向上

## 8. 応用分野別の知識

| 分野 | 重要なセンサ・技術 |
|------|------------------|
| **IoT** | 温度・湿度・気圧・加速度、低消費電力設計、無線通信 |
| **ロボティクス** | IMU（加速度+ジャイロ）、LiDAR、カメラ、フォースセンサ |
| **自動運転** | LiDAR、ミリ波レーダー、カメラ、超音波、GNSS |
| **医療・ヘルスケア** | 心電図、脈波、SpO2、体温、生体インピーダンス |
| **産業用** | 圧力・流量・温度、振動センサ、予知保全 |


## 9. 実践的なスキル

### ハードウェア
- データシートの読み方（電気的特性、タイミング図）
- ブレッドボード/基板での配線
- オシロスコープ・ロジックアナライザの使い方

### ソフトウェア
- マイコン（Arduino, ESP32, Pico等）でのセンサ読み取り
- センサドライバの実装（レジスタ設定、通信プロトコル処理）
- データの可視化（シリアルプロッタ、Python + Matplotlib等）


## 学習可能な仮想環境

### 1. センサの原理・特性（ノイズ・バイアス・ドリフト等）

__Robot Sensor Simulator__

ブラウザ上で、センサの**ノイズ、バイアス、ドリフト、量子化誤差、データ欠落（dropouts）、フィルタリング、センサフュージョン**をインタラクティブに実験できます。理論解説とガイド付き実験が60〜150分のカリキュラムとして用意されています。
[Robot Sensor Simulator](https://roboticsprojecthub.com/sensor-simulator/)

__IoT Virtual Lab（インド工科大学系）__

Arduino・ESP8266/ESP32を使った**センサ・アクチュエータ・マイコン・クラウドの連携**をシミュレーションで学べます。MQTT/HTTPプロトコルでのセンサデータ送信も含まれています。
[IoT Virtual Lab](https://iot-dei.vlabs.ac.in/)

### 2. 信号処理（ADC・フィルタ・ノイズ）

__NovaSolver シミュレーター群__

日本語も行けるようなシミュレータとなると以下がよさそうです。

| ツール | 内容 |
|--------|------|
| **ADC量子化ノイズ・SNRシミュレーター** | ビット数・フルスケール電圧・サンプリング周波数を変えて、量子化ステップ・SNR・ENOBをリアルタイム確認 |
| **デジタルフィルター設計シミュレーター** | バターワース（IIR）・ウィンドウFIRの次数・カットオフ周波数をスライダー調整し、振幅・位相応答を対数スケールで確認 |
| **カルマンフィルターシミュレーター** | プロセスノイズQ・観測ノイズRを調整して、カルマンゲイン・推定値・不確かさを可視化 |

[ADC量子化ノイズ・SNRシミュレーター](https://novasolver.jp/tools/adc-quantization-noise.html)
[デジタルフィルター設計シミュレーター](https://novasolver.jp/tools/signal-filter.html)
[カルマンフィルターシミュレーター](https://novasolver.jp/tools/kalman-filter.html)

__ADC Resolution & Oversampling Lab__

ブラウザベースのデジタルラボで、**A/D変換の量子化ノイズとオーバーサンプリング**を実際の信号を録音して実験できます。フルレポートのエクスポートも可能です。
[ADC Simulator GitHub](https://github.com/Vertiam/adc-simulator)

__DigiSim Analog Lab__

アナログ回路シミュレータで、**オペアンプ、フィルタ、トランジスタ、センサー**を含む50種類の部品を使って回路を描き、AC応答・過渡解析・ライブ解析がブラウザ上で実行できます。
[DigiSim Analog Lab](https://digisim.io/ja/analog)

__Simulations4All Signal Processing Tool__

FFTスペクトラムアナライザ、スペクトログラム、デジタルフィルタ設計（Butterworth, Chebyshev, Bessel, Elliptic）、FIR/IIR、極零点図、群遅延、畳み込み可視化など、**包括的な信号処理ツール**です。
[Simulations4All](https://simulations4all.com/simulations/signal-processing-tool)

### 3. センサフュージョン・カルマンフィルタ

__Kalman Filter Tutorial（日本語対応）__

数式中心ではなく、**手を動かす数値例と図解**でカルマンフィルタを直感的に理解できるインタラクティブガイドです。
[kalmanfilter.net JP](https://kalmanfilter.net/JP/default_jp.aspx)

__Homo Deus Lab - Kalman Filter Simulator__

プロセスノイズQと観測ノイズRを調整し、**カルマンフィルタの収束過程と推定精度**をリアルタイムで確認できます。センサフュージョンの基礎理解に最適です。
[Homo Deus Lab](https://homo-deus.com/lab/navigation/kalman-filter/)

__EKF Sensor Fusion（IMU + GPS）__

拡張カルマンフィルタ（EKF）を使った**IMUとGPSの非同期センサデータ融合**をインタラクティブにシミュレーション。Ground Truth・GPS Only・IMU Dead Reckoning・EKFの比較が可能です。
[EKF Sensor Fusion](https://brilliant-starship-dd6f4b.netlify.app/)

__mysimulator.uk - Kalman Filter__

Three.js/WebGLを使った**移動目標追跡シミュレータ**。共分散楕円が予測ステップで膨張し、更新ステップで縮小する様子を視覚的に理解できます。
[mysimulator.uk](https://www.mysimulator.uk/algorithms/kalman-filter/)

### 4. 通信プロトコル・マイコン連携

__Wokwi（総合シミュレータ）__

Arduino/ESP32/Pico/STM32に対応。**UART・I2C・SPI・1-Wire**の通信プロトコルを実際のコードで動かしながら学べます。温度センサ、距離センサ、IMUなど多数の部品が利用可能で、ロジックアナライザも使えます。
[Wokwi](https://wokwi.com/)

__CircuitLabs__

**UART・I2Cのパケット構成**をインタラクティブに学べる仮想ラボです。スタートビット・データ・ストップビットの流れを視覚的に確認できます。
[CircuitLabs UART](https://circuitlabs.net/labs/uart-communication-virtual-lab/)
[CircuitLabs I2C](https://circuitlabs.net/labs/i2c-virtual-lab/)

__IoT Simulator__

Arduino・ESP32のブラウザシミュレータ。センサを含む仮想回路を構築し、実際のArduinoコードで動作確認できます。
[IoTSimulator](https://iotsimulator.net/)

### 5. DSP・高度な信号処理

__Potik__

ブラウザ上でブロックをドラッグ&ドロップして、**DSP・RF・レーダー**の信号処理を実験できます。QPSK変調、RRCフィルタ、AWGNチャネル、コンスタレーション図などがリアルタイムで確認できます。
[Potik](https://potik.org/)

__J-DSP（Java DSP）__

アリゾナ州立大学が開発した**オンラインDSP仮想ラボ**。フィルタ設計、スペクトラム解析、畳み込み、サンプリングなどをブラウザで学べます。
[J-DSP](https://jdsp.engineering.asu.edu/)

__EEG AFE Simulator__

生体信号計測を題材に、**計測電極→計装アンプ→HPF→ノッチフィルタ→LPF→ADC**という一連のアナログフロントエンドをインタラクティブに体験できます。センサ信号処理の流れを理解するのに非常に良い教材です。
[EEG AFE Simulator](https://bionichaos.com/eeg_hardware/)

### 6. MATLAB/Octave系（より高度な解析）

__NaveGo__

MATLAB/GNU Octave用のオープンソースツールボックス。**IMU・GNSS・統合航法システム**の処理と、慣性センサのAllan分散解析が可能です。
[NaveGo GitHub](https://github.com/rodralez/NaveGo)

### まとめ：知識領域と対応環境

| 学習したい知識 | おすすめ環境 |
|--------------|-------------|
| **センサのノイズ・バイアス・ドリフト** | [Robot Sensor Simulator](https://roboticsprojecthub.com/sensor-simulator/) |
| **ADC・量子化・サンプリング** | [NovaSolver ADC](https://novasolver.jp/tools/adc-quantization-noise.html), [ADC Simulator](https://github.com/Vertiam/adc-simulator) |
| **アナログフィルタ・オペアンプ** | [DigiSim Analog Lab](https://digisim.io/ja/analog) |
| **デジタルフィルタ設計** | [NovaSolver Filter](https://novasolver.jp/tools/signal-filter.html), [Simulations4All](https://simulations4all.com/simulations/signal-processing-tool), [J-DSP](https://jdsp.engineering.asu.edu/) |
| **カルマンフィルタ・センサフュージョン** | [NovaSolver Kalman](https://novasolver.jp/tools/kalman-filter.html), [kalmanfilter.net](https://kalmanfilter.net/JP/default_jp.aspx), [EKF Simulator](https://brilliant-starship-dd6f4b.netlify.app/) |
| **UART/I2C/SPI通信** | [Wokwi](https://wokwi.com/), [CircuitLabs](https://circuitlabs.net/labs/uart-communication-virtual-lab/) |
| **センサ→マイコン→クラウド全体** | [IoT Virtual Lab](https://iot-dei.vlabs.ac.in/), [Wokwi](https://wokwi.com/), [IoTSimulator](https://iotsimulator.net/) |
| **生体/精密信号のフロントエンド** | [EEG AFE Simulator](https://bionichaos.com/eeg_hardware/) |
| **DSP・RF・レーダー** | [Potik](https://potik.org/) |

特に [NovaSolver](https://novasolver.jp/tools/adc-quantization-noise.html)（日本語対応・各種シミュレータが揃っている）と [Wokwi](https://wokwi.com/)（実際のコードが動く）を組み合わせると、理論から実装まで一貫して学べると思います。

## 総括

### 1. 知識体系の構造

9つの領域は、以下の流れで整理されています。

```
【物理現象】→【電気信号】→【信号処理】→【通信・統合】→【実装】
   (1)(2)      (3)(4)(5)      (6)(7)        (8)         (9)
```

| 段階 | 領域 | 核心 |
|------|------|------|
| **① 概念理解** | センサの基本概念・5要素 | 「何を測るか」「どう変換するか」 |
| **② 原理把握** | センサの種類と原理（10物理量） | 温度・光・力・距離・加速度・角速度・磁気・湿度・ガス・画像 |
| **③ 回路・信号** | 後段回路・信号処理 | オペアンプ・フィルタ・ADC・サンプリング定理 |
| **④ 特性評価** | 静的特性・動的特性 | 感度・分解能・精度・応答時間・時定数 |
| **⑤ ノイズ対策** | 外来ノイズと対策 | シールド・グラウンド・差動伝送・フィルタリング |
| **⑥ 通信** | UART・I2C・SPI等 | センサとマイコンの接続方法 |
| **⑦ 統合** | センサフュージョン | 相補フィルタ・カルマンフィルタ |
| **⑧ 応用** | 分野別知識 | IoT・ロボティクス・自動運転・医療・産業 |
| **⑨ 実践** | ハード・ソフトスキル | データシート読解・配線・ドライバ実装・可視化 |

### 2. 学習ロードマップ

資料の内容から、以下のような学習順序が導けます。

__Phase 1: 基礎固め（概念・原理）__
1. **センサとは何か**（Sensor vs Transducer vs Actuator）
2. **センサの5要素**を理解する
3. **身近なセンサ**（温度・距離・加速度）の原理を押さえる
4. **センサ特性**（感度・分解能・精度）の違いを理解する

__Phase 2: 信号処理入門__
5. **サンプリング定理**と**ADC**（量子化・分解能）
6. **フィルタ**（LPF/HPF/BPF）の役割
7. **ノイズ対策**の基本概念

__Phase 3: 実装・通信__
8. **通信プロトコル**（UART → I2C → SPI の順がおすすめ）
9. **マイコンでセンサを読む**（Arduino/ESP32/Pico）
10. **データの可視化**（シリアルプロッタ・Python）

__Phase 4: 応用・統合__
11. **センサフュージョン**（加速度+ジャイロの姿勢推定）
12. **カルマンフィルタ**（ノイズを考慮した状態推定）
13. **ロボット制御への応用**（IMU・LiDAR・カメラの使い分け）

### 3. 仮想環境との対応関係

資料では、各知識領域に対応する**実物不要の学習環境**が具体的に紹介されています。

| 学習フェーズ | 対応環境 | 特徴 |
|-------------|---------|------|
| **センサ特性・ノイズ理解** | [Robot Sensor Simulator](https://roboticsprojecthub.com/sensor-simulator/) | ノイズ・バイアス・ドリフト・量子化をブラウザで実験 |
| **ADC・サンプリング** | [NovaSolver ADC](https://novasolver.jp/tools/adc-quantization-noise.html) | 日本語対応、ビット数とSNRの関係を可視化 |
| **フィルタ設計** | [NovaSolver Filter](https://novasolver.jp/tools/signal-filter.html) | IIR/FIRの周波数応答をスライダー調整 |
| **アナログ回路** | [DigiSim Analog Lab](https://digisim.io/ja/analog) | オペアンプ・フィルタ回路をブラウザで描画・解析 |
| **カルマンフィルタ** | [NovaSolver Kalman](https://novasolver.jp/tools/kalman-filter.html), [kalmanfilter.net](https://kalmanfilter.net/JP/default_jp.aspx) | 日本語で直感的に理解可能 |
| **EKF・センサフュージョン** | [EKF Sensor Fusion](https://brilliant-starship-dd6f4b.netlify.app/) | IMU+GPS融合をリアルタイム比較 |
| **通信プロトコル** | [Wokwi](https://wokwi.com/), [CircuitLabs](https://circuitlabs.net/labs/uart-communication-virtual-lab/) | 実際のコードでUART/I2C/SPIを動かせる |
| **センサ→クラウド全体** | [IoT Virtual Lab](https://iot-dei.vlabs.ac.in/), [IoTSimulator](https://iotsimulator.net/) | マイコン・センサ・クラウドの連携をシミュレート |
| **DSP・高度信号処理** | [Potik](https://potik.org/), [J-DSP](https://jdsp.engineering.asu.edu/) | ブロック図でDSPを学べる |
| **生体信号フロントエンド** | [EEG AFE Simulator](https://bionichaos.com/eeg_hardware/) | 計装アンプ→フィルタ→ADCの流れを体験 |
| **統合航法（高度）** | [NaveGo](https://github.com/rodralez/NaveGo) | MATLAB/OctaveでIMU・GNSS解析 |

