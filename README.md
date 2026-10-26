# SureHCS Device Probe

Trình kết nối chẩn đoán máy chấm công cho đội triển khai SureHCS. Dùng khi cần đọc
cấu hình/giao thức của máy chấm công nằm trong mạng LAN của khách để chọn driver phù hợp.

## Chạy (trên một máy trong LAN khách)

Mở **PowerShell** (không cần quyền Admin), dán một dòng do SureHCS cấp:

```powershell
iex "& { $(irm https://raw.githubusercontent.com/tmone/surehcs-device-probe/<sha>/probe.ps1) } -Bundle '<chuỗi SureHCS cấp>'"
```

Để cửa sổ mở trong khi SureHCS làm việc. Xong thì **đóng cửa sổ** hoặc **Ctrl+C**.

## Nó làm gì — và KHÔNG làm gì

- Tải `cloudflared` bản đã **ghim phiên bản + kiểm SHA256** rồi mở một kết nối ra ngoài
  tới trung tâm SureHCS. Khách **không phải đăng nhập** gì.
- **Không** cài service, **không** tạo user, **không** sửa cấu hình/registry máy.
- Portable: mọi thứ nằm trong thư mục tạm, **tự xoá khi thoát**. Đóng cửa sổ = tắt ngay.
- Chuỗi `-Bundle` chỉ chứa thông tin kết nối của đúng khách hàng đó. **Không có bí mật nào
  nằm trong mã nguồn công khai này.**

## Mã nguồn

Chỉ có một file: [`probe.ps1`](probe.ps1). Đọc được toàn bộ trước khi chạy.
