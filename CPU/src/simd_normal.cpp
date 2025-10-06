#include <iostream>
#include <vector>
#include <immintrin.h>  // AVX2
#include <cmath>
#include <cstring>
#include "cnpy.h"

// ---------- 通常版 ----------
void fc_relu_scalar(const float* X, const float* W, const float* B, float* H, int in_size, int out_size) {
    for (int i = 0; i < out_size; i++) {
        float sum = 0.0f;
        for (int j = 0; j < in_size; j++) {
            sum += X[j] * W[i * in_size + j];
        }
        sum += B[i];
        H[i] = std::max(sum, 0.0f); // ReLU
    }
}

void fc_scalar(const float* X, const float* W, const float* B, float* Y, int in_size, int out_size) {
    for (int i = 0; i < out_size; i++) {
        float sum = 0.0f;
        for (int j = 0; j < in_size; j++) {
            sum += X[j] * W[i * in_size + j];
        }
        Y[i] = sum + B[i];
    }
}

// ---------- AVX2 SIMD版 ----------
void fc_relu_simd(const float* X, const float* W, const float* B, float* H, int in_size, int out_size) {
    for (int i = 0; i < out_size; i++) {
        __m256 acc = _mm256_setzero_ps();
        int j = 0;
        for (; j + 8 <= in_size; j += 8) {
            __m256 x = _mm256_loadu_ps(&X[j]);
            __m256 w = _mm256_loadu_ps(&W[i * in_size + j]);
            acc = _mm256_fmadd_ps(x, w, acc); // acc += x * w
        }
        // 残りの要素
        float tmp[8];
        _mm256_storeu_ps(tmp, acc);
        float sum = tmp[0] + tmp[1] + tmp[2] + tmp[3] + tmp[4] + tmp[5] + tmp[6] + tmp[7];
        for (; j < in_size; j++) sum += X[j] * W[i * in_size + j];
        sum += B[i];
        H[i] = std::max(sum, 0.0f);
    }
}

void fc_simd(const float* X, const float* W, const float* B, float* Y, int in_size, int out_size) {
    for (int i = 0; i < out_size; i++) {
        __m256 acc = _mm256_setzero_ps();
        int j = 0;
        for (; j + 8 <= in_size; j += 8) {
            __m256 x = _mm256_loadu_ps(&X[j]);
            __m256 w = _mm256_loadu_ps(&W[i * in_size + j]);
            acc = _mm256_fmadd_ps(x, w, acc);
        }
        float tmp[8];
        _mm256_storeu_ps(tmp, acc);
        float sum = tmp[0] + tmp[1] + tmp[2] + tmp[3] + tmp[4] + tmp[5] + tmp[6] + tmp[7];
        for (; j < in_size; j++) sum += X[j] * W[i * in_size + j];
        Y[i] = sum + B[i];
    }
}

int main() {
    // npyから読み込み
    auto x = cnpy::npy_load("input.npy");
    auto w1 = cnpy::npy_load("w1.npy");
    auto b1 = cnpy::npy_load("b1.npy");
    auto w2 = cnpy::npy_load("w2.npy");
    auto b2 = cnpy::npy_load("b2.npy");
    auto y_ref = cnpy::npy_load("output_pytorch.npy");

    float* X = x.data<float>();
    float* W1 = w1.data<float>();
    float* B1 = b1.data<float>();
    float* W2 = w2.data<float>();
    float* B2 = b2.data<float>();
    float* Yref = y_ref.data<float>();

    float H_scalar[3], H_simd[3];
    float Y_scalar[2], Y_simd[2];

    // ----- 通常版 -----
    fc_relu_scalar(X, W1, B1, H_scalar, 4, 3);
    fc_scalar(H_scalar, W2, B2, Y_scalar, 3, 2);

    // ----- SIMD版 -----
    fc_relu_simd(X, W1, B1, H_simd, 4, 3);
    fc_simd(H_simd, W2, B2, Y_simd, 3, 2);

    std::cout << std::fixed;
    std::cout << "PyTorch output:\t[" << Yref[0] << ", " << Yref[1] << "]\n";
    std::cout << "Scalar output:\t[" << Y_scalar[0] << ", " << Y_scalar[1] << "]\n";
    std::cout << "SIMD output:\t[" << Y_simd[0] << ", " << Y_simd[1] << "]\n";

    // 比較
    for (int i = 0; i < 2; i++) {
        float diff_scalar = fabs(Yref[i] - Y_scalar[i]);
        float diff_simd   = fabs(Yref[i] - Y_simd[i]);
        std::cout << "Output[" << i << "] diff scalar=" << diff_scalar
                  << ", simd=" << diff_simd << "\n";
    }

    // 完全一致チェック
    if (memcmp(Yref, Y_scalar, sizeof(float) * 2) == 0)
        std::cout << "✅ Scalar版はbitレベルで完全一致\n";
    else
        std::cout << "⚠️ Scalar版はbit一致ではない（誤差あり）\n";

    return 0;
}