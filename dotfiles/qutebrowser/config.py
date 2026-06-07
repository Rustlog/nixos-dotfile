#!/usr/bin/env python3

import os

set  = config.set
bind = config.bind

os.environ["QT_QPA_PLATFORM"]         = "wayland"
os.environ["QT_QPA_PLATFORMTHEME"]    = "gtk3"

config.load_autoconfig(False)

# Colors
set("colors.statusbar.normal.bg",   "#1A1A1A")
set("colors.statusbar.normal.fg",   "#CCCCCC")
set("colors.statusbar.insert.bg",   "#0066CC")
set("colors.statusbar.insert.fg",   "#FFFFFF")
set("colors.statusbar.command.bg",  "#1A1A1A")
set("colors.statusbar.command.fg",  "#FFFFFF")
set("colors.tabs.indicator.stop",   "#00FFAA")

# Keybindings
bind("<Ctrl+Shift+H>",  "tab-move +1" )
bind("<Ctrl+Shift+L>",  "tab-move -1" )
bind("<Shift+E>",       "edit-url"    )
bind("<Ctrl+M>",        "tab-mute"    )
bind("<Ctrl+=>",        "zoom-in"     )
bind("<Ctrl+->",        "zoom-out"    )
bind("td",              "config-cycle -u '{url}' -t colors.webpage.darkmode.enabled true false ;; reload" )
bind("tD",              "config-cycle -t colors.webpage.darkmode.enabled true false"                      )

# Set Font
set("fonts.default_family", [ "SourceCodePro" ]    )
set("fonts.web.family.fixed",       "SourceCodePro" )
set("fonts.web.family.sans_serif",  "SourceCodePro" )
set("fonts.web.family.serif",       "SourceCodePro" )
set("fonts.web.family.standard",    "SourceCodePro" )
set("fonts.default_size",           "10pt"          )
set("fonts.default_size",           "16px"          )

# Zoomlevels
set("zoom.levels", [
    "10%",  "20%",  "30%",  "40%",  "50%",  "60%",
    "70%",  "80%",  "90%",  "100%", "110%", "120%",
    "130%", "140%", "150%", "160%", "170%", "180%",
    "190%", "200%", "210%", "220%", "220%", "230%",
    "240%", "250%", "260%", "270%", "280%", "290%",
    "300%", "310%", "320%", "230%", "340%", "350%",
    "360%", "270%", "380%", "390%", "400%", "410%",
    "420%", "430%", "440%", "450%", "460%", "470%",
    "480%", "490%", "500%", "510%", "520%", "530%",
    "540%", "550%", "560%", "570%", "580%", "590%",
    "600%", "610%", "620%", "630%", "640%", "650%",
    "670%", "680%", "690%", "700%", "710%", "720%",
])

# Content-blocking
set("content.blocking.enabled", True    )
set("content.blocking.method", "both"   )
set("content.blocking.adblock.lists", [
    "https://ublockorigin.pages.dev/filters/filters.min.txt",
    "https://ublockorigin.pages.dev/filters/badware.min.txt",
    "https://ublockorigin.pages.dev/filters/privacy.min.txt",
    "https://ublockorigin.pages.dev/filters/unbreak.min.txt",
    "https://ublockorigin.pages.dev/filters/quick-fixes.min.txt",
    "https://ublockorigin.pages.dev/filters/annoyances.min.txt",
    "https://ublockorigin.pages.dev/filters/annoyances-cookies.txt",
    "https://cdn.jsdelivr.net/gh/uBlockOrigin/uAssetsCDN@main/thirdparties/easylist.txt",
    "https://cdn.jsdelivr.net/gh/uBlockOrigin/uAssetsCDN@main/thirdparties/easyprivacy.txt",
    "https://easylist-downloads.adblockplus.org/indianlist.txt",
    "https://cdn.jsdelivr.net/gh/uBlockOrigin/uAssetsCDN@main/thirdparties/easylist-annoyances.txt",
])

set("content.blocking.hosts.lists", [
    "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext",
])

set("content.canvas_reading", True)

# Set environment
set("url.default_page",         "about:blank"    )
set("url.start_pages",          "about:blank"    )
set("auto_save.session",        True             )
set("content.geolocation",      False            )
set("content.private_browsing", True             )
set("content.autoplay",         False            )
set("fonts.web.size.default",   20               )
set("tabs.width",               "4%"             )
set("editor.command", ["foot", "--app-id", "solid_f", "vim", "{file}"]          )
set("tabs.title.format",        "{audio}{index}: {current_title:.30}{private}"  )
set("content.headers.user_agent",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36")

set("content.headers.custom", {
    "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "accept-encoding": "gzip, deflate, br",
    "sec-fetch-mode": "navigate",
    "sec-fetch-site": "none",
    "sec-fetch-user": "?1",
    "upgrade-insecure-requests": "1"
})

# Request or force dark theme on sites
set("colors.webpage.bg", "black")
set("colors.webpage.preferred_color_scheme", "dark" )
force_dark_on = [
    "https://*.google.com/*",
    "qute://bookmarks",
    "qute://bindings",
    "qute://settings",
    "qute://version",
    "qute://history",
    "qute://help",
    "qute://gpl",
]
for site in force_dark_on:
    set("colors.webpage.darkmode.enabled", True, site)

# Default search engines
set("url.searchengines", {
    "DEFAULT": "https://startpage.com/sp/search?q={}",
    "!g": "https://www.google.com/search?q={}",
    "!d": "https://duckduckgo.com/search?q={}",
    "!s": "https://startpage.com/sp/search?q={}",
    "!gh": "https://github.com/search?o=desc&q={}&s=stars",
    "!yt": "https://www.youtube.com/results?search_query={}",
})

