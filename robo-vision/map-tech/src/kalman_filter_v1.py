import numpy as np
import matplotlib.pyplot as plt

class KalmanFilter:
    def __init__(self, F, H, Q, R, x0, P0):
        """
        カルマンフィルタのパラメータを初期化

        引数:
          F  : 状態遷移行列
          H  : 観測行列
          Q  : プロセス雑音共分散
          R  : 観測雑音共分散
          x0 : 初期状態ベクトル
          P0 : 初期誤差共分散行列
        """
        self.F = F
        self.H = H
        self.Q = Q
        self.R = R
        self.x = x0
        self.P = P0

    def predict(self):
        """
        予測ステップ:
          状態予測:        x = F * x
          誤差共分散予測:  P = F * P * F^T + Q
        """
        self.x = self.F @ self.x
        self.P = self.F @ self.P @ self.F.T + self.Q
        return self.x

    def update(self, z):
        """
        更新ステップ:
          観測 z に基づいて状態と誤差共分散を更新

        引数:
          z : 観測値
        """
        # イノベーション（残差）
        y = z - self.H @ self.x
        # 観測共分散
        S = self.H @ self.P @ self.H.T + self.R
        # カルマンゲインの計算
        K = self.P @ self.H.T @ np.linalg.inv(S)
        # 状態の更新
        self.x = self.x + K @ y
        # 誤差共分散の更新
        I = np.eye(self.P.shape[0])
        self.P = (I - K @ self.H) @ self.P
        return self.x


# --- パラメータの設定 ---
dt = 1.0  # サンプリング間隔

# 状態遷移行列 (定常速度モデル)
F = np.array([[1, dt],
              [0, 1]])

# 観測行列 (位置のみ観測可能)
H = np.array([[1, 0]])

# プロセス雑音共分散 (適当な値を設定)
phi = 0.1
Q_base = np.array([[dt**3/3 , dt**2/2 ],
                  [dt**2/2 , dt]])
Q = Q_base * phi

# 観測雑音共分散
r = 25.0 # 5m^2
R = np.array([[r]])

# 初期状態とその誤差共分散
x0 = np.array([[0],  # 位置の初期値
               [0]])  # 速度の初期値
P0 = np.eye(2)

# カルマンフィルタのインスタンス作成
kf = KalmanFilter(F, H, Q, R, x0, P0)

# --- シミュレーションデータの生成 ---
num_steps = 200

# 真の初期状態 (例: 位置=0, 速度=1.0)
true_x = np.array([[0],
                   [1.0]])

true_states = []  # 真の状態の履歴
measurements = []  # 観測値の履歴
estimated_states = []  # 推定状態の履歴

np.random.seed(0)  # 再現性のため乱数シードを固定
count = 0
for _ in range(num_steps):

    # 真の状態更新
    true_x = F @ true_x
    true_states.append(true_x.copy())

    # 観測値生成 (観測雑音を付加)
    z = H @ true_x + np.random.normal(0, np.sqrt(r), size=(1, 1))
    measurements.append(z.copy())

    # カルマンフィルタの予測と更新
    kf.predict()
    kf.update(z)
    estimated_states.append(kf.x.copy())
    count += 1

# --- 結果のプロット ---
time = np.arange(num_steps)
true_positions = [state[0, 0] for state in true_states]
est_positions = [state[0, 0] for state in estimated_states]
measured_positions = [z[0, 0] for z in measurements]

plt.figure(figsize=(10, 6))
plt.plot(time, true_positions, label='True Position', linewidth=2, color='gray')
plt.plot(time, est_positions, label='Estimated Position', linewidth=2)
plt.scatter(time, measured_positions, label='Measured Position', color='red', marker='o')
plt.xlabel('Time Step')
plt.ylabel('Position')
plt.title('Kalman Filter: Position Estimation')
plt.legend()
plt.grid(True)
plt.show()
