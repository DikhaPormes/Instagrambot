#!/bin/bash
# Instagram Bot Script v3.0
# Banner warna + countdown + progress bar + auto follow/unfollow

# -----------------------------
# CONFIG
# -----------------------------
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0 Safari/537.36"
COOKIE_FILE="./insta_cookie.txt"

# -----------------------------
# COLOR CODES
# -----------------------------
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
RESET="\033[0m"

# -----------------------------
# FUNCTIONS
# -----------------------------
print_banner() {
cat << "EOF"
${CYAN} ___           _                     _                         _   
${CYAN}|_ _|_ __  ___| |_ __ _ ___ ___  ___| |_ ___  _ __ ___   __ _| |_ 
${MAGENTA} | || '_ \/ __| __/ _` / __/ __|/ _ \ __/ _ \| '_ ` _ \ / _` | __|
${YELLOW} | || | | \__ \ || (_| \__ \__ \  __/ || (_) | | | | | | (_| | |_ 
${GREEN}|___|_| |_|___/\__\__,_|___/___/\___|\__\___/|_| |_| |_|\__,_|\__|
EOF
echo -e "${RESET}"
}

login() {
    read -p "Username: " IG_USER
    read -s -p "Password: " IG_PASS
    echo
    curl -s -c $COOKIE_FILE -A "$USER_AGENT" \
        -d "username=$IG_USER&password=$IG_PASS" \
        -X POST "https://www.instagram.com/accounts/login/ajax/" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -H "X-CSRFToken: 0" \
        -H "X-Requested-With: XMLHttpRequest" \
        -o /dev/null
    echo -e "${GREEN}[*] Login selesai, cookies disimpan di $COOKIE_FILE${RESET}"
}

get_user_id() {
    local username="$1"
    local id=$(curl -s -b $COOKIE_FILE -A "$USER_AGENT" \
        "https://www.instagram.com/$username/?__a=1" | grep -o '"id":"[0-9]*"' | head -1 | cut -d':' -f2 | tr -d '"')
    if [[ -z "$id" ]]; then
        echo -e "${RED}[!] Gagal ambil user_id $username${RESET}"
        return 1
    fi
    echo "$id"
}

progress_bar() {
    local duration=$1
    local i=0
    local total=30
    echo -n "["
    while [ $i -le $total ]; do
        sleep $(echo "$duration/$total" | bc -l)
        echo -n "#"
        i=$((i+1))
    done
    echo "] Done!"
}

follow_user() {
    local target_user="$1"
    local user_id=$(get_user_id $target_user)
    if [[ -z "$user_id" ]]; then return 1; fi
    echo -e "${YELLOW}[*] Follow $target_user dalam 3 detik...${RESET}"
    for i in 3 2 1; do echo -n "$i... "; sleep 1; done; echo
    curl -s -b $COOKIE_FILE -A "$USER_AGENT" \
        -X POST "https://www.instagram.com/web/friendships/$user_id/follow/" \
        -H "X-Requested-With: XMLHttpRequest" \
        -o /dev/null
    echo -e "${GREEN}[*] Progress follow $target_user:${RESET}"
    progress_bar 3
}

unfollow_user() {
    local target_user="$1"
    local user_id=$(get_user_id $target_user)
    if [[ -z "$user_id" ]]; then return 1; fi
    echo -e "${YELLOW}[*] Unfollow $target_user dalam 3 detik...${RESET}"
    for i in 3 2 1; do echo -n "$i... "; sleep 1; done; echo
    curl -s -b $COOKIE_FILE -A "$USER_AGENT" \
        -X POST "https://www.instagram.com/web/friendships/$user_id/unfollow/" \
        -H "X-Requested-With: XMLHttpRequest" \
        -o /dev/null
    echo -e "${GREEN}[*] Progress unfollow $target_user:${RESET}"
    progress_bar 3
}

auto_loop() {
    read -p "Masukkan username target list (pisah koma): " targets
    read -p "Delay per aksi (detik): " delay
    IFS=',' read -ra arr <<< "$targets"
    while true; do
        for username in "${arr[@]}"; do
            follow_user $username
            sleep $delay
            unfollow_user $username
            sleep $delay
        done
    done
}

# -----------------------------
# MAIN MENU
# -----------------------------
print_banner
while true; do
    echo -e "${CYAN}--------------------------------${RESET}"
    echo -e "${MAGENTA}Instagram Bot Menu${RESET}"
    echo -e "${CYAN}1) Login${RESET}"
    echo -e "${CYAN}2) Follow User${RESET}"
    echo -e "${CYAN}3) Unfollow User${RESET}"
    echo -e "${CYAN}4) Auto Follow/Unfollow Loop${RESET}"
    echo -e "${CYAN}5) Exit${RESET}"
    echo -e "${CYAN}--------------------------------${RESET}"
    read -p "Pilih: " choice
    case $choice in
        1) login ;;
        2) read -p "Username target: " target; follow_user $target ;;
        3) read -p "Username target: " target; unfollow_user $target ;;
        4) auto_loop ;;
        5) exit 0 ;;
        *) echo -e "${RED}[!] Pilihan salah${RESET}" ;;
    esac
done
