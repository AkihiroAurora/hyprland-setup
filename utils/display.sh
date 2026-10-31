#!/bin/bash

# what changed: printf instead of echo -e, so a backslash in a path or message can't
# eat a character; messages take "$*" so multi-word args survive.

print_logo() {
    printf '\033[1;38;2;203;166;247m\n'
    cat <<"EOF"
   _____   __   .__.__    .__                  ___ ___                          _________       __
  /  _  \ |  _|__|  |__ |__|______  ____    /   |   \ ___.__._____________   /   _____/ _____/  |_ __ ________
 /  /_\  \|  |/ /  |  |  \|  \_  __ \/  _ \  /    ~    <   |  |\____ \_  __ \  \_____  \_/ __ \   __\  |  \____ \
/    |    \    < |  |   Y  \  ||  | \(  <_> ) \    Y    /\___  ||  |_> >  | \/  /        \  ___/|  | |  |  /  |_> >
\____|__  /__|_ \__|___|  /__||__|   \____/   \___|_  / / ____||   __/|__|    /_______  /\___  >__| |____/|   __/
        \/     \/       \/                          \/  \/     |__|                   \/     \/           |__|
EOF
    printf '\033[0m\n'
}

print_info()    { printf '\033[1;38;2;137;180;250mINFO:\033[0m %s\n' "$*"; }
print_success() { printf '\033[1;38;2;166;227;161mSUCCESS:\033[0m %s\n' "$*"; }
print_warning() { printf '\033[1;38;2;249;226;175mWARNING:\033[0m %s\n' "$*"; }
print_error()   { printf '\033[1;38;2;243;139;168mERROR:\033[0m %s\n' "$*"; }

# Copy a file aside once, keeping the first (pre-change) version.
# Used before we edit anything under /etc. Safe to call repeatedly.
backup_file() {
    local f="$1"
    [ -f "$f" ] || return 0
    if [ ! -f "$f.bak" ]; then
        sudo cp -a "$f" "$f.bak" || print_warning "couldn't back up $f"
    fi
}
