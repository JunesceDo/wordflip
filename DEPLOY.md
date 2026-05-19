# WordFlip — Hướng dẫn Deploy

## Tổng quan

```
Vercel (host HTML) ←→ Supabase (PostgreSQL database)
```

Tất cả miễn phí. Dữ liệu được lưu trên Supabase, truy cập từ mọi thiết bị qua URL Vercel.

---

## Bước 1 — Tạo Supabase project (5 phút)

1. Vào [app.supabase.com](https://app.supabase.com) → **New project**
2. Đặt tên project, chọn region gần nhất (Singapore cho VN)
3. Đặt password database → **Create new project** (chờ ~2 phút)

### Tạo bảng

4. Vào **SQL Editor** (menu trái)
5. Dán toàn bộ nội dung file `schema.sql` vào
6. Nhấn **Run** (Ctrl+Enter)
7. Kiểm tra tab **Table Editor** — phải thấy 3 bảng: `decks`, `cards`, `study_log`

### Lấy credentials

8. Vào **Project Settings** → **API**
9. Copy 2 thứ:
   - **Project URL** — dạng `https://xxxx.supabase.co`
   - **anon public** key — chuỗi dài bắt đầu bằng `eyJ...`

> ⚠️ Dùng `anon public` key, KHÔNG phải `service_role` key

---

## Bước 2 — Deploy lên Vercel (3 phút)

### Cách A: Drag & Drop (nhanh nhất, không cần Git)

1. Vào [vercel.com](https://vercel.com) → đăng ký / đăng nhập (dùng GitHub/Google)
2. Dashboard → **Add New** → **Project**
3. Kéo thả **thư mục `wordflip-deploy`** vào vùng upload
4. Nhấn **Deploy**
5. Sau ~30 giây → nhận URL dạng `https://wordflip-xxxx.vercel.app`

### Cách B: Qua GitHub (khuyến nghị — dễ update sau này)

```bash
# Tạo repo GitHub mới, push lên
cd wordflip-deploy
git init
git add .
git commit -m "init WordFlip"
git remote add origin https://github.com/YOUR_USERNAME/wordflip.git
git push -u origin main
```

Sau đó trên Vercel: **Import Git Repository** → chọn repo → **Deploy**

---

## Bước 3 — Kết nối Supabase trong app

1. Mở URL Vercel vừa tạo
2. Màn hình setup tự động hiện ra
3. Dán **Project URL** và **anon key** vào
4. Nhấn **Kết nối và bắt đầu**
5. App tự test kết nối → nếu thành công hiện `☁ kết nối` trên header

> Credentials được lưu trong localStorage của trình duyệt — mỗi thiết bị mới cần nhập lại 1 lần.

---

## Sử dụng trên nhiều thiết bị

| Thiết bị | Làm gì |
|----------|--------|
| Điện thoại | Mở URL Vercel → nhập URL + key → kết nối |
| Máy tính công ty | Tương tự |
| Máy tính cá nhân | Tương tự |

**Sync hoạt động như thế nào:**
- Mở app → tự động pull dữ liệu mới nhất từ server
- Sau mỗi buổi học → tự động push tiến độ lên server
- Nút **↺ Sync** trên header để sync thủ công bất cứ lúc nào

---

## Thêm vào màn hình chính (mobile)

**iOS Safari:** Share → Add to Home Screen  
**Android Chrome:** Menu (3 chấm) → Add to Home Screen

App sẽ chạy như native app, không có thanh địa chỉ.

---

## Bảo mật (tùy chọn)

App hiện dùng RLS policy cho phép tất cả — phù hợp khi chỉ bạn biết URL.

Nếu muốn bảo mật hơn, thêm password đơn giản bằng cách thêm vào đầu `<script>` trong `index.html`:

```javascript
const APP_PASSWORD = 'your-password-here';
if (localStorage.getItem('wf_auth') !== APP_PASSWORD) {
  const pw = prompt('Nhập mật khẩu:');
  if (pw !== APP_PASSWORD) { document.body.innerHTML = '🔒'; throw new Error('Unauthorized'); }
  localStorage.setItem('wf_auth', pw);
}
```

---

## Troubleshooting

**Lỗi "relation does not exist"**  
→ Chưa chạy `schema.sql`. Vào Supabase SQL Editor và chạy lại.

**Lỗi "Invalid API key"**  
→ Kiểm tra đã dùng `anon public` key chưa (không phải `service_role`).

**App hiện trắng sau deploy**  
→ Vercel cần file `index.html` ở root của project — đảm bảo deploy đúng thư mục.

**Dữ liệu không sync**  
→ Nhấn ↺ Sync thủ công. Nếu vẫn lỗi, kiểm tra browser console (F12).
