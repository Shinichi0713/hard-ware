Arduino/ESP32/Pico/STM32に対応。UART・I2C・SPI・1-Wireの通信プロトコルを実際のコードで動かしながら学べます。温度センサ、距離センサ、IMUなど多数の部品が利用可能で、ロジックアナライザも使えます。


はい、いくつかの優れた仮想環境が存在します。以下、**RTL設計向け（FPGA/ASIC）**と**マイコン・回路シミュレーション向け**に分けて紹介します。

---

## 1. RTL設計向け（SystemVerilog / VHDL）

### EDA Playground（最も推奨）

**特徴**:
- ブラウザのみで動作、無料、アカウント不要でも使用可能
- SystemVerilog / VHDL / UVM 等、複数のシミュレータ（ModelSim等）を選択可能
- コードエディタと波形ビューワが統合

**SPI/UART練習のメリット**:
- 先ほどのスチュアートプラットフォームのような**自作コントローラをすぐシミュレート**できます
- テストベンチ（Testbench）を書いて、送信波形・受信データを確認できます
- **UARTのサンプルコードが既に公開されている**ため、すぐに学習を始められます

**URL**: [edaplayground.com](https://www.edaplayground.com)

---

### Makerchip / Virtual FPGA Lab

**特徴**:
- TL-Verilogという高級RTL記述言語で、ブラウザ上でFPGA設計を学べます
- 仮想FPGAボード上でLEDやスイッチとの動作を確認できます
- オープンソース（FOSSi Foundation支援）

**向いている人**: FPGA設計の入門から実践まで、ブラウザで完結させたい方

**URL**: [makerchip.com](https://makerchip.com) / [github.com/os-fpga/Virtual-FPGA-Lab](https://github.com/os-fpga/Virtual-FPGA-Lab)

---

## 2. マイコン + 回路シミュレーション向け

### Wokwi（最も使いやすい）

**特徴**:
- ブラウザ上でArduino、ESP32、Raspberry Pi Pico等をシミュレート
- **SPI・I2C・UARTデバイスを回路図上に配置**して、実際に通信する様子を確認可能
- ロジックアナライザ機能付き（波形をリアルタイムで見られる）

**SPI/UART練習のメリット**:
- IMUやLCD等の仮想センサを接続し、SPI/I2C/UARTのコードを書いて動作確認ができる
- 配線図とコードを同時に見ながら学習できる

**URL**: [wokwi.com](https://wokwi.com)

---

### sensbench / Velxio / TIF Sandbox

**特徴**:
- ブラウザベースの回路 + マイコン統合シミュレータ
- SPICE-accurateなアナログシミュレーションと、ESP32 / RP2040 / ATtiny85等のデジタルシミュレーションが連携
- オシロスコープ・シリアルモニタ機能付き

**URL**:
- [sensbench.com](https://app.sensbench.com)
- [velxio.dev](https://velxio.dev)
- [sandbox.tiflabs.in](https://sandbox.tiflabs.in)

---

## 3. 実践学習の進め方（おすすめの組み合わせ）

| 段階 | 環境 | 学習内容 |
|---|---|---|
| **1. 通信の動作を理解する** | Wokwi | Arduino/ESP32でSPI・I2C・UARTの送受信プログラムを書き、仮想センサと通信する |
| **2. RTLを書いてシミュレートする** | EDA Playground | SystemVerilogでUART/SPIの送受信モジュールを自作し、テストベンチで波形確認 |
| **3. 実際のFPGAで動かす** | 実機（Arty A7 / Tang Nano等） | EDA Playgroundで検証したコードを実機に移植 |

---

## 4. 参考: 既存のSPI/UART RTLライブラリ

Ethan Peterson氏が公開している **FPGA Peripherals Library**（SystemVerilog製）には、UART・SPI・I2C等のペリフェラル実装が含まれており、EDA Playgroundに移植して学習するのに適しています。<source-chip title="Ethan Peterson FPGA Peripherals" url="https://portfolio.petetech.net/fpga-peripherals/" />

---

## まとめ

| 目的 | 推奨環境 |
|---|---|
| **SystemVerilog/VHDLでSPI/UARTコントローラを設計・検証** | EDA Playground |
| **マイコンのSPI/I2C/UART通信プログラムを動かしてみる** | Wokwi |
| **回路全体（アナログ込み）をシミュレート** | sensbench / Velxio |
| **仮想FPGAボード上で動作確認** | Makerchip / Virtual FPGA Lab |

特に、先ほどのスチュアートプラットフォームのIMU接続を想定する場合、**EDA PlaygroundでSPI/I2CコントローラをRTL設計し、Wokwiでマイコン側の制御コードを書く**という使い分けが効果的です。

特定の環境（例えばEDA Playground）でのSPIコントローラの実装例や、WokwiでのUART通信サンプルをご希望であれば、生成いたします。


