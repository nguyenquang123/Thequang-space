import re
with open('style.css', 'r', encoding='utf-8') as f:
    css = f.read()

# Remove scrollbar hiding from .tabs-header-wrapper
css = re.sub(r'scrollbar-width: none; /\* Firefox \*/', 'scrollbar-width: thin; /* Firefox */', css)
css = re.sub(r'-ms-overflow-style: none; /\* IE/Edge \*/', '', css)

# Make sure we don't hide -webkit-scrollbar for .tabs-header-wrapper
css = re.sub(r'\.tabs-header-wrapper::-webkit-scrollbar\s*{\s*display: none[^}]*}', '', css)

smart_scrollbar = '''
/* === SMART HORIZONTAL SCROLLBAR FOR TABS === */
.tabs-header-wrapper {
    overflow-x: auto !important;
    overflow-y: hidden !important;
    scrollbar-width: thin;
    scrollbar-color: rgba(0,0,0,0.15) transparent;
    padding-bottom: 5px;
}
[data-theme="dark"] .tabs-header-wrapper {
    scrollbar-color: rgba(255,255,255,0.15) transparent;
}
.tabs-header-wrapper::-webkit-scrollbar {
    height: 4px;
    display: block !important;
}
.tabs-header-wrapper::-webkit-scrollbar-track {
    background: transparent;
}
.tabs-header-wrapper::-webkit-scrollbar-thumb {
    background: rgba(0,0,0,0.15);
    border-radius: 4px;
}
[data-theme="dark"] .tabs-header-wrapper::-webkit-scrollbar-thumb {
    background: rgba(255,255,255,0.15);
}
'''

css += smart_scrollbar

with open('style.css', 'w', encoding='utf-8') as f:
    f.write(css)
print('Smart horizontal scrollbar applied.')
