document.addEventListener("DOMContentLoaded", () => {
    // 0. Reset Scroll on Reload
    if ('scrollRestoration' in history) {
        history.scrollRestoration = 'manual';
    }
    window.scrollTo(0, 0);
    
    // Remove hash from URL if present without triggering scroll
    if (window.location.hash) {
        history.replaceState(null, null, ' ');
    }

    // 1. Real-time Clock
    const clockTime = document.getElementById('live-clock');
    const clockDate = document.getElementById('live-date');

    function updateClock() {
        const now = new Date();
        
        // Format Time
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        const seconds = String(now.getSeconds()).padStart(2, '0');
        clockTime.textContent = `${hours}:${minutes}:${seconds}`;

        // Format Date
        const days = ['Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy'];
        const dayName = days[now.getDay()];
        const day = String(now.getDate()).padStart(2, '0');
        const month = String(now.getMonth() + 1).padStart(2, '0');
        const year = now.getFullYear();
        
        clockDate.textContent = `${dayName}, ${day}/${month}/${year}`;
    }

    if (clockTime && clockDate) {
        updateClock();
        setInterval(updateClock, 1000);
    }

    // 2. Sticky Navbar on Scroll
    const navbar = document.getElementById('navbar');
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    });

    // 3. Intersection Observer for Scroll Animations
    const observerOptions = {
        root: null,
        rootMargin: '0px',
        threshold: 0.15
    };

    const observer = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            }
        });
    }, observerOptions);

    const animatedElements = document.querySelectorAll('.fade-in-up');
    animatedElements.forEach(el => observer.observe(el));

        // 4. Tabs Logic
    const tabButtons = document.querySelectorAll('.tab-btn');

    tabButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            const container = btn.closest('.tabs-container');
            const targetId = btn.getAttribute('data-tab');
            
            // Remove active class from siblings in the same container
            container.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            container.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));

            // Add active class to clicked button
            btn.classList.add('active');
            
            // Center the clicked tab button
            btn.scrollIntoView({ behavior: 'smooth', inline: 'center', block: 'nearest' });

            // Show corresponding pane
            const targetPane = document.getElementById(targetId);
            if (targetPane) targetPane.classList.add('active');
        });
    });

    // 5. Theme Toggle Logic
    const themeBtn = document.getElementById('theme-toggle');
    const rootEl = document.documentElement;
    const savedTheme = localStorage.getItem('theme');

    if (savedTheme === 'dark') {
        rootEl.setAttribute('data-theme', 'dark');
    }

    themeBtn.addEventListener('click', () => {
        const currentTheme = rootEl.getAttribute('data-theme');
        if (currentTheme === 'dark') {
            rootEl.removeAttribute('data-theme');
            localStorage.setItem('theme', 'light');
        } else {
            rootEl.setAttribute('data-theme', 'dark');
            localStorage.setItem('theme', 'dark');
        }
    });

    // 6. Custom Cursor Logic
    const cursor = document.getElementById('custom-cursor');
    if (cursor) {
        let mouseX = 0, mouseY = 0;
        
        document.addEventListener('mousemove', (e) => {
            mouseX = e.clientX;
            mouseY = e.clientY;
        });
        
        function animateCursor() {
            cursor.style.left = mouseX + 'px';
            cursor.style.top = mouseY + 'px';
            requestAnimationFrame(animateCursor);
        }
        animateCursor();

        const interactiveElements = document.querySelectorAll('a, button, .tab-btn');
        interactiveElements.forEach(el => {
            el.addEventListener('mouseenter', () => cursor.classList.add('hovering'));
            el.addEventListener('mouseleave', () => cursor.classList.remove('hovering'));
        });
    }

    // 7. Scroll Progress Bar
    const progressBar = document.getElementById('scroll-progress');
    window.addEventListener('scroll', () => {
        const winScroll = document.body.scrollTop || document.documentElement.scrollTop;
        const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
        const scrolled = (winScroll / height) * 100;
        if (progressBar) {
            progressBar.style.width = scrolled + "%";
        }
    });

    // 8. Copy to Clipboard (Email)
    const emailLink = document.getElementById('email-link');
    const toast = document.getElementById('toast');
    if (emailLink && toast) {
        emailLink.addEventListener('click', () => {
            navigator.clipboard.writeText('quang@thequang.space').then(() => {
                toast.classList.add('show');
                setTimeout(() => {
                    toast.classList.remove('show');
                }, 3000);
            }).catch(err => {
                console.error('Không thể copy', err);
            });
        });
    }

    // 9. Parallax Effect on Hero Clock
    const heroSection = document.getElementById('hero');
    const clockCard = document.getElementById('parallax-clock');
    if (heroSection && clockCard) {
        heroSection.addEventListener('mousemove', (e) => {
            const x = (e.clientX / window.innerWidth - 0.5) * 20; // max 10px rotation/move
            const y = (e.clientY / window.innerHeight - 0.5) * 20;
            
            clockCard.style.transform = `translate(${x}px, ${y}px) rotateX(${-y}deg) rotateY(${x}deg)`;
        });

        heroSection.addEventListener('mouseleave', () => {
            clockCard.style.transform = `translate(0px, 0px) rotateX(0deg) rotateY(0deg)`;
        });
    }

// 10. Checkout Modals Logic
    const openModalBtns = document.querySelectorAll('.open-modal-btn');
    const closeBtns = document.querySelectorAll('.close-modal');
    const modals = document.querySelectorAll('.checkout-modal');

    openModalBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            const targetId = btn.getAttribute('href').replace('#', '');
            const targetModal = document.getElementById(targetId);
            if (targetModal) {
                targetModal.classList.add('show');
                // Lock body scroll
                document.body.style.overflow = 'hidden';
            }
        });
    });

    closeBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const modal = btn.closest('.checkout-modal');
            modal.classList.remove('show');
            document.body.style.overflow = '';
        });
    });

    modals.forEach(modal => {
        modal.addEventListener('click', (e) => {
            // Close if clicking outside the modal content (on the overlay)
            if (e.target.classList.contains('checkout-modal') || e.target.classList.contains('modal-overlay')) {
                modal.classList.remove('show');
                document.body.style.overflow = '';
            }
        });
    });

});


// Contextual Greeting
function updateGreeting() {
    const clockLabel = document.querySelector('.clock-label');
    if (!clockLabel) return;
    
    const hour = new Date().getHours();
    let greeting = 'Xin chào';
    
    if (hour >= 5 && hour < 11) {
        greeting = 'Chào buổi sáng';
    } else if (hour >= 11 && hour < 14) {
        greeting = 'Chào buổi trưa';
    } else if (hour >= 14 && hour < 18) {
        greeting = 'Chào buổi chiều';
    } else if (hour >= 18 && hour < 22) {
        greeting = 'Chào buổi tối';
    } else {
        greeting = 'Chào buổi đêm';
    }
    
    clockLabel.textContent = greeting + ', bây giờ là';
}
updateGreeting();
// Update greeting occasionally in case user leaves page open
setInterval(updateGreeting, 60000);

// 12. Free Download Modal Logic
const freeDownloadBtns = document.querySelectorAll('.open-free-download-btn');
const confirmDownloadBtn = document.getElementById('confirm-free-download-btn');
if (freeDownloadBtns.length > 0 && confirmDownloadBtn) {
    freeDownloadBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const fileUrl = btn.getAttribute('data-file');
            confirmDownloadBtn.setAttribute('href', fileUrl);
        });
    });
    
    confirmDownloadBtn.addEventListener('click', () => {
        const modal = confirmDownloadBtn.closest('.checkout-modal');
        if (modal) {
            modal.classList.remove('show');
        }
    });
}
