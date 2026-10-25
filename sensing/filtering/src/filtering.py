"""
FIRフィルタ vs IIRフィルタ 比較実験
====================================
真の信号（5Hz正弦波）にノイズ（50Hz, 120Hz, ホワイトノイズ）を加え、
FIRフィルタとIIRフィルタでノイズ除去の効果を比較する。

必要条件:
    pip install numpy matplotlib scipy
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy import signal


# ============================================================
# 1. 実験パラメータの設定
# ============================================================

fs = 1000           # サンプリング周波数 [Hz]
T = 2.0             # 信号の長さ [秒]
t = np.arange(0, T, 1/fs)  # 時間軸
N = len(t)          # サンプル数

# 真の信号: 5Hz の正弦波（振幅2.0）
f_signal = 5
signal_true = 2.0 * np.sin(2 * np.pi * f_signal * t)

# ノイズ1: 50Hz の高周波ノイズ（電源ノイズを模倣）
f_noise1 = 50
noise1 = 0.8 * np.sin(2 * np.pi * f_noise1 * t)

# ノイズ2: 120Hz の高周波ノイズ（機械振動を模倣）
f_noise2 = 120
noise2 = 0.5 * np.sin(2 * np.pi * f_noise2 * t)

# ノイズ3: ホワイトノイズ（ランダムな微小ノイズ）
np.random.seed(42)
noise3 = 0.3 * np.random.randn(N)

# 観測信号: 真の信号 + 全ノイズ
observed = signal_true + noise1 + noise2 + noise3


# ============================================================
# 2. FIRフィルタの設計と適用
# ============================================================

fc = 20             # カットオフ周波数 [Hz]
numtaps = 101       # FIRフィルタのタップ数（次数）

# Hamming窓を使ったローパスFIRフィルタの係数を設計
fir_coeff = signal.firwin(numtaps, cutoff=fc, fs=fs, window='hamming')

# FIRフィルタを観測信号に適用
fir_filtered = signal.lfilter(fir_coeff, 1.0, observed)

# FIRフィルタのグループ遅延（線形位相なので一定）
fir_delay_samples = (numtaps - 1) // 2
fir_delay_sec = fir_delay_samples / fs


# ============================================================
# 3. IIRフィルタの設計と適用
# ============================================================

order = 4           # IIRフィルタの次数

# バターワース ローパスIIRフィルタの係数を設計
b_iir, a_iir = signal.butter(order, fc, fs=fs, btype='low')

# IIRフィルタを観測信号に適用
iir_filtered = signal.lfilter(b_iir, a_iir, observed)


# ============================================================
# 4. 定量的な評価（遅延補正後）
# ============================================================

# FIRは線形位相なので一定の遅延が生じる。評価時は真の信号を遅延させて比較
signal_delayed_fir = np.zeros_like(signal_true)
signal_delayed_fir[fir_delay_samples:] = signal_true[:-fir_delay_samples]

# IIRの遅延は概算（位相が非線形なので完全補正は困難）
iir_delay_samples = 10
signal_delayed_iir = np.zeros_like(signal_true)
signal_delayed_iir[iir_delay_samples:] = signal_true[:-iir_delay_samples]

# 評価開始位置（過渡応答が落ち着いた後）
start_eval = 600

# RMSE（平均二乗誤差の平方根）を計算
rmse_observed = np.sqrt(np.mean((observed[start_eval:] - signal_true[start_eval:])**2))
rmse_fir = np.sqrt(np.mean((fir_filtered[start_eval:] - signal_delayed_fir[start_eval:])**2))
rmse_iir = np.sqrt(np.mean((iir_filtered[start_eval:] - signal_delayed_iir[start_eval:])**2))

# SNR（信号対雑音比）を計算
def compute_snr(sig, noise):
    return 10 * np.log10(np.mean(sig**2) / np.mean(noise**2))

noise_obs = observed[start_eval:] - signal_true[start_eval:]
noise_fir = fir_filtered[start_eval:] - signal_delayed_fir[start_eval:]
noise_iir = iir_filtered[start_eval:] - signal_delayed_iir[start_eval:]

snr_observed = compute_snr(signal_true[start_eval:], noise_obs)
snr_fir = compute_snr(signal_delayed_fir[start_eval:], noise_fir)
snr_iir = compute_snr(signal_delayed_iir[start_eval:], noise_iir)


# ============================================================
# 5. 結果の表示（コンソール出力）
# ============================================================

print("=" * 60)
print("【FIRフィルタ vs IIRフィルタ 比較実験結果】")
print("=" * 60)
print(f"\n【実験条件】")
print(f"  サンプリング周波数: {fs} Hz")
print(f"  信号長: {T} 秒")
print(f"  真の信号: {f_signal} Hz 正弦波（振幅2.0）")
print(f"  ノイズ: {f_noise1}Hz + {f_noise2}Hz + ホワイトノイズ")
print(f"  フィルタ: ローパス, カットオフ {fc} Hz")
print(f"  FIR: {numtaps}タップ, Hamming窓")
print(f"  IIR: {order}次, Butterworth")

print(f"\n【遅延情報】")
print(f"  FIRグループ遅延: {fir_delay_samples} サンプル = {fir_delay_sec*1000:.1f} ms")
print(f"  IIR概算遅延: {iir_delay_samples} サンプル = {iir_delay_samples/fs*1000:.1f} ms")

print(f"\n【定量的評価（遅延補正後）】")
print(f"  {'項目':<20} {'観測信号':>12} {'FIR後':>12} {'IIR後':>12}")
print(f"  {'-'*56}")
print(f"  {'RMSE (誤差)':<20} {rmse_observed:>12.4f} {rmse_fir:>12.4f} {rmse_iir:>12.4f}")
print(f"  {'SNR (dB)':<20} {snr_observed:>12.2f} {snr_fir:>12.2f} {snr_iir:>12.2f}")

print(f"\n【解釈】")
print(f"  - FIR: SNR {snr_fir - snr_observed:.1f}dB 向上, RMSE 約 {rmse_observed/rmse_fir:.0f} 分の1")
print(f"  - IIR: SNR {snr_iir - snr_observed:.1f}dB 向上, RMSE 約 {rmse_observed/rmse_iir:.1f} 分の1")


# ============================================================
# 6. グラフ描画
# ============================================================

# --- 図1: 時域波形の比較 ---
fig1, axes = plt.subplots(4, 1, figsize=(14, 12), sharex=True)

axes[0].plot(t, signal_true, 'g-', linewidth=1.5)
axes[0].set_ylabel('Amplitude')
axes[0].set_title('(1) 真の信号（5Hz 正弦波）', fontsize=12)
axes[0].set_ylim(-3.5, 3.5)
axes[0].grid(True, alpha=0.3)

axes[1].plot(t, observed, 'r-', linewidth=0.5, alpha=0.8)
axes[1].set_ylabel('Amplitude')
axes[1].set_title('(2) 観測信号（真の信号 + 50Hz + 120Hz + ホワイトノイズ）', fontsize=12)
axes[1].set_ylim(-5, 5)
axes[1].grid(True, alpha=0.3)

axes[2].plot(t, fir_filtered, 'b-', linewidth=1.0)
axes[2].set_ylabel('Amplitude')
axes[2].set_title(f'(3) FIRフィルタ後（{numtaps}タップ, fc={fc}Hz, Hamming窓）', fontsize=12)
axes[2].set_ylim(-3.5, 3.5)
axes[2].grid(True, alpha=0.3)

axes[3].plot(t, iir_filtered, 'm-', linewidth=1.0)
axes[3].set_ylabel('Amplitude')
axes[3].set_title(f'(4) IIRフィルタ後（{order}次, fc={fc}Hz, Butterworth）', fontsize=12)
axes[3].set_xlabel('Time [s]')
axes[3].set_ylim(-3.5, 3.5)
axes[3].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('filter_time_domain.png', dpi=150, bbox_inches='tight')
print("\n  → filter_time_domain.png を保存しました")


# --- 図2: 周波数応答の比較 ---
fig2, axes = plt.subplots(2, 1, figsize=(12, 8))

w_fir, h_fir = signal.freqz(fir_coeff, worN=8192, fs=fs)
axes[0].plot(w_fir, 20 * np.log10(np.abs(h_fir) + 1e-10), 'b-', linewidth=1.5)
axes[0].axvline(fc, color='r', linestyle='--', alpha=0.7, label=f'Cutoff fc={fc}Hz')
axes[0].axvline(f_signal, color='g', linestyle=':', alpha=0.8, label=f'Signal f={f_signal}Hz')
axes[0].axvline(f_noise1, color='orange', linestyle=':', alpha=0.8, label=f'Noise f={f_noise1}Hz')
axes[0].axvline(f_noise2, color='purple', linestyle=':', alpha=0.8, label=f'Noise f={f_noise2}Hz')
axes[0].axhline(-3, color='gray', linestyle='--', alpha=0.5)
axes[0].set_ylabel('Gain [dB]')
axes[0].set_title(f'FIRフィルタの周波数応答（{numtaps}タップ, Hamming窓, fc={fc}Hz）', fontsize=12)
axes[0].set_xlim(0, 200)
axes[0].set_ylim(-80, 5)
axes[0].legend(loc='upper right', fontsize=8)
axes[0].grid(True, alpha=0.3)

w_iir, h_iir = signal.freqz(b_iir, a_iir, worN=8192, fs=fs)
axes[1].plot(w_iir, 20 * np.log10(np.abs(h_iir) + 1e-10), 'm-', linewidth=1.5)
axes[1].axvline(fc, color='r', linestyle='--', alpha=0.7, label=f'Cutoff fc={fc}Hz')
axes[1].axvline(f_signal, color='g', linestyle=':', alpha=0.8, label=f'Signal f={f_signal}Hz')
axes[1].axvline(f_noise1, color='orange', linestyle=':', alpha=0.8, label=f'Noise f={f_noise1}Hz')
axes[1].axvline(f_noise2, color='purple', linestyle=':', alpha=0.8, label=f'Noise f={f_noise2}Hz')
axes[1].axhline(-3, color='gray', linestyle='--', alpha=0.5)
axes[1].set_ylabel('Gain [dB]')
axes[1].set_xlabel('Frequency [Hz]')
axes[1].set_title(f'IIRフィルタの周波数応答（{order}次, Butterworth, fc={fc}Hz）', fontsize=12)
axes[1].set_xlim(0, 200)
axes[1].set_ylim(-80, 5)
axes[1].legend(loc='upper right', fontsize=8)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('filter_frequency_response.png', dpi=150, bbox_inches='tight')
print("  → filter_frequency_response.png を保存しました")


# --- 図3: スペクトル比較 ---
def compute_spectrum(x, fs):
    """FFTで片側スペクトルを計算"""
    N = len(x)
    fft_vals = np.fft.rfft(x)
    freqs = np.fft.rfftfreq(N, 1/fs)
    magnitude = np.abs(fft_vals) / N
    magnitude[1:] *= 2  # DC以外は2倍
    return freqs, magnitude

fig3, axes = plt.subplots(2, 2, figsize=(14, 10))

signals = [
    ('True Signal', signal_true, 'g'),
    ('Observed (Noisy)', observed, 'r'),
    ('FIR Filtered', fir_filtered, 'b'),
    ('IIR Filtered', iir_filtered, 'm'),
]

for idx, (name, sig, color) in enumerate(signals):
    ax = axes[idx // 2, idx % 2]
    freqs, mag = compute_spectrum(sig, fs)
    ax.semilogy(freqs, mag + 1e-10, color=color, linewidth=1.0)
    ax.axvline(f_signal, color='g', linestyle=':', alpha=0.7, label=f'Signal {f_signal}Hz')
    ax.axvline(f_noise1, color='orange', linestyle=':', alpha=0.7, label=f'Noise {f_noise1}Hz')
    ax.axvline(f_noise2, color='purple', linestyle=':', alpha=0.7, label=f'Noise {f_noise2}Hz')
    ax.axvline(fc, color='gray', linestyle='--', alpha=0.5, label=f'Cutoff {fc}Hz')
    ax.set_xlim(0, 200)
    ax.set_ylim(1e-4, 3)
    ax.set_xlabel('Frequency [Hz]')
    ax.set_ylabel('Magnitude')
    ax.set_title(f'Spectrum: {name}', fontsize=11)
    ax.legend(loc='upper right', fontsize=7)
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('filter_spectrum.png', dpi=150, bbox_inches='tight')
print("  → filter_spectrum.png を保存しました")

plt.show()