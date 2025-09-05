#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Detect Ubuntu version
UBUNTU_VERSION=$(lsb_release -rs)

# Functions
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

update_system() {
    echo -e "${GREEN}Cập nhật hệ thống...${NC}"
    sudo apt update && sudo apt upgrade -y
    print_success "Hệ thống đã được cập nhật"
}

install_nginx() {
    echo -e "${GREEN}Cài đặt Nginx...${NC}"
    sudo apt install -y nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
    print_success "Nginx đã được cài đặt và khởi động"
}

install_certbot() {
    echo -e "${GREEN}Cài đặt Certbot...${NC}"
    sudo apt install -y certbot python3-certbot-nginx
    print_success "Certbot đã được cài đặt"
}

install_redis() {
    echo -e "${GREEN}Cài đặt Redis...${NC}"
    sudo apt install -y redis-server
    sudo systemctl enable redis-server
    sudo systemctl start redis-server
    print_success "Redis đã được cài đặt và khởi động"
}

install_docker() {
    echo -e "${GREEN}Cài đặt Docker + Compose...${NC}"
    
    # Remove old versions
    sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null
    
    # Install dependencies
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release
    
    # Add Docker GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    
    # Enable and start Docker
    sudo systemctl enable docker
    sudo systemctl start docker
    
    print_success "Docker đã được cài đặt"
    print_warning "Hãy logout/login để áp dụng group docker"
}

install_pm2() {
    echo -e "${GREEN}Cài Node.js + PM2...${NC}"
    
    # Install Node.js 20 LTS
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
    
    # Install PM2
    sudo npm install -g pm2
    
    # Setup PM2 to start on boot
    pm2 startup systemd -u $USER --hp /home/$USER
    
    print_success "Node.js và PM2 đã được cài đặt"
}

install_git() {
    echo -e "${GREEN}Cài đặt Git...${NC}"
    sudo apt install -y git
    print_success "Git đã được cài đặt"
}

install_postgres() {
    echo -e "${GREEN}Cài đặt PostgreSQL...${NC}"
    sudo apt install -y postgresql postgresql-contrib
    sudo systemctl enable postgresql
    sudo systemctl start postgresql
    print_success "PostgreSQL đã được cài đặt và khởi động"
}

install_cloudpanel_ubuntu22() {
    echo -e "${GREEN}Cài đặt CloudPanel cho Ubuntu 22.04...${NC}"
    
    PS3="Chọn Database Engine: "
    options=("MariaDB 11.4" "MariaDB 10.11" "MariaDB 10.6" "MySQL 8.0" "Quay lại")
    
    select opt in "${options[@]}"
    do
        case $opt in
            "MariaDB 11.4")
                curl -sS https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh
                echo "985bed747446eabad433c2e8115e21d6898628fa982c9e55ff6cd0d7c35b501d install.sh" | sha256sum -c && sudo DB_ENGINE=MARIADB_11.4 bash install.sh
                break
                ;;
            "MariaDB 10.11")
                curl -sS https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh
                echo "985bed747446eabad433c2e8115e21d6898628fa982c9e55ff6cd0d7c35b501d install.sh" | sha256sum -c && sudo DB_ENGINE=MARIADB_10.11 bash install.sh
                break
                ;;
            "MariaDB 10.6")
                curl -sS https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh
                echo "985bed747446eabad433c2e8115e21d6898628fa982c9e55ff6cd0d7c35b501d install.sh" | sha256sum -c && sudo DB_ENGINE=MARIADB_10.6 bash install.sh
                break
                ;;
            "MySQL 8.0")
                curl -sS https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh
                echo "985bed747446eabad433c2e8115e21d6898628fa982c9e55ff6cd0d7c35b501d install.sh" | sha256sum -c && sudo DB_ENGINE=MYSQL_8.0 bash install.sh
                break
                ;;
            "Quay lại")
                return
                ;;
            *)
                echo "Lựa chọn không hợp lệ"
                ;;
        esac
    done
    
    print_success "CloudPanel đã được cài đặt"
    print_warning "CloudPanel đã bao gồm: Nginx, PHP, MySQL/MariaDB, phpMyAdmin, ..."
}

install_cloudpanel_ubuntu24() {
    echo -e "${GREEN}Cài đặt CloudPanel cho Ubuntu 24.04...${NC}"
    
    PS3="Chọn Database Engine: "
    options=("MariaDB 11.4" "MariaDB 10.11" "MySQL 8.0" "MySQL 8.4" "Quay lại")
    
    select opt in "${options[@]}"
    do
        case $opt in
            "MariaDB 11.4")
                curl -sS https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh
                echo "985bed747446eabad433c2e8115e21d6898628fa982c9e55ff6cd0d7c35b501d install.sh" | sha256sum -c && sudo DB_ENGINE=MARIADB_11.4 bash install.sh
                break
                ;;
            "MariaDB 10.11")
                curl -sS https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh
                echo "985bed747446eabad433c2e8115e21d6898628fa982c9e55ff6cd0d7c35b501d install.sh" | sha256sum -c && sudo DB_ENGINE=MARIADB_10.11 bash install.sh
                break
                ;;
            "MySQL 8.0")
                curl -sS https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh
                echo "985bed747446eabad433c2e8115e21d6898628fa982c9e55ff6cd0d7c35b501d install.sh" | sha256sum -c && sudo DB_ENGINE=MYSQL_8.0 bash install.sh
                break
                ;;
            "MySQL 8.4")
                curl -sS https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh
                echo "985bed747446eabad433c2e8115e21d6898628fa982c9e55ff6cd0d7c35b501d install.sh" | sha256sum -c && sudo DB_ENGINE=MYSQL_8.4 bash install.sh
                break
                ;;
            "Quay lại")
                return
                ;;
            *)
                echo "Lựa chọn không hợp lệ"
                ;;
        esac
    done
    
    print_success "CloudPanel đã được cài đặt"
    print_warning "CloudPanel đã bao gồm: Nginx, PHP, MySQL/MariaDB, phpMyAdmin, ..."
}

install_cloudpanel() {
    if [[ "$UBUNTU_VERSION" == "22.04" ]]; then
        install_cloudpanel_ubuntu22
    elif [[ "$UBUNTU_VERSION" == "24.04" ]]; then
        install_cloudpanel_ubuntu24
    else
        print_warning "CloudPanel chỉ hỗ trợ Ubuntu 22.04 và 24.04"
        print_warning "Đang thử cài đặt với script mặc định..."
        curl -sSL https://installer.cloudpanel.io/ce/v2/install.sh | sudo bash
    fi
}

install_mysql_standalone() {
    echo -e "${GREEN}Cài đặt MySQL/MariaDB độc lập...${NC}"
    sudo apt install -y mariadb-server mariadb-client
    sudo systemctl enable mariadb
    sudo systemctl start mariadb
    print_success "MariaDB đã được cài đặt"
    print_warning "Chạy 'sudo mysql_secure_installation' để cấu hình bảo mật"
}

install_sqlite() {
    echo -e "${GREEN}Cài đặt SQLite...${NC}"
    sudo apt install -y sqlite3 libsqlite3-dev
    print_success "SQLite đã được cài đặt"
}

install_php() {
    echo -e "${GREEN}Cài đặt PHP và các module phổ biến...${NC}"
    sudo apt install -y php php-fpm php-mysql php-xml php-curl php-gd php-mbstring php-zip php-bcmath php-json php-intl
    print_success "PHP đã được cài đặt"
}

install_composer() {
    echo -e "${GREEN}Cài đặt Composer...${NC}"
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    sudo chmod +x /usr/local/bin/composer
    print_success "Composer đã được cài đặt"
}

install_yarn() {
    echo -e "${GREEN}Cài đặt Yarn...${NC}"
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update && sudo apt install -y yarn
    print_success "Yarn đã được cài đặt"
}

install_fail2ban() {
    echo -e "${GREEN}Cài đặt Fail2ban...${NC}"
    sudo apt install -y fail2ban
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
    print_success "Fail2ban đã được cài đặt và khởi động"
}

install_ufw() {
    echo -e "${GREEN}Cài đặt và cấu hình UFW Firewall...${NC}"
    sudo apt install -y ufw
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    print_success "UFW đã được cài đặt"
    print_warning "Chạy 'sudo ufw enable' để kích hoạt firewall"
}

show_menu() {
    echo -e "\n${GREEN}===== SCRIPT CÀI ĐẶT CHO UBUNTU $UBUNTU_VERSION =====${NC}"
    echo -e "${YELLOW}Lưu ý: CloudPanel đã bao gồm Nginx, PHP, MySQL/MariaDB${NC}\n"
    
    echo "--- Hệ thống cơ bản ---"
    echo "1) Update hệ thống"
    echo "2) Git + Cấu hình"
    
    echo -e "\n--- Web Server & Database ---"
    echo "3) CloudPanel (đã có Nginx, PHP, MySQL)"
    echo "4) Nginx (độc lập)"
    echo "5) MySQL/MariaDB (độc lập)"
    echo "6) PostgreSQL"
    echo "7) SQLite"
    echo "8) Redis"
    
    echo -e "\n--- Development Tools ---"
    echo "9) PHP (8.2/8.3/8.4) + Full Extensions"
    echo "10) Composer (Latest)"
    echo "11) Node.js (via NVM) + PM2"
    echo "12) Yarn"
    echo "13) Docker + Compose"
    
    echo -e "\n--- Security & SSL ---"
    echo "14) Certbot (Let's Encrypt)"
    echo "15) Fail2ban"
    echo "16) UFW Firewall"
    
    echo -e "\n--- Cài đặt nhanh ---"
    echo "20) Cài CloudPanel + Tools cơ bản"
    echo "21) Cài LEMP Stack (Nginx, MySQL, PHP 8.3)"
    echo "22) Cài Full Stack Development"
    echo "99) Cài tất cả"
    
    echo -e "\n0) Thoát"
}

install_cloudpanel_basic() {
    update_system
    install_git
    install_cloudpanel
    install_redis
    install_certbot
    install_fail2ban
    install_ufw
}

install_lemp_stack() {
    update_system
    install_nginx
    install_mysql_standalone
    install_php
    install_composer
    install_certbot
}

install_full_dev() {
    update_system
    install_git
    install_docker
    install_pm2
    install_redis
    install_postgres
    install_sqlite
    install_composer
    install_yarn
}

# Main menu loop
while true; do
    show_menu
    read -p "Nhập số (có thể chọn nhiều, cách nhau bằng dấu phẩy): " input
    
    # Convert comma to space and process choices
    choices=$(echo $input | tr ',' ' ')
    
    for choice in $choices; do
        case $choice in
            1) update_system ;;
            2) install_git ;;
            3) install_cloudpanel ;;
            4) install_nginx ;;
            5) install_mysql_standalone ;;
            6) install_postgres ;;
            7) install_sqlite ;;
            8) install_redis ;;
            9) install_php ;;
            10) install_composer ;;
            11) install_pm2 ;;
            12) install_yarn ;;
            13) install_docker ;;
            14) install_certbot ;;
            15) install_fail2ban ;;
            16) install_ufw ;;
            20) install_cloudpanel_basic ;;
            21) install_lemp_stack ;;
            22) install_full_dev ;;
            99) 
                update_system
                install_git
                install_cloudpanel
                install_redis
                install_docker
                install_pm2
                install_postgres
                install_sqlite
                install_certbot
                install_fail2ban
                install_ufw
                install_composer
                install_yarn
                ;;
            0) 
                echo -e "${GREEN}Cảm ơn đã sử dụng script!${NC}"
                exit 0
                ;;
            *) 
                print_error "Lựa chọn $choice không hợp lệ!"
                ;;
        esac
    done
    
    echo -e "\n${GREEN}Hoàn thành!${NC}"
    read -p "Nhấn Enter để tiếp tục..."
done
