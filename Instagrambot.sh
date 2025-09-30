#!/bin/bash
# Instagram Bot Script v3.6 Aman + Cookie Manual
# by developer Dikha Pormes
# Jangan disebarkan tanpa izin

# -----------------------------
# AUTO INSTALL DEPENDENCIES
# -----------------------------
install_dependencies() {
    echo -e "\033[36m[INFO] Mengecek paket yang dibutuhkan...\033[0m"
    packages=("bash" "curl" "bc")
    for pkg in "${packages[@]}"; do
        if ! command -v $pkg &> /dev/null; then
            echo -e "\033[33m[INFO] Paket $pkg belum terpasang, menginstal...\033[0m"
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y $pkg
            elif command -v pkg &> /dev/null; then
                pkg install -y $pkg
            else
                echo -e "\033[31m[ERROR] Tidak menemukan package manager (apt/pkg). Pasang paket $pkg manual.\033[0m"
                exit 1
            fi
        else
            echo -e "\033[32m[INFO] Paket $pkg sudah terpasang\033[0m"
        fi
    done
}
install_dependencies

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
cat << EOF
${CYAN}🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
${MAGENTA}      📸 InstaBot v3.6 Aman 📸      
${CYAN}🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
${YELLOW}Follow/Unfollow otomatis + animasi RPG
${GREEN}💖 Buat akun kamu lebih aktif 💖
${RED}✍️ by developer Dikha Pormes, jangan disebarkan tanpa izin
EOF
echo -e "${RESET}"
}

check_cookie() {
    if [[ ! -f $COOKIE_FILE ]]; then
        echo -e "${RED}[!] File cookie $COOKIE_FILE tidak ditemukan.${RESET}"
        echo -e "${YELLOW}→ Cara: login di browser, export sessionid, simpan di $COOKIE_FILE${RESET}"
        exit 1
    fi
}

get_user_id() {
    local username="$1"
    local id=$(curl -s -b $COOKIE_FILE -A "$USER_AGENT" \
        "https://www.instagram.com/$username/?__a=1" | grep -o '"id":"[0-9]*"' | head -1 | cut -d':' -f2 | tr -d '"')
    if [[ -z "$id" ]]; then
        echo -e "${RED}❌ Gagal ambil user_id $username${RESET}"
        return 1
    fi
    echo "$id"
}

countdown_cinematic() {
    local seconds=$1
    local action=$2
    local emojis=("⏳" "⌛" "💫" "🌟" "✨" "🔥" "💖" "🌈" "🎆")
    for ((i=seconds;i>0;i--)); do
        emoji=${emojis[$RANDOM % ${#emojis[@]}]}
        colors=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)
        color=${colors[$RANDOM % ${#colors[@]}]}
        echo -ne "\r${color}$emoji $action in $i... ✨✨✨${RESET}"
        sleep 1
    done
    echo -e "\r${GREEN}✅ $action sekarang!          ${RESET}"
}

progress_bar_rpg() {
    local duration=$1
    local total=30
    local frames=("💖" "💛" "💚" "💙" "💜" "🧡" "✨" "🌟" "🔥" "🌈")
    for i in $(seq 0 $total); do
        sleep $(echo "$duration/$total" | bc -l)
        percent=$((i * 100 / total))
        echo -ne "\r["
        for j in $(seq 1 $i); do
            echo -n "${frames[$RANDOM % ${#frames[@]}]}"
        done
        for j in $(seq $i $total); do
            echo -n "✨"
        done
        echo -n "] $percent% "
    done
    echo -e "\n${GREEN}🎉 Done!${RESET}"
}

follow_user() {
    check_cookie
    local target_user="$1"
    local user_id=$(get_user_id $target_user)
    if [[ -z "$user_id" ]]; then return 1; fi
    countdown_cinematic 3 "Follow $target_user"
    curl -s -b $COOKIE_FILE -A "$USER_AGENT" \
        -X POST "https://www.instagram.com/web/friendships/$user_id/follow/" \
        -H "X-Requested-With: XMLHttpRequest" \
        -o /dev/null
    progress_bar_rpg 3
    sleep $((10 + RANDOM % 11))
}

unfollow_user() {
    check_cookie
    local target_user="$1"
    local user_id=$(get_user_id $target_user)
    if [[ -z "$user_id" ]]; then return 1; fi
    countdown_cinematic 3 "Unfollow $target_user"
    curl -s -b $COOKIE_FILE -A "$USER_AGENT" \
        -X POST "https://www.instagram.com/web/friendships/$user_id/unfollow/" \
        -H "X-Requested-With: XMLHttpRequest" \
        -o /dev/null
    progress_bar_rpg 3
    sleep $((10 + RANDOM % 11))
}

auto_loop() {
    read -p "Masukkan username target list (pisah koma): " targets
    read -p "Delay per loop tambahan (detik, misal 15-30): " loop_delay
    IFS=',' read -ra arr <<< "$targets"
    while true; do
        for username in "${arr[@]}"; do
            follow_user $username
            unfollow_user $username
        done
        echo -e "${YELLOW}⏳ Istirahat sebentar sebelum loop berikutnya...${RESET}"
        sleep $((loop_delay + RANDOM % 16))
    done
}

# -----------------------------
# MAIN MENU
# -----------------------------
print_banner
while true; do
    echo -e "${CYAN}--------------------------------${RESET}"
    echo -e "${MAGENTA}📋 Menu InstaBot v3.6 Aman${RESET}"
    echo -e "${CYAN}1) Gunakan Cookie Manual 🔑${RESET}"
    echo -e "${CYAN}2) Follow User ➕${RESET}"
    echo -e "${CYAN}3) Unfollow User ➖${RESET}"
    echo -e "${CYAN}4) Auto Follow/Unfollow Loop 🔄${RESET}"
    echo -e "${CYAN}5) Exit ❌${RESET}"
    echo -e "${CYAN}--------------------------------${RESET}"
    read -p "Pilih: " choice
    case $choice in
        1) echo -e "${GREEN}✅ Pastikan $COOKIE_FILE sudah diisi sessionid dari browser.${RESET}" ;;
        2) read -p "Username target: " target; follow_user $target ;;
        3) read -p "Username target: " target; unfollow_user $target ;;
        4) auto_loop ;;
        5) exit 0 ;;
        *) echo -e "${RED}❌ Pilihan salah${RESET}" ;;
    esac
done
