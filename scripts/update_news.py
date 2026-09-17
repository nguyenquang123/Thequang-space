import feedparser
import re
import os

feeds = {
    'tech-news': 'https://vnexpress.net/rss/so-hoa.rss',
    'economy-news': 'https://vnexpress.net/rss/kinh-doanh.rss',
    'stock-news': 'https://cafef.vn/thi-truong-chung-khoan.rss',
    'auto-news': 'https://vnexpress.net/rss/oto-xe-may.rss',
    'football-news': 'https://vnexpress.net/rss/the-thao.rss',
    'esports-news': 'https://gamek.vn/esport.rss'
}

def clean_html(raw_html):
    if not raw_html: return ''
    cleanr = re.compile('<.*?>')
    cleantext = re.sub(cleanr, '', raw_html)
    return cleantext.strip()

html_path = 'index.html'
if not os.path.exists(html_path):
    html_path = '../index.html'
    
with open(html_path, 'r', encoding='utf-8') as f:
    html = f.read()

tabs_content_html = ""
for tab_id, url in feeds.items():
    print(f"Fetching {tab_id} from {url}...")
    try:
        feed = feedparser.parse(url)
        articles = feed.entries[:10]
    except Exception as e:
        print(f"Error fetching {url}: {e}")
        articles = []
    
    active_class = ' active' if tab_id == 'tech-news' else ''
    tabs_content_html += f'''                        <!-- {tab_id} Tab -->
                        <div id="{tab_id}" class="tab-pane{active_class}">
                            <div class="news-container">
'''
    if not articles:
        tabs_content_html += '                                <div class="news-loading">Chưa thể tải tin tức lúc này.</div>\n'
    for a in articles:
        title = a.get('title', 'No title')
        link = a.get('link', '#')
        desc = clean_html(a.get('description', ''))
        
        if len(desc) > 150:
            desc = desc[:150] + '...'
            
        pubDate = a.get('published', '')
        date_str = pubDate
        parts = pubDate.split(' ')
        if len(parts) >= 4:
            month_map = {'Jan':'1', 'Feb':'2', 'Mar':'3', 'Apr':'4', 'May':'5', 'Jun':'6', 'Jul':'7', 'Aug':'8', 'Sep':'9', 'Oct':'10', 'Nov':'11', 'Dec':'12'}
            month = month_map.get(parts[2], parts[2])
            date_str = f"{parts[1]} Tháng {month}, {parts[3]}"
        
        tabs_content_html += f'''                                <article class="news-item">
                                    <h3>{title} <a href="{link}" target="_blank" class="source-icon" title="Đến trang nguồn"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path><polyline points="15 3 21 3 21 9"></polyline><line x1="10" y1="14" x2="21" y2="3"></line></svg></a></h3>
                                    <span class="news-date">{date_str}</span>
                                    <p>{desc}</p>
                                </article>
'''
    tabs_content_html += '''                            </div>
                        </div>
'''

start_token = '<div class="tabs-content">'
end_token = '</div>\n                </div>\n            </div>\n        </section>'

news_start = html.find('<!-- News Section (Tabs) -->')
start_idx = html.find(start_token, news_start)
end_idx = html.find(end_token, start_idx)

if start_idx != -1 and end_idx != -1:
    new_html = html[:start_idx + len(start_token)] + '\n' + tabs_content_html + '                    ' + html[end_idx:]
    with open(html_path, 'w', encoding='utf-8') as f:
        f.write(new_html)
    print("Updated index.html successfully.")
else:
    print("Could not find insertion points in index.html")
