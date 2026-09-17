SOP Desktop App
===============

Mục đích
--------
App nhỏ chạy trên Windows để quản lý SOP / Workguide / Material List từ shared folder:
Z:\1. HFSVINA Public\4. Production Engineering Team\NEW_LINE공정

Cách chạy
---------
1. Đảm bảo máy tính đang truy cập được ổ Z:
2. Bấm đúp file: Run_SOP_Desktop_App.vbs để mở app không hiện cửa sổ CMD
3. App sẽ tự quét folder nếu thấy ổ Z:
4. Chọn file trong bảng, sau đó bấm:
   - Open file: mở file PDF/Excel/Word
   - Open folder: mở Explorer và chọn đúng file
   - Copy path: copy đường dẫn file

Bộ lọc
------
- Search: tìm theo model, code system, area, loại file, tên file hoặc folder
- Area: lọc All / S2 / UOT / OTHER
- Cây bên trái: xem theo Model -> Code system -> Area

Nhận diện loại file
-------------------
- Thư mục hoặc tên file có "Thứ tự thao tác" sẽ hiện là Workguide.
- Thư mục hoặc tên file có "Distribution list" sẽ hiện là Material List.
- Các file SOP vẫn hiện là SOP.

Nếu không mở được
-----------------
- Kiểm tra ổ Z: đã được map trên Windows chưa
- Thử mở folder Z trên Explorer trước
- Sau đó quay lại app và bấm Scan

Ghi chú
-------
App không cần cài thêm Python hay thư viện ngoài. App dùng PowerShell và Windows Forms có sẵn trên Windows.
Nếu dùng file .bat thì cửa sổ CMD có thể hiện trong thoáng chốc; file .vbs sẽ chạy ẩn cửa sổ này.
