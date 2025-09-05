#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m'

update_system() {
    echo -e "${GREEN}Cập nhật hệ thống...${NC}"
    sudo apt update && sudo apt upgrade -y
}

install_certbot() {
    echo -e "${GREEN}Cài đặt Certbot...${NC}"
    sudo apt install -y certbot python3-certbot-nginx
}

install_redis() {
    echo -e "${GREEN}Cài đặt Redis...${NC}"
    sudo apt install -y redis-server
    sudo systemctl enable redis-server
}

install_docker() {
    echo -e "${GREEN}Cài đặt Docker + Compose...${NC}"
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo usermod -aG docker $USER
    echo -e "${GREEN}Docker cài xong. Hãy logout/login để áp dụng group docker.${NC}"
}

install_pm2() {
    echo -e "${GREEN}Cài Node.js + PM2...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
    sudo npm install -g pm2
}

install_git() {
    echo -e "${GREEN}Cài đặt Git...${NC}"
    sudo apt install -y git
}

install_postgres() {
    echo -e "${GREEN}Cài đặt PostgreSQL...${NC}"
    sudo apt install -y postgresql postgresql-contrib
    sudo systemctl enable postgresql
}

install_cloudpanel() {
    echo -e "${GREEN}Cài đặt CloudPanel...${NC}"
    curl -sSL https://installer.cloudpanel.io/ce/v2/install.sh | sudo bash
}

install_mysql() {
    echo -e "${GREEN}Cài đặt MySQL/MariaDB...${NC}"
    sudo apt install -y mariadb-server mariadb-client
    sudo systemctl enable mariadb
    sudo systemctl start mariadb
    echo -e "${GREEN}Bạn có thể chạy 'sudo mysql_secure_installation' để cấu hình bảo mật.${NC}"
}

install_sqlite() {
    echo -e "${GREEN}Cài đặt SQLite...${NC}"
    sudo apt install -y sqlite3 libsqlite3-dev
    echo -e "${GREEN}SQLite đã được cài đặt.${NC}"
}

show_menu() {
    echo -e "\n${GREEN}--- Chọn phần mềm cần cài (multi-select) ---${NC}"
    echo "1) Update hệ thống"
    echo "2) Certbot"
    echo "3) Redis"
    echo "4) Docker + Compose"
    echo "5) Node.js + PM2"
    echo "6) Git"
    echo "7) PostgreSQL"
    echo "8) CloudPanel"
    echo "9) MySQL/MariaDB"
    echo "10) SQLite"
    echo "11) Cài tất cả"
    echo "0) Thoát"
}

while true; do
    show_menu
    read -p "Nhập số (cách nhau bằng dấu phẩy hoặc khoảng trắng): " input

    # Thay dấu phẩy thành khoảng trắng rồi loop
    choices=$(echo $input | tr ',' ' ')

    for choice in $choices; do
        case $choice in
            1) update_system ;;
            2) install_certbot ;;
            3) install_redis ;;
            4) install_docker ;;
            5) install_pm2 ;;
            6) install_git ;;
            7) install_postgres ;;
            8) install_cloudpanel ;;
            9) install_mysql ;;
            10) install_sqlite ;;
            11) update_system; install_certbot; install_redis; install_docker; install_pm2; install_git; install_postgres; install_cloudpanel; install_mysql; install_sqlite ;;
            0) exit ;;
            *) echo "Lựa chọn $choice không hợp lệ!" ;;
        esac
    done
done
