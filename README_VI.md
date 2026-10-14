# Malachite: GKI 6.1.78 + KernelSU Next v3.4.2 (không SUSFS)

Dành riêng cho malachite chạy HyperOS 1 / Android 14, bootloader đã mở bằng Unlock LK.

## Căn cứ phiên bản
- Kernel trên máy: `6.1.78-android14-11-gb6577b760481-ab12075023`
- GKI chính thức: `android14-6.1-2024-06_r4`, commit bắt đầu `b6577b760481`
- KernelSU Next: `v3.4.2`; tích hợp thẳng vào kernel với `CONFIG_KSU=y`.
- Không tích hợp SUSFS.

## Chạy workflow
Vào tab **Actions** → **Malachite - GKI 6.1.78 KSU Next (NO SUSFS)** → **Run workflow** (nhánh main).
Sau khi build xong, tải **Artifacts** trong trang run và kiểm tra `build-verification.txt`, `build.log`, `Image` và/hoặc `Image.lz4`.

**Đây là build thử nghiệm.** Tích hợp KernelSU vào GKI theo chế độ built-in không còn là phương án được upstream ưu tiên bảo trì. Một workflow màu xanh chỉ chứng minh kernel biên dịch thành công, KHÔNG chứng minh boot được trên malachite.

**Không flash trực tiếp** bất kỳ file `Image` hoặc `Image.lz4` nào. Phải đối chiếu kernel, ghép vào `boot.img` gốc đúng cách và có ROM gốc để khôi phục. Không flash `vendor_boot.img` của lần thử LKM trước và không khóa bootloader.

Nguồn:
- https://source.android.com/docs/core/architecture/kernel/gki-android14-6_1-deprecated-builds
- https://github.com/KernelSU-Next/KernelSU-Next/tree/v3.4.2
