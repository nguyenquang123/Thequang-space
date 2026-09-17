new_html = """
        <!-- Products Section -->
        <section id="products" class="products-section">
            <div class="container">
                <h2 class="section-title fade-in-up">Sản phẩm Thương mại</h2>
                <div class="tabs-container fade-in-up delay-1">
                    <div class="tabs-header-wrapper">
                        <div class="tabs-header">
                            <button class="tab-btn active" data-tab="product-premium">Tài khoản Premium</button>
                            <button class="tab-btn" data-tab="product-soft">Phần mềm</button>
                            <button class="tab-btn" data-tab="product-media">Media</button>
                            <button class="tab-btn" data-tab="product-tech">Công nghệ</button>
                            <button class="tab-btn" data-tab="product-cosmetics">Mỹ phẩm</button>
                        </div>
                    </div>
                    
                    <div class="tabs-content">
                        <!-- Category: Tài khoản Premium -->
                        <div id="product-premium" class="tab-pane active">
                            <div class="product-grid">
                                <!-- ChatGPT Plus -->
                                <div class="pricing-card">
                                    <div class="pricing-badge">Tiết kiệm ~20%</div>
                                    <h4>ChatGPT Plus / OpenAI</h4>
                                    <div class="price-section">
                                        <span class="old-price">~520.000đ ($20/tháng)</span>
                                        <span class="new-price">400.000đ</span>
                                        <span class="duration">/ 1 Tháng</span>
                                    </div>
                                    <ul class="features-list">
                                        <li>Truy cập mô hình thông minh nhất: GPT-4, GPT-4o.</li>
                                        <li>Trò chuyện giọng nói nâng cao (Advanced Voice).</li>
                                        <li>Vẽ ảnh DALL-E 3, lướt web và phân tích dữ liệu.</li>
                                        <li>Sử dụng và tạo các Custom GPTs chuyên biệt.</li>
                                    </ul>
                                    <div class="warranty-status">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                                        Bảo hành trọn thời gian sử dụng
                                    </div>
                                    <a href="#modal-chatgpt" class="buy-btn open-modal-btn">Liên hệ mua ngay</a>
                                </div>

                                <!-- Gemini Pro -->
                                <div class="pricing-card">
                                    <div class="pricing-badge">Tiết kiệm ~98%</div>
                                    <h4>Gemini Pro (Google AI)</h4>
                                    <div class="price-section">
                                        <span class="old-price">~8.820.000đ (490k/tháng)</span>
                                        <span class="new-price">150.000đ</span>
                                        <span class="duration">/ 18 Tháng</span>
                                    </div>
                                    <ul class="features-list">
                                        <li>Trợ lý AI thông minh nhất của Google.</li>
                                        <li>Tốc độ xử lý, viết lách, lên ý tưởng vượt trội.</li>
                                        <li>Giải quyết tác vụ phức tạp, code logic.</li>
                                        <li>Dữ liệu cập nhật theo thời gian thực.</li>
                                    </ul>
                                    <div class="warranty-status">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                                        Bảo hành 7 ngày (Hỗ trợ kỹ thuật tuần đầu)
                                    </div>
                                    <a href="#modal-gemini" class="buy-btn open-modal-btn">Liên hệ mua ngay</a>
                                </div>

                                <!-- Canva Pro -->
                                <div class="pricing-card">
                                    <div class="pricing-badge">Tiết kiệm ~90%</div>
                                    <h4>Canva Pro</h4>
                                    <div class="price-section">
                                        <span class="old-price">~149.000đ/tháng</span>
                                        <span class="new-price">99.000đ</span>
                                        <span class="duration">/ 1 Năm</span>
                                    </div>
                                    <ul class="features-list">
                                        <li>&#10003; Nâng cấp chính chủ email cá nhân.</li>
                                        <li>&#10003; Kho lưu trữ 1TB Cloud.</li>
                                        <li>&#10003; Magic Studio AI, Magic Eraser.</li>
                                        <li>&#10003; Mở khóa 100+ triệu hình ảnh, video, âm thanh premium.</li>
                                    </ul>
                                    <div class="warranty-status">&#9919; Bảo hành 1 đổi 1 trọn thời gian</div>
                                    <a href="#modal-canva" class="buy-btn open-modal-btn">Liên hệ mua ngay</a>
                                </div>
                                
                                <!-- Capcut Pro -->
                                <div class="pricing-card">
                                    <div class="pricing-badge">Bán chạy</div>
                                    <h4>Capcut Pro</h4>
                                    <div class="price-section">
                                        <span class="old-price">~200.000đ/tháng</span>
                                        <span class="new-price">150.000đ</span>
                                        <span class="duration">/ 6 Tháng</span>
                                    </div>
                                    <ul class="features-list">
                                        <li>&#10003; Mở khóa mọi hiệu ứng, filter độc quyền.</li>
                                        <li>&#10003; Xóa nền thông minh, Tracking tự động.</li>
                                        <li>&#10003; Chuyển văn bản thành giọng nói (AI Voice).</li>
                                        <li>&#10003; Chỉnh sửa màu sắc chuyên nghiệp.</li>
                                    </ul>
                                    <div class="warranty-status">&#9919; Hỗ trợ kích hoạt tận tình</div>
                                    <a href="#modal-capcut" class="buy-btn open-modal-btn">Liên hệ mua ngay</a>
                                </div>
                            </div>
                        </div>

                        <!-- Category: Phần mềm -->
                        <div id="product-soft" class="tab-pane">
                            <div class="product-grid">
                                <a href="#" class="product-card" target="_blank">
                                    <h4>Office Translator</h4>
                                    <p>Phần mềm hỗ trợ dịch tài liệu nhanh chóng.</p>
                                    <span class="status-tag">Chờ update</span>
                                </a>
                                <a href="#" class="product-card" target="_blank">
                                    <h4>Document Quick Access</h4>
                                    <p>Phần mềm truy cập nhanh tài liệu.</p>
                                    <span class="status-tag">Chờ update</span>
                                </a>
                            </div>
                        </div>

                        <!-- Category: Media -->
                        <div id="product-media" class="tab-pane">
                            <div class="product-grid">
                                <a href="#" class="product-card" target="_blank">
                                    <h4>Dịch vụ Dựng Video</h4>
                                    <p>Chỉnh sửa, cắt ghép video chuyên nghiệp (Vlog, Shorts, TikTok, Doanh nghiệp).</p>
                                    <span class="status-tag">Liên hệ báo giá</span>
                                </a>
                                <a href="#" class="product-card" target="_blank">
                                    <h4>Chỉnh sửa Hình ảnh</h4>
                                    <p>Retouch ảnh chân dung, ảnh sản phẩm thương mại sắc nét.</p>
                                    <span class="status-tag">Liên hệ báo giá</span>
                                </a>
                            </div>
                        </div>

                        <!-- Category: Công nghệ -->
                        <div id="product-tech" class="tab-pane">
                            <div class="product-grid">
                                <a href="#" class="product-card" target="_blank">
                                    <h4>Website Cá Nhân</h4>
                                    <p>Gói thiết kế website Portfolio tối giản và tinh tế.</p>
                                    <span class="status-tag">Đang nhận đặt hàng</span>
                                </a>
                                <a href="#" class="product-card" target="_blank">
                                    <h4>Hệ thống Landing Page</h4>
                                    <p>Tối ưu tỷ lệ chuyển đổi cho sản phẩm và chiến dịch.</p>
                                    <span class="status-tag">Đang nhận đặt hàng</span>
                                </a>
                                <a href="#" class="product-card" target="_blank">
                                    <h4>Cảm biến & Công tắc thông minh</h4>
                                    <p>Tự động hóa ánh sáng theo ngữ cảnh.</p>
                                    <span class="status-tag">Chờ update</span>
                                </a>
                                <a href="#" class="product-card" target="_blank">
                                    <h4>Rèm tự động</h4>
                                    <p>Điều khiển từ xa qua smartphone.</p>
                                    <span class="status-tag">Chờ update</span>
                                </a>
                            </div>
                        </div>

                        <!-- Category: Mỹ phẩm -->
                        <div id="product-cosmetics" class="tab-pane">
                            <div class="product-grid">
                                <a href="#" class="product-card" target="_blank">
                                    <h4>Top mỹ phẩm bán chạy</h4>
                                    <p>Hàng chính hãng chăm sóc sắc đẹp.</p>
                                    <span class="status-tag">Chờ update</span>
                                </a>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </section>"""

import re
with open('index.html', 'r', encoding='utf-8') as f:
    html = f.read()

# Replace the entire section
start_token = '<!-- Products Section -->'
end_token = '<!-- News Section (Tabs) -->'
start_idx = html.find(start_token)
end_idx = html.find(end_token)

if start_idx != -1 and end_idx != -1:
    new_doc = html[:start_idx] + new_html + '\n\n        ' + html[end_idx:]
    with open('index.html', 'w', encoding='utf-8') as f:
        f.write(new_doc)
    print("Done restructuring products section.")
else:
    print("Could not find boundaries")
