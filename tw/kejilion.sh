#!/bin/bash
sh_v="4.4.9"


gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_bai='\033[0m'
gl_zi='\033[35m'
gl_kjlan='\033[96m'


canshu="default"
permission_granted="false"
ENABLE_STATS="true"


quanju_canshu() {
if [ "$canshu" = "CN" ]; then
	zhushi=0
	gh_proxy="https://gh.kejilion.pro/"
elif [ "$canshu" = "V6" ]; then
	zhushi=1
	gh_proxy="https://gh.kejilion.pro/"
else
	zhushi=1  # 0 表示执行，1 表示不执行
	gh_proxy="https://"
fi

gh_https_url="https://"

}
quanju_canshu



# 定義一個函數來執行命令
run_command() {
	if [ "$zhushi" -eq 0 ]; then
		"$@"
	fi
}


canshu_v6() {
	if grep -q '^canshu="V6"' /usr/local/bin/k > /dev/null 2>&1; then
		sed -i 's/^canshu="default"/canshu="V6"/' ~/kejilion.sh
	fi
}


CheckFirstRun_true() {
	if grep -q '^permission_granted="true"' /usr/local/bin/k > /dev/null 2>&1; then
		sed -i 's/^permission_granted="false"/permission_granted="true"/' ~/kejilion.sh
	fi
}



# 收集功能埋藏資訊的函數，記錄當前腳本版本號，使用時間，系統版本，CPU架構，機器所在國家和用戶使用的功能名稱，絕對不涉及任何敏感信息，請放心！請相信我！
# 為什麼要設計這個功能，目的更好的了解使用者喜歡使用的功能，進一步優化功能推出更多符合使用者需求的功能。
# 全文可搜尋 send_stats 函數呼叫位置，透明開源，如有顧慮可拒絕使用。



send_stats() {
	if [ "$ENABLE_STATS" == "false" ]; then
		return
	fi

	local country=$(curl -s ipinfo.io/country)
	local os_info=$(grep PRETTY_NAME /etc/os-release | cut -d '=' -f2 | tr -d '"')
	local cpu_arch=$(uname -m)

	(
		curl -s -X POST "https://api.kejilion.pro/api/log" \
			-H "Content-Type: application/json" \
			-d "{\"action\":\"$1\",\"timestamp\":\"$(date -u '+%Y-%m-%d %H:%M:%S')\",\"country\":\"$country\",\"os_info\":\"$os_info\",\"cpu_arch\":\"$cpu_arch\",\"version\":\"$sh_v\"}" \
		&>/dev/null
	) &

}


yinsiyuanquan2() {

if grep -q '^ENABLE_STATS="false"' /usr/local/bin/k > /dev/null 2>&1; then
	sed -i 's/^ENABLE_STATS="true"/ENABLE_STATS="false"/' ~/kejilion.sh
fi

}



canshu_v6
CheckFirstRun_true
yinsiyuanquan2


sed -i '/^alias k=/d' ~/.bashrc > /dev/null 2>&1
sed -i '/^alias k=/d' ~/.profile > /dev/null 2>&1
sed -i '/^alias k=/d' ~/.bash_profile > /dev/null 2>&1
cp -f ./kejilion.sh ~/kejilion.sh > /dev/null 2>&1
cp -f ~/kejilion.sh /usr/local/bin/k > /dev/null 2>&1
ln -sf /usr/local/bin/k /usr/bin/k > /dev/null 2>&1



CheckFirstRun_false() {
	if grep -q '^permission_granted="false"' /usr/local/bin/k > /dev/null 2>&1; then
		UserLicenseAgreement
	fi
}

# 提示使用者同意條款
UserLicenseAgreement() {
	clear
	echo -e "${gl_kjlan}歡迎使用科技lion腳本工具箱${gl_bai}"
	echo "首次使用腳本，請先閱讀並同意使用者授權協議。"
	echo "使用者授權協議: https://blog.kejilion.pro/user-license-agreement/"
	echo -e "----------------------"
	read -e -p "是否同意以上條款？ (y/n):" user_input


	if [ "$user_input" = "y" ] || [ "$user_input" = "Y" ]; then
		send_stats "許可同意"
		sed -i 's/^permission_granted="false"/permission_granted="true"/' ~/kejilion.sh
		sed -i 's/^permission_granted="false"/permission_granted="true"/' /usr/local/bin/k
	else
		send_stats "許可拒絕"
		clear
		exit
	fi
}

CheckFirstRun_false





ip_address() {

get_public_ip() {
	curl -s https://ipinfo.io/ip && echo
}

get_local_ip() {
	ip route get 8.8.8.8 2>/dev/null | grep -oP 'src \K[^ ]+' || \
	hostname -I 2>/dev/null | awk '{print $1}' || \
	ifconfig 2>/dev/null | grep -E 'inet [0-9]' | grep -v '127.0.0.1' | awk '{print $2}' | head -n1
}

public_ip=$(get_public_ip)
isp_info=$(curl -s --max-time 3 http://ipinfo.io/org)


if echo "$isp_info" | grep -Eiq 'CHINANET|mobile|unicom|telecom'; then
  ipv4_address=$(get_local_ip)
else
  ipv4_address="$public_ip"
fi


# ipv4_address=$(curl -s https://ipinfo.io/ip && echo)
ipv6_address=$(curl -s --max-time 1 https://v6.ipinfo.io/ip && echo)

}



install() {
	if [ $# -eq 0 ]; then
		echo "未提供軟體包參數!"
		return 1
	fi

	for package in "$@"; do
		if ! command -v "$package" &>/dev/null; then
			echo -e "${gl_kjlan}正在安裝$package...${gl_bai}"
			if command -v dnf &>/dev/null; then
				dnf -y update
				dnf install -y epel-release
				dnf install -y "$package"
			elif command -v yum &>/dev/null; then
				yum -y update
				yum install -y epel-release
				yum install -y "$package"
			elif command -v apt &>/dev/null; then
				apt update -y
				apt install -y "$package"
			elif command -v apk &>/dev/null; then
				apk update
				apk add "$package"
			elif command -v pacman &>/dev/null; then
				pacman -Syu --noconfirm
				pacman -S --noconfirm "$package"
			elif command -v zypper &>/dev/null; then
				zypper refresh
				zypper install -y "$package"
			elif command -v opkg &>/dev/null; then
				opkg update
				opkg install "$package"
			elif command -v pkg &>/dev/null; then
				pkg update
				pkg install -y "$package"
			else
				echo "未知的套件管理器!"
				return 1
			fi
		fi
	done
}


check_disk_space() {
	local required_gb=$1
	local path=${2:-/}

	mkdir -p "$path"

	local required_space_mb=$((required_gb * 1024))
	local available_space_mb=$(df -m "$path" | awk 'NR==2 {print $4}')

	if [ "$available_space_mb" -lt "$required_space_mb" ]; then
		echo -e "${gl_huang}提示:${gl_bai}磁碟空間不足！"
		echo "目前可用空間: $((available_space_mb/1024))G"
		echo "最小需求空間:${required_gb}G"
		echo "無法繼續安裝，請清理磁碟空間後重試。"
		send_stats "磁碟空間不足"
		break_end
		kejilion
	fi
}



install_dependency() {
	switch_mirror false false
	check_port
	check_swap
	prefer_ipv4
	auto_optimize_dns
	install wget unzip tar jq grep

}

remove() {
	if [ $# -eq 0 ]; then
		echo "未提供軟體包參數!"
		return 1
	fi

	for package in "$@"; do
		echo -e "${gl_kjlan}正在卸載$package...${gl_bai}"
		if command -v dnf &>/dev/null; then
			dnf remove -y "$package"
		elif command -v yum &>/dev/null; then
			yum remove -y "$package"
		elif command -v apt &>/dev/null; then
			apt purge -y "$package"
		elif command -v apk &>/dev/null; then
			apk del "$package"
		elif command -v pacman &>/dev/null; then
			pacman -Rns --noconfirm "$package"
		elif command -v zypper &>/dev/null; then
			zypper remove -y "$package"
		elif command -v opkg &>/dev/null; then
			opkg remove "$package"
		elif command -v pkg &>/dev/null; then
			pkg delete -y "$package"
		else
			echo "未知的套件管理器!"
			return 1
		fi
	done
}


# 通用 systemctl 函數，適用於各種發行版
systemctl() {
	local COMMAND="$1"
	local SERVICE_NAME="$2"

	if command -v apk &>/dev/null; then
		service "$SERVICE_NAME" "$COMMAND"
	else
		/bin/systemctl "$COMMAND" "$SERVICE_NAME"
	fi
}


# 重啟服務
restart() {
	systemctl restart "$1"
	if [ $? -eq 0 ]; then
		echo "$1服務已重啟。"
	else
		echo "錯誤：重啟$1服務失敗。"
	fi
}

# 啟動服務
start() {
	systemctl start "$1"
	if [ $? -eq 0 ]; then
		echo "$1服務已啟動。"
	else
		echo "錯誤：啟動$1服務失敗。"
	fi
}

# 停止服務
stop() {
	systemctl stop "$1"
	if [ $? -eq 0 ]; then
		echo "$1服務已停止。"
	else
		echo "錯誤：停止$1服務失敗。"
	fi
}

# 查看服務狀態
status() {
	systemctl status "$1"
	if [ $? -eq 0 ]; then
		echo "$1服務狀態已顯示。"
	else
		echo "錯誤：無法顯示$1服務狀態。"
	fi
}


enable() {
	local SERVICE_NAME="$1"
	if command -v apk &>/dev/null; then
		rc-update add "$SERVICE_NAME" default
	else
	   /bin/systemctl enable "$SERVICE_NAME"
	fi

	echo "$SERVICE_NAME已設定為開機自啟動。"
}



break_end() {
	  echo -e "${gl_lv}操作完成${gl_bai}"
	  echo "按任意鍵繼續..."
	  read -n 1 -s -r -p ""
	  echo ""
	  clear
}

kejilion() {
			cd ~
			kejilion_sh
}




stop_containers_or_kill_process() {
	local port=$1
	local containers=$(docker ps --filter "publish=$port" --format "{{.ID}}" 2>/dev/null)

	if [ -n "$containers" ]; then
		docker stop $containers
	else
		install lsof
		for pid in $(lsof -t -i:$port); do
			kill -9 $pid
		done
	fi
}


check_port() {
	stop_containers_or_kill_process 80
	stop_containers_or_kill_process 443
}


install_add_docker_cn() {

local country=$(curl -s ipinfo.io/country)
if [ "$country" = "CN" ]; then
	cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": [
	"https://docker.1ms.run",
	"https://docker.m.ixdev.cn",
	"https://hub.rat.dev",
	"https://dockerproxy.net",
	"https://docker-registry.nmqu.com",
	"https://docker.amingg.com",
	"https://docker.hlmirror.com",
	"https://hub1.nat.tf",
	"https://hub2.nat.tf",
	"https://hub3.nat.tf",
	"https://docker.m.daocloud.io",
	"https://docker.kejilion.pro",
	"https://docker.367231.xyz",
	"https://hub.1panel.dev",
	"https://dockerproxy.cool",
	"https://docker.apiba.cn",
	"https://proxy.vvvv.ee"
  ]
}
EOF
fi


enable docker
start docker
restart docker

}



linuxmirrors_install_docker() {

local country=$(curl -s ipinfo.io/country)
if [ "$country" = "CN" ]; then
	bash <(curl -sSL https://linuxmirrors.cn/docker.sh) \
	  --source mirrors.huaweicloud.com/docker-ce \
	  --source-registry docker.1ms.run \
	  --protocol https \
	  --use-intranet-source false \
	  --install-latest true \
	  --close-firewall false \
	  --ignore-backup-tips
else
	bash <(curl -sSL https://linuxmirrors.cn/docker.sh) \
	  --source download.docker.com \
	  --source-registry registry.hub.docker.com \
	  --protocol https \
	  --use-intranet-source false \
	  --install-latest true \
	  --close-firewall false \
	  --ignore-backup-tips
fi

install_add_docker_cn

}



install_add_docker() {
	echo -e "${gl_kjlan}正在安裝docker環境...${gl_bai}"
	if command -v apt &>/dev/null || command -v yum &>/dev/null || command -v dnf &>/dev/null; then
		linuxmirrors_install_docker
	else
		install docker docker-compose
		install_add_docker_cn

	fi
	sleep 2
}


install_docker() {
	if ! command -v docker &>/dev/null; then
		install_add_docker
	fi
}


docker_ps() {
while true; do
	clear
	send_stats "Docker容器管理"
	echo "Docker容器列表"
	docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
	echo ""
	echo "容器操作"
	echo "------------------------"
	echo "1. 建立新的容器"
	echo "------------------------"
	echo "2. 啟動指定容器 6. 啟動所有容器"
	echo "3. 停止指定容器 7. 停止所有容器"
	echo "4. 刪除指定容器 8. 刪除所有容器"
	echo "5. 重啟指定容器 9. 重新啟動所有容器"
	echo "------------------------"
	echo "11. 進入指定容器 12. 查看容器日誌"
	echo "13. 查看容器網路 14. 查看容器佔用"
	echo "------------------------"
	echo "15. 開啟容器連接埠存取 16. 關閉容器連接埠訪問"
	echo "------------------------"
	echo "0. 返回上一級選單"
	echo "------------------------"
	read -e -p "請輸入你的選擇:" sub_choice
	case $sub_choice in
		1)
			send_stats "新容器"
			read -e -p "請輸入建立命令:" dockername
			$dockername
			;;
		2)
			send_stats "啟動指定容器"
			read -e -p "請輸入容器名稱（多個容器名稱請以空格分隔）:" dockername
			docker start $dockername
			;;
		3)
			send_stats "停止指定容器"
			read -e -p "請輸入容器名稱（多個容器名稱請以空格分隔）:" dockername
			docker stop $dockername
			;;
		4)
			send_stats "刪除指定容器"
			read -e -p "請輸入容器名稱（多個容器名稱請以空格分隔）:" dockername
			docker rm -f $dockername
			;;
		5)
			send_stats "重啟指定容器"
			read -e -p "請輸入容器名稱（多個容器名稱請以空格分隔）:" dockername
			docker restart $dockername
			;;
		6)
			send_stats "啟動所有容器"
			docker start $(docker ps -a -q)
			;;
		7)
			send_stats "停止所有容器"
			docker stop $(docker ps -q)
			;;
		8)
			send_stats "刪除所有容器"
			read -e -p "$(echo -e "${gl_hong}注意: ${gl_bai}确定删除所有容器吗？(Y/N): ")" choice
			case "$choice" in
			  [Yy])
				docker rm -f $(docker ps -a -q)
				;;
			  [Nn])
				;;
			  *)
				echo "無效的選擇，請輸入 Y 或 N。"
				;;
			esac
			;;
		9)
			send_stats "重啟所有容器"
			docker restart $(docker ps -q)
			;;
		11)
			send_stats "進入容器"
			read -e -p "請輸入容器名稱:" dockername
			docker exec -it $dockername /bin/sh
			break_end
			;;
		12)
			send_stats "查看容器日誌"
			read -e -p "請輸入容器名稱:" dockername
			docker logs $dockername
			break_end
			;;
		13)
			send_stats "查看容器網絡"
			echo ""
			container_ids=$(docker ps -q)
			echo "------------------------------------------------------------"
			printf "%-25s %-25s %-25s\n" "容器名稱" "網路名稱" "IP位址"
			for container_id in $container_ids; do
				local container_info=$(docker inspect --format '{{ .Name }}{{ range $network, $config := .NetworkSettings.Networks }} {{ $network }} {{ $config.IPAddress }}{{ end }}' "$container_id")
				local container_name=$(echo "$container_info" | awk '{print $1}')
				local network_info=$(echo "$container_info" | cut -d' ' -f2-)
				while IFS= read -r line; do
					local network_name=$(echo "$line" | awk '{print $1}')
					local ip_address=$(echo "$line" | awk '{print $2}')
					printf "%-20s %-20s %-15s\n" "$container_name" "$network_name" "$ip_address"
				done <<< "$network_info"
			done
			break_end
			;;
		14)
			send_stats "查看容器佔用"
			docker stats --no-stream
			break_end
			;;

		15)
			send_stats "允許容器連接埠訪問"
			read -e -p "請輸入容器名稱:" docker_name
			ip_address
			clear_container_rules "$docker_name" "$ipv4_address"
			local docker_port=$(docker port $docker_name | awk -F'[:]' '/->/ {print $NF}' | uniq)
			check_docker_app_ip
			break_end
			;;

		16)
			send_stats "阻止容器連接埠訪問"
			read -e -p "請輸入容器名稱:" docker_name
			ip_address
			block_container_port "$docker_name" "$ipv4_address"
			local docker_port=$(docker port $docker_name | awk -F'[:]' '/->/ {print $NF}' | uniq)
			check_docker_app_ip
			break_end
			;;

		*)
			break  # 跳出循环，退出菜单
			;;
	esac
done
}


docker_image() {
while true; do
	clear
	send_stats "Docker映像管理"
	echo "Docker映像列表"
	docker image ls
	echo ""
	echo "鏡像操作"
	echo "------------------------"
	echo "1. 取得指定鏡像 3. 刪除指定鏡像"
	echo "2. 更新指定鏡像 4. 刪除所有鏡像"
	echo "------------------------"
	echo "0. 返回上一級選單"
	echo "------------------------"
	read -e -p "請輸入你的選擇:" sub_choice
	case $sub_choice in
		1)
			send_stats "拉取鏡像"
			read -e -p "請輸入鏡像名稱（多個鏡像名稱請以空格分隔）:" imagenames
			for name in $imagenames; do
				echo -e "${gl_kjlan}正在取得鏡像:$name${gl_bai}"
				docker pull $name
			done
			;;
		2)
			send_stats "更新鏡像"
			read -e -p "請輸入鏡像名稱（多個鏡像名稱請以空格分隔）:" imagenames
			for name in $imagenames; do
				echo -e "${gl_kjlan}正在更新鏡像:$name${gl_bai}"
				docker pull $name
			done
			;;
		3)
			send_stats "刪除鏡像"
			read -e -p "請輸入鏡像名稱（多個鏡像名稱請以空格分隔）:" imagenames
			for name in $imagenames; do
				docker rmi -f $name
			done
			;;
		4)
			send_stats "刪除所有鏡像"
			read -e -p "$(echo -e "${gl_hong}注意: ${gl_bai}确定删除所有镜像吗？(Y/N): ")" choice
			case "$choice" in
			  [Yy])
				docker rmi -f $(docker images -q)
				;;
			  [Nn])
				;;
			  *)
				echo "無效的選擇，請輸入 Y 或 N。"
				;;
			esac
			;;
		*)
			break  # 跳出循环，退出菜单
			;;
	esac
done


}





check_crontab_installed() {
	if ! command -v crontab >/dev/null 2>&1; then
		install_crontab
	fi
}



install_crontab() {

	if [ -f /etc/os-release ]; then
		. /etc/os-release
		case "$ID" in
			ubuntu|debian|kali)
				apt update
				apt install -y cron
				systemctl enable cron
				systemctl start cron
				;;
			centos|rhel|almalinux|rocky|fedora)
				yum install -y cronie
				systemctl enable crond
				systemctl start crond
				;;
			alpine)
				apk add --no-cache cronie
				rc-update add crond
				rc-service crond start
				;;
			arch|manjaro)
				pacman -S --noconfirm cronie
				systemctl enable cronie
				systemctl start cronie
				;;
			opensuse|suse|opensuse-tumbleweed)
				zypper install -y cron
				systemctl enable cron
				systemctl start cron
				;;
			iStoreOS|openwrt|ImmortalWrt|lede)
				opkg update
				opkg install cron
				/etc/init.d/cron enable
				/etc/init.d/cron start
				;;
			FreeBSD)
				pkg install -y cronie
				sysrc cron_enable="YES"
				service cron start
				;;
			*)
				echo "不支援的發行版:$ID"
				return
				;;
		esac
	else
		echo "無法確定作業系統。"
		return
	fi

	echo -e "${gl_lv}crontab 已安裝且 cron 服務正在執行。${gl_bai}"
}



docker_ipv6_on() {
	root_use
	install jq

	local CONFIG_FILE="/etc/docker/daemon.json"
	local REQUIRED_IPV6_CONFIG='{"ipv6": true, "fixed-cidr-v6": "2001:db8:1::/64"}'

	# 檢查設定檔是否存在，如果不存在則建立檔案並寫入預設設定
	if [ ! -f "$CONFIG_FILE" ]; then
		echo "$REQUIRED_IPV6_CONFIG" | jq . > "$CONFIG_FILE"
		restart docker
	else
		# 使用jq處理設定檔的更新
		local ORIGINAL_CONFIG=$(<"$CONFIG_FILE")

		# 檢查目前配置是否已經有 ipv6 設定
		local CURRENT_IPV6=$(echo "$ORIGINAL_CONFIG" | jq '.ipv6 // false')

		# 更新配置，開啟 IPv6
		if [[ "$CURRENT_IPV6" == "false" ]]; then
			UPDATED_CONFIG=$(echo "$ORIGINAL_CONFIG" | jq '. + {ipv6: true, "fixed-cidr-v6": "2001:db8:1::/64"}')
		else
			UPDATED_CONFIG=$(echo "$ORIGINAL_CONFIG" | jq '. + {"fixed-cidr-v6": "2001:db8:1::/64"}')
		fi

		# 比較原始配置與新配置
		if [[ "$ORIGINAL_CONFIG" == "$UPDATED_CONFIG" ]]; then
			echo -e "${gl_huang}目前已開啟ipv6訪問${gl_bai}"
		else
			echo "$UPDATED_CONFIG" | jq . > "$CONFIG_FILE"
			restart docker
		fi
	fi
}


docker_ipv6_off() {
	root_use
	install jq

	local CONFIG_FILE="/etc/docker/daemon.json"

	# 檢查設定檔是否存在
	if [ ! -f "$CONFIG_FILE" ]; then
		echo -e "${gl_hong}設定檔不存在${gl_bai}"
		return
	fi

	# 讀取目前配置
	local ORIGINAL_CONFIG=$(<"$CONFIG_FILE")

	# 使用jq處理設定檔的更新
	local UPDATED_CONFIG=$(echo "$ORIGINAL_CONFIG" | jq 'del(.["fixed-cidr-v6"]) | .ipv6 = false')

	# 檢查目前的 ipv6 狀態
	local CURRENT_IPV6=$(echo "$ORIGINAL_CONFIG" | jq -r '.ipv6 // false')

	# 比較原始配置與新配置
	if [[ "$CURRENT_IPV6" == "false" ]]; then
		echo -e "${gl_huang}目前已關閉ipv6訪問${gl_bai}"
	else
		echo "$UPDATED_CONFIG" | jq . > "$CONFIG_FILE"
		restart docker
		echo -e "${gl_huang}已成功關閉ipv6訪問${gl_bai}"
	fi
}



save_iptables_rules() {
	mkdir -p /etc/iptables
	touch /etc/iptables/rules.v4
	iptables-save > /etc/iptables/rules.v4
	check_crontab_installed
	crontab -l | grep -v 'iptables-restore' | crontab - > /dev/null 2>&1
	(crontab -l ; echo '@reboot iptables-restore < /etc/iptables/rules.v4') | crontab - > /dev/null 2>&1

}




iptables_open() {
	install iptables
	save_iptables_rules
	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -F

	ip6tables -P INPUT ACCEPT
	ip6tables -P FORWARD ACCEPT
	ip6tables -P OUTPUT ACCEPT
	ip6tables -F

}



open_port() {
	local ports=($@)  # 将传入的参数转换为数组
	if [ ${#ports[@]} -eq 0 ]; then
		echo "請提供至少一個連接埠號"
		return 1
	fi

	install iptables

	for port in "${ports[@]}"; do
		# 刪除已存在的關閉規則
		iptables -D INPUT -p tcp --dport $port -j DROP 2>/dev/null
		iptables -D INPUT -p udp --dport $port -j DROP 2>/dev/null

		# 新增開啟規則
		if ! iptables -C INPUT -p tcp --dport $port -j ACCEPT 2>/dev/null; then
			iptables -I INPUT 1 -p tcp --dport $port -j ACCEPT
		fi

		if ! iptables -C INPUT -p udp --dport $port -j ACCEPT 2>/dev/null; then
			iptables -I INPUT 1 -p udp --dport $port -j ACCEPT
			echo "已開啟連接埠$port"
		fi
	done

	save_iptables_rules
	send_stats "已開啟連接埠"
}


close_port() {
	local ports=($@)  # 将传入的参数转换为数组
	if [ ${#ports[@]} -eq 0 ]; then
		echo "請提供至少一個連接埠號"
		return 1
	fi

	install iptables

	for port in "${ports[@]}"; do
		# 刪除已存在的開啟規則
		iptables -D INPUT -p tcp --dport $port -j ACCEPT 2>/dev/null
		iptables -D INPUT -p udp --dport $port -j ACCEPT 2>/dev/null

		# 新增關閉規則
		if ! iptables -C INPUT -p tcp --dport $port -j DROP 2>/dev/null; then
			iptables -I INPUT 1 -p tcp --dport $port -j DROP
		fi

		if ! iptables -C INPUT -p udp --dport $port -j DROP 2>/dev/null; then
			iptables -I INPUT 1 -p udp --dport $port -j DROP
			echo "已關閉連接埠$port"
		fi
	done

	# 刪除已存在的規則（如果有）
	iptables -D INPUT -i lo -j ACCEPT 2>/dev/null
	iptables -D FORWARD -i lo -j ACCEPT 2>/dev/null

	# 插入新規則到第一條
	iptables -I INPUT 1 -i lo -j ACCEPT
	iptables -I FORWARD 1 -i lo -j ACCEPT

	save_iptables_rules
	send_stats "已關閉連接埠"
}


allow_ip() {
	local ips=($@)  # 将传入的参数转换为数组
	if [ ${#ips[@]} -eq 0 ]; then
		echo "請提供至少一個IP位址或IP段"
		return 1
	fi

	install iptables

	for ip in "${ips[@]}"; do
		# 刪除已存在的阻止規則
		iptables -D INPUT -s $ip -j DROP 2>/dev/null

		# 新增允許規則
		if ! iptables -C INPUT -s $ip -j ACCEPT 2>/dev/null; then
			iptables -I INPUT 1 -s $ip -j ACCEPT
			echo "已放行IP$ip"
		fi
	done

	save_iptables_rules
	send_stats "已放行IP"
}

block_ip() {
	local ips=($@)  # 将传入的参数转换为数组
	if [ ${#ips[@]} -eq 0 ]; then
		echo "請提供至少一個IP位址或IP段"
		return 1
	fi

	install iptables

	for ip in "${ips[@]}"; do
		# 刪除已存在的允許規則
		iptables -D INPUT -s $ip -j ACCEPT 2>/dev/null

		# 新增阻止規則
		if ! iptables -C INPUT -s $ip -j DROP 2>/dev/null; then
			iptables -I INPUT 1 -s $ip -j DROP
			echo "已阻止IP$ip"
		fi
	done

	save_iptables_rules
	send_stats "已阻止IP"
}







enable_ddos_defense() {
	# 開啟防禦 DDoS
	iptables -A DOCKER-USER -p tcp --syn -m limit --limit 500/s --limit-burst 100 -j ACCEPT
	iptables -A DOCKER-USER -p tcp --syn -j DROP
	iptables -A DOCKER-USER -p udp -m limit --limit 3000/s -j ACCEPT
	iptables -A DOCKER-USER -p udp -j DROP
	iptables -A INPUT -p tcp --syn -m limit --limit 500/s --limit-burst 100 -j ACCEPT
	iptables -A INPUT -p tcp --syn -j DROP
	iptables -A INPUT -p udp -m limit --limit 3000/s -j ACCEPT
	iptables -A INPUT -p udp -j DROP

	send_stats "開啟DDoS防禦"
}

# 關閉DDoS防禦
disable_ddos_defense() {
	# 關閉防禦 DDoS
	iptables -D DOCKER-USER -p tcp --syn -m limit --limit 500/s --limit-burst 100 -j ACCEPT 2>/dev/null
	iptables -D DOCKER-USER -p tcp --syn -j DROP 2>/dev/null
	iptables -D DOCKER-USER -p udp -m limit --limit 3000/s -j ACCEPT 2>/dev/null
	iptables -D DOCKER-USER -p udp -j DROP 2>/dev/null
	iptables -D INPUT -p tcp --syn -m limit --limit 500/s --limit-burst 100 -j ACCEPT 2>/dev/null
	iptables -D INPUT -p tcp --syn -j DROP 2>/dev/null
	iptables -D INPUT -p udp -m limit --limit 3000/s -j ACCEPT 2>/dev/null
	iptables -D INPUT -p udp -j DROP 2>/dev/null

	send_stats "關閉DDoS防禦"
}





# 管理國家IP規則的函數
manage_country_rules() {
	local action="$1"
	shift  # 去掉第一个参数，剩下的全是国家代码

	install ipset

	for country_code in "$@"; do
		local ipset_name="${country_code,,}_block"
		local download_url="http://www.ipdeny.com/ipblocks/data/countries/${country_code,,}.zone"

		case "$action" in
			block)
				if ! ipset list "$ipset_name" &> /dev/null; then
					ipset create "$ipset_name" hash:net
				fi

				if ! wget -q "$download_url" -O "${country_code,,}.zone"; then
					echo "錯誤：下載$country_code的 IP 區域檔案失敗"
					continue
				fi

				while IFS= read -r ip; do
					ipset add "$ipset_name" "$ip" 2>/dev/null
				done < "${country_code,,}.zone"

				iptables -I INPUT -m set --match-set "$ipset_name" src -j DROP

				echo "已成功阻止$country_code的 IP 位址"
				rm "${country_code,,}.zone"
				;;

			allow)
				if ! ipset list "$ipset_name" &> /dev/null; then
					ipset create "$ipset_name" hash:net
				fi

				if ! wget -q "$download_url" -O "${country_code,,}.zone"; then
					echo "錯誤：下載$country_code的 IP 區域檔案失敗"
					continue
				fi

				ipset flush "$ipset_name"
				while IFS= read -r ip; do
					ipset add "$ipset_name" "$ip" 2>/dev/null
				done < "${country_code,,}.zone"


				iptables -P INPUT DROP
				iptables -A INPUT -m set --match-set "$ipset_name" src -j ACCEPT

				echo "已成功允許$country_code的 IP 位址"
				rm "${country_code,,}.zone"
				;;

			unblock)
				iptables -D INPUT -m set --match-set "$ipset_name" src -j DROP 2>/dev/null

				if ipset list "$ipset_name" &> /dev/null; then
					ipset destroy "$ipset_name"
				fi

				echo "已成功解除$country_code的 IP 位址限制"
				;;

			*)
				echo "用法: manage_country_rules {block|allow|unblock} <country_code...>"
				;;
		esac
	done
}










iptables_panel() {
  root_use
  install iptables
  save_iptables_rules
  while true; do
		  clear
		  echo "進階防火牆管理"
		  send_stats "進階防火牆管理"
		  echo "------------------------"
		  iptables -L INPUT
		  echo ""
		  echo "防火牆管理"
		  echo "------------------------"
		  echo "1. 開放指定連接埠 2. 關閉指定連接埠"
		  echo "3. 開放所有連接埠 4. 關閉所有連接埠"
		  echo "------------------------"
		  echo "5. IP白名單 6. IP黑名單"
		  echo "7. 清除指定IP"
		  echo "------------------------"
		  echo "11. 允許PING 12. 禁止PING"
		  echo "------------------------"
		  echo "13. 啟動DDOS防禦 14. 關閉DDOS防禦"
		  echo "------------------------"
		  echo "15. 阻止指定國家IP 16. 僅允許指定國家IP"
		  echo "17. 解除指定國家IP限制"
		  echo "------------------------"
		  echo "0. 返回上一級選單"
		  echo "------------------------"
		  read -e -p "請輸入你的選擇:" sub_choice
		  case $sub_choice in
			  1)
				  read -e -p "請輸入開放的連接埠號碼:" o_port
				  open_port $o_port
				  send_stats "開放指定連接埠"
				  ;;
			  2)
				  read -e -p "請輸入關閉的連接埠號碼:" c_port
				  close_port $c_port
				  send_stats "關閉指定連接埠"
				  ;;
			  3)
				  # 開放所有連接埠
				  current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')
				  iptables -F
				  iptables -X
				  iptables -P INPUT ACCEPT
				  iptables -P FORWARD ACCEPT
				  iptables -P OUTPUT ACCEPT
				  iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
				  iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
				  iptables -A INPUT -i lo -j ACCEPT
				  iptables -A FORWARD -i lo -j ACCEPT
				  iptables -A INPUT -p tcp --dport $current_port -j ACCEPT
				  iptables-save > /etc/iptables/rules.v4
				  send_stats "開放所有連接埠"
				  ;;
			  4)
				  # 關閉所有連接埠
				  current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')
				  iptables -F
				  iptables -X
				  iptables -P INPUT DROP
				  iptables -P FORWARD DROP
				  iptables -P OUTPUT ACCEPT
				  iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
				  iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
				  iptables -A INPUT -i lo -j ACCEPT
				  iptables -A FORWARD -i lo -j ACCEPT
				  iptables -A INPUT -p tcp --dport $current_port -j ACCEPT
				  iptables-save > /etc/iptables/rules.v4
				  send_stats "關閉所有連接埠"
				  ;;

			  5)
				  # IP 白名單
				  read -e -p "請輸入放行的IP或IP段:" o_ip
				  allow_ip $o_ip
				  ;;
			  6)
				  # IP 黑名單
				  read -e -p "請輸入封鎖的IP或IP段:" c_ip
				  block_ip $c_ip
				  ;;
			  7)
				  # 清除指定 IP
				  read -e -p "請輸入清除的IP:" d_ip
				  iptables -D INPUT -s $d_ip -j ACCEPT 2>/dev/null
				  iptables -D INPUT -s $d_ip -j DROP 2>/dev/null
				  iptables-save > /etc/iptables/rules.v4
				  send_stats "清除指定IP"
				  ;;
			  11)
				  # 允許 PING
				  iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
				  iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
				  iptables-save > /etc/iptables/rules.v4
				  send_stats "允許PING"
				  ;;
			  12)
				  # 禁用 PING
				  iptables -D INPUT -p icmp --icmp-type echo-request -j ACCEPT 2>/dev/null
				  iptables -D OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT 2>/dev/null
				  iptables-save > /etc/iptables/rules.v4
				  send_stats "禁用PING"
				  ;;
			  13)
				  enable_ddos_defense
				  ;;
			  14)
				  disable_ddos_defense
				  ;;

			  15)
				  read -e -p "請輸入阻止的國家代碼（多個國家代碼可用空格隔開如 CN US JP）:" country_code
				  manage_country_rules block $country_code
				  send_stats "允許國家$country_code的IP"
				  ;;
			  16)
				  read -e -p "請輸入允許的國家代碼（多個國家代碼可用空格隔開如 CN US JP）:" country_code
				  manage_country_rules allow $country_code
				  send_stats "阻止國家$country_code的IP"
				  ;;

			  17)
				  read -e -p "請輸入清除的國家代碼（多個國家代碼可用空格隔開如 CN US JP）:" country_code
				  manage_country_rules unblock $country_code
				  send_stats "清除國家$country_code的IP"
				  ;;

			  *)
				  break  # 跳出循环，退出菜单
				  ;;
		  esac
  done

}






add_swap() {
	local new_swap=$1  # 获取传入的参数

	# 取得目前系統中所有的 swap 分割區
	local swap_partitions=$(grep -E '^/dev/' /proc/swaps | awk '{print $1}')

	# 遍歷並刪除所有的 swap 分割區
	for partition in $swap_partitions; do
		swapoff "$partition"
		wipefs -a "$partition"
		mkswap -f "$partition"
	done

	# 確保 /swapfile 不再被使用
	swapoff /swapfile

	# 刪除舊的 /swapfile
	rm -f /swapfile

	# 建立新的 swap 分割區
	fallocate -l ${new_swap}M /swapfile
	chmod 600 /swapfile
	mkswap /swapfile
	swapon /swapfile

	sed -i '/\/swapfile/d' /etc/fstab
	echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

	if [ -f /etc/alpine-release ]; then
		echo "nohup swapon /swapfile" > /etc/local.d/swap.start
		chmod +x /etc/local.d/swap.start
		rc-update add local
	fi

	echo -e "虛擬記憶體大小已調整為${gl_huang}${new_swap}${gl_bai}M"
}




check_swap() {

local swap_total=$(free -m | awk 'NR==3{print $2}')

# 判斷是否需要建立虛擬記憶體
[ "$swap_total" -gt 0 ] || add_swap 1024


}









ldnmp_v() {

	  # 取得nginx版本
	  local nginx_version=$(docker exec nginx nginx -v 2>&1)
	  local nginx_version=$(echo "$nginx_version" | grep -oP "nginx/\K[0-9]+\.[0-9]+\.[0-9]+")
	  echo -n -e "nginx : ${gl_huang}v$nginx_version${gl_bai}"

	  # 取得mysql版本
	  local dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
	  local mysql_version=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -e "SELECT VERSION();" 2>/dev/null | tail -n 1)
	  echo -n -e "            mysql : ${gl_huang}v$mysql_version${gl_bai}"

	  # 取得php版本
	  local php_version=$(docker exec php php -v 2>/dev/null | grep -oP "PHP \K[0-9]+\.[0-9]+\.[0-9]+")
	  echo -n -e "            php : ${gl_huang}v$php_version${gl_bai}"

	  # 取得redis版本
	  local redis_version=$(docker exec redis redis-server -v 2>&1 | grep -oP "v=+\K[0-9]+\.[0-9]+")
	  echo -e "            redis : ${gl_huang}v$redis_version${gl_bai}"

	  echo "------------------------"
	  echo ""

}



install_ldnmp_conf() {

  # 建立必要的目錄和文件
  cd /home && mkdir -p web/html web/mysql web/certs web/conf.d web/stream.d web/redis web/log/nginx web/letsencrypt && touch web/docker-compose.yml
  wget -O /home/web/nginx.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/nginx10.conf
  wget -O /home/web/conf.d/default.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/default10.conf

  default_server_ssl

  # 下載 docker-compose.yml 檔案並進行替換
  wget -O /home/web/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/kejilion/docker/main/LNMP-docker-compose-10.yml
  dbrootpasswd=$(openssl rand -base64 16) ; dbuse=$(openssl rand -hex 4) ; dbusepasswd=$(openssl rand -base64 8)

  # 在 docker-compose.yml 檔案中進行替換
  sed -i "s#webroot#$dbrootpasswd#g" /home/web/docker-compose.yml
  sed -i "s#kejilionYYDS#$dbusepasswd#g" /home/web/docker-compose.yml
  sed -i "s#kejilion#$dbuse#g" /home/web/docker-compose.yml

}


update_docker_compose_with_db_creds() {

  cp /home/web/docker-compose.yml /home/web/docker-compose1.yml

  if ! grep -q "letsencrypt" /home/web/docker-compose.yml; then
	wget -O /home/web/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/kejilion/docker/main/LNMP-docker-compose-10.yml

  	dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose1.yml | tr -d '[:space:]')
  	dbuse=$(grep -oP 'MYSQL_USER:\s*\K.*' /home/web/docker-compose1.yml | tr -d '[:space:]')
  	dbusepasswd=$(grep -oP 'MYSQL_PASSWORD:\s*\K.*' /home/web/docker-compose1.yml | tr -d '[:space:]')

	sed -i "s#webroot#$dbrootpasswd#g" /home/web/docker-compose.yml
	sed -i "s#kejilionYYDS#$dbusepasswd#g" /home/web/docker-compose.yml
	sed -i "s#kejilion#$dbuse#g" /home/web/docker-compose.yml
  fi

  if grep -q "kjlion/nginx:alpine" /home/web/docker-compose1.yml; then
  	sed -i 's|kjlion/nginx:alpine|nginx:alpine|g' /home/web/docker-compose.yml  > /dev/null 2>&1
	sed -i 's|nginx:alpine|kjlion/nginx:alpine|g' /home/web/docker-compose.yml  > /dev/null 2>&1
  fi

}





auto_optimize_dns() {
	# 取得國家代碼（如 CN、US 等）
	local country=$(curl -s ipinfo.io/country)

	# 根據國家設定 DNS
	if [ "$country" = "CN" ]; then
		local dns1_ipv4="223.5.5.5"
		local dns2_ipv4="183.60.83.19"
		local dns1_ipv6="2400:3200::1"
		local dns2_ipv6="2400:da00::6666"
	else
		local dns1_ipv4="1.1.1.1"
		local dns2_ipv4="8.8.8.8"
		local dns1_ipv6="2606:4700:4700::1111"
		local dns2_ipv6="2001:4860:4860::8888"
	fi

	set_dns


}


prefer_ipv4() {
grep -q '^precedence ::ffff:0:0/96  100' /etc/gai.conf 2>/dev/null \
	|| echo 'precedence ::ffff:0:0/96  100' >> /etc/gai.conf
echo "已切換為 IPv4 優先"
send_stats "已切換為 IPv4 優先"
}




install_ldnmp() {

	  update_docker_compose_with_db_creds

	  cd /home/web && docker compose up -d
	  sleep 1
  	  crontab -l 2>/dev/null | grep -v 'logrotate' | crontab -
  	  (crontab -l 2>/dev/null; echo '0 2 * * * docker exec nginx apk add logrotate && docker exec nginx logrotate -f /etc/logrotate.conf') | crontab -

	  fix_phpfpm_conf php
	  fix_phpfpm_conf php74

	  # mysql調優
	  wget -O /home/custom_mysql_config.cnf ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/custom_mysql_config-1.cnf
	  docker cp /home/custom_mysql_config.cnf mysql:/etc/mysql/conf.d/
	  rm -rf /home/custom_mysql_config.cnf



	  restart_ldnmp
	  sleep 2

	  clear
	  echo "LDNMP環境安裝完畢"
	  echo "------------------------"
	  ldnmp_v

}


install_certbot() {

	cd ~
	curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/auto_cert_renewal.sh
	chmod +x auto_cert_renewal.sh

	check_crontab_installed
	local cron_job="0 0 * * * ~/auto_cert_renewal.sh"
	crontab -l 2>/dev/null | grep -vF "$cron_job" | crontab -
	(crontab -l 2>/dev/null; echo "$cron_job") | crontab -
	echo "續簽任務已更新"
}


install_ssltls() {
	  docker stop nginx > /dev/null 2>&1
	  cd ~

	  local file_path="/etc/letsencrypt/live/$yuming/fullchain.pem"
	  if [ ! -f "$file_path" ]; then
		 	local ipv4_pattern='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
			local ipv6_pattern='^(([0-9A-Fa-f]{1,4}:){1,7}:|([0-9A-Fa-f]{1,4}:){7,7}[0-9A-Fa-f]{1,4}|::1)$'
			if [[ ($yuming =~ $ipv4_pattern || $yuming =~ $ipv6_pattern) ]]; then
				mkdir -p /etc/letsencrypt/live/$yuming/
				if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
					openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -keyout /etc/letsencrypt/live/$yuming/privkey.pem -out /etc/letsencrypt/live/$yuming/fullchain.pem -days 5475 -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
				else
					openssl genpkey -algorithm Ed25519 -out /etc/letsencrypt/live/$yuming/privkey.pem
					openssl req -x509 -key /etc/letsencrypt/live/$yuming/privkey.pem -out /etc/letsencrypt/live/$yuming/fullchain.pem -days 5475 -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
				fi
			else
				docker run --rm -p 80:80 -v /etc/letsencrypt/:/etc/letsencrypt certbot/certbot certonly --standalone -d "$yuming" --email your@email.com --agree-tos --no-eff-email --force-renewal --key-type ecdsa
			fi
	  fi
	  mkdir -p /home/web/certs/
	  cp /etc/letsencrypt/live/$yuming/fullchain.pem /home/web/certs/${yuming}_cert.pem > /dev/null 2>&1
	  cp /etc/letsencrypt/live/$yuming/privkey.pem /home/web/certs/${yuming}_key.pem > /dev/null 2>&1

	  docker start nginx > /dev/null 2>&1
}



install_ssltls_text() {
	echo -e "${gl_huang}$yuming公鑰資訊${gl_bai}"
	cat /etc/letsencrypt/live/$yuming/fullchain.pem
	echo ""
	echo -e "${gl_huang}$yuming私鑰資訊${gl_bai}"
	cat /etc/letsencrypt/live/$yuming/privkey.pem
	echo ""
	echo -e "${gl_huang}證書存放路徑${gl_bai}"
	echo "公鑰: /etc/letsencrypt/live/$yuming/fullchain.pem"
	echo "私鑰: /etc/letsencrypt/live/$yuming/privkey.pem"
	echo ""
}





add_ssl() {
echo -e "${gl_huang}快速申請SSL證書，過期前自動續約${gl_bai}"
yuming="${1:-}"
if [ -z "$yuming" ]; then
	add_yuming
fi
install_docker
install_certbot
docker run --rm -v /etc/letsencrypt/:/etc/letsencrypt certbot/certbot delete --cert-name "$yuming" -n 2>/dev/null
install_ssltls
certs_status
install_ssltls_text
ssl_ps
}


ssl_ps() {
	echo -e "${gl_huang}已申請的證書到期情況${gl_bai}"
	echo "站點資訊 證書到期時間"
	echo "------------------------"
	for cert_dir in /etc/letsencrypt/live/*; do
	  local cert_file="$cert_dir/fullchain.pem"
	  if [ -f "$cert_file" ]; then
		local domain=$(basename "$cert_dir")
		local expire_date=$(openssl x509 -noout -enddate -in "$cert_file" | awk -F'=' '{print $2}')
		local formatted_date=$(date -d "$expire_date" '+%Y-%m-%d')
		printf "%-30s%s\n" "$domain" "$formatted_date"
	  fi
	done
	echo ""
}




default_server_ssl() {
install openssl

if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
	openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -keyout /home/web/certs/default_server.key -out /home/web/certs/default_server.crt -days 5475 -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
else
	openssl genpkey -algorithm Ed25519 -out /home/web/certs/default_server.key
	openssl req -x509 -key /home/web/certs/default_server.key -out /home/web/certs/default_server.crt -days 5475 -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
fi

openssl rand -out /home/web/certs/ticket12.key 48
openssl rand -out /home/web/certs/ticket13.key 80

}


certs_status() {

	sleep 1

	local file_path="/etc/letsencrypt/live/$yuming/fullchain.pem"
	if [ -f "$file_path" ]; then
		send_stats "網域證書申請成功"
	else
		send_stats "網域證書申請失敗"
		echo -e "${gl_hong}注意:${gl_bai}證書申請失敗，請檢查以下可能原因並重試："
		echo -e "1. 網域拼字錯誤 ➠ 請檢查網域名稱輸入是否正確"
		echo -e "2. DNS解析問題 ➠ 確認網域名稱已正確解析至本伺服器IP"
		echo -e "3. 網路設定問題 ➠ 如使用Cloudflare Warp等虛擬網路請暫時關閉"
		echo -e "4. 防火牆限制 ➠ 檢查80/443連接埠是否開放，確保驗證可存取"
		echo -e "5. 申請次數超限 ➠ Let's Encrypt有每週限額(5次/網域/週)"
		echo -e "6. 國內備案限制 ➠ 中國大陸環境請確認網域是否備案"
		echo "------------------------"
		echo "1. 重新申請 2. 匯入已有憑證 0. 退出"
		echo "------------------------"
		read -e -p "請輸入你的選擇:" sub_choice
		case $sub_choice in
	  	  1)
	  	  	send_stats "重新申請"
		  	echo "請再次嘗試部署$webname"
		  	add_yuming
		  	install_ssltls
		  	certs_status

	  		  ;;
	  	  2)
	  	  	send_stats "導入已有證書"

			# 定義檔案路徑
			local cert_file="/home/web/certs/${yuming}_cert.pem"
			local key_file="/home/web/certs/${yuming}_key.pem"

			mkdir -p /home/web/certs

			# 1. 輸入憑證 (ECC 和 RSA 憑證開頭都是 BEGIN CERTIFICATE)
			echo "請貼上 證書 (CRT/PEM) 內容 (以兩次回車結束)："
			local cert_content=""
			while IFS= read -r line; do
				[[ -z "$line" && "$cert_content" == *"-----BEGIN"* ]] && break
				cert_content+="${line}"$'\n'
			done

			# 2. 輸入私鑰 (相容 RSA, ECC, PKCS#8)
			echo "請貼上 憑證私鑰 (Private Key) 內容 (按兩次回車結束)："
			local key_content=""
			while IFS= read -r line; do
				[[ -z "$line" && "$key_content" == *"-----BEGIN"* ]] && break
				key_content+="${line}"$'\n'
			done

			# 3. 智能校驗
			# 只要包含 "BEGIN CERTIFICATE" 和 "PRIVATE KEY" 即可透過
			if [[ "$cert_content" == *"-----BEGIN CERTIFICATE-----"* && "$key_content" == *"PRIVATE KEY-----"* ]]; then
				echo -n "$cert_content" > "$cert_file"
				echo -n "$key_content" > "$key_file"

				chmod 644 "$cert_file"
				chmod 600 "$key_file"

				# 識別目前證書類型並顯示
				if [[ "$key_content" == *"EC PRIVATE KEY"* ]]; then
					echo "偵測到 ECC 憑證已成功儲存。"
				else
					echo "偵測到 RSA 憑證已成功儲存。"
				fi
				auth_method="ssl_imported"
			else
				echo "錯誤：無效的憑證或私鑰格式！"
				certs_status
			fi
	  		  ;;
	  	  *)
		  	  exit
	  		  ;;
		esac
	fi

}


repeat_add_yuming() {
if [ -e /home/web/conf.d/$yuming.conf ]; then
  send_stats "網域重複使用"
  web_del "${yuming}" > /dev/null 2>&1
fi

}


add_yuming() {
	  ip_address
	  echo -e "先將網域名稱解析到本機IP:${gl_huang}$ipv4_address  $ipv6_address${gl_bai}"
	  read -e -p "請輸入你的IP或解析過的網域名稱:" yuming
}


check_ip_and_get_access_port() {
	local yuming="$1"

	local ipv4_pattern='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
	local ipv6_pattern='^(([0-9A-Fa-f]{1,4}:){1,7}:|([0-9A-Fa-f]{1,4}:){7,7}[0-9A-Fa-f]{1,4}|::1)$'

	if [[ "$yuming" =~ $ipv4_pattern || "$yuming" =~ $ipv6_pattern ]]; then
		read -e -p "請輸入訪問/監聽端口，回車預設使用 80:" access_port
		access_port=${access_port:-80}
	fi
}



update_nginx_listen_port() {
	local yuming="$1"
	local access_port="$2"
	local conf="/home/web/conf.d/${yuming}.conf"

	# 如果 access_port 為空，則跳過
	[ -z "$access_port" ] && return 0

	# 刪除所有 listen 行
	sed -i '/^[[:space:]]*listen[[:space:]]\+/d' "$conf"

	# 在 server { 後插入新的 l​​isten
	sed -i "/server {/a\\
	listen ${access_port};\\
	listen [::]:${access_port};
" "$conf"
}



add_db() {
	  dbname=$(echo "$yuming" | sed -e 's/[^A-Za-z0-9]/_/g')
	  dbname="${dbname}"

	  dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
	  dbuse=$(grep -oP 'MYSQL_USER:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
	  dbusepasswd=$(grep -oP 'MYSQL_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
	  docker exec mysql mysql -u root -p"$dbrootpasswd" -e "CREATE DATABASE $dbname; GRANT ALL PRIVILEGES ON $dbname.* TO \"$dbuse\"@\"%\";"
}


restart_ldnmp() {
	  docker exec nginx chown -R nginx:nginx /var/www/html > /dev/null 2>&1
	  docker exec nginx mkdir -p /var/cache/nginx/proxy > /dev/null 2>&1
	  docker exec nginx mkdir -p /var/cache/nginx/fastcgi > /dev/null 2>&1
	  docker exec nginx chown -R nginx:nginx /var/cache/nginx/proxy > /dev/null 2>&1
	  docker exec nginx chown -R nginx:nginx /var/cache/nginx/fastcgi > /dev/null 2>&1
	  docker exec php chown -R www-data:www-data /var/www/html > /dev/null 2>&1
	  docker exec php74 chown -R www-data:www-data /var/www/html > /dev/null 2>&1
	  cd /home/web && docker compose restart


}

nginx_upgrade() {

  local ldnmp_pods="nginx"
  cd /home/web/
  docker rm -f $ldnmp_pods > /dev/null 2>&1
  docker images --filter=reference="kjlion/${ldnmp_pods}*" -q | xargs docker rmi > /dev/null 2>&1
  docker images --filter=reference="${ldnmp_pods}*" -q | xargs docker rmi > /dev/null 2>&1
  docker compose up -d --force-recreate $ldnmp_pods
  crontab -l 2>/dev/null | grep -v 'logrotate' | crontab -
  (crontab -l 2>/dev/null; echo '0 2 * * * docker exec nginx apk add logrotate && docker exec nginx logrotate -f /etc/logrotate.conf') | crontab -
  docker exec nginx chown -R nginx:nginx /var/www/html
  docker exec nginx mkdir -p /var/cache/nginx/proxy
  docker exec nginx mkdir -p /var/cache/nginx/fastcgi
  docker exec nginx chown -R nginx:nginx /var/cache/nginx/proxy
  docker exec nginx chown -R nginx:nginx /var/cache/nginx/fastcgi
  docker restart $ldnmp_pods > /dev/null 2>&1

  send_stats "更新$ldnmp_pods"
  echo "更新${ldnmp_pods}完成"

}

phpmyadmin_upgrade() {
  local ldnmp_pods="phpmyadmin"
  local local docker_port=8877
  local dbuse=$(grep -oP 'MYSQL_USER:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
  local dbusepasswd=$(grep -oP 'MYSQL_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')

  cd /home/web/
  docker rm -f $ldnmp_pods > /dev/null 2>&1
  docker images --filter=reference="$ldnmp_pods*" -q | xargs docker rmi > /dev/null 2>&1
  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/docker/refs/heads/main/docker-compose.phpmyadmin.yml
  docker compose -f docker-compose.phpmyadmin.yml up -d
  clear
  ip_address

  check_docker_app_ip
  echo "登入資訊:"
  echo "使用者名稱:$dbuse"
  echo "密碼:$dbusepasswd"
  echo
  send_stats "啟動$ldnmp_pods"
}


cf_purge_cache() {
  local CONFIG_FILE="/home/web/config/cf-purge-cache.txt"
  local API_TOKEN
  local EMAIL
  local ZONE_IDS

  # 檢查設定檔是否存在
  if [ -f "$CONFIG_FILE" ]; then
	# 從設定檔讀取 API_TOKEN 和 zone_id
	read API_TOKEN EMAIL ZONE_IDS < "$CONFIG_FILE"
	# 將 ZONE_IDS 轉換為數組
	ZONE_IDS=($ZONE_IDS)
  else
	# 提示使用者是否清理快取
	read -e -p "需要清理 Cloudflare 的快取嗎？ （y/n）:" answer
	if [[ "$answer" == "y" ]]; then
	  echo "CF資訊保存在$CONFIG_FILE，可以後期修改CF訊息"
	  read -e -p "請輸入你的 API_TOKEN:" API_TOKEN
	  read -e -p "請輸入你的CF用戶名:" EMAIL
	  read -e -p "請輸入 zone_id（多個以空格分隔）:" -a ZONE_IDS

	  mkdir -p /home/web/config/
	  echo "$API_TOKEN $EMAIL ${ZONE_IDS[*]}" > "$CONFIG_FILE"
	fi
  fi

  # 循環遍歷每個 zone_id 並執行清除快取命令
  for ZONE_ID in "${ZONE_IDS[@]}"; do
	echo "正在清除快取 for zone_id:$ZONE_ID"
	curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
	-H "X-Auth-Email: $EMAIL" \
	-H "X-Auth-Key: $API_TOKEN" \
	-H "Content-Type: application/json" \
	--data '{"purge_everything":true}'
  done

  echo "快取清除請求已發送完畢。"
}



web_cache() {
  send_stats "清理網站快取"
  cf_purge_cache
  cd /home/web && docker compose restart
}



web_del() {

	send_stats "刪除站點數據"
	yuming_list="${1:-}"
	if [ -z "$yuming_list" ]; then
		read -e -p "刪除站點數據，請輸入你的網域名稱（多個網域以空格隔開）:" yuming_list
		if [[ -z "$yuming_list" ]]; then
			return
		fi
	fi

	for yuming in $yuming_list; do
		echo "正在刪除網域名稱:$yuming"
		rm -r /home/web/html/$yuming > /dev/null 2>&1
		rm /home/web/conf.d/$yuming.conf > /dev/null 2>&1
		rm /home/web/certs/${yuming}_key.pem > /dev/null 2>&1
		rm /home/web/certs/${yuming}_cert.pem > /dev/null 2>&1

		# 將網域名稱轉換為資料庫名
		dbname=$(echo "$yuming" | sed -e 's/[^A-Za-z0-9]/_/g')
		dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')

		# 刪除資料庫前檢查是否存在，避免報錯
		echo "正在刪除資料庫:$dbname"
		docker exec mysql mysql -u root -p"$dbrootpasswd" -e "DROP DATABASE ${dbname};" > /dev/null 2>&1
	done

	docker exec nginx nginx -s reload

}


nginx_waf() {
	local mode=$1

	if ! grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		wget -O /home/web/nginx.conf "${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/nginx10.conf"
	fi

	# 根據 mode 參數決定開啟或關閉 WAF
	if [ "$mode" == "on" ]; then
		# 開啟 WAF：去掉註釋
		sed -i 's|# load_module /etc/nginx/modules/ngx_http_modsecurity_module.so;|load_module /etc/nginx/modules/ngx_http_modsecurity_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# modsecurity on;|\1modsecurity on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# modsecurity_rules_file /etc/nginx/modsec/modsecurity.conf;|\1modsecurity_rules_file /etc/nginx/modsec/modsecurity.conf;|' /home/web/nginx.conf > /dev/null 2>&1
	elif [ "$mode" == "off" ]; then
		# 關閉 WAF：加上註釋
		sed -i 's|^load_module /etc/nginx/modules/ngx_http_modsecurity_module.so;|# load_module /etc/nginx/modules/ngx_http_modsecurity_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)modsecurity on;|\1# modsecurity on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)modsecurity_rules_file /etc/nginx/modsec/modsecurity.conf;|\1# modsecurity_rules_file /etc/nginx/modsec/modsecurity.conf;|' /home/web/nginx.conf > /dev/null 2>&1
	else
		echo "無效的參數：使用 'on' 或 'off'"
		return 1
	fi

	# 檢查 nginx 鏡像並根據情況處理
	if grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		docker exec nginx nginx -s reload
	else
		sed -i 's|nginx:alpine|kjlion/nginx:alpine|g' /home/web/docker-compose.yml
		nginx_upgrade
	fi

}

check_waf_status() {
	if grep -q "^\s*#\s*modsecurity on;" /home/web/nginx.conf; then
		waf_status=""
	elif grep -q "modsecurity on;" /home/web/nginx.conf; then
		waf_status="WAF已開啟"
	else
		waf_status=""
	fi
}


check_cf_mode() {
	if [ -f "/etc/fail2ban/action.d/cloudflare-docker.conf" ]; then
		CFmessage="cf模式已開啟"
	else
		CFmessage=""
	fi
}


nginx_http_on() {

local ipv4_pattern='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
local ipv6_pattern='^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?))|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?))|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?))|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|(2[0-4][0-9]|[01]?[0-9][0-9]?))))$'
if [[ ($yuming =~ $ipv4_pattern || $yuming =~ $ipv6_pattern) ]]; then
	sed -i '/if (\$scheme = http) {/,/}/s/^/#/' /home/web/conf.d/${yuming}.conf
fi

}


patch_wp_memory_limit() {
  local MEMORY_LIMIT="${1:-256M}"      # 第一个参数，默认256M
  local MAX_MEMORY_LIMIT="${2:-256M}"  # 第二个参数，默认256M
  local TARGET_DIR="/home/web/html"    # 路径写死

  find "$TARGET_DIR" -type f -name "wp-config.php" | while read -r FILE; do
	# 刪除舊定義
	sed -i "/define(['\"]WP_MEMORY_LIMIT['\"].*/d" "$FILE"
	sed -i "/define(['\"]WP_MAX_MEMORY_LIMIT['\"].*/d" "$FILE"

	# 插入新定義，放在含 "Happy publishing" 的行前
	awk -v insert="define('WP_MEMORY_LIMIT', '$MEMORY_LIMIT');\ndefine('WP_MAX_MEMORY_LIMIT', '$MAX_MEMORY_LIMIT');" \
	'
	  /Happy publishing/ {
		print insert
	  }
	  { print }
	' "$FILE" > "$FILE.tmp" && mv -f "$FILE.tmp" "$FILE"

	echo "[+] Replaced WP_MEMORY_LIMIT in $FILE"
  done
}




patch_wp_debug() {
  local DEBUG="${1:-false}"           # 第一个参数，默认false
  local DEBUG_DISPLAY="${2:-false}"   # 第二个参数，默认false
  local DEBUG_LOG="${3:-false}"       # 第三个参数，默认false
  local TARGET_DIR="/home/web/html"   # 路径写死

  find "$TARGET_DIR" -type f -name "wp-config.php" | while read -r FILE; do
	# 刪除舊定義
	sed -i "/define(['\"]WP_DEBUG['\"].*/d" "$FILE"
	sed -i "/define(['\"]WP_DEBUG_DISPLAY['\"].*/d" "$FILE"
	sed -i "/define(['\"]WP_DEBUG_LOG['\"].*/d" "$FILE"

	# 插入新定義，放在含 "Happy publishing" 的行前
	awk -v insert="define('WP_DEBUG_DISPLAY', $DEBUG_DISPLAY);\ndefine('WP_DEBUG_LOG', $DEBUG_LOG);" \
	'
	  /Happy publishing/ {
		print insert
	  }
	  { print }
	' "$FILE" > "$FILE.tmp" && mv -f "$FILE.tmp" "$FILE"

	echo "[+] Replaced WP_DEBUG settings in $FILE"
  done
}




patch_wp_url() {
  local HOME_URL="$1"
  local SITE_URL="$2"
  local TARGET_DIR="/home/web/html"

  find "$TARGET_DIR" -type f -name "wp-config-sample.php" | while read -r FILE; do
	# 刪除舊定義
	sed -i "/define(['\"]WP_HOME['\"].*/d" "$FILE"
	sed -i "/define(['\"]WP_SITEURL['\"].*/d" "$FILE"

	# 產生插入內容
	INSERT="
define('WP_HOME', '$HOME_URL');
define('WP_SITEURL', '$SITE_URL');
"

	# 插入到 “Happy publishing” 之前
	awk -v insert="$INSERT" '
	  /Happy publishing/ {
		print insert
	  }
	  { print }
	' "$FILE" > "$FILE.tmp" && mv -f "$FILE.tmp" "$FILE"

	echo "[+] Updated WP_HOME and WP_SITEURL in $FILE"
  done
}








nginx_br() {

	local mode=$1

	if ! grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		wget -O /home/web/nginx.conf "${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/nginx10.conf"
	fi

	if [ "$mode" == "on" ]; then
		# 開啟 Brotli：去掉註釋
		sed -i 's|# load_module /etc/nginx/modules/ngx_http_brotli_filter_module.so;|load_module /etc/nginx/modules/ngx_http_brotli_filter_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|# load_module /etc/nginx/modules/ngx_http_brotli_static_module.so;|load_module /etc/nginx/modules/ngx_http_brotli_static_module.so;|' /home/web/nginx.conf > /dev/null 2>&1

		sed -i 's|^\(\s*\)# brotli on;|\1brotli on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_static on;|\1brotli_static on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_comp_level \(.*\);|\1brotli_comp_level \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_buffers \(.*\);|\1brotli_buffers \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_min_length \(.*\);|\1brotli_min_length \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_window \(.*\);|\1brotli_window \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# brotli_types \(.*\);|\1brotli_types \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i '/brotli_types/,+6 s/^\(\s*\)#\s*/\1/' /home/web/nginx.conf

	elif [ "$mode" == "off" ]; then
		# 關閉 Brotli：加上註釋
		sed -i 's|^load_module /etc/nginx/modules/ngx_http_brotli_filter_module.so;|# load_module /etc/nginx/modules/ngx_http_brotli_filter_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^load_module /etc/nginx/modules/ngx_http_brotli_static_module.so;|# load_module /etc/nginx/modules/ngx_http_brotli_static_module.so;|' /home/web/nginx.conf > /dev/null 2>&1

		sed -i 's|^\(\s*\)brotli on;|\1# brotli on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_static on;|\1# brotli_static on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_comp_level \(.*\);|\1# brotli_comp_level \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_buffers \(.*\);|\1# brotli_buffers \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_min_length \(.*\);|\1# brotli_min_length \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_window \(.*\);|\1# brotli_window \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)brotli_types \(.*\);|\1# brotli_types \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i '/brotli_types/,+6 {
			/^[[:space:]]*[^#[:space:]]/ s/^\(\s*\)/\1# /
		}' /home/web/nginx.conf

	else
		echo "無效的參數：使用 'on' 或 'off'"
		return 1
	fi

	# 檢查 nginx 鏡像並根據情況處理
	if grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		docker exec nginx nginx -s reload
	else
		sed -i 's|nginx:alpine|kjlion/nginx:alpine|g' /home/web/docker-compose.yml
		nginx_upgrade
	fi


}



nginx_zstd() {

	local mode=$1

	if ! grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		wget -O /home/web/nginx.conf "${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/nginx10.conf"
	fi

	if [ "$mode" == "on" ]; then
		# 開啟 Zstd：去掉註釋
		sed -i 's|# load_module /etc/nginx/modules/ngx_http_zstd_filter_module.so;|load_module /etc/nginx/modules/ngx_http_zstd_filter_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|# load_module /etc/nginx/modules/ngx_http_zstd_static_module.so;|load_module /etc/nginx/modules/ngx_http_zstd_static_module.so;|' /home/web/nginx.conf > /dev/null 2>&1

		sed -i 's|^\(\s*\)# zstd on;|\1zstd on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# zstd_static on;|\1zstd_static on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# zstd_comp_level \(.*\);|\1zstd_comp_level \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# zstd_buffers \(.*\);|\1zstd_buffers \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# zstd_min_length \(.*\);|\1zstd_min_length \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)# zstd_types \(.*\);|\1zstd_types \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i '/zstd_types/,+6 s/^\(\s*\)#\s*/\1/' /home/web/nginx.conf



	elif [ "$mode" == "off" ]; then
		# 關閉 Zstd：加上註釋
		sed -i 's|^load_module /etc/nginx/modules/ngx_http_zstd_filter_module.so;|# load_module /etc/nginx/modules/ngx_http_zstd_filter_module.so;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^load_module /etc/nginx/modules/ngx_http_zstd_static_module.so;|# load_module /etc/nginx/modules/ngx_http_zstd_static_module.so;|' /home/web/nginx.conf > /dev/null 2>&1

		sed -i 's|^\(\s*\)zstd on;|\1# zstd on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)zstd_static on;|\1# zstd_static on;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)zstd_comp_level \(.*\);|\1# zstd_comp_level \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)zstd_buffers \(.*\);|\1# zstd_buffers \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)zstd_min_length \(.*\);|\1# zstd_min_length \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i 's|^\(\s*\)zstd_types \(.*\);|\1# zstd_types \2;|' /home/web/nginx.conf > /dev/null 2>&1
		sed -i '/zstd_types/,+6 {
			/^[[:space:]]*[^#[:space:]]/ s/^\(\s*\)/\1# /
		}' /home/web/nginx.conf


	else
		echo "無效的參數：使用 'on' 或 'off'"
		return 1
	fi

	# 檢查 nginx 鏡像並根據情況處理
	if grep -q "kjlion/nginx:alpine" /home/web/docker-compose.yml; then
		docker exec nginx nginx -s reload
	else
		sed -i 's|nginx:alpine|kjlion/nginx:alpine|g' /home/web/docker-compose.yml
		nginx_upgrade
	fi



}








nginx_gzip() {

	local mode=$1
	if [ "$mode" == "on" ]; then
		sed -i 's|^\(\s*\)# gzip on;|\1gzip on;|' /home/web/nginx.conf > /dev/null 2>&1
	elif [ "$mode" == "off" ]; then
		sed -i 's|^\(\s*\)gzip on;|\1# gzip on;|' /home/web/nginx.conf > /dev/null 2>&1
	else
		echo "無效的參數：使用 'on' 或 'off'"
		return 1
	fi

	docker exec nginx nginx -s reload

}






web_security() {
	  send_stats "LDNMP環境防禦"
	  while true; do
		check_f2b_status
		check_waf_status
		check_cf_mode
			  clear
			  echo -e "伺服器網站防禦程序${check_f2b_status}${gl_lv}${CFmessage}${waf_status}${gl_bai}"
			  echo "------------------------"
			  echo "1. 安裝防禦程序"
			  echo "------------------------"
			  echo "5. 查看SSH攔截記錄 6. 查看網站攔截記錄"
			  echo "7. 檢視防禦規則清單 8. 查看日誌即時監控"
			  echo "------------------------"
			  echo "11. 設定攔截參數 12. 清除所有拉黑的IP"
			  echo "------------------------"
			  echo "21. cloudflare模式 22. 高負載開啟5秒盾"
			  echo "------------------------"
			  echo "31. 開啟WAF 32. 關閉WAF"
			  echo "33. 開啟DDOS防禦 34. 關閉DDOS防禦"
			  echo "------------------------"
			  echo "9. 卸載防禦程序"
			  echo "------------------------"
			  echo "0. 返回上一級選單"
			  echo "------------------------"
			  read -e -p "請輸入你的選擇:" sub_choice
			  case $sub_choice in
				  1)
					  f2b_install_sshd
					  cd /etc/fail2ban/filter.d
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/fail2ban-nginx-cc.conf
					  wget ${gh_proxy}raw.githubusercontent.com/linuxserver/fail2ban-confs/master/filter.d/nginx-418.conf
					  wget ${gh_proxy}raw.githubusercontent.com/linuxserver/fail2ban-confs/master/filter.d/nginx-deny.conf
					  wget ${gh_proxy}raw.githubusercontent.com/linuxserver/fail2ban-confs/master/filter.d/nginx-unauthorized.conf
					  wget ${gh_proxy}raw.githubusercontent.com/linuxserver/fail2ban-confs/master/filter.d/nginx-bad-request.conf

					  cd /etc/fail2ban/jail.d/
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/config/main/fail2ban/nginx-docker-cc.conf
					  sed -i "/cloudflare/d" /etc/fail2ban/jail.d/nginx-docker-cc.conf
					  f2b_status
					  ;;
				  5)
					  echo "------------------------"
					  f2b_sshd
					  echo "------------------------"
					  ;;
				  6)

					  echo "------------------------"
					  local xxx="fail2ban-nginx-cc"
					  f2b_status_xxx
					  echo "------------------------"
					  local xxx="nginx-418"
					  f2b_status_xxx
					  echo "------------------------"
					  local xxx="nginx-bad-request"
					  f2b_status_xxx
					  echo "------------------------"
					  local xxx="nginx-badbots"
					  f2b_status_xxx
					  echo "------------------------"
					  local xxx="nginx-botsearch"
					  f2b_status_xxx
					  echo "------------------------"
					  local xxx="nginx-deny"
					  f2b_status_xxx
					  echo "------------------------"
					  local xxx="nginx-http-auth"
					  f2b_status_xxx
					  echo "------------------------"
					  local xxx="nginx-unauthorized"
					  f2b_status_xxx
					  echo "------------------------"
					  local xxx="php-url-fopen"
					  f2b_status_xxx
					  echo "------------------------"

					  ;;

				  7)
					  fail2ban-client status
					  ;;
				  8)
					  tail -f /var/log/fail2ban.log

					  ;;
				  9)
					  remove fail2ban
					  rm -rf /etc/fail2ban
					  crontab -l | grep -v "CF-Under-Attack.sh" | crontab - 2>/dev/null
					  echo "Fail2Ban防禦程序已卸載"
					  break
					  ;;

				  11)
					  install nano
					  nano /etc/fail2ban/jail.d/nginx-docker-cc.conf
					  f2b_status
					  break
					  ;;

				  12)
					  fail2ban-client unban --all
					  ;;

				  21)
					  send_stats "cloudflare模式"
					  echo "到cf後台右上角我的個人資料，選擇左側API令牌，取得Global API Key"
					  echo "https://dash.cloudflare.com/login"
					  read -e -p "輸入CF的帳號:" cfuser
					  read -e -p "輸入CF的Global API Key:" cftoken

					  wget -O /home/web/conf.d/default.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/default11.conf
					  docker exec nginx nginx -s reload

					  cd /etc/fail2ban/jail.d/
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/config/main/fail2ban/nginx-docker-cc.conf

					  cd /etc/fail2ban/action.d
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/config/main/fail2ban/cloudflare-docker.conf

					  sed -i "s/kejilion@outlook.com/$cfuser/g" /etc/fail2ban/action.d/cloudflare-docker.conf
					  sed -i "s/APIKEY00000/$cftoken/g" /etc/fail2ban/action.d/cloudflare-docker.conf
					  f2b_status

					  echo "已配置cloudflare模式，可在cf後台，站點-安全性-事件中查看攔截記錄"
					  ;;

				  22)
					  send_stats "高負載開啟5秒盾"
					  echo -e "${gl_huang}網站每5分鐘自動偵測，當達偵測到高負載會自動開盾，低負載也會自動關閉5秒盾。${gl_bai}"
					  echo "--------------"
					  echo "取得CF參數:"
					  echo -e "到cf後台右上角我的個人資料，選擇左側API令牌，取得${gl_huang}Global API Key${gl_bai}"
					  echo -e "到cf後台域名概要頁面右下方獲取${gl_huang}區域ID${gl_bai}"
					  echo "https://dash.cloudflare.com/login"
					  echo "--------------"
					  read -e -p "輸入CF的帳號:" cfuser
					  read -e -p "輸入CF的Global API Key:" cftoken
					  read -e -p "輸入CF中網域名稱的區域ID:" cfzonID

					  cd ~
					  install jq bc
					  check_crontab_installed
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/CF-Under-Attack.sh
					  chmod +x CF-Under-Attack.sh
					  sed -i "s/AAAA/$cfuser/g" ~/CF-Under-Attack.sh
					  sed -i "s/BBBB/$cftoken/g" ~/CF-Under-Attack.sh
					  sed -i "s/CCCC/$cfzonID/g" ~/CF-Under-Attack.sh

					  local cron_job="*/5 * * * * ~/CF-Under-Attack.sh"

					  local existing_cron=$(crontab -l 2>/dev/null | grep -F "$cron_job")

					  if [ -z "$existing_cron" ]; then
						  (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
						  echo "高負載自動開盾腳本已新增"
					  else
						  echo "自動開盾腳本已存在，無需添加"
					  fi

					  ;;

				  31)
					  nginx_waf on
					  echo "站點WAF已開啟"
					  send_stats "站點WAF已開啟"
					  ;;

				  32)
				  	  nginx_waf off
					  echo "站點WAF已關閉"
					  send_stats "站點WAF已關閉"
					  ;;

				  33)
					  enable_ddos_defense
					  ;;

				  34)
					  disable_ddos_defense
					  ;;

				  *)
					  break
					  ;;
			  esac
	  break_end
	  done
}



check_ldnmp_mode() {

	local MYSQL_CONTAINER="mysql"
	local MYSQL_CONF="/etc/mysql/conf.d/custom_mysql_config.cnf"

	# 檢查 MySQL 設定檔中是否包含 4096M
	if docker exec "$MYSQL_CONTAINER" grep -q "4096M" "$MYSQL_CONF" 2>/dev/null; then
		mode_info="高性能模式"
	else
		mode_info="標準模式"
	fi



}


check_nginx_compression() {

	local CONFIG_FILE="/home/web/nginx.conf"

	# 檢查 zstd 是否開啟且未被註解（整行以 zstd on; 開頭）
	if grep -qE '^\s*zstd\s+on;' "$CONFIG_FILE"; then
		zstd_status="zstd壓縮已開啟"
	else
		zstd_status=""
	fi

	# 檢查 brotli 是否開啟且未被註釋
	if grep -qE '^\s*brotli\s+on;' "$CONFIG_FILE"; then
		br_status="br壓縮已開啟"
	else
		br_status=""
	fi

	# 檢查 gzip 是否開啟且未被註釋
	if grep -qE '^\s*gzip\s+on;' "$CONFIG_FILE"; then
		gzip_status="gzip壓縮已開啟"
	else
		gzip_status=""
	fi
}




web_optimization() {
		  while true; do
		  	  check_ldnmp_mode
			  check_nginx_compression
			  clear
			  send_stats "優化LDNMP環境"
			  echo -e "優化LDNMP環境${gl_lv}${mode_info}${gzip_status}${br_status}${zstd_status}${gl_bai}"
			  echo "------------------------"
			  echo "1. 標準模式 2. 高效能模式 (建議2H4G以上)"
			  echo "------------------------"
			  echo "3. 開啟gzip壓縮 4. 關閉gzip壓縮"
			  echo "5. 開啟br壓縮 6. 關閉br壓縮"
			  echo "7. 開啟zstd壓縮 8. 關閉zstd壓縮"
			  echo "------------------------"
			  echo "0. 返回上一級選單"
			  echo "------------------------"
			  read -e -p "請輸入你的選擇:" sub_choice
			  case $sub_choice in
				  1)
				  send_stats "站點標準模式"

				  local cpu_cores=$(nproc)
				  local connections=$((1024 * ${cpu_cores}))
				  sed -i "s/worker_processes.*/worker_processes ${cpu_cores};/" /home/web/nginx.conf
				  sed -i "s/worker_connections.*/worker_connections ${connections};/" /home/web/nginx.conf


				  # php調優
				  wget -O /home/optimized_php.ini ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/optimized_php.ini
				  docker cp /home/optimized_php.ini php:/usr/local/etc/php/conf.d/optimized_php.ini
				  docker cp /home/optimized_php.ini php74:/usr/local/etc/php/conf.d/optimized_php.ini
				  rm -rf /home/optimized_php.ini

				  # php調優
				  wget -O /home/www.conf ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/www-1.conf
				  docker cp /home/www.conf php:/usr/local/etc/php-fpm.d/www.conf
				  docker cp /home/www.conf php74:/usr/local/etc/php-fpm.d/www.conf
				  rm -rf /home/www.conf

				  patch_wp_memory_limit
				  patch_wp_debug

				  fix_phpfpm_conf php
				  fix_phpfpm_conf php74

				  # mysql調優
				  wget -O /home/custom_mysql_config.cnf ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/custom_mysql_config-1.cnf
				  docker cp /home/custom_mysql_config.cnf mysql:/etc/mysql/conf.d/
				  rm -rf /home/custom_mysql_config.cnf


				  cd /home/web && docker compose restart

				  optimize_balanced


				  echo "LDNMP環境已設定成 標準模式"

					  ;;
				  2)
				  send_stats "站點高效能模式"

				  # nginx調優
				  local cpu_cores=$(nproc)
				  local connections=$((2048 * ${cpu_cores}))
				  sed -i "s/worker_processes.*/worker_processes ${cpu_cores};/" /home/web/nginx.conf
				  sed -i "s/worker_connections.*/worker_connections ${connections};/" /home/web/nginx.conf

				  # php調優
				  wget -O /home/optimized_php.ini ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/optimized_php.ini
				  docker cp /home/optimized_php.ini php:/usr/local/etc/php/conf.d/optimized_php.ini
				  docker cp /home/optimized_php.ini php74:/usr/local/etc/php/conf.d/optimized_php.ini
				  rm -rf /home/optimized_php.ini

				  # php調優
				  wget -O /home/www.conf ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/www.conf
				  docker cp /home/www.conf php:/usr/local/etc/php-fpm.d/www.conf
				  docker cp /home/www.conf php74:/usr/local/etc/php-fpm.d/www.conf
				  rm -rf /home/www.conf

				  patch_wp_memory_limit 512M 512M
				  patch_wp_debug

				  fix_phpfpm_conf php
				  fix_phpfpm_conf php74

				  # mysql調優
				  wget -O /home/custom_mysql_config.cnf ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/custom_mysql_config.cnf
				  docker cp /home/custom_mysql_config.cnf mysql:/etc/mysql/conf.d/
				  rm -rf /home/custom_mysql_config.cnf

				  cd /home/web && docker compose restart

				  optimize_web_server

				  echo "LDNMP環境已設定成 高效能模式"

					  ;;
				  3)
				  send_stats "nginx_gzip on"
				  nginx_gzip on
					  ;;
				  4)
				  send_stats "nginx_gzip off"
				  nginx_gzip off
					  ;;
				  5)
				  send_stats "nginx_br on"
				  nginx_br on
					  ;;
				  6)
				  send_stats "nginx_br off"
				  nginx_br off
					  ;;
				  7)
				  send_stats "nginx_zstd on"
				  nginx_zstd on
					  ;;
				  8)
				  send_stats "nginx_zstd off"
				  nginx_zstd off
					  ;;
				  *)
					  break
					  ;;
			  esac
			  break_end

		  done


}










check_docker_app() {
	if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name" ; then
		check_docker="${gl_lv}已安裝${gl_bai}"
	else
		check_docker="${gl_hui}未安裝${gl_bai}"
	fi
}



# check_docker_app() {

# if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name"; then
# check_docker="${gl_lv}已安裝${gl_bai}"
# else
# check_docker="${gl_hui}未安裝${gl_bai}"
# fi

# }


check_docker_app_ip() {
echo "------------------------"
echo "訪問地址:"
ip_address



if [ -n "$ipv4_address" ]; then
	echo "http://$ipv4_address:${docker_port}"
fi

if [ -n "$ipv6_address" ]; then
	echo "http://[$ipv6_address]:${docker_port}"
fi

local search_pattern1="$ipv4_address:${docker_port}"
local search_pattern2="127.0.0.1:${docker_port}"

for file in /home/web/conf.d/*; do
	if [ -f "$file" ]; then
		if grep -q "$search_pattern1" "$file" 2>/dev/null || grep -q "$search_pattern2" "$file" 2>/dev/null; then
			echo "https://$(basename "$file" | sed 's/\.conf$//')"
		fi
	fi
done


}


check_docker_image_update() {
	local container_name=$1
	update_status=""

	# 1. 區域檢查
	local country=$(curl -s --max-time 2 ipinfo.io/country)
	[[ "$country" == "CN" ]] && return

	# 2. 取得本地鏡像訊息
	local container_info=$(docker inspect --format='{{.Created}},{{.Config.Image}}' "$container_name" 2>/dev/null)
	[[ -z "$container_info" ]] && return

	local container_created=$(echo "$container_info" | cut -d',' -f1)
	local full_image_name=$(echo "$container_info" | cut -d',' -f2)
	local container_created_ts=$(date -d "$container_created" +%s 2>/dev/null)

	# 3. 智慧路由判斷
	if [[ "$full_image_name" == ghcr.io* ]]; then
		# --- 場景 A: 鏡像在 GitHub (ghcr.io) ---
		# 提取倉庫路徑，例如 ghcr.io/onexru/oneimg -> onexru/oneimg
		local repo_path=$(echo "$full_image_name" | sed 's/ghcr.io\///' | cut -d':' -f1)
		# 註：ghcr.io 的 API 比較複雜，通常最快的方法是查 GitHub Repo 的 Release
		local api_url="https://api.github.com/repos/$repo_path/releases/latest"
		local remote_date=$(curl -s "$api_url" | jq -r '.published_at' 2>/dev/null)

	elif [[ "$full_image_name" == *"oneimg"* ]]; then
		# --- 場景 B: 特殊指定 (即便在 Docker Hub，也想透過 GitHub Release 判斷) ---
		local api_url="https://api.github.com/repos/onexru/oneimg/releases/latest"
		local remote_date=$(curl -s "$api_url" | jq -r '.published_at' 2>/dev/null)

	else
		# --- 場景 C: 標準 Docker Hub ---
		local image_repo=${full_image_name%%:*}
		local image_tag=${full_image_name##*:}
		[[ "$image_repo" == "$image_tag" ]] && image_tag="latest"
		[[ "$image_repo" != */* ]] && image_repo="library/$image_repo"

		local api_url="https://hub.docker.com/v2/repositories/$image_repo/tags/$image_tag"
		local remote_date=$(curl -s "$api_url" | jq -r '.last_updated' 2>/dev/null)
	fi

	# 4. 時間戳對比
	if [[ -n "$remote_date" && "$remote_date" != "null" ]]; then
		local remote_ts=$(date -d "$remote_date" +%s 2>/dev/null)
		if [[ $container_created_ts -lt $remote_ts ]]; then
			update_status="${gl_huang}發現新版本!${gl_bai}"
		fi
	fi
}







block_container_port() {
	local container_name_or_id=$1
	local allowed_ip=$2

	# 取得容器的 IP 位址
	local container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_name_or_id")

	if [ -z "$container_ip" ]; then
		return 1
	fi

	install iptables


	# 檢查並封鎖其他所有 IP
	if ! iptables -C DOCKER-USER -p tcp -d "$container_ip" -j DROP &>/dev/null; then
		iptables -I DOCKER-USER -p tcp -d "$container_ip" -j DROP
	fi

	# 檢查並放行指定 IP
	if ! iptables -C DOCKER-USER -p tcp -s "$allowed_ip" -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -I DOCKER-USER -p tcp -s "$allowed_ip" -d "$container_ip" -j ACCEPT
	fi

	# 檢查並放行本地網路 127.0.0.0/8
	if ! iptables -C DOCKER-USER -p tcp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -I DOCKER-USER -p tcp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT
	fi



	# 檢查並封鎖其他所有 IP
	if ! iptables -C DOCKER-USER -p udp -d "$container_ip" -j DROP &>/dev/null; then
		iptables -I DOCKER-USER -p udp -d "$container_ip" -j DROP
	fi

	# 檢查並放行指定 IP
	if ! iptables -C DOCKER-USER -p udp -s "$allowed_ip" -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -I DOCKER-USER -p udp -s "$allowed_ip" -d "$container_ip" -j ACCEPT
	fi

	# 檢查並放行本地網路 127.0.0.0/8
	if ! iptables -C DOCKER-USER -p udp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -I DOCKER-USER -p udp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT
	fi

	if ! iptables -C DOCKER-USER -m state --state ESTABLISHED,RELATED -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -I DOCKER-USER -m state --state ESTABLISHED,RELATED -d "$container_ip" -j ACCEPT
	fi


	echo "已阻止IP+連接埠存取該服務"
	save_iptables_rules
}




clear_container_rules() {
	local container_name_or_id=$1
	local allowed_ip=$2

	# 取得容器的 IP 位址
	local container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_name_or_id")

	if [ -z "$container_ip" ]; then
		return 1
	fi

	install iptables


	# 清除封鎖其他所有 IP 的規則
	if iptables -C DOCKER-USER -p tcp -d "$container_ip" -j DROP &>/dev/null; then
		iptables -D DOCKER-USER -p tcp -d "$container_ip" -j DROP
	fi

	# 清除放行指定 IP 的規則
	if iptables -C DOCKER-USER -p tcp -s "$allowed_ip" -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -D DOCKER-USER -p tcp -s "$allowed_ip" -d "$container_ip" -j ACCEPT
	fi

	# 清除放行本地網路 127.0.0.0/8 的規則
	if iptables -C DOCKER-USER -p tcp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -D DOCKER-USER -p tcp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT
	fi





	# 清除封鎖其他所有 IP 的規則
	if iptables -C DOCKER-USER -p udp -d "$container_ip" -j DROP &>/dev/null; then
		iptables -D DOCKER-USER -p udp -d "$container_ip" -j DROP
	fi

	# 清除放行指定 IP 的規則
	if iptables -C DOCKER-USER -p udp -s "$allowed_ip" -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -D DOCKER-USER -p udp -s "$allowed_ip" -d "$container_ip" -j ACCEPT
	fi

	# 清除放行本地網路 127.0.0.0/8 的規則
	if iptables -C DOCKER-USER -p udp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -D DOCKER-USER -p udp -s 127.0.0.0/8 -d "$container_ip" -j ACCEPT
	fi


	if iptables -C DOCKER-USER -m state --state ESTABLISHED,RELATED -d "$container_ip" -j ACCEPT &>/dev/null; then
		iptables -D DOCKER-USER -m state --state ESTABLISHED,RELATED -d "$container_ip" -j ACCEPT
	fi


	echo "已允許IP+連接埠存取該服務"
	save_iptables_rules
}






block_host_port() {
	local port=$1
	local allowed_ip=$2

	if [[ -z "$port" || -z "$allowed_ip" ]]; then
		echo "錯誤：請提供連接埠號碼和允許存取的 IP。"
		echo "用法: block_host_port <連接埠號碼> <允許的IP>"
		return 1
	fi

	install iptables


	# 拒絕其他所有 IP 訪問
	if ! iptables -C INPUT -p tcp --dport "$port" -j DROP &>/dev/null; then
		iptables -I INPUT -p tcp --dport "$port" -j DROP
	fi

	# 允許指定 IP 存取
	if ! iptables -C INPUT -p tcp --dport "$port" -s "$allowed_ip" -j ACCEPT &>/dev/null; then
		iptables -I INPUT -p tcp --dport "$port" -s "$allowed_ip" -j ACCEPT
	fi

	# 允許本機訪問
	if ! iptables -C INPUT -p tcp --dport "$port" -s 127.0.0.0/8 -j ACCEPT &>/dev/null; then
		iptables -I INPUT -p tcp --dport "$port" -s 127.0.0.0/8 -j ACCEPT
	fi





	# 拒絕其他所有 IP 訪問
	if ! iptables -C INPUT -p udp --dport "$port" -j DROP &>/dev/null; then
		iptables -I INPUT -p udp --dport "$port" -j DROP
	fi

	# 允許指定 IP 存取
	if ! iptables -C INPUT -p udp --dport "$port" -s "$allowed_ip" -j ACCEPT &>/dev/null; then
		iptables -I INPUT -p udp --dport "$port" -s "$allowed_ip" -j ACCEPT
	fi

	# 允許本機訪問
	if ! iptables -C INPUT -p udp --dport "$port" -s 127.0.0.0/8 -j ACCEPT &>/dev/null; then
		iptables -I INPUT -p udp --dport "$port" -s 127.0.0.0/8 -j ACCEPT
	fi

	# 允許已建立和相關連線的流量
	if ! iptables -C INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT &>/dev/null; then
		iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	fi

	echo "已阻止IP+連接埠存取該服務"
	save_iptables_rules
}




clear_host_port_rules() {
	local port=$1
	local allowed_ip=$2

	if [[ -z "$port" || -z "$allowed_ip" ]]; then
		echo "錯誤：請提供連接埠號碼和允許存取的 IP。"
		echo "用法: clear_host_port_rules <連接埠號碼> <允許的IP>"
		return 1
	fi

	install iptables


	# 清除封鎖所有其他 IP 存取的規則
	if iptables -C INPUT -p tcp --dport "$port" -j DROP &>/dev/null; then
		iptables -D INPUT -p tcp --dport "$port" -j DROP
	fi

	# 清除允許本機存取的規則
	if iptables -C INPUT -p tcp --dport "$port" -s 127.0.0.0/8 -j ACCEPT &>/dev/null; then
		iptables -D INPUT -p tcp --dport "$port" -s 127.0.0.0/8 -j ACCEPT
	fi

	# 清除允許指定 IP 存取的規則
	if iptables -C INPUT -p tcp --dport "$port" -s "$allowed_ip" -j ACCEPT &>/dev/null; then
		iptables -D INPUT -p tcp --dport "$port" -s "$allowed_ip" -j ACCEPT
	fi


	# 清除封鎖所有其他 IP 存取的規則
	if iptables -C INPUT -p udp --dport "$port" -j DROP &>/dev/null; then
		iptables -D INPUT -p udp --dport "$port" -j DROP
	fi

	# 清除允許本機存取的規則
	if iptables -C INPUT -p udp --dport "$port" -s 127.0.0.0/8 -j ACCEPT &>/dev/null; then
		iptables -D INPUT -p udp --dport "$port" -s 127.0.0.0/8 -j ACCEPT
	fi

	# 清除允許指定 IP 存取的規則
	if iptables -C INPUT -p udp --dport "$port" -s "$allowed_ip" -j ACCEPT &>/dev/null; then
		iptables -D INPUT -p udp --dport "$port" -s "$allowed_ip" -j ACCEPT
	fi


	echo "已允許IP+連接埠存取該服務"
	save_iptables_rules

}



setup_docker_dir() {

	mkdir -p /home /home/docker 2>/dev/null

	if [ -d "/vol1/1000/" ] && [ ! -d "/vol1/1000/docker" ]; then
		cp -f /home/docker /home/docker1 2>/dev/null
		rm -rf /home/docker 2>/dev/null
		mkdir -p /vol1/1000/docker 2>/dev/null
		ln -s /vol1/1000/docker /home/docker 2>/dev/null
	fi

	if [ -d "/volume1/" ] && [ ! -d "/volume1/docker" ]; then
		cp -f /home/docker /home/docker1 2>/dev/null
		rm -rf /home/docker 2>/dev/null
		mkdir -p /volume1/docker 2>/dev/null
		ln -s /volume1/docker /home/docker 2>/dev/null
	fi


}


add_app_id() {
mkdir -p /home/docker
touch /home/docker/appno.txt
grep -qxF "${app_id}" /home/docker/appno.txt || echo "${app_id}" >> /home/docker/appno.txt

}



docker_app() {
send_stats "${docker_name}管理"

while true; do
	clear
	check_docker_app
	check_docker_image_update $docker_name
	echo -e "$docker_name $check_docker $update_status"
	echo "$docker_describe"
	echo "$docker_url"
	if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name"; then
		if [ ! -f "/home/docker/${docker_name}_port.conf" ]; then
			local docker_port=$(docker port "$docker_name" | head -n1 | awk -F'[:]' '/->/ {print $NF; exit}')
			docker_port=${docker_port:-0000}
			echo "$docker_port" > "/home/docker/${docker_name}_port.conf"
		fi
		local docker_port=$(cat "/home/docker/${docker_name}_port.conf")
		check_docker_app_ip
	fi
	echo ""
	echo "------------------------"
	echo "1. 安裝 2. 更新 3. 卸載"
	echo "------------------------"
	echo "5. 新增網域存取 6. 刪除網域存取"
	echo "7. 允許IP+連接埠存取 8. 阻止IP+連接埠訪問"
	echo "------------------------"
	echo "0. 返回上一級選單"
	echo "------------------------"
	read -e -p "請輸入你的選擇:" choice
	 case $choice in
		1)
			setup_docker_dir
			check_disk_space $app_size /home/docker
			while true; do
				read -e -p "輸入應用程式對外服務端口，回車預設使用${docker_port}連接埠:" app_port
				local app_port=${app_port:-${docker_port}}

				if ss -tuln | grep -q ":$app_port "; then
					echo -e "${gl_hong}錯誤:${gl_bai}連接埠$app_port已被佔用，請更換一個端口"
					send_stats "應用程式連接埠已被佔用"
				else
					local docker_port=$app_port
					break
				fi
			done

			install jq
			install_docker
			docker_rum
			echo "$docker_port" > "/home/docker/${docker_name}_port.conf"

			add_app_id

			clear
			echo "$docker_name已經安裝完成"
			check_docker_app_ip
			echo ""
			$docker_use
			$docker_passwd
			send_stats "安裝$docker_name"
			;;
		2)
			docker rm -f "$docker_name"
			docker rmi -f "$docker_img"
			docker_rum

			add_app_id

			clear
			echo "$docker_name已經安裝完成"
			check_docker_app_ip
			echo ""
			$docker_use
			$docker_passwd
			send_stats "更新$docker_name"
			;;
		3)
			docker rm -f "$docker_name"
			docker rmi -f "$docker_img"
			rm -rf "/home/docker/$docker_name"
			rm -f /home/docker/${docker_name}_port.conf

			sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
			echo "應用程式已解除安裝"
			send_stats "解除安裝$docker_name"
			;;

		5)
			echo "${docker_name}域名存取設定"
			send_stats "${docker_name}域名存取設定"
			add_yuming
			ldnmp_Proxy ${yuming} 127.0.0.1 ${docker_port}
			block_container_port "$docker_name" "$ipv4_address"
			;;

		6)
			echo "網域格式 example.com 不含https://"
			web_del
			;;

		7)
			send_stats "允許IP存取${docker_name}"
			clear_container_rules "$docker_name" "$ipv4_address"
			;;

		8)
			send_stats "阻止IP訪問${docker_name}"
			block_container_port "$docker_name" "$ipv4_address"
			;;

		*)
			break
			;;
	 esac
	 break_end
done

}





docker_app_plus() {
	send_stats "$app_name"
	while true; do
		clear
		check_docker_app
		check_docker_image_update $docker_name
		echo -e "$app_name $check_docker $update_status"
		echo "$app_text"
		echo "$app_url"
		if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name"; then
			if [ ! -f "/home/docker/${docker_name}_port.conf" ]; then
				local docker_port=$(docker port "$docker_name" | head -n1 | awk -F'[:]' '/->/ {print $NF; exit}')
				docker_port=${docker_port:-0000}
				echo "$docker_port" > "/home/docker/${docker_name}_port.conf"
			fi
			local docker_port=$(cat "/home/docker/${docker_name}_port.conf")
			check_docker_app_ip
		fi
		echo ""
		echo "------------------------"
		echo "1. 安裝 2. 更新 3. 卸載"
		echo "------------------------"
		echo "5. 新增網域存取 6. 刪除網域存取"
		echo "7. 允許IP+連接埠存取 8. 阻止IP+連接埠訪問"
		echo "------------------------"
		echo "0. 返回上一級選單"
		echo "------------------------"
		read -e -p "輸入你的選擇:" choice
		case $choice in
			1)
				setup_docker_dir
				check_disk_space $app_size /home/docker

				while true; do
					read -e -p "輸入應用程式對外服務端口，回車預設使用${docker_port}連接埠:" app_port
					local app_port=${app_port:-${docker_port}}

					if ss -tuln | grep -q ":$app_port "; then
						echo -e "${gl_hong}錯誤:${gl_bai}連接埠$app_port已被佔用，請更換一個端口"
						send_stats "應用程式連接埠已被佔用"
					else
						local docker_port=$app_port
						break
					fi
				done

				install jq
				install_docker
				docker_app_install
				echo "$docker_port" > "/home/docker/${docker_name}_port.conf"

				add_app_id
				send_stats "$app_name安裝"
				;;

			2)
				docker_app_update
				add_app_id
				send_stats "$app_name更新"
				;;

			3)
				docker_app_uninstall
				rm -f /home/docker/${docker_name}_port.conf

				sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
				send_stats "$app_name解除安裝"
				;;

			5)
				echo "${docker_name}域名存取設定"
				send_stats "${docker_name}域名存取設定"
				add_yuming
				ldnmp_Proxy ${yuming} 127.0.0.1 ${docker_port}
				block_container_port "$docker_name" "$ipv4_address"

				;;
			6)
				echo "網域格式 example.com 不含https://"
				web_del
				;;
			7)
				send_stats "允許IP存取${docker_name}"
				clear_container_rules "$docker_name" "$ipv4_address"
				;;
			8)
				send_stats "阻止IP訪問${docker_name}"
				block_container_port "$docker_name" "$ipv4_address"
				;;
			*)
				break
				;;
		esac
		break_end
	done
}





prometheus_install() {

local PROMETHEUS_DIR="/home/docker/monitoring/prometheus"
local GRAFANA_DIR="/home/docker/monitoring/grafana"
local NETWORK_NAME="monitoring"

# Create necessary directories
mkdir -p $PROMETHEUS_DIR
mkdir -p $GRAFANA_DIR

# Set correct ownership for Grafana directory
chown -R 472:472 $GRAFANA_DIR

if [ ! -f "$PROMETHEUS_DIR/prometheus.yml" ]; then
	curl -o "$PROMETHEUS_DIR/prometheus.yml" ${gh_proxy}raw.githubusercontent.com/kejilion/config/refs/heads/main/prometheus/prometheus.yml
fi

# Create Docker network for monitoring
docker network create $NETWORK_NAME

# Run Node Exporter container
docker run -d \
  --name=node-exporter \
  --network $NETWORK_NAME \
  --restart=always \
  prom/node-exporter

# Run Prometheus container
docker run -d \
  --name prometheus \
  -v $PROMETHEUS_DIR/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v $PROMETHEUS_DIR/data:/prometheus \
  --network $NETWORK_NAME \
  --restart=always \
  --user 0:0 \
  prom/prometheus:latest

# Run Grafana container
docker run -d \
  --name grafana \
  -p ${docker_port}:3000 \
  -v $GRAFANA_DIR:/var/lib/grafana \
  --network $NETWORK_NAME \
  --restart=always \
  grafana/grafana:latest

}




tmux_run() {
	# Check if the session already exists
	tmux has-session -t $SESSION_NAME 2>/dev/null
	# $? is a special variable that holds the exit status of the last executed command
	if [ $? != 0 ]; then
	  # Session doesn't exist, create a new one
	  tmux new -s $SESSION_NAME
	else
	  # Session exists, attach to it
	  tmux attach-session -t $SESSION_NAME
	fi
}


tmux_run_d() {

local base_name="tmuxd"
local tmuxd_ID=1

# 檢查會話是否存在的函數
session_exists() {
  tmux has-session -t $1 2>/dev/null
}

# 循環直到找到一個不存在的會話名稱
while session_exists "$base_name-$tmuxd_ID"; do
  local tmuxd_ID=$((tmuxd_ID + 1))
done

# 建立新的 tmux 會話
tmux new -d -s "$base_name-$tmuxd_ID" "$tmuxd"


}



f2b_status() {
	 fail2ban-client reload
	 sleep 3
	 fail2ban-client status
}

f2b_status_xxx() {
	fail2ban-client status $xxx
}

check_f2b_status() {
	if command -v fail2ban-client >/dev/null 2>&1; then
		check_f2b_status="${gl_lv}已安裝${gl_bai}"
	else
		check_f2b_status="${gl_hui}未安裝${gl_bai}"
	fi
}

f2b_install_sshd() {

	docker rm -f fail2ban >/dev/null 2>&1
	install fail2ban
	start fail2ban
	enable fail2ban

	if command -v dnf &>/dev/null; then
		cd /etc/fail2ban/jail.d/
		curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/config/main/fail2ban/centos-ssh.conf
	fi

	if command -v apt &>/dev/null; then
		install rsyslog
		systemctl start rsyslog
		systemctl enable rsyslog
	fi

}

f2b_sshd() {
	if grep -q 'Alpine' /etc/issue; then
		xxx=alpine-sshd
		f2b_status_xxx
	else
		xxx=sshd
		f2b_status_xxx
	fi
}

# 基礎參數配置：封禁時長(bantime)、時間視窗(findtime)、重試次數(maxretry)
# 說明：
# - 優先寫入 /etc/fail2ban/jail.d/sshd.local（覆蓋預設 jail 配置，升級不易丟）
# - 若是 Alpine 且 jail 名稱不同，仍寫 sshd.local；Fail2Ban 會以 jail 名稱配對
f2b_basic_config() {
	root_use
	install nano

	if ! command -v fail2ban-client >/dev/null 2>&1; then
		echo -e "${gl_hui}未偵測到 fail2ban-client，請先安裝 fail2ban。${gl_bai}"
		return
	fi

	local jail_name="sshd"
	if grep -qi 'Alpine' /etc/issue 2>/dev/null; then
		# Alpine 預設 jail 通常為 sshd；僅當偵測到自訂 alpine-sshd 規則時才切換
		if [ -f /etc/fail2ban/filter.d/alpine-sshd.conf ] || [ -f /etc/fail2ban/jail.d/alpine-ssh.conf ] || [ -f /etc/fail2ban/jail.d/alpine-sshd.local ]; then
			jail_name="alpine-sshd"
		fi
	fi

	echo "即將配置 SSH jail：$jail_name"
	read -e -p "封禁時長 bantime (秒/分鐘/小時，如 3600 或 1h) [預設 1h]:" bantime
	read -e -p "時間窗口 findtime (秒/分鐘/小時，如 600 或 10m) [預設 10m]:" findtime
	read -e -p "重試次數 maxretry (整數) [預設 5]:" maxretry

	bantime=${bantime:-1h}
	findtime=${findtime:-10m}
	maxretry=${maxretry:-5}

	mkdir -p /etc/fail2ban/jail.d
	cat > /etc/fail2ban/jail.d/sshd.local <<EOF
[$jail_name]
# Managed by kejilion.sh
# Note: enable the jail so these parameters take effect
enabled = true
bantime = $bantime
findtime = $findtime
maxretry = $maxretry
EOF

	# Ensure a logfile exists for sshd jail on Debian/Ubuntu minimal images
	# (without it, fail2ban-server may refuse to start)
	if [ "$jail_name" = "sshd" ]; then
		if [ -f /etc/fail2ban/jail.d/sshd.local ]; then
			grep -qE '^\s*logpath\s*=' /etc/fail2ban/jail.d/sshd.local || echo 'logpath = /var/log/auth.log' >> /etc/fail2ban/jail.d/sshd.local
		fi
	fi

	echo -e "${gl_lv}已寫入配置${gl_bai}: /etc/fail2ban/jail.d/sshd.local"
	fail2ban-client reload >/dev/null 2>&1 || true
	sleep 2
	fail2ban-client status $jail_name || true
}

# 直接開啟主配置/覆蓋配置編輯（nano）
# 優先編輯 /etc/fail2ban/jail.d/sshd.local（更安全），若不存在則創建
f2b_edit_config() {
	root_use
	install nano

	if [ ! -d /etc/fail2ban ]; then
		echo -e "${gl_hui}/etc/fail2ban 不存在，請先安裝 fail2ban。${gl_bai}"
		return
	fi

	mkdir -p /etc/fail2ban/jail.d
	local cfg="/etc/fail2ban/jail.d/sshd.local"
	[ -f "$cfg" ] || printf "[sshd]\n# bantime/findtime/maxretry\n" > "$cfg"

	nano "$cfg"
	echo -e "${gl_lv}已儲存${gl_bai}，正在 reload fail2ban..."
	fail2ban-client reload >/dev/null 2>&1 || true
}



server_reboot() {

	read -e -p "$(echo -e "${gl_huang}提示: ${gl_bai}现在重启服务器吗？(Y/N): ")" rboot
	case "$rboot" in
	  [Yy])
		echo "已重啟"
		reboot
		;;
	  *)
		echo "已取消"
		;;
	esac


}





output_status() {
	output=$(awk 'BEGIN { rx_total = 0; tx_total = 0 }
		$1 ~ /^(eth|ens|enp|eno)[0-9]+/ {
			rx_total += $2
			tx_total += $10
		}
		END {
			rx_units = "Bytes";
			tx_units = "Bytes";
			if (rx_total > 1024) { rx_total /= 1024; rx_units = "K"; }
			if (rx_total > 1024) { rx_total /= 1024; rx_units = "M"; }
			if (rx_total > 1024) { rx_total /= 1024; rx_units = "G"; }

			if (tx_total > 1024) { tx_total /= 1024; tx_units = "K"; }
			if (tx_total > 1024) { tx_total /= 1024; tx_units = "M"; }
			if (tx_total > 1024) { tx_total /= 1024; tx_units = "G"; }

			printf("%.2f%s %.2f%s\n", rx_total, rx_units, tx_total, tx_units);
		}' /proc/net/dev)

	rx=$(echo "$output" | awk '{print $1}')
	tx=$(echo "$output" | awk '{print $2}')

}




ldnmp_install_status_one() {

   if docker inspect "php" &>/dev/null; then
	clear
	send_stats "無法再次安裝LDNMP環境"
	echo -e "${gl_huang}提示:${gl_bai}建站環境已安裝。無需再次安裝！"
	break_end
	linux_ldnmp
   fi

}


ldnmp_install_all() {
cd ~
send_stats "安裝LDNMP環境"
root_use
clear
echo -e "${gl_huang}LDNMP環境未安裝，開始安裝LDNMP環境...${gl_bai}"
check_disk_space 3 /home
install_dependency
install_docker
install_certbot
install_ldnmp_conf
install_ldnmp

}


nginx_install_all() {
cd ~
send_stats "安裝nginx環境"
root_use
clear
echo -e "${gl_huang}nginx未安裝，開始安裝nginx環境...${gl_bai}"
install_dependency
install_docker
install_certbot
install_ldnmp_conf
nginx_upgrade
clear
local nginx_version=$(docker exec nginx nginx -v 2>&1)
local nginx_version=$(echo "$nginx_version" | grep -oP "nginx/\K[0-9]+\.[0-9]+\.[0-9]+")
echo "nginx已安裝完成"
echo -e "目前版本:${gl_huang}v$nginx_version${gl_bai}"
echo ""

}




ldnmp_install_status() {

	if ! docker inspect "php" &>/dev/null; then
		send_stats "請先安裝LDNMP環境"
		ldnmp_install_all
	fi

}


nginx_install_status() {

	if ! docker inspect "nginx" &>/dev/null; then
		send_stats "請先安裝nginx環境"
		nginx_install_all
	fi

}




ldnmp_web_on() {
	  clear
	  echo "您的$webname搭建好了！"
	  echo "https://$yuming"
	  echo "------------------------"
	  echo "$webname安裝資訊如下:"

}

nginx_web_on() {
	clear

	local ipv4_pattern='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
	local ipv6_pattern='^(([0-9A-Fa-f]{1,4}:){1,7}:|([0-9A-Fa-f]{1,4}:){7,7}[0-9A-Fa-f]{1,4}|::1)$'

	echo "您的$webname搭建好了！"

	if [[ "$yuming" =~ $ipv4_pattern || "$yuming" =~ $ipv6_pattern ]]; then
		mv /home/web/conf.d/"$yuming".conf /home/web/conf.d/"${yuming}_${access_port}".conf
		echo "http://$yuming:$access_port"
	elif grep -q '^[[:space:]]*#.*if (\$scheme = http)' "/home/web/conf.d/"$yuming".conf"; then
		echo "http://$yuming"
	else
		echo "https://$yuming"
	fi
}



ldnmp_wp() {
  clear
  # wordpress
  webname="WordPress"
  yuming="${1:-}"
  send_stats "安裝$webname"
  echo "開始部署$webname"
  if [ -z "$yuming" ]; then
	add_yuming
  fi
  repeat_add_yuming
  ldnmp_install_status


  install_ssltls
  certs_status
  add_db

  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/wordpress.com.conf
  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
  nginx_http_on


  cd /home/web/html
  mkdir $yuming
  cd $yuming
  wget -O latest.zip ${gh_proxy}github.com/kejilion/Website_source_code/raw/refs/heads/main/wp-latest.zip
  unzip latest.zip
  rm latest.zip
  echo "define('FS_METHOD', 'direct'); define('WP_REDIS_HOST', 'redis'); define('WP_REDIS_PORT', '6379'); define('WP_REDIS_MAXTTL', 86400); define('WP_CACHE_KEY_SALT', '${yuming}_');" >> /home/web/html/$yuming/wordpress/wp-config-sample.php
  sed -i "s|database_name_here|$dbname|g" /home/web/html/$yuming/wordpress/wp-config-sample.php
  sed -i "s|username_here|$dbuse|g" /home/web/html/$yuming/wordpress/wp-config-sample.php
  sed -i "s|password_here|$dbusepasswd|g" /home/web/html/$yuming/wordpress/wp-config-sample.php
  sed -i "s|localhost|mysql|g" /home/web/html/$yuming/wordpress/wp-config-sample.php
  patch_wp_url "https://$yuming" "https://$yuming"
  cp /home/web/html/$yuming/wordpress/wp-config-sample.php /home/web/html/$yuming/wordpress/wp-config.php


  restart_ldnmp
  nginx_web_on

}



ldnmp_Proxy() {
	clear
	webname="反向代理-IP+埠"
	yuming="${1:-}"
	reverseproxy="${2:-}"
	port="${3:-}"

	send_stats "安裝$webname"
	echo "開始部署$webname"
	if [ -z "$yuming" ]; then
		add_yuming
	fi

	check_ip_and_get_access_port "$yuming"

	if [ -z "$reverseproxy" ]; then
		read -e -p "請輸入你的反代IP (回車預設本機IP 127.0.0.1):" reverseproxy
		reverseproxy=${reverseproxy:-127.0.0.1}
	fi

	if [ -z "$port" ]; then
		read -e -p "請輸入你的反代端口:" port
	fi
	nginx_install_status


	install_ssltls
	certs_status

	wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/reverse-proxy-backend.conf

	backend=$(tr -dc 'A-Za-z' < /dev/urandom | head -c 8)
	sed -i "s/backend_yuming_com/backend_$backend/g" /home/web/conf.d/"$yuming".conf


	sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	reverseproxy_port="$reverseproxy:$port"
	upstream_servers=""
	for server in $reverseproxy_port; do
		upstream_servers="$upstream_servers    server $server;\n"
	done

	sed -i "s/# 動態添加/$upstream_servers/g" /home/web/conf.d/$yuming.conf
	sed -i '/remote_addr/d' /home/web/conf.d/$yuming.conf

	update_nginx_listen_port "$yuming" "$access_port"

	nginx_http_on
	docker exec nginx nginx -s reload
	nginx_web_on
}



ldnmp_Proxy_backend() {
	clear
	webname="反向代理-負載平衡"

	send_stats "安裝$webname"
	echo "開始部署$webname"
	if [ -z "$yuming" ]; then
		add_yuming
	fi

	check_ip_and_get_access_port "$yuming"

	if [ -z "$reverseproxy_port" ]; then
		read -e -p "請輸入你的多個反代IP+埠以空格隔開（例如 127.0.0.1:3000 127.0.0.1:3002）：" reverseproxy_port
	fi

	nginx_install_status

	install_ssltls
	certs_status

	wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/reverse-proxy-backend.conf

	backend=$(tr -dc 'A-Za-z' < /dev/urandom | head -c 8)
	sed -i "s/backend_yuming_com/backend_$backend/g" /home/web/conf.d/"$yuming".conf


	sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	upstream_servers=""
	for server in $reverseproxy_port; do
		upstream_servers="$upstream_servers    server $server;\n"
	done

	sed -i "s/# 動態添加/$upstream_servers/g" /home/web/conf.d/$yuming.conf


	update_nginx_listen_port "$yuming" "$access_port"

	nginx_http_on
	docker exec nginx nginx -s reload
	nginx_web_on
}






list_stream_services() {

	STREAM_DIR="/home/web/stream.d"
	printf "%-25s %-18s %-25s %-20s\n" "服務名" "通訊類型" "本機地址" "後端地址"

	if [ -z "$(ls -A "$STREAM_DIR")" ]; then
		return
	fi

	for conf in "$STREAM_DIR"/*; do
		# 服務名取檔名
		service_name=$(basename "$conf" .conf)

		# 取得 upstream 區塊中的 server 後端 IP:端口
		backend=$(grep -Po '(?<=server )[^;]+' "$conf" | head -n1)

		# 取得 listen 端口
		listen_port=$(grep -Po '(?<=listen )[^;]+' "$conf" | head -n1)

		# 預設本地 IP
		ip_address
		local_ip="$ipv4_address"

		# 取得通訊類型，優先從檔案名稱後綴或內容判斷
		if grep -qi 'udp;' "$conf"; then
			proto="udp"
		else
			proto="tcp"
		fi

		# 拼接監聽 IP:端口
		local_addr="$local_ip:$listen_port"

		printf "%-22s %-14s %-21s %-20s\n" "$service_name" "$proto" "$local_addr" "$backend"
	done
}









stream_panel() {
	send_stats "Stream四層代理"
	local app_id="104"
	local docker_name="nginx"

	while true; do
		clear
		check_docker_app
		check_docker_image_update $docker_name
		echo -e "Stream四層代理轉送工具$check_docker $update_status"
		echo "NGINX Stream 是 NGINX 的 TCP/UDP 代理模組，用於實現高效能的 傳輸層流量轉送和負載平衡。"
		echo "------------------------"
		if [ -d "/home/web/stream.d" ]; then
			list_stream_services
		fi
		echo ""
		echo "------------------------"
		echo "1. 安裝 2. 更新 3. 卸載"
		echo "------------------------"
		echo "4. 新增轉送服務 5. 修改轉送服務 6. 刪除轉送服務"
		echo "------------------------"
		echo "0. 返回上一級選單"
		echo "------------------------"
		read -e -p "輸入你的選擇:" choice
		case $choice in
			1)
				nginx_install_status
				add_app_id
				send_stats "安裝Stream四層代理"
				;;
			2)
				update_docker_compose_with_db_creds
				nginx_upgrade
				add_app_id
				send_stats "更新Stream四層代理"
				;;
			3)
				read -e -p "確定要刪除 nginx 容器嗎？這可能會影響網站功能！ (y/N):" confirm
				if [[ "$confirm" =~ ^[Yy]$ ]]; then
					docker rm -f nginx
					sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
					send_stats "更新Stream四層代理"
					echo "nginx 容器已刪除。"
				else
					echo "操作已取消。"
				fi

				;;

			4)
				ldnmp_Proxy_backend_stream
				add_app_id
				send_stats "新增四層代理"
				;;
			5)
				send_stats "編輯轉送配置"
				read -e -p "請輸入你要編輯的服務名稱:" stream_name
				install nano
				nano /home/web/stream.d/$stream_name.conf
				docker restart nginx
				send_stats "修改四層代理"
				;;
			6)
				send_stats "刪除轉送配置"
				read -e -p "請輸入你要刪除的服務名稱:" stream_name
				rm /home/web/stream.d/$stream_name.conf > /dev/null 2>&1
				docker restart nginx
				send_stats "刪除四層代理"
				;;
			*)
				break
				;;
		esac
		break_end
	done
}



ldnmp_Proxy_backend_stream() {
	clear
	webname="Stream四層代理-負載平衡"

	send_stats "安裝$webname"
	echo "開始部署$webname"

	# 取得代理名稱
	read -erp "請輸入代理轉發名稱 (如 mysql_proxy):" proxy_name
	if [ -z "$proxy_name" ]; then
		echo "名稱不能為空"; return 1
	fi

	# 取得監聽埠
	read -erp "請輸入本機監聽埠 (如 3306):" listen_port
	if ! [[ "$listen_port" =~ ^[0-9]+$ ]]; then
		echo "連接埠必須是數字"; return 1
	fi

	echo "請選擇協議類型："
	echo "1. TCP    2. UDP"
	read -erp "請輸入序號 [1-2]:" proto_choice

	case "$proto_choice" in
		1) proto="tcp"; listen_suffix="" ;;
		2) proto="udp"; listen_suffix=" udp" ;;
		*) echo "無效選擇"; return 1 ;;
	esac

	read -e -p "請輸入你的一個或多個後端IP+埠以空格隔開（例如 10.13.0.2:3306 10.13.0.3:3306）：" reverseproxy_port

	nginx_install_status
	cd /home && mkdir -p web/stream.d
	grep -q '^[[:space:]]*stream[[:space:]]*{' /home/web/nginx.conf || echo -e '\nstream {\n    include /etc/nginx/stream.d/*.conf;\n}' | tee -a /home/web/nginx.conf
	wget -O /home/web/stream.d/$proxy_name.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/reverse-proxy-backend-stream.conf

	backend=$(tr -dc 'A-Za-z' < /dev/urandom | head -c 8)
	sed -i "s/backend_yuming_com/${proxy_name}_${backend}/g" /home/web/stream.d/"$proxy_name".conf
	sed -i "s|listen 80|listen $listen_port $listen_suffix|g" /home/web/stream.d/$proxy_name.conf
	sed -i "s|listen \[::\]:|listen [::]:${listen_port} ${listen_suffix}|g" "/home/web/stream.d/${proxy_name}.conf"

	upstream_servers=""
	for server in $reverseproxy_port; do
		upstream_servers="$upstream_servers    server $server;\n"
	done

	sed -i "s/# 動態添加/$upstream_servers/g" /home/web/stream.d/$proxy_name.conf

	docker exec nginx nginx -s reload
	clear
	echo "您的$webname搭建好了！"
	echo "------------------------"
	echo "訪問地址:"
	ip_address
	if [ -n "$ipv4_address" ]; then
		echo "$ipv4_address:${listen_port}"
	fi
	if [ -n "$ipv6_address" ]; then
		echo "$ipv6_address:${listen_port}"
	fi
	echo ""
}





find_container_by_host_port() {
	port="$1"
	docker_name=$(docker ps --format '{{.ID}} {{.Names}}' | while read id name; do
		if docker port "$id" | grep -q ":$port"; then
			echo "$name"
			break
		fi
	done)
}




ldnmp_web_status() {
	root_use
	while true; do
		local cert_count=$(ls /home/web/certs/*_cert.pem 2>/dev/null | wc -l)
		local output="${gl_lv}${cert_count}${gl_bai}"

		local dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
		local db_count=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -e "SHOW DATABASES;" 2> /dev/null | grep -Ev "Database|information_schema|mysql|performance_schema|sys" | wc -l)
		local db_output="${gl_lv}${db_count}${gl_bai}"

		clear
		send_stats "LDNMP站台管理"
		echo "LDNMP環境"
		echo "------------------------"
		ldnmp_v

		echo -e "站點:${output}證書到期時間"
		echo -e "------------------------"
		for cert_file in /home/web/certs/*_cert.pem; do
		  local domain=$(basename "$cert_file" | sed 's/_cert.pem//')
		  if [ -n "$domain" ]; then
			local expire_date=$(openssl x509 -noout -enddate -in "$cert_file" | awk -F'=' '{print $2}')
			local formatted_date=$(date -d "$expire_date" '+%Y-%m-%d')
			printf "%-30s%s\n" "$domain" "$formatted_date"
		  fi
		done

		for conf_file in /home/web/conf.d/*_*.conf; do
		  [ -e "$conf_file" ] || continue
		  basename "$conf_file" .conf
		done

		for conf_file in /home/web/conf.d/*.conf; do
		  [ -e "$conf_file" ] || continue

		  filename=$(basename "$conf_file")

		  if [ "$filename" = "map.conf" ] || [ "$filename" = "default.conf" ]; then
			continue
		  fi

		  if ! grep -q "ssl_certificate" "$conf_file"; then
			basename "$conf_file" .conf
		  fi
		done

		echo "------------------------"
		echo ""
		echo -e "資料庫:${db_output}"
		echo -e "------------------------"
		local dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
		docker exec mysql mysql -u root -p"$dbrootpasswd" -e "SHOW DATABASES;" 2> /dev/null | grep -Ev "Database|information_schema|mysql|performance_schema|sys"

		echo "------------------------"
		echo ""
		echo "網站目錄"
		echo "------------------------"
		echo -e "數據${gl_hui}/home/web/html${gl_bai}證書${gl_hui}/home/web/certs${gl_bai}配置${gl_hui}/home/web/conf.d${gl_bai}"
		echo "------------------------"
		echo ""
		echo "操作"
		echo "------------------------"
		echo "1. 申請/更新網域憑證 2. 克隆站點域名"
		echo "3. 清理站點快取 4. 建立關聯站點"
		echo "5. 查看訪問日誌 6. 查看錯誤日誌"
		echo "7. 編輯全域配置 8. 編輯站點配置"
		echo "9. 管理站點資料庫 10. 查看站點分析報告"
		echo "------------------------"
		echo "20. 刪除指定站點數據"
		echo "------------------------"
		echo "0. 返回上一級選單"
		echo "------------------------"
		read -e -p "請輸入你的選擇:" sub_choice
		case $sub_choice in
			1)
				send_stats "申請網域證書"
				read -e -p "請輸入你的網域名稱:" yuming
				install_certbot
				docker run --rm -v /etc/letsencrypt/:/etc/letsencrypt certbot/certbot delete --cert-name "$yuming" -n 2>/dev/null
				install_ssltls
				certs_status

				;;

			2)
				send_stats "克隆站點域名"
				read -e -p "請輸入舊網域名稱:" oddyuming
				read -e -p "請輸入新網域:" yuming
				install_certbot
				install_ssltls
				certs_status


				add_db
				local odd_dbname=$(echo "$oddyuming" | sed -e 's/[^A-Za-z0-9]/_/g')
				local odd_dbname="${odd_dbname}"

				docker exec mysql mysqldump -u root -p"$dbrootpasswd" $odd_dbname | docker exec -i mysql mysql -u root -p"$dbrootpasswd" $dbname

				local tables=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -D $dbname -e "SHOW TABLES;" | awk '{ if (NR>1) print $1 }')
				for table in $tables; do
					columns=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -D $dbname -e "SHOW COLUMNS FROM $table;" | awk '{ if (NR>1) print $1 }')
					for column in $columns; do
						docker exec mysql mysql -u root -p"$dbrootpasswd" -D $dbname -e "UPDATE $table SET $column = REPLACE($column, '$oddyuming', '$yuming') WHERE $column LIKE '%$oddyuming%';"
					done
				done

				# 網站目錄替換
				cp -r /home/web/html/$oddyuming /home/web/html/$yuming

				find /home/web/html/$yuming -type f -exec sed -i "s/$odd_dbname/$dbname/g" {} +
				find /home/web/html/$yuming -type f -exec sed -i "s/$oddyuming/$yuming/g" {} +

				cp /home/web/conf.d/$oddyuming.conf /home/web/conf.d/$yuming.conf
				sed -i "s/$oddyuming/$yuming/g" /home/web/conf.d/$yuming.conf

				cd /home/web && docker compose restart

				;;


			3)
				web_cache
				;;
			4)
				send_stats "建立關聯站點"
				echo -e "為現有的站點再關聯一個新網域用於訪問"
				read -e -p "請輸入現有的網域名稱:" oddyuming
				read -e -p "請輸入新網域:" yuming
				install_certbot
				install_ssltls
				certs_status

				cp /home/web/conf.d/$oddyuming.conf /home/web/conf.d/$yuming.conf
				sed -i "s|server_name $oddyuming|server_name $yuming|g" /home/web/conf.d/$yuming.conf
				sed -i "s|/etc/nginx/certs/${oddyuming}_cert.pem|/etc/nginx/certs/${yuming}_cert.pem|g" /home/web/conf.d/$yuming.conf
				sed -i "s|/etc/nginx/certs/${oddyuming}_key.pem|/etc/nginx/certs/${yuming}_key.pem|g" /home/web/conf.d/$yuming.conf

				docker exec nginx nginx -s reload

				;;
			5)
				send_stats "查看訪問日誌"
				tail -n 200 /home/web/log/nginx/access.log
				break_end
				;;
			6)
				send_stats "查看錯誤日誌"
				tail -n 200 /home/web/log/nginx/error.log
				break_end
				;;
			7)
				send_stats "編輯全域配置"
				install nano
				nano /home/web/nginx.conf
				docker exec nginx nginx -s reload
				;;

			8)
				send_stats "編輯網站配置"
				read -e -p "編輯網站配置，請輸入你要編輯的網域:" yuming
				install nano
				nano /home/web/conf.d/$yuming.conf
				docker exec nginx nginx -s reload
				;;
			9)
				phpmyadmin_upgrade
				break_end
				;;
			10)
				send_stats "查看網站數據"
				install goaccess
				goaccess --log-format=COMBINED /home/web/log/nginx/access.log
				;;

			20)
				web_del
				docker run --rm -v /etc/letsencrypt/:/etc/letsencrypt certbot/certbot delete --cert-name "$yuming" -n 2>/dev/null

				;;
			*)
				break  # 跳出循环，退出菜单
				;;
		esac
	done


}


check_panel_app() {
if $lujing > /dev/null 2>&1; then
	check_panel="${gl_lv}已安裝${gl_bai}"
else
	check_panel=""
fi
}



install_panel() {
send_stats "${panelname}管理"
while true; do
	clear
	check_panel_app
	echo -e "$panelname $check_panel"
	echo "${panelname}是一款時下流行且強大的維運管理面板。"
	echo "官網介紹:$panelurl "

	echo ""
	echo "------------------------"
	echo "1. 安裝 2. 管理 3. 卸載"
	echo "------------------------"
	echo "0. 返回上一級選單"
	echo "------------------------"
	read -e -p "請輸入你的選擇:" choice
	 case $choice in
		1)
			check_disk_space 1
			install wget
			iptables_open
			panel_app_install

			add_app_id
			send_stats "${panelname}安裝"
			;;
		2)
			panel_app_manage

			add_app_id
			send_stats "${panelname}控制"

			;;
		3)
			panel_app_uninstall

			sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
			send_stats "${panelname}解除安裝"
			;;
		*)
			break
			;;
	 esac
	 break_end
done

}



check_frp_app() {

if [ -d "/home/frp/" ]; then
	check_frp="${gl_lv}已安裝${gl_bai}"
else
	check_frp="${gl_hui}未安裝${gl_bai}"
fi

}



donlond_frp() {
  role="$1"
  config_file="/home/frp/${role}.toml"

  docker run -d \
	--name "$role" \
	--restart=always \
	--network host \
	-v "$config_file":"/frp/${role}.toml" \
	kjlion/frp:alpine \
	"/frp/${role}" -c "/frp/${role}.toml"

}




generate_frps_config() {

	send_stats "安裝frp服務端"
	# 產生隨機連接埠和憑證
	local bind_port=8055
	local dashboard_port=8056
	local token=$(openssl rand -hex 16)
	local dashboard_user="user_$(openssl rand -hex 4)"
	local dashboard_pwd=$(openssl rand -hex 8)

	mkdir -p /home/frp
	touch /home/frp/frps.toml
	cat <<EOF > /home/frp/frps.toml
[common]
bind_port = $bind_port
authentication_method = token
token = $token
dashboard_port = $dashboard_port
dashboard_user = $dashboard_user
dashboard_pwd = $dashboard_pwd
EOF

	donlond_frp frps

	# 輸出產生的信息
	ip_address
	echo "------------------------"
	echo "客戶端部署時所需使用的參數"
	echo "服務IP:$ipv4_address"
	echo "token: $token"
	echo
	echo "FRP面板資訊"
	echo "FRP面板位址: http://$ipv4_address:$dashboard_port"
	echo "FRP面板使用者名稱:$dashboard_user"
	echo "FRP面板密碼:$dashboard_pwd"
	echo

	open_port 8055 8056

}



configure_frpc() {
	send_stats "安裝frp客戶端"
	read -e -p "請輸入外網對接IP:" server_addr
	read -e -p "請輸入外網對接token:" token
	echo

	mkdir -p /home/frp
	touch /home/frp/frpc.toml
	cat <<EOF > /home/frp/frpc.toml
[common]
server_addr = ${server_addr}
server_port = 8055
token = ${token}

EOF

	donlond_frp frpc

	open_port 8055

}

add_forwarding_service() {
	send_stats "新增frp內網服務"
	# 提示使用者輸入服務名稱和轉發訊息
	read -e -p "請輸入服務名稱:" service_name
	read -e -p "請輸入轉送類型 (tcp/udp) [回​​車預設tcp]:" service_type
	local service_type=${service_type:-tcp}
	read -e -p "請輸入內網IP [回車預設127.0.0.1]:" local_ip
	local local_ip=${local_ip:-127.0.0.1}
	read -e -p "請輸入內部網路連接埠:" local_port
	read -e -p "請輸入外網埠:" remote_port

	# 將使用者輸入寫入設定檔
	cat <<EOF >> /home/frp/frpc.toml
[$service_name]
type = ${service_type}
local_ip = ${local_ip}
local_port = ${local_port}
remote_port = ${remote_port}

EOF

	# 輸出產生的信息
	echo "服務$service_name已成功加入到 frpc.toml"

	docker restart frpc

	open_port $local_port

}



delete_forwarding_service() {
	send_stats "刪除frp內網服務"
	# 提示使用者輸入需要刪除的服務名稱
	read -e -p "請輸入需要刪除的服務名稱:" service_name
	# 使用 sed 刪除該服務及其相關配置
	sed -i "/\[$service_name\]/,/^$/d" /home/frp/frpc.toml
	echo "服務$service_name已成功從 frpc.toml 刪除"

	docker restart frpc

}


list_forwarding_services() {
	local config_file="$1"

	# 列印表頭
	printf "%-20s %-25s %-30s %-10s\n" "服務名稱" "內部網路位址" "外網位址" "協定"

	awk '
	BEGIN {
		server_addr=""
		server_port=""
		current_service=""
	}

	/^server_addr = / {
		gsub(/"|'"'"'/, "", $3)
		server_addr=$3
	}

	/^server_port = / {
		gsub(/"|'"'"'/, "", $3)
		server_port=$3
	}

	/^\[.*\]/ {
		# 如果已有服務訊息，在處理新服務之前列印目前服務
		if (current_service != "" && current_service != "common" && local_ip != "" && local_port != "") {
			printf "%-16s %-21s %-26s %-10s\n", \
				current_service, \
				local_ip ":" local_port, \
				server_addr ":" remote_port, \
				type
		}

		# 更新目前服務名稱
		if ($1 != "[common]") {
			gsub(/[\[\]]/, "", $1)
			current_service=$1
			# 清除之前的值
			local_ip=""
			local_port=""
			remote_port=""
			type=""
		}
	}

	/^local_ip = / {
		gsub(/"|'"'"'/, "", $3)
		local_ip=$3
	}

	/^local_port = / {
		gsub(/"|'"'"'/, "", $3)
		local_port=$3
	}

	/^remote_port = / {
		gsub(/"|'"'"'/, "", $3)
		remote_port=$3
	}

	/^type = / {
		gsub(/"|'"'"'/, "", $3)
		type=$3
	}

	END {
		# 列印最後一個服務的訊息
		if (current_service != "" && current_service != "common" && local_ip != "" && local_port != "") {
			printf "%-16s %-21s %-26s %-10s\n", \
				current_service, \
				local_ip ":" local_port, \
				server_addr ":" remote_port, \
				type
		}
	}' "$config_file"
}



# 取得 FRP 服務端端口
get_frp_ports() {
	mapfile -t ports < <(ss -tulnape | grep frps | awk '{print $5}' | awk -F':' '{print $NF}' | sort -u)
}

# 產生訪問地址
generate_access_urls() {
	# 首先獲取所有連接埠
	get_frp_ports

	# 檢查是否有非 8055/8056 的端口
	local has_valid_ports=false
	for port in "${ports[@]}"; do
		if [[ $port != "8055" && $port != "8056" ]]; then
			has_valid_ports=true
			break
		fi
	done

	# 只在有有效連接埠時顯示標題和內容
	if [ "$has_valid_ports" = true ]; then
		echo "FRP服務對外存取位址:"

		# 處理 IPv4 位址
		for port in "${ports[@]}"; do
			if [[ $port != "8055" && $port != "8056" ]]; then
				echo "http://${ipv4_address}:${port}"
			fi
		done

		# 處理 IPv6 位址（如果存在）
		if [ -n "$ipv6_address" ]; then
			for port in "${ports[@]}"; do
				if [[ $port != "8055" && $port != "8056" ]]; then
					echo "http://[${ipv6_address}]:${port}"
				fi
			done
		fi

		# 處理 HTTPS 配置
		for port in "${ports[@]}"; do
			if [[ $port != "8055" && $port != "8056" ]]; then
				local frps_search_pattern="${ipv4_address}:${port}"
				local frps_search_pattern2="127.0.0.1:${port}"
				for file in /home/web/conf.d/*.conf; do
					if [ -f "$file" ]; then
						if grep -q "$frps_search_pattern" "$file" 2>/dev/null || grep -q "$frps_search_pattern2" "$file" 2>/dev/null; then
							echo "https://$(basename "$file" .conf)"
						fi
					fi
				done
			fi
		done
	fi
}


frps_main_ports() {
	ip_address
	generate_access_urls
}




frps_panel() {
	send_stats "FRP服務端"
	local app_id="55"
	local docker_name="frps"
	local docker_port=8056
	while true; do
		clear
		check_frp_app
		check_docker_image_update $docker_name
		echo -e "FRP服務端$check_frp $update_status"
		echo "建構FRP內網穿透服務環境，將無公網IP的設備暴露到互聯網"
		echo "官網介紹:${gh_https_url}github.com/fatedier/frp/"
		echo "影片教學: https://www.bilibili.com/video/BV1yMw6e2EwL?t=124.0"
		if [ -d "/home/frp/" ]; then
			check_docker_app_ip
			frps_main_ports
		fi
		echo ""
		echo "------------------------"
		echo "1. 安裝 2. 更新 3. 卸載"
		echo "------------------------"
		echo "5. 內部網路服務網域存取 6. 刪除網域名稱訪問"
		echo "------------------------"
		echo "7. 允許IP+連接埠存取 8. 阻止IP+連接埠訪問"
		echo "------------------------"
		echo "00. 刷新服務狀態 0. 返回上一級選單"
		echo "------------------------"
		read -e -p "輸入你的選擇:" choice
		case $choice in
			1)
				install jq grep ss
				install_docker
				generate_frps_config

				add_app_id
				echo "FRP服務端已經安裝完成"
				;;
			2)
				crontab -l | grep -v 'frps' | crontab - > /dev/null 2>&1
				tmux kill-session -t frps >/dev/null 2>&1
				docker rm -f frps && docker rmi kjlion/frp:alpine >/dev/null 2>&1
				[ -f /home/frp/frps.toml ] || cp /home/frp/frp_0.61.0_linux_amd64/frps.toml /home/frp/frps.toml
				donlond_frp frps

				add_app_id
				echo "FRP服務端已經更新完成"
				;;
			3)
				crontab -l | grep -v 'frps' | crontab - > /dev/null 2>&1
				tmux kill-session -t frps >/dev/null 2>&1
				docker rm -f frps && docker rmi kjlion/frp:alpine
				rm -rf /home/frp

				close_port 8055 8056

				sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
				echo "應用程式已解除安裝"
				;;
			5)
				echo "將內網穿透服務反代成域名訪問"
				send_stats "FRP對外域名訪問"
				add_yuming
				read -e -p "請輸入你的內部網路穿透服務埠:" frps_port
				ldnmp_Proxy ${yuming} 127.0.0.1 ${frps_port}
				block_host_port "$frps_port" "$ipv4_address"
				;;
			6)
				echo "網域格式 example.com 不含https://"
				web_del
				;;

			7)
				send_stats "允許IP存取"
				read -e -p "請輸入需要放行的連接埠:" frps_port
				clear_host_port_rules "$frps_port" "$ipv4_address"
				;;

			8)
				send_stats "阻止IP訪問"
				echo "如果你已經反代域名訪問了，可用此功能阻止IP+端口訪問，這樣更安全。"
				read -e -p "請輸入需要阻止的連接埠:" frps_port
				block_host_port "$frps_port" "$ipv4_address"
				;;

			00)
				send_stats "重新整理FRP服務狀態"
				echo "已經刷新FRP服務狀態"
				;;

			*)
				break
				;;
		esac
		break_end
	done
}


frpc_panel() {
	send_stats "FRP客戶端"
	local app_id="56"
	local docker_name="frpc"
	local docker_port=8055
	while true; do
		clear
		check_frp_app
		check_docker_image_update $docker_name
		echo -e "FRP客戶端$check_frp $update_status"
		echo "與服務端對接，對接後可建立內網穿透服務到網際網路存取"
		echo "官網介紹:${gh_https_url}github.com/fatedier/frp/"
		echo "影片教學: https://www.bilibili.com/video/BV1yMw6e2EwL?t=173.9"
		echo "------------------------"
		if [ -d "/home/frp/" ]; then
			[ -f /home/frp/frpc.toml ] || cp /home/frp/frp_0.61.0_linux_amd64/frpc.toml /home/frp/frpc.toml
			list_forwarding_services "/home/frp/frpc.toml"
		fi
		echo ""
		echo "------------------------"
		echo "1. 安裝 2. 更新 3. 卸載"
		echo "------------------------"
		echo "4. 新增對外服務 5. 刪除對外服務 6. 手動設定服務"
		echo "------------------------"
		echo "0. 返回上一級選單"
		echo "------------------------"
		read -e -p "輸入你的選擇:" choice
		case $choice in
			1)
				install jq grep ss
				install_docker
				configure_frpc

				add_app_id
				echo "FRP客戶端已經安裝完成"
				;;
			2)
				crontab -l | grep -v 'frpc' | crontab - > /dev/null 2>&1
				tmux kill-session -t frpc >/dev/null 2>&1
				docker rm -f frpc && docker rmi kjlion/frp:alpine >/dev/null 2>&1
				[ -f /home/frp/frpc.toml ] || cp /home/frp/frp_0.61.0_linux_amd64/frpc.toml /home/frp/frpc.toml
				donlond_frp frpc

				add_app_id
				echo "FRP客戶端已經更新完成"
				;;

			3)
				crontab -l | grep -v 'frpc' | crontab - > /dev/null 2>&1
				tmux kill-session -t frpc >/dev/null 2>&1
				docker rm -f frpc && docker rmi kjlion/frp:alpine
				rm -rf /home/frp
				close_port 8055

				sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
				echo "應用程式已解除安裝"
				;;

			4)
				add_forwarding_service
				;;

			5)
				delete_forwarding_service
				;;

			6)
				install nano
				nano /home/frp/frpc.toml
				docker restart frpc
				;;

			*)
				break
				;;
		esac
		break_end
	done
}




yt_menu_pro() {

	local app_id="66"
	local VIDEO_DIR="/home/yt-dlp"
	local URL_FILE="$VIDEO_DIR/urls.txt"
	local ARCHIVE_FILE="$VIDEO_DIR/archive.txt"

	mkdir -p "$VIDEO_DIR"

	while true; do

		if [ -x "/usr/local/bin/yt-dlp" ]; then
		   local YTDLP_STATUS="${gl_lv}已安裝${gl_bai}"
		else
		   local YTDLP_STATUS="${gl_hui}未安裝${gl_bai}"
		fi

		clear
		send_stats "yt-dlp 下載工具"
		echo -e "yt-dlp $YTDLP_STATUS"
		echo -e "yt-dlp 是一個功能強大的影片下載工具，支援 YouTube、Bilibili、Twitter 等數千網站。"
		echo -e "官網位址：${gh_https_url}github.com/yt-dlp/yt-dlp"
		echo "-------------------------"
		echo "已下載影片清單:"
		ls -td "$VIDEO_DIR"/*/ 2>/dev/null || echo "（暫無）"
		echo "-------------------------"
		echo "1. 安裝 2. 更新 3. 卸載"
		echo "-------------------------"
		echo "5. 單一影片下載 6. 大量影片下載 7. 自訂參數下載"
		echo "8. 下載為MP3音訊 9.刪除影片目錄 10. Cookie管理（開發中）"
		echo "-------------------------"
		echo "0. 返回上一級選單"
		echo "-------------------------"
		read -e -p "請輸入選項編號:" choice

		case $choice in
			1)
				send_stats "正在安裝 yt-dlp..."
				echo "正在安裝 yt-dlp..."
				install ffmpeg
				curl -L ${gh_https_url}github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
				chmod a+rx /usr/local/bin/yt-dlp

				add_app_id
				echo "安裝完成。按任意鍵繼續..."
				read ;;
			2)
				send_stats "正在更新 yt-dlp..."
				echo "正在更新 yt-dlp..."
				yt-dlp -U

				add_app_id
				echo "更新完成。按任意鍵繼續..."
				read ;;
			3)
				send_stats "正在卸載 yt-dlp..."
				echo "正在卸載 yt-dlp..."
				rm -f /usr/local/bin/yt-dlp

				sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
				echo "卸載完成。按任意鍵繼續..."
				read ;;
			5)
				send_stats "單一影片下載"
				read -e -p "請輸入影片連結:" url
				yt-dlp -P "$VIDEO_DIR" -f "bv*+ba/b" --merge-output-format mp4 \
					--write-subs --sub-langs all \
					--write-thumbnail --embed-thumbnail \
					--write-info-json \
					-o "$VIDEO_DIR/%(title)s/%(title)s.%(ext)s" \
					--no-overwrites --no-post-overwrites "$url"
				read -e -p "下載完成，按任何鍵繼續..." ;;
			6)
				send_stats "大量影片下載"
				install nano
				if [ ! -f "$URL_FILE" ]; then
				  echo -e "# 輸入多個視訊連結位址\n# https://www.bilibili.com/bangumi/play/ep733316?spm_id_from=333.337.0.0&from_spmid=666.25.episode.0" > "$URL_FILE"
				fi
				nano $URL_FILE
				echo "現在開始批量下載..."
				yt-dlp -P "$VIDEO_DIR" -f "bv*+ba/b" --merge-output-format mp4 \
					--write-subs --sub-langs all \
					--write-thumbnail --embed-thumbnail \
					--write-info-json \
					-a "$URL_FILE" \
					-o "$VIDEO_DIR/%(title)s/%(title)s.%(ext)s" \
					--no-overwrites --no-post-overwrites
				read -e -p "批次下載完成，按任何鍵繼續..." ;;
			7)
				send_stats "自訂影片下載"
				read -e -p "請輸入完整 yt-dlp 參數（不含 yt-dlp）:" custom
				yt-dlp -P "$VIDEO_DIR" $custom \
					--write-subs --sub-langs all \
					--write-thumbnail --embed-thumbnail \
					--write-info-json \
					-o "$VIDEO_DIR/%(title)s/%(title)s.%(ext)s" \
					--no-overwrites --no-post-overwrites
				read -e -p "執行完成，按任意鍵繼續..." ;;
			8)
				send_stats "MP3下載"
				read -e -p "請輸入影片連結:" url
				yt-dlp -P "$VIDEO_DIR" -x --audio-format mp3 \
					--write-subs --sub-langs all \
					--write-thumbnail --embed-thumbnail \
					--write-info-json \
					-o "$VIDEO_DIR/%(title)s/%(title)s.%(ext)s" \
					--no-overwrites --no-post-overwrites "$url"
				read -e -p "音訊下載完成，按任意鍵繼續..." ;;

			9)
				send_stats "刪除影片"
				read -e -p "請輸入刪除影片名稱:" rmdir
				rm -rf "$VIDEO_DIR/$rmdir"
				;;
			*)
				break ;;
		esac
	done
}





current_timezone() {
	if grep -q 'Alpine' /etc/issue; then
	   date +"%Z %z"
	else
	   timedatectl | grep "Time zone" | awk '{print $3}'
	fi

}


set_timedate() {
	local shiqu="$1"
	if grep -q 'Alpine' /etc/issue; then
		install tzdata
		cp /usr/share/zoneinfo/${shiqu} /etc/localtime
		hwclock --systohc
	else
		timedatectl set-timezone ${shiqu}
	fi
}



# 修復dpkg中斷問題
fix_dpkg() {
	pkill -9 -f 'apt|dpkg'
	rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock
	DEBIAN_FRONTEND=noninteractive dpkg --configure -a
}


linux_update() {
	echo -e "${gl_kjlan}正在系統更新...${gl_bai}"
	if command -v dnf &>/dev/null; then
		dnf -y update
	elif command -v yum &>/dev/null; then
		yum -y update
	elif command -v apt &>/dev/null; then
		fix_dpkg
		DEBIAN_FRONTEND=noninteractive apt update -y
		DEBIAN_FRONTEND=noninteractive apt full-upgrade -y
	elif command -v apk &>/dev/null; then
		apk update && apk upgrade
	elif command -v pacman &>/dev/null; then
		pacman -Syu --noconfirm
	elif command -v zypper &>/dev/null; then
		zypper refresh
		zypper update
	elif command -v opkg &>/dev/null; then
		opkg update
	else
		echo "未知的套件管理器!"
		return
	fi
}



linux_clean() {
	echo -e "${gl_kjlan}正在系統清理...${gl_bai}"
	if command -v dnf &>/dev/null; then
		rpm --rebuilddb
		dnf autoremove -y
		dnf clean all
		dnf makecache
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v yum &>/dev/null; then
		rpm --rebuilddb
		yum autoremove -y
		yum clean all
		yum makecache
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v apt &>/dev/null; then
		fix_dpkg
		apt autoremove --purge -y
		apt clean -y
		apt autoclean -y
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v apk &>/dev/null; then
		echo "清理包管理器快取..."
		apk cache clean
		echo "刪除系統日誌..."
		rm -rf /var/log/*
		echo "刪除APK快取..."
		rm -rf /var/cache/apk/*
		echo "刪除臨時檔案..."
		rm -rf /tmp/*

	elif command -v pacman &>/dev/null; then
		pacman -Rns $(pacman -Qdtq) --noconfirm
		pacman -Scc --noconfirm
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v zypper &>/dev/null; then
		zypper clean --all
		zypper refresh
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v opkg &>/dev/null; then
		echo "刪除系統日誌..."
		rm -rf /var/log/*
		echo "刪除臨時檔案..."
		rm -rf /tmp/*

	elif command -v pkg &>/dev/null; then
		echo "清理未使用的依賴..."
		pkg autoremove -y
		echo "清理包管理器快取..."
		pkg clean -y
		echo "刪除系統日誌..."
		rm -rf /var/log/*
		echo "刪除臨時檔案..."
		rm -rf /tmp/*

	else
		echo "未知的套件管理器!"
		return
	fi
	return
}



bbr_on() {

# 統一寫入到 sysctl.d 以防與核心調優模組打架
local CONF="/etc/sysctl.d/99-kejilion-bbr.conf"
mkdir -p /etc/sysctl.d
echo "net.core.default_qdisc=fq" > "$CONF"
echo "net.ipv4.tcp_congestion_control=bbr" >> "$CONF"

# 清理可能導致衝突的舊版 sysctl.conf 殘留
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf 2>/dev/null
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf 2>/dev/null

sysctl -p "$CONF" >/dev/null 2>&1 || sysctl --system >/dev/null 2>&1

}


set_dns() {

ip_address

chattr -i /etc/resolv.conf
> /etc/resolv.conf

if [ -n "$ipv4_address" ]; then
	echo "nameserver $dns1_ipv4" >> /etc/resolv.conf
	echo "nameserver $dns2_ipv4" >> /etc/resolv.conf
fi

if [ -n "$ipv6_address" ]; then
	echo "nameserver $dns1_ipv6" >> /etc/resolv.conf
	echo "nameserver $dns2_ipv6" >> /etc/resolv.conf
fi

if [ ! -s /etc/resolv.conf ]; then
	echo "nameserver 223.5.5.5" >> /etc/resolv.conf
	echo "nameserver 8.8.8.8" >> /etc/resolv.conf
fi

chattr +i /etc/resolv.conf

}


set_dns_ui() {
root_use
send_stats "優化DNS"
while true; do
	clear
	echo "優化DNS位址"
	echo "------------------------"
	echo "目前DNS地址"
	cat /etc/resolv.conf
	echo "------------------------"
	echo ""
	echo "1. 國外DNS優化:"
	echo " v4: 1.1.1.1 8.8.8.8"
	echo " v6: 2606:4700:4700::1111 2001:4860:4860::8888"
	echo "2. 國內DNS優化:"
	echo " v4: 223.5.5.5 183.60.83.19"
	echo " v6: 2400:3200::1 2400:da00::6666"
	echo "3. 手動編輯DNS配置"
	echo "------------------------"
	echo "0. 返回上一級選單"
	echo "------------------------"
	read -e -p "請輸入你的選擇:" Limiting
	case "$Limiting" in
	  1)
		local dns1_ipv4="1.1.1.1"
		local dns2_ipv4="8.8.8.8"
		local dns1_ipv6="2606:4700:4700::1111"
		local dns2_ipv6="2001:4860:4860::8888"
		set_dns
		send_stats "國外DNS優化"
		;;
	  2)
		local dns1_ipv4="223.5.5.5"
		local dns2_ipv4="183.60.83.19"
		local dns1_ipv6="2400:3200::1"
		local dns2_ipv6="2400:da00::6666"
		set_dns
		send_stats "國內DNS優化"
		;;
	  3)
		install nano
		chattr -i /etc/resolv.conf
		nano /etc/resolv.conf
		chattr +i /etc/resolv.conf
		send_stats "手動編輯DNS配置"
		;;
	  *)
		break
		;;
	esac
done

}



restart_ssh() {
	restart sshd ssh > /dev/null 2>&1

}



correct_ssh_config() {

	local sshd_config="/etc/ssh/sshd_config"


	if grep -Eq "^\s*PasswordAuthentication\s+no" "$sshd_config"; then
		sed -i -e 's/^\s*#\?\s*PermitRootLogin .*/PermitRootLogin prohibit-password/' \
			   -e 's/^\s*#\?\s*PasswordAuthentication .*/PasswordAuthentication no/' \
			   -e 's/^\s*#\?\s*PubkeyAuthentication .*/PubkeyAuthentication yes/' \
			   -e 's/^\s*#\?\s*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' "$sshd_config"
	else
		sed -i -e 's/^\s*#\?\s*PermitRootLogin .*/PermitRootLogin yes/' \
			   -e 's/^\s*#\?\s*PasswordAuthentication .*/PasswordAuthentication yes/' \
			   -e 's/^\s*#\?\s*PubkeyAuthentication .*/PubkeyAuthentication yes/' "$sshd_config"
	fi

	rm -rf /etc/ssh/sshd_config.d/* /etc/ssh/ssh_config.d/*
}


new_ssh_port() {

  local new_port=$1

  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

  sed -i '/^\s*#\?\s*Port\s\+/d' /etc/ssh/sshd_config
  echo "Port $new_port" >> /etc/ssh/sshd_config

  correct_ssh_config

  restart_ssh
  open_port $new_port
  remove iptables-persistent ufw firewalld iptables-services > /dev/null 2>&1

  echo "SSH 連接埠已修改為:$new_port"

  sleep 1

}



sshkey_on() {

	sed -i -e 's/^\s*#\?\s*PermitRootLogin .*/PermitRootLogin prohibit-password/' \
		   -e 's/^\s*#\?\s*PasswordAuthentication .*/PasswordAuthentication no/' \
		   -e 's/^\s*#\?\s*PubkeyAuthentication .*/PubkeyAuthentication yes/' \
		   -e 's/^\s*#\?\s*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
	rm -rf /etc/ssh/sshd_config.d/* /etc/ssh/ssh_config.d/*
	restart_ssh
	echo -e "${gl_lv}使用者金鑰登入模式已開啟，已關閉密碼登入模式，重連將會生效${gl_bai}"

}



add_sshkey() {
	chmod 700 "${HOME}"
	mkdir -p "${HOME}/.ssh"
	chmod 700 "${HOME}/.ssh"
	touch "${HOME}/.ssh/authorized_keys"

	ssh-keygen -t ed25519 -C "xxxx@gmail.com" -f "${HOME}/.ssh/sshkey" -N ""

	cat "${HOME}/.ssh/sshkey.pub" >> "${HOME}/.ssh/authorized_keys"
	chmod 600 "${HOME}/.ssh/authorized_keys"

	ip_address
	echo -e "私鑰資訊已生成，務必複製保存，可保存成${gl_huang}${ipv4_address}_ssh.key${gl_bai}文件，用於以後的SSH登錄"

	echo "--------------------------------"
	cat "${HOME}/.ssh/sshkey"
	echo "--------------------------------"

	sshkey_on
}





import_sshkey() {

	local public_key="$1"
	local base_dir="${2:-$HOME}"
	local ssh_dir="${base_dir}/.ssh"
	local auth_keys="${ssh_dir}/authorized_keys"

	if [[ -z "$public_key" ]]; then
		read -e -p "請輸入您的SSH公鑰內容（通常以 'ssh-rsa' 或 'ssh-ed25519' 開頭）:" public_key
	fi

	if [[ -z "$public_key" ]]; then
		echo -e "${gl_hong}錯誤：未輸入公鑰內容。${gl_bai}"
		return 1
	fi

	if [[ ! "$public_key" =~ ^ssh-(rsa|ed25519|ecdsa) ]]; then
		echo -e "${gl_hong}錯誤：看起來不像合法的 SSH 公鑰。${gl_bai}"
		return 1
	fi

	if grep -Fxq "$public_key" "$auth_keys" 2>/dev/null; then
		echo "該公鑰已存在，無需重複添加"
		return 0
	fi

	mkdir -p "$ssh_dir"
	chmod 700 "$ssh_dir"
	touch "$auth_keys"
	echo "$public_key" >> "$auth_keys"
	chmod 600 "$auth_keys"

	sshkey_on
}



fetch_remote_ssh_keys() {

	local keys_url="$1"
	local base_dir="${2:-$HOME}"
	local ssh_dir="${base_dir}/.ssh"
	local authorized_keys="${ssh_dir}/authorized_keys"
	local temp_file

	if [[ -z "${keys_url}" ]]; then
		read -e -p "請輸入您的遠端公鑰URL：" keys_url
	fi

	echo "此腳本將從遠端 URL 拉取 SSH 公鑰，並添加到${authorized_keys}"
	echo ""
	echo "遠端公鑰地址："
	echo "  ${keys_url}"
	echo ""

	# 建立臨時文件
	temp_file=$(mktemp)

	# 下載公鑰
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL --connect-timeout 10 "${keys_url}" -o "${temp_file}" || {
			echo "錯誤：無法從 URL 下載公鑰（網路問題或位址無效）" >&2
			rm -f "${temp_file}"
			return 1
		}
	elif command -v wget >/dev/null 2>&1; then
		wget -q --timeout=10 -O "${temp_file}" "${keys_url}" || {
			echo "錯誤：無法從 URL 下載公鑰（網路問題或位址無效）" >&2
			rm -f "${temp_file}"
			return 1
		}
	else
		echo "錯誤：系統中未找到 curl 或 wget，無法下載公鑰" >&2
		rm -f "${temp_file}"
		return 1
	fi

	# 檢查內容是否有效
	if [[ ! -s "${temp_file}" ]]; then
		echo "錯誤：下載到的檔案為空，URL 可能不包含任何公鑰" >&2
		rm -f "${temp_file}"
		return 1
	fi

	mkdir -p "${ssh_dir}"
	chmod 700 "${ssh_dir}"
	touch "${authorized_keys}"
	chmod 600 "${authorized_keys}"

	# 備份原有 authorized_keys
	if [[ -f "${authorized_keys}" ]]; then
		cp "${authorized_keys}" "${authorized_keys}.bak.$(date +%Y%m%d-%H%M%S)"
		echo "已備份原有 authorized_keys 文件"
	fi

	# 追加公鑰（避免重複）
	local added=0
	while IFS= read -r line; do
		[[ -z "${line}" || "${line}" =~ ^# ]] && continue

		if ! grep -Fxq "${line}" "${authorized_keys}" 2>/dev/null; then
			echo "${line}" >> "${authorized_keys}"
			((added++))
		fi
	done < "${temp_file}"

	rm -f "${temp_file}"

	echo ""
	if (( added > 0 )); then
		echo "成功添加${added}條新的公鑰到${authorized_keys}"
		sshkey_on
	else
		echo "沒有新的公鑰需要添加（可能已全部存在）"
	fi

	echo ""
}




fetch_github_ssh_keys() {

	local username="$1"
	local base_dir="${2:-$HOME}"

	echo "操作前，請確保您已在 GitHub 帳戶中新增了 SSH 公鑰："
	echo "1. 登入${gh_https_url}github.com/settings/keys"
	echo "2. 點選 New SSH key 或 Add SSH key"
	echo "3. Title 可隨意填寫（例如：Home Laptop 2026）"
	echo "4. 將本機公鑰內容（通常是 ~/.ssh/id_ed25519.pub 或 id_rsa.pub 的全部內容）貼到 Key 字段"
	echo "5. 點選 Add SSH key 完成新增"
	echo ""
	echo "新增完成後，GitHub 會公開提供您的所有公鑰，位址為："
	echo "  ${gh_https_url}github.com/您的使用者名稱.keys"
	echo ""


	if [[ -z "${username}" ]]; then
		read -e -p "請輸入您的 GitHub 使用者名稱（username，不含 @）：" username
	fi

	if [[ -z "${username}" ]]; then
		echo "錯誤：GitHub 使用者名稱不能為空" >&2
		return 1
	fi

	keys_url="${gh_https_url}github.com/${username}.keys"

	fetch_remote_ssh_keys "${keys_url}" "${base_dir}"

}


sshkey_panel() {
  root_use
  send_stats "使用者密鑰登入"
  while true; do
	  clear
	  local REAL_STATUS=$(grep -i "^PubkeyAuthentication" /etc/ssh/sshd_config | tr '[:upper:]' '[:lower:]')
	  if [[ "$REAL_STATUS" =~ "yes" ]]; then
		  IS_KEY_ENABLED="${gl_lv}已啟用${gl_bai}"
	  else
	  	  IS_KEY_ENABLED="${gl_hui}未啟用${gl_bai}"
	  fi
  	  echo -e "使用者密鑰登入模式${IS_KEY_ENABLED}"
  	  echo "進階玩法: https://blog.kejilion.pro/ssh-key"
  	  echo "------------------------------------------------"
  	  echo "將會產生金鑰對，更安全的方式SSH登錄"
	  echo "------------------------"
	  echo "1. 產生新密鑰對 2. 手動輸入已有公鑰"
	  echo "3. 從GitHub導入已有公鑰 4. 從網址導入已有公鑰"
	  echo "5. 編輯公鑰檔案 6. 查看本機金鑰"
	  echo "------------------------"
	  echo "0. 返回上一級選單"
	  echo "------------------------"
	  read -e -p "請輸入你的選擇:" host_dns
	  case $host_dns in
		  1)
	  		send_stats "產生新密鑰"
	  		add_sshkey
			break_end
			  ;;
		  2)
			send_stats "導入已有公鑰"
			import_sshkey
			break_end
			  ;;
		  3)
			send_stats "導入GitHub遠端公鑰"
			fetch_github_ssh_keys
			break_end
			  ;;
		  4)
			send_stats "導入URL遠端公鑰"
			read -e -p "請輸入您的遠端公鑰URL：" keys_url
			fetch_remote_ssh_keys "${keys_url}"
			break_end
			  ;;

		  5)
			send_stats "編輯公鑰文件"
			install nano
			nano ${HOME}/.ssh/authorized_keys
			break_end
			  ;;

		  6)
			send_stats "查看本機密鑰"
			echo "------------------------"
			echo "公鑰資訊"
			cat ${HOME}/.ssh/authorized_keys
			echo "------------------------"
			echo "私鑰資訊"
			cat ${HOME}/.ssh/sshkey
			echo "------------------------"
			break_end
			  ;;
		  *)
			  break  # 跳出循环，退出菜单
			  ;;
	  esac
  done


}






add_sshpasswd() {

	root_use
	send_stats "設定密碼登入模式"
	echo "設定密碼登入模式"

	local target_user="$1"

	# 如果沒有透過參數傳入，則交互輸入
	if [[ -z "$target_user" ]]; then
		read -e -p "請輸入要修改密碼的使用者名稱（預設 root）:" target_user
	fi

	# 回車不輸入，預設 root
	target_user=${target_user:-root}

	# 校驗用戶是否存在
	if ! id "$target_user" >/dev/null 2>&1; then
		echo "錯誤：用戶$target_user不存在"
		return 1
	fi

	passwd "$target_user"

	if [[ "$target_user" == "root" ]]; then
		sed -i 's/^\s*#\?\s*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
	fi

	sed -i 's/^\s*#\?\s*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
	rm -rf /etc/ssh/sshd_config.d/* /etc/ssh/ssh_config.d/*

	restart_ssh

	echo -e "${gl_lv}密碼設定完畢，已更改為密碼登入模式！${gl_bai}"
}














root_use() {
clear
[ "$EUID" -ne 0 ] && echo -e "${gl_huang}提示:${gl_bai}該功能需要root用戶才能運作！" && break_end && kejilion
}












dd_xitong() {
		send_stats "重裝系統"
		dd_xitong_MollyLau() {
			wget --no-check-certificate -qO InstallNET.sh "${gh_proxy}raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh" && chmod a+x InstallNET.sh

		}

		dd_xitong_bin456789() {
			curl -O ${gh_proxy}raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh
		}

		dd_xitong_1() {
		  echo -e "重裝後初始使用者名稱:${gl_huang}root${gl_bai}初始密碼:${gl_huang}LeitboGi0ro${gl_bai}初始連接埠:${gl_huang}22${gl_bai}"
		  echo -e "${gl_huang}重裝後請及時修改初始密碼，以防止暴力入侵。命令列輸入passwd修改密碼${gl_bai}"
		  echo -e "按任意鍵繼續..."
		  read -n 1 -s -r -p ""
		  install wget
		  dd_xitong_MollyLau
		}

		dd_xitong_2() {
		  echo -e "重裝後初始使用者名稱:${gl_huang}Administrator${gl_bai}初始密碼:${gl_huang}Teddysun.com${gl_bai}初始連接埠:${gl_huang}3389${gl_bai}"
		  echo -e "按任意鍵繼續..."
		  read -n 1 -s -r -p ""
		  install wget
		  dd_xitong_MollyLau
		}

		dd_xitong_3() {
		  echo -e "重裝後初始使用者名稱:${gl_huang}root${gl_bai}初始密碼:${gl_huang}123@@@${gl_bai}初始連接埠:${gl_huang}22${gl_bai}"
		  echo -e "按任意鍵繼續..."
		  read -n 1 -s -r -p ""
		  dd_xitong_bin456789
		}

		dd_xitong_4() {
		  echo -e "重裝後初始使用者名稱:${gl_huang}Administrator${gl_bai}初始密碼:${gl_huang}123@@@${gl_bai}初始連接埠:${gl_huang}3389${gl_bai}"
		  echo -e "按任意鍵繼續..."
		  read -n 1 -s -r -p ""
		  dd_xitong_bin456789
		}

		  while true; do
			root_use
			echo "重裝系統"
			echo "--------------------------------"
			echo -e "${gl_hong}注意:${gl_bai}重裝有風險失聯，不放心者慎用。重裝預計花費15分鐘，請提前備份資料。"
			echo -e "${gl_hui}感謝bin456789大佬和leitbogioro大佬的腳本支持！${gl_bai} "
			echo -e "${gl_hui}bin456789項目地址:${gh_https_url}github.com/bin456789/reinstall${gl_bai}"
			echo -e "${gl_hui}leitbogioro專案地址:${gh_https_url}github.com/leitbogioro/Tools${gl_bai}"
			echo "------------------------"
			echo "1. Debian 13                  2. Debian 12"
			echo "3. Debian 11                  4. Debian 10"
			echo "------------------------"
			echo "11. Ubuntu 24.04              12. Ubuntu 22.04"
			echo "13. Ubuntu 20.04              14. Ubuntu 18.04"
			echo "------------------------"
			echo "21. Rocky Linux 10            22. Rocky Linux 9"
			echo "23. Alma Linux 10             24. Alma Linux 9"
			echo "25. oracle Linux 10           26. oracle Linux 9"
			echo "27. Fedora Linux 42           28. Fedora Linux 41"
			echo "29. CentOS 10                 30. CentOS 9"
			echo "------------------------"
			echo "31. Alpine Linux              32. Arch Linux"
			echo "33. Kali Linux                34. openEuler"
			echo "35. openSUSE Tumbleweed 36. fnos飛牛公測版"
			echo "------------------------"
			echo "41. Windows 11                42. Windows 10"
			echo "43. Windows 7                 44. Windows Server 2025"
			echo "45. Windows Server 2022       46. Windows Server 2019"
			echo "47. Windows 11 ARM"
			echo "------------------------"
			echo "0. 返回上一級選單"
			echo "------------------------"
			read -e -p "請選擇要重裝的系統:" sys_choice
			case "$sys_choice" in


			  1)
				send_stats "重裝debian 13"
				dd_xitong_3
				bash reinstall.sh debian 13
				reboot
				exit
				;;

			  2)
				send_stats "重裝debian 12"
				dd_xitong_1
				bash InstallNET.sh -debian 12
				reboot
				exit
				;;
			  3)
				send_stats "重裝debian 11"
				dd_xitong_1
				bash InstallNET.sh -debian 11
				reboot
				exit
				;;
			  4)
				send_stats "重裝debian 10"
				dd_xitong_1
				bash InstallNET.sh -debian 10
				reboot
				exit
				;;
			  11)
				send_stats "重裝ubuntu 24.04"
				dd_xitong_1
				bash InstallNET.sh -ubuntu 24.04
				reboot
				exit
				;;
			  12)
				send_stats "重裝ubuntu 22.04"
				dd_xitong_1
				bash InstallNET.sh -ubuntu 22.04
				reboot
				exit
				;;
			  13)
				send_stats "重裝ubuntu 20.04"
				dd_xitong_1
				bash InstallNET.sh -ubuntu 20.04
				reboot
				exit
				;;
			  14)
				send_stats "重裝ubuntu 18.04"
				dd_xitong_1
				bash InstallNET.sh -ubuntu 18.04
				reboot
				exit
				;;


			  21)
				send_stats "重裝rockylinux10"
				dd_xitong_3
				bash reinstall.sh rocky
				reboot
				exit
				;;

			  22)
				send_stats "重裝rockylinux9"
				dd_xitong_3
				bash reinstall.sh rocky 9
				reboot
				exit
				;;

			  23)
				send_stats "重裝alma10"
				dd_xitong_3
				bash reinstall.sh almalinux
				reboot
				exit
				;;

			  24)
				send_stats "重裝alma9"
				dd_xitong_3
				bash reinstall.sh almalinux 9
				reboot
				exit
				;;

			  25)
				send_stats "重裝oracle10"
				dd_xitong_3
				bash reinstall.sh oracle
				reboot
				exit
				;;

			  26)
				send_stats "重裝oracle9"
				dd_xitong_3
				bash reinstall.sh oracle 9
				reboot
				exit
				;;

			  27)
				send_stats "重裝fedora42"
				dd_xitong_3
				bash reinstall.sh fedora
				reboot
				exit
				;;

			  28)
				send_stats "重裝fedora41"
				dd_xitong_3
				bash reinstall.sh fedora 41
				reboot
				exit
				;;

			  29)
				send_stats "重裝centos10"
				dd_xitong_3
				bash reinstall.sh centos 10
				reboot
				exit
				;;

			  30)
				send_stats "重裝centos9"
				dd_xitong_3
				bash reinstall.sh centos 9
				reboot
				exit
				;;

			  31)
				send_stats "重裝alpine"
				dd_xitong_1
				bash InstallNET.sh -alpine
				reboot
				exit
				;;

			  32)
				send_stats "重裝arch"
				dd_xitong_3
				bash reinstall.sh arch
				reboot
				exit
				;;

			  33)
				send_stats "重裝kali"
				dd_xitong_3
				bash reinstall.sh kali
				reboot
				exit
				;;

			  34)
				send_stats "重裝openeuler"
				dd_xitong_3
				bash reinstall.sh openeuler
				reboot
				exit
				;;

			  35)
				send_stats "重裝opensuse"
				dd_xitong_3
				bash reinstall.sh opensuse
				reboot
				exit
				;;

			  36)
				send_stats "重裝飛牛"
				dd_xitong_3
				bash reinstall.sh fnos
				reboot
				exit
				;;

			  41)
				send_stats "重裝windows11"
				dd_xitong_2
				bash InstallNET.sh -windows 11 -lang "cn"
				reboot
				exit
				;;

			  42)
				dd_xitong_2
				send_stats "重裝windows10"
				bash InstallNET.sh -windows 10 -lang "cn"
				reboot
				exit
				;;

			  43)
				send_stats "重裝windows7"
				dd_xitong_4
				bash reinstall.sh windows --iso="https://drive.massgrave.dev/cn_windows_7_professional_with_sp1_x64_dvd_u_677031.iso" --image-name='Windows 7 PROFESSIONAL'
				reboot
				exit
				;;

			  44)
				send_stats "重裝windows server 25"
				dd_xitong_2
				bash InstallNET.sh -windows 2025 -lang "cn"
				reboot
				exit
				;;

			  45)
				send_stats "重裝windows server 22"
				dd_xitong_2
				bash InstallNET.sh -windows 2022 -lang "cn"
				reboot
				exit
				;;

			  46)
				send_stats "重裝windows server 19"
				dd_xitong_2
				bash InstallNET.sh -windows 2019 -lang "cn"
				reboot
				exit
				;;

			  47)
				send_stats "重裝windows11 ARM"
				dd_xitong_4
				bash reinstall.sh dd --img https://r2.hotdog.eu.org/win11-arm-with-pagefile-15g.xz
				reboot
				exit
				;;

			  *)
				break
				;;
			esac
		  done
}


bbrv3() {
		  root_use
		  send_stats "bbrv3管理"

		  local cpu_arch=$(uname -m)
		  if [ "$cpu_arch" = "aarch64" ]; then
			bash <(curl -sL jhb.ovh/jb/bbrv3arm.sh)
			break_end
			linux_Settings
		  fi

		  if dpkg -l | grep -q 'linux-xanmod'; then
			while true; do
				  clear
				  local kernel_version=$(uname -r)
				  echo "您已安裝xanmod的BBRv3內核"
				  echo "當前核心版本:$kernel_version"

				  echo ""
				  echo "核心管理"
				  echo "------------------------"
				  echo "1. 更新BBRv3內核 2. 卸載BBRv3內核"
				  echo "------------------------"
				  echo "0. 返回上一級選單"
				  echo "------------------------"
				  read -e -p "請輸入你的選擇:" sub_choice

				  case $sub_choice in
					  1)
						apt purge -y 'linux-*xanmod1*'
						update-grub

						# wget -qO - https://dl.xanmod.org/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes
						wget -qO - ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes

						# 步驟3：新增儲存庫
						echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list

						# version=$(wget -q https://dl.xanmod.org/check_x86-64_psabi.sh && chmod +x check_x86-64_psabi.sh && ./check_x86-64_psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')
						local version=$(wget -q ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/check_x86-64_psabi.sh && chmod +x check_x86-64_psabi.sh && ./check_x86-64_psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')

						apt update -y
						apt install -y linux-xanmod-x64v$version

						echo "XanMod核心已更新。重啟後生效"
						rm -f /etc/apt/sources.list.d/xanmod-release.list
						rm -f check_x86-64_psabi.sh*

						server_reboot

						  ;;
					  2)
						apt purge -y 'linux-*xanmod1*'
						update-grub
						echo "XanMod核心已卸載。重啟後生效"
						server_reboot
						  ;;

					  *)
						  break  # 跳出循环，退出菜单
						  ;;

				  esac
			done
		else

		  clear
		  echo "設定BBR3加速"
		  echo "影片介紹: https://www.bilibili.com/video/BV14K421x7BS?t=0.1"
		  echo "------------------------------------------------"
		  echo "僅支援Debian/Ubuntu"
		  echo "請備份數據，將為你升級Linux核心開啟BBR3"
		  echo "------------------------------------------------"
		  read -e -p "確定繼續嗎？ (Y/N):" choice

		  case "$choice" in
			[Yy])
			check_disk_space 3
			if [ -r /etc/os-release ]; then
				. /etc/os-release
				if [ "$ID" != "debian" ] && [ "$ID" != "ubuntu" ]; then
					echo "目前環境不支持，僅支援Debian和Ubuntu系統"
					break_end
					linux_Settings
				fi
			else
				echo "無法確定作業系統類型"
				break_end
				linux_Settings
			fi

			check_swap
			install wget gnupg

			# wget -qO - https://dl.xanmod.org/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes
			wget -qO - ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes

			# 步驟3：新增儲存庫
			echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list

			# version=$(wget -q https://dl.xanmod.org/check_x86-64_psabi.sh && chmod +x check_x86-64_psabi.sh && ./check_x86-64_psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')
			local version=$(wget -q ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/check_x86-64_psabi.sh && chmod +x check_x86-64_psabi.sh && ./check_x86-64_psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')

			apt update -y
			apt install -y linux-xanmod-x64v$version

			bbr_on

			echo "XanMod核心安裝並BBR3啟用成功。重啟後生效"
			rm -f /etc/apt/sources.list.d/xanmod-release.list
			rm -f check_x86-64_psabi.sh*
			server_reboot

			  ;;
			[Nn])
			  echo "已取消"
			  ;;
			*)
			  echo "無效的選擇，請輸入 Y 或 N。"
			  ;;
		  esac
		fi

}


elrepo_install() {
	# 導入 ELRepo GPG 公鑰
	echo "導入 ELRepo GPG 公鑰..."
	rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
	# 檢測系統版本
	local os_version=$(rpm -q --qf "%{VERSION}" $(rpm -qf /etc/os-release) 2>/dev/null | awk -F '.' '{print $1}')
	local os_name=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
	# 確保我們在一個支援的作業系統上運行
	if [[ "$os_name" != *"Red Hat"* && "$os_name" != *"AlmaLinux"* && "$os_name" != *"Rocky"* && "$os_name" != *"Oracle"* && "$os_name" != *"CentOS"* ]]; then
		echo "不支援的作業系統：$os_name"
		break_end
		linux_Settings
	fi
	# 列印偵測到的作業系統訊息
	echo "偵測到的作業系統:$os_name $os_version"
	# 根據系統版本安裝對應的 ELRepo 倉庫配置
	if [[ "$os_version" == 8 ]]; then
		echo "安裝 ELRepo 倉庫設定 (版本 8)..."
		yum -y install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
	elif [[ "$os_version" == 9 ]]; then
		echo "安裝 ELRepo 倉庫設定 (版本 9)..."
		yum -y install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm
	elif [[ "$os_version" == 10 ]]; then
		echo "安裝 ELRepo 倉庫設定 (版本 10)..."
		yum -y install https://www.elrepo.org/elrepo-release-10.el10.elrepo.noarch.rpm
	else
		echo "不支援的系統版本：$os_version"
		break_end
		linux_Settings
	fi
	# 啟用 ELRepo 內核倉庫並安裝最新的主線內核
	echo "啟用 ELRepo 核心倉庫並安裝最新的主線核心..."
	# yum -y --enablerepo=elrepo-kernel install kernel-ml
	yum --nogpgcheck -y --enablerepo=elrepo-kernel install kernel-ml
	echo "已安裝 ELRepo 倉庫配置並更新至最新主線核心。"
	server_reboot

}


elrepo() {
		  root_use
		  send_stats "紅帽內核管理"
		  if uname -r | grep -q 'elrepo'; then
			while true; do
				  clear
				  kernel_version=$(uname -r)
				  echo "您已安裝elrepo內核"
				  echo "當前核心版本:$kernel_version"

				  echo ""
				  echo "核心管理"
				  echo "------------------------"
				  echo "1. 更新elrepo內核 2. 卸載elrepo內核"
				  echo "------------------------"
				  echo "0. 返回上一級選單"
				  echo "------------------------"
				  read -e -p "請輸入你的選擇:" sub_choice

				  case $sub_choice in
					  1)
						dnf remove -y elrepo-release
						rpm -qa | grep elrepo | grep kernel | xargs rpm -e --nodeps
						elrepo_install
						send_stats "更新紅帽內核"
						server_reboot

						  ;;
					  2)
						dnf remove -y elrepo-release
						rpm -qa | grep elrepo | grep kernel | xargs rpm -e --nodeps
						echo "elrepo核心已卸載。重啟後生效"
						send_stats "解除安裝紅帽內核"
						server_reboot

						  ;;
					  *)
						  break  # 跳出循环，退出菜单
						  ;;

				  esac
			done
		else

		  clear
		  echo "請備份數據，將為你升級Linux內核"
		  echo "影片介紹: https://www.bilibili.com/video/BV1mH4y1w7qA?t=529.2"
		  echo "------------------------------------------------"
		  echo "僅支援紅帽系列發行 CentOS/RedHat/Alma/Rocky/oracle"
		  echo "升級Linux核心可提升系統效能與安全，建議有條件的嘗試，生產環境謹慎升級！"
		  echo "------------------------------------------------"
		  read -e -p "確定繼續嗎？ (Y/N):" choice

		  case "$choice" in
			[Yy])
			  check_swap
			  elrepo_install
			  send_stats "升級紅帽內核"
			  server_reboot
			  ;;
			[Nn])
			  echo "已取消"
			  ;;
			*)
			  echo "無效的選擇，請輸入 Y 或 N。"
			  ;;
		  esac
		fi

}




clamav_freshclam() {
	echo -e "${gl_kjlan}正在更新病毒庫...${gl_bai}"
	docker run --rm \
		--name clamav \
		--mount source=clam_db,target=/var/lib/clamav \
		clamav/clamav-debian:latest \
		freshclam
}

clamav_scan() {
	if [ $# -eq 0 ]; then
		echo "請指定要掃描的目錄。"
		return
	fi

	echo -e "${gl_kjlan}正在掃描目錄$@...${gl_bai}"

	# 建構 mount 參數
	local MOUNT_PARAMS=""
	for dir in "$@"; do
		MOUNT_PARAMS+="--mount type=bind,source=${dir},target=/mnt/host${dir} "
	done

	# 建構 clamscan 指令參數
	local SCAN_PARAMS=""
	for dir in "$@"; do
		SCAN_PARAMS+="/mnt/host${dir} "
	done

	mkdir -p /home/docker/clamav/log/ > /dev/null 2>&1
	> /home/docker/clamav/log/scan.log > /dev/null 2>&1

	# 執行 Docker 命令
	docker run --rm \
		--name clamav \
		--mount source=clam_db,target=/var/lib/clamav \
		$MOUNT_PARAMS \
		-v /home/docker/clamav/log/:/var/log/clamav/ \
		clamav/clamav-debian:latest \
		clamscan -r --log=/var/log/clamav/scan.log $SCAN_PARAMS

	echo -e "${gl_lv}$@ 扫描完成，病毒报告存放在${gl_huang}/home/docker/clamav/log/scan.log${gl_bai}"
	echo -e "${gl_lv}如果有病毒請在${gl_huang}scan.log${gl_lv}文件中搜尋FOUND關鍵字確認病毒位置${gl_bai}"

}







clamav() {
		  root_use
		  send_stats "病毒掃描管理"
		  while true; do
				clear
				echo "clamav病毒掃描工具"
				echo "影片介紹: https://www.bilibili.com/video/BV1TqvZe4EQm?t=0.1"
				echo "------------------------"
				echo "是一個開源的防毒軟體工具，主要用於偵測和刪除各種類型的惡意軟體。"
				echo "包括病毒、木馬、間諜軟體、惡意腳本和其他有害軟體。"
				echo "------------------------"
				echo -e "${gl_lv}1. 全盤掃描${gl_bai}             ${gl_huang}2. 重要目錄掃描${gl_bai}            ${gl_kjlan}3. 自訂目錄掃描${gl_bai}"
				echo "------------------------"
				echo "0. 返回上一級選單"
				echo "------------------------"
				read -e -p "請輸入你的選擇:" sub_choice
				case $sub_choice in
					1)
					  send_stats "全碟掃描"
					  install_docker
					  docker volume create clam_db > /dev/null 2>&1
					  clamav_freshclam
					  clamav_scan /
					  break_end

						;;
					2)
					  send_stats "重要目錄掃描"
					  install_docker
					  docker volume create clam_db > /dev/null 2>&1
					  clamav_freshclam
					  clamav_scan /etc /var /usr /home /root
					  break_end
						;;
					3)
					  send_stats "自訂目錄掃描"
					  read -e -p "請輸入要掃描的目錄，用空格分隔（例如：/etc /var /usr /home /root）:" directories
					  install_docker
					  clamav_freshclam
					  clamav_scan $directories
					  break_end
						;;
					*)
					  break  # 跳出循环，退出菜单
						;;
				esac
		  done

}


# ============================================================================
# Linux 核心調優模組（重構版）
# 統一核心函數 + 場景差異化參數 + 持久化到設定檔 + 硬體自適應
# 取代原 optimize_high_performance / optimize_balanced / optimize_web_server / restore_defaults
# ============================================================================

# 取得記憶體大小（MB）
_get_mem_mb() {
	awk '/MemTotal/{printf "%d", $2/1024}' /proc/meminfo
}

# 統一內核調優核心函數
# 參數: $1 = 模式名稱, $2 = 場景 (high/balanced/web/stream/game)
_kernel_optimize_core() {
	local mode_name="$1"
	local scene="${2:-high}"
	local CONF="/etc/sysctl.d/99-kejilion-optimize.conf"
	local MEM_MB=$(_get_mem_mb)

	echo -e "${gl_lv}切換到${mode_name}...${gl_bai}"

	# ── 根據場景設定參數 ──
	local SWAPPINESS DIRTY_RATIO DIRTY_BG_RATIO OVERCOMMIT MIN_FREE_KB VFS_PRESSURE
	local RMEM_MAX WMEM_MAX TCP_RMEM TCP_WMEM
	local SOMAXCONN BACKLOG SYN_BACKLOG
	local PORT_RANGE SCHED_AUTOGROUP THP NUMA FIN_TIMEOUT
	local KEEPALIVE_TIME KEEPALIVE_INTVL KEEPALIVE_PROBES

	case "$scene" in
		high|stream|game)
			# 高效能/直播/遊戲：激進參數
			SWAPPINESS=10
			DIRTY_RATIO=15
			DIRTY_BG_RATIO=5
			OVERCOMMIT=1
			VFS_PRESSURE=50
			RMEM_MAX=67108864
			WMEM_MAX=67108864
			TCP_RMEM="4096 262144 67108864"
			TCP_WMEM="4096 262144 67108864"
			SOMAXCONN=8192
			BACKLOG=250000
			SYN_BACKLOG=8192
			PORT_RANGE="1024 65535"
			SCHED_AUTOGROUP=0
			THP="never"
			NUMA=0
			FIN_TIMEOUT=10
			KEEPALIVE_TIME=300
			KEEPALIVE_INTVL=30
			KEEPALIVE_PROBES=5
			;;
		web)
			# 網站伺服器：高並發優先
			SWAPPINESS=10
			DIRTY_RATIO=20
			DIRTY_BG_RATIO=10
			OVERCOMMIT=1
			VFS_PRESSURE=50
			RMEM_MAX=33554432
			WMEM_MAX=33554432
			TCP_RMEM="4096 131072 33554432"
			TCP_WMEM="4096 131072 33554432"
			SOMAXCONN=16384
			BACKLOG=10000
			SYN_BACKLOG=16384
			PORT_RANGE="1024 65535"
			SCHED_AUTOGROUP=0
			THP="never"
			NUMA=0
			FIN_TIMEOUT=15
			KEEPALIVE_TIME=600
			KEEPALIVE_INTVL=60
			KEEPALIVE_PROBES=5
			;;
		balanced)
			# 均衡模式：適度優化
			SWAPPINESS=30
			DIRTY_RATIO=20
			DIRTY_BG_RATIO=10
			OVERCOMMIT=0
			VFS_PRESSURE=75
			RMEM_MAX=16777216
			WMEM_MAX=16777216
			TCP_RMEM="4096 87380 16777216"
			TCP_WMEM="4096 65536 16777216"
			SOMAXCONN=4096
			BACKLOG=5000
			SYN_BACKLOG=4096
			PORT_RANGE="1024 49151"
			SCHED_AUTOGROUP=1
			THP="always"
			NUMA=1
			FIN_TIMEOUT=30
			KEEPALIVE_TIME=600
			KEEPALIVE_INTVL=60
			KEEPALIVE_PROBES=5
			;;
	esac

	# ── 根據記憶體大小自適應調整 ──
	if [ "$MEM_MB" -ge 16384 ]; then
		MIN_FREE_KB=131072
		[ "$scene" != "balanced" ] && SWAPPINESS=5
	elif [ "$MEM_MB" -ge 4096 ]; then
		MIN_FREE_KB=65536
	elif [ "$MEM_MB" -ge 1024 ]; then
		MIN_FREE_KB=32768
		# 小記憶體縮小緩衝區
		if [ "$scene" != "balanced" ]; then
			RMEM_MAX=16777216
			WMEM_MAX=16777216
			TCP_RMEM="4096 87380 16777216"
			TCP_WMEM="4096 65536 16777216"
		fi
	else
		MIN_FREE_KB=16384
		SWAPPINESS=30
		OVERCOMMIT=0
		RMEM_MAX=4194304
		WMEM_MAX=4194304
		TCP_RMEM="4096 32768 4194304"
		TCP_WMEM="4096 32768 4194304"
		SOMAXCONN=1024
		BACKLOG=1000
	fi

	# ── 直播場景額外：UDP 緩衝區加大 ──
	local STREAM_EXTRA=""
	if [ "$scene" = "stream" ]; then
		STREAM_EXTRA="
# 直播推流 UDP 優化
net.ipv4.udp_rmem_min = 16384
net.ipv4.udp_wmem_min = 16384
net.ipv4.tcp_notsent_lowat = 16384"
	fi

	# ── 遊戲服場景額外：低延遲優先 ──
	local GAME_EXTRA=""
	if [ "$scene" = "game" ]; then
		GAME_EXTRA="
# 遊戲服低延遲優化
net.ipv4.udp_rmem_min = 16384
net.ipv4.udp_wmem_min = 16384
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_slow_start_after_idle = 0"
	fi

	# ── 載入 BBR 模組 ──
	local CC="bbr"
	local QDISC="fq"
	local KVER
	KVER=$(uname -r | grep -oP '^\d+\.\d+')
	if printf '%s\n%s' "4.9" "$KVER" | sort -V -C; then
		if ! lsmod 2>/dev/null | grep -q tcp_bbr; then
			modprobe tcp_bbr 2>/dev/null
		fi
		if ! sysctl net.ipv4.tcp_available_congestion_control 2>/dev/null | grep -q bbr; then
			CC="cubic"
			QDISC="fq_codel"
		fi
	else
		CC="cubic"
		QDISC="fq_codel"
	fi

	# ── 備份已有設定 ──
	[ -f "$CONF" ] && cp "$CONF" "${CONF}.bak.$(date +%s)"

	# ── 寫入設定檔（持久化） ──
	echo -e "${gl_lv}寫入優化配置...${gl_bai}"
	cat > "$CONF" << SYSCTL
# kejilion 核心調優配置
# 模式: $mode_name | 場景: $scene
# 記憶體: ${MEM_MB}MB | 產生時間: $(date '+%Y-%m-%d %H:%M:%S')

# ── TCP 擁塞控制 ──
net.core.default_qdisc = $QDISC
net.ipv4.tcp_congestion_control = $CC

# ── TCP 緩衝區 ──
net.core.rmem_max = $RMEM_MAX
net.core.wmem_max = $WMEM_MAX
net.core.rmem_default = $(echo "$TCP_RMEM" | awk '{print $2}')
net.core.wmem_default = $(echo "$TCP_WMEM" | awk '{print $2}')
net.ipv4.tcp_rmem = $TCP_RMEM
net.ipv4.tcp_wmem = $TCP_WMEM

# ── 連接隊列 ──
net.core.somaxconn = $SOMAXCONN
net.core.netdev_max_backlog = $BACKLOG
net.ipv4.tcp_max_syn_backlog = $SYN_BACKLOG

# ── TCP 連線最佳化 ──
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = $FIN_TIMEOUT
net.ipv4.tcp_keepalive_time = $KEEPALIVE_TIME
net.ipv4.tcp_keepalive_intvl = $KEEPALIVE_INTVL
net.ipv4.tcp_keepalive_probes = $KEEPALIVE_PROBES
net.ipv4.tcp_max_tw_buckets = 65536
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_window_scaling = 1

# ── 埠與記憶體 ──
net.ipv4.ip_local_port_range = $PORT_RANGE
net.ipv4.tcp_mem = $((MEM_MB * 1024 / 8)) $((MEM_MB * 1024 / 4)) $((MEM_MB * 1024 / 2))
net.ipv4.tcp_max_orphans = 32768

# ── 虛擬記憶體 ──
vm.swappiness = $SWAPPINESS
vm.dirty_ratio = $DIRTY_RATIO
vm.dirty_background_ratio = $DIRTY_BG_RATIO
vm.overcommit_memory = $OVERCOMMIT
vm.min_free_kbytes = $MIN_FREE_KB
vm.vfs_cache_pressure = $VFS_PRESSURE

# ── CPU/核心調度 ──
kernel.sched_autogroup_enabled = $SCHED_AUTOGROUP
$([ -f /proc/sys/kernel/numa_balancing ] && echo "kernel.numa_balancing = $NUMA" || echo "# numa_balancing 不支持")

# ── 安全防護 ──
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# ── 文件描述符 ──
fs.file-max = 1048576
fs.nr_open = 1048576

# ── 連結追蹤 ──
$(if [ -f /proc/sys/net/netfilter/nf_conntrack_max ]; then
echo "net.netfilter.nf_conntrack_max = $((SOMAXCONN * 32))"
echo "net.netfilter.nf_conntrack_tcp_timeout_established = 7200"
echo "net.netfilter.nf_conntrack_tcp_timeout_time_wait = 30"
echo "net.netfilter.nf_conntrack_tcp_timeout_close_wait = 15"
echo "net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 15"
else
echo "# conntrack 未啟用"
fi)
$STREAM_EXTRA
$GAME_EXTRA
SYSCTL

	# ── 應用配置（逐行，跳過不支援的參數） ──
	echo -e "${gl_lv}應用優化參數...${gl_bai}"
	local applied=0 skipped=0
	while IFS= read -r line; do
		# 跳過註解和空行
		[[ "$line" =~ ^[[:space:]]*# ]] && continue
		[[ -z "${line// /}" ]] && continue
		if sysctl -w "$line" >/dev/null 2>&1; then
			applied=$((applied + 1))
		else
			skipped=$((skipped + 1))
		fi
	done < "$CONF"
	echo -e "${gl_lv}已應用${applied}項參數${skipped:+，跳過${skipped}項不支援的參數}${gl_bai}"

	# ── 透明大頁面 ──
	if [ -f /sys/kernel/mm/transparent_hugepage/enabled ]; then
		echo "$THP" > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null
	fi

	# ── 文件描述符限制 ──
	if ! grep -q "# kejilion-optimize" /etc/security/limits.conf 2>/dev/null; then
		cat >> /etc/security/limits.conf << 'LIMITS'

# kejilion-optimize
* soft nofile 1048576
* hard nofile 1048576
root soft nofile 1048576
root hard nofile 1048576
LIMITS
	fi

	# ── BBR 持久化 ──
	if [ "$CC" = "bbr" ]; then
		echo "tcp_bbr" > /etc/modules-load.d/bbr.conf 2>/dev/null
		# 清理舊的 sysctl.conf 裡的 bbr 設定（避免衝突）
		sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf 2>/dev/null
	fi

	echo -e "${gl_lv}${mode_name}優化完成！配置已持久化到${CONF}${gl_bai}"
	echo -e "${gl_lv}記憶體:${MEM_MB}MB | 壅塞演算法:${CC}| 隊列:${QDISC}${gl_bai}"
}

# ── 各模式入口函數（保持原有呼叫介面不變） ──

optimize_high_performance() {
	_kernel_optimize_core "${tiaoyou_moshi:-高性能优化模式}" "high"
}

optimize_balanced() {
	_kernel_optimize_core "均衡最佳化模式" "balanced"
}

optimize_web_server() {
	_kernel_optimize_core "網站建置優化模式" "web"
}

# ── 還原預設設定（完全清理） ──
restore_defaults() {
	echo -e "${gl_lv}還原到預設值...${gl_bai}"

	local CONF="/etc/sysctl.d/99-kejilion-optimize.conf"

	# 刪除最佳化設定檔（含外鏈自動調優配置）
	rm -f "$CONF"
	rm -f /etc/sysctl.d/99-network-optimize.conf

	# 清理 sysctl.conf 裡可能殘留的 bbr 配置
	sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf 2>/dev/null

	# 重新載入系統預設配置
	sysctl --system 2>/dev/null | tail -1

	# 還原透明大頁面
	[ -f /sys/kernel/mm/transparent_hugepage/enabled ] && \
		echo always > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null

	# 清理檔案描述符配置
	if grep -q "# kejilion-optimize" /etc/security/limits.conf 2>/dev/null; then
		sed -i '/# kejilion-optimize/,+4d' /etc/security/limits.conf
	fi

	# 清理 BBR 持久化
	rm -f /etc/modules-load.d/bbr.conf 2>/dev/null

	echo -e "${gl_lv}系統已還原到預設設定${gl_bai}"
}


Kernel_optimize() {
	root_use
	while true; do
	  clear
	  send_stats "Linux核心調優管理"
	  local current_mode=$(grep "^# 模式:" /etc/sysctl.d/99-kejilion-optimize.conf 2>/dev/null | sed 's/# 模式: //' | awk -F'|' '{print $1}' | xargs)
	  [ -z "$current_mode" ] && [ -f /etc/sysctl.d/99-network-optimize.conf ] && current_mode="自動調優模式"
	  echo "Linux系統核心參數優化"
	  if [ -n "$current_mode" ]; then
		  echo -e "當前模式:${gl_lv}${current_mode}${gl_bai}"
	  else
		  echo -e "當前模式:${gl_hui}未最佳化${gl_bai}"
	  fi
	  echo "影片介紹: https://www.bilibili.com/video/BV1Kb421J7yg?t=0.1"
	  echo "------------------------------------------------"
	  echo "提供多種系統參數調優模式，使用者可依自身使用場景進行選擇切換。"
	  echo -e "${gl_huang}提示:${gl_bai}生產環境請謹慎使用！"
	  echo -e "--------------------"
	  echo -e "1. 高效能最佳化模式： 最大化系統效能，激進的記憶體和網路參數。"
	  echo -e "2. 均衡最佳化模式： 在效能與資源消耗之間取得平衡，適合日常使用。"
	  echo -e "3. 網站最佳化模式： 針對網站伺服器最佳化，超高並發連線佇列。"
	  echo -e "4. 直播最佳化模式： 針對直播推流優化，UDP 緩衝區加大，減少延遲。"
	  echo -e "5. 遊戲服最佳化模式： 針對遊戲伺服器最佳化，低延遲優先。"
	  echo -e "6. 還原預設設定： 將系統設定還原為預設配置。"
	  echo -e "7. 自動調優： 依測試資料自動調優核心參數。${gl_huang}★${gl_bai}"
	  echo "--------------------"
	  echo "0. 返回上一級選單"
	  echo "--------------------"
	  read -e -p "請輸入你的選擇:" sub_choice
	  case $sub_choice in
		  1)
			  cd ~
			  clear
			  local tiaoyou_moshi="高效能最佳化模式"
			  optimize_high_performance
			  send_stats "高性能模式最​​佳化"
			  ;;
		  2)
			  cd ~
			  clear
			  optimize_balanced
			  send_stats "均衡模式最佳化"
			  ;;
		  3)
			  cd ~
			  clear
			  optimize_web_server
			  send_stats "網站優化模式"
			  ;;
		  4)
			  cd ~
			  clear
			  _kernel_optimize_core "直播優化模式" "stream"
			  send_stats "直播推流優化"
			  ;;
		  5)
			  cd ~
			  clear
			  _kernel_optimize_core "遊戲服優化模式" "game"
			  send_stats "遊戲服優化"
			  ;;
		  6)
			  cd ~
			  clear
			  restore_defaults
			  curl -sS ${gh_proxy}raw.githubusercontent.com/kejilion/sh/refs/heads/main/network-optimize.sh -o /tmp/network-optimize.sh && source /tmp/network-optimize.sh && restore_network_defaults
			  send_stats "還原預設設定"
			  ;;

		  7)
			  cd ~
			  clear
			  curl -sS ${gh_proxy}raw.githubusercontent.com/kejilion/sh/refs/heads/main/network-optimize.sh | bash
			  send_stats "核心自動調優"
			  ;;

		  *)
			  break
			  ;;
	  esac
	  break_end
	done
}







update_locale() {
	local lang=$1
	local locale_file=$2

	if [ -f /etc/os-release ]; then
		. /etc/os-release
		case $ID in
			debian|ubuntu|kali)
				install locales
				sed -i "s/^\s*#\?\s*${locale_file}/${locale_file}/" /etc/locale.gen
				locale-gen
				echo "LANG=${lang}" > /etc/default/locale
				export LANG=${lang}
				echo -e "${gl_lv}系統語言已經修改為:$lang重新連線SSH生效。${gl_bai}"
				hash -r
				break_end

				;;
			centos|rhel|almalinux|rocky|fedora)
				install glibc-langpack-zh
				localectl set-locale LANG=${lang}
				echo "LANG=${lang}" | tee /etc/locale.conf
				echo -e "${gl_lv}系統語言已經修改為:$lang重新連線SSH生效。${gl_bai}"
				hash -r
				break_end
				;;
			*)
				echo "不支援的系統:$ID"
				break_end
				;;
		esac
	else
		echo "不支援的系統，無法辨識系統類型。"
		break_end
	fi
}




linux_language() {
root_use
send_stats "切換系統語言"
while true; do
  clear
  echo "當前系統語言:$LANG"
  echo "------------------------"
  echo "1. 英文 2. 簡體中文 3. 繁體中文"
  echo "------------------------"
  echo "0. 返回上一級選單"
  echo "------------------------"
  read -e -p "輸入你的選擇:" choice

  case $choice in
	  1)
		  update_locale "en_US.UTF-8" "en_US.UTF-8"
		  send_stats "切換到英文"
		  ;;
	  2)
		  update_locale "zh_CN.UTF-8" "zh_CN.UTF-8"
		  send_stats "切換到簡體中文"
		  ;;
	  3)
		  update_locale "zh_TW.UTF-8" "zh_TW.UTF-8"
		  send_stats "切換到繁體中文"
		  ;;
	  *)
		  break
		  ;;
  esac
done
}



shell_bianse_profile() {

if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
	sed -i '/^PS1=/d' ~/.bashrc
	echo "${bianse}" >> ~/.bashrc
	# source ~/.bashrc
else
	sed -i '/^PS1=/d' ~/.profile
	echo "${bianse}" >> ~/.profile
	# source ~/.profile
fi
echo -e "${gl_lv}變更完成。重新連接SSH後可查看變化！${gl_bai}"

hash -r
break_end

}



shell_bianse() {
  root_use
  send_stats "命令列美化工具"
  while true; do
	clear
	echo "命令列美化工具"
	echo "------------------------"
	echo -e "1. \033[1;32mroot \033[1;34mlocalhost \033[1;31m~ \033[0m${gl_bai}#"
	echo -e "2. \033[1;35mroot \033[1;36mlocalhost \033[1;33m~ \033[0m${gl_bai}#"
	echo -e "3. \033[1;31mroot \033[1;32mlocalhost \033[1;34m~ \033[0m${gl_bai}#"
	echo -e "4. \033[1;36mroot \033[1;33mlocalhost \033[1;37m~ \033[0m${gl_bai}#"
	echo -e "5. \033[1;37mroot \033[1;31mlocalhost \033[1;32m~ \033[0m${gl_bai}#"
	echo -e "6. \033[1;33mroot \033[1;34mlocalhost \033[1;35m~ \033[0m${gl_bai}#"
	echo -e "7. root localhost ~ #"
	echo "------------------------"
	echo "0. 返回上一級選單"
	echo "------------------------"
	read -e -p "輸入你的選擇:" choice

	case $choice in
	  1)
		local bianse="PS1='\[\033[1;32m\]\u\[\033[0m\]@\[\033[1;34m\]\h\[\033[0m\] \[\033[1;31m\]\w\[\033[0m\] # '"
		shell_bianse_profile

		;;
	  2)
		local bianse="PS1='\[\033[1;35m\]\u\[\033[0m\]@\[\033[1;36m\]\h\[\033[0m\] \[\033[1;33m\]\w\[\033[0m\] # '"
		shell_bianse_profile
		;;
	  3)
		local bianse="PS1='\[\033[1;31m\]\u\[\033[0m\]@\[\033[1;32m\]\h\[\033[0m\] \[\033[1;34m\]\w\[\033[0m\] # '"
		shell_bianse_profile
		;;
	  4)
		local bianse="PS1='\[\033[1;36m\]\u\[\033[0m\]@\[\033[1;33m\]\h\[\033[0m\] \[\033[1;37m\]\w\[\033[0m\] # '"
		shell_bianse_profile
		;;
	  5)
		local bianse="PS1='\[\033[1;37m\]\u\[\033[0m\]@\[\033[1;31m\]\h\[\033[0m\] \[\033[1;32m\]\w\[\033[0m\] # '"
		shell_bianse_profile
		;;
	  6)
		local bianse="PS1='\[\033[1;33m\]\u\[\033[0m\]@\[\033[1;34m\]\h\[\033[0m\] \[\033[1;35m\]\w\[\033[0m\] # '"
		shell_bianse_profile
		;;
	  7)
		local bianse=""
		shell_bianse_profile
		;;
	  *)
		break
		;;
	esac

  done
}




linux_trash() {
  root_use
  send_stats "系統回收站"

  local bashrc_profile="/root/.bashrc"
  local TRASH_DIR="$HOME/.local/share/Trash/files"

  while true; do

	local trash_status
	if ! grep -q "trash-put" "$bashrc_profile"; then
		trash_status="${gl_hui}未啟用${gl_bai}"
	else
		trash_status="${gl_lv}已啟用${gl_bai}"
	fi

	clear
	echo -e "目前回收站${trash_status}"
	echo -e "啟用後rm刪除的檔案先進入回收站，防止誤刪重要檔案！"
	echo "------------------------------------------------"
	ls -l --color=auto "$TRASH_DIR" 2>/dev/null || echo "回收站為空"
	echo "------------------------"
	echo "1. 啟用回收站 2. 關閉回收站"
	echo "3. 還原內容 4. 清空回收站"
	echo "------------------------"
	echo "0. 返回上一級選單"
	echo "------------------------"
	read -e -p "輸入你的選擇:" choice

	case $choice in
	  1)
		install trash-cli
		sed -i '/alias rm/d' "$bashrc_profile"
		echo "alias rm='trash-put'" >> "$bashrc_profile"
		source "$bashrc_profile"
		echo "回收站已啟用，刪除的檔案將移至回收站。"
		sleep 2
		;;
	  2)
		remove trash-cli
		sed -i '/alias rm/d' "$bashrc_profile"
		echo "alias rm='rm -i'" >> "$bashrc_profile"
		source "$bashrc_profile"
		echo "回收站已關閉，檔案將直接刪除。"
		sleep 2
		;;
	  3)
		read -e -p "輸入要還原的檔名:" file_to_restore
		if [ -e "$TRASH_DIR/$file_to_restore" ]; then
		  mv "$TRASH_DIR/$file_to_restore" "$HOME/"
		  echo "$file_to_restore已還原到主目錄。"
		else
		  echo "文件不存在。"
		fi
		;;
	  4)
		read -e -p "確認清空回收站？ [y/n]:" confirm
		if [[ "$confirm" == "y" ]]; then
		  trash-empty
		  echo "回收站已清空。"
		fi
		;;
	  *)
		break
		;;
	esac
  done
}

linux_fav() {
send_stats "命令收藏夾"
bash <(curl -l -s ${gh_proxy}raw.githubusercontent.com/byJoey/cmdbox/refs/heads/main/install.sh)
}

# 建立備份
create_backup() {
	send_stats "建立備份"
	local TIMESTAMP=$(date +"%Y%m%d%H%M%S")

	# 提示使用者輸入備份目錄
	echo "建立備份範例："
	echo "- 備份單一目錄: /var/www"
	echo "- 備份多個目錄: /etc /home /var/log"
	echo "- 直接回車將使用預設目錄 (/etc /usr /home)"
	read -e -p "請輸入要備份的目錄（多個目錄以空格分隔，直接回車則使用預設目錄）：" input

	# 如果使用者沒有輸入目錄，則使用預設目錄
	if [ -z "$input" ]; then
		BACKUP_PATHS=(
			"/etc"              # 配置文件和软件包配置
			"/usr"              # 已安装的软件文件
			"/home"             # 用户数据
		)
	else
		# 將使用者輸入的目錄以空格分隔成數組
		IFS=' ' read -r -a BACKUP_PATHS <<< "$input"
	fi

	# 產生備份檔案前綴
	local PREFIX=""
	for path in "${BACKUP_PATHS[@]}"; do
		# 提取目錄名稱並去除斜杠
		dir_name=$(basename "$path")
		PREFIX+="${dir_name}_"
	done

	# 去除最後一條底線
	local PREFIX=${PREFIX%_}

	# 產生備份檔名
	local BACKUP_NAME="${PREFIX}_$TIMESTAMP.tar.gz"

	# 列印使用者選擇的目錄
	echo "您選擇的備份目錄為："
	for path in "${BACKUP_PATHS[@]}"; do
		echo "- $path"
	done

	# 建立備份
	echo "正在建立備份$BACKUP_NAME..."
	install tar
	tar -czvf "$BACKUP_DIR/$BACKUP_NAME" "${BACKUP_PATHS[@]}"

	# 檢查命令是否成功
	if [ $? -eq 0 ]; then
		echo "備份建立成功:$BACKUP_DIR/$BACKUP_NAME"
	else
		echo "備份建立失敗！"
		exit 1
	fi
}

# 恢復備份
restore_backup() {
	send_stats "恢復備份"
	# 選擇要還原的備份
	read -e -p "請輸入要還原的備份檔名:" BACKUP_NAME

	# 檢查備份檔案是否存在
	if [ ! -f "$BACKUP_DIR/$BACKUP_NAME" ]; then
		echo "備份檔案不存在！"
		exit 1
	fi

	echo "正在恢復備份$BACKUP_NAME..."
	tar -xzvf "$BACKUP_DIR/$BACKUP_NAME" -C /

	if [ $? -eq 0 ]; then
		echo "備份恢復成功！"
	else
		echo "備份恢復失敗！"
		exit 1
	fi
}

# 列出備份
list_backups() {
	echo "可用的備份："
	ls -1 "$BACKUP_DIR"
}

# 刪除備份
delete_backup() {
	send_stats "刪除備份"

	read -e -p "請輸入要刪除的備份檔名:" BACKUP_NAME

	# 檢查備份檔案是否存在
	if [ ! -f "$BACKUP_DIR/$BACKUP_NAME" ]; then
		echo "備份檔案不存在！"
		exit 1
	fi

	# 刪除備份
	rm -f "$BACKUP_DIR/$BACKUP_NAME"

	if [ $? -eq 0 ]; then
		echo "備份刪除成功！"
	else
		echo "備份刪除失敗！"
		exit 1
	fi
}

# 備份主選單
linux_backup() {
	BACKUP_DIR="/backups"
	mkdir -p "$BACKUP_DIR"
	while true; do
		clear
		send_stats "系統備份功能"
		echo "系統備份功能"
		echo "------------------------"
		list_backups
		echo "------------------------"
		echo "1. 建立備份 2. 恢復備份 3. 刪除備份"
		echo "------------------------"
		echo "0. 返回上一級選單"
		echo "------------------------"
		read -e -p "請輸入你的選擇:" choice
		case $choice in
			1) create_backup ;;
			2) restore_backup ;;
			3) delete_backup ;;
			*) break ;;
		esac
		read -e -p "按下回車鍵繼續..."
	done
}









# SSH 輸入標準化函數
kj_ssh_validate_host() {
	local host="$1"
	[[ -n "$host" && ! "$host" =~ [[:space:]] && "$host" =~ ^[A-Za-z0-9._:-]+$ ]]
}

kj_ssh_validate_port() {
	local port="$1"
	[[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -ge 1 ] && [ "$port" -le 65535 ]
}

kj_ssh_validate_user() {
	local user="$1"
	[[ -n "$user" && "$user" =~ ^[A-Za-z_][A-Za-z0-9._-]*$ ]]
}

kj_ssh_read_host_port() {
	local host_prompt="$1"
	local port_prompt="$2"
	local default_port="${3:-22}"

	while true; do
		read -e -p "$host_prompt" KJ_SSH_HOST
		if kj_ssh_validate_host "$KJ_SSH_HOST"; then
			break
		fi
		echo "錯誤: 請輸入有效的伺服器位址。"
	done

	while true; do
		read -e -p "$port_prompt" KJ_SSH_PORT
		KJ_SSH_PORT=${KJ_SSH_PORT:-$default_port}
		if kj_ssh_validate_port "$KJ_SSH_PORT"; then
			break
		fi
		echo "錯誤: 連接埠必須是 1-65535 之間的數字。"
	done
}

kj_ssh_read_host_user_port() {
	local host_prompt="$1"
	local user_prompt="$2"
	local port_prompt="$3"
	local default_user="${4:-root}"
	local default_port="${5:-22}"

	kj_ssh_read_host_port "$host_prompt" "$port_prompt" "$default_port"

	while true; do
		read -e -p "$user_prompt" KJ_SSH_USER
		KJ_SSH_USER=${KJ_SSH_USER:-$default_user}
		if kj_ssh_validate_user "$KJ_SSH_USER"; then
			break
		fi
		echo "錯誤: 使用者名稱格式不正確。"
	done
}

kj_ssh_parse_remote() {
	local remote_raw="$1"
	local default_user="${2:-root}"
	local remote_user remote_host

	if [[ "$remote_raw" == *@* ]]; then
		remote_user="${remote_raw%@*}"
		remote_host="${remote_raw#*@}"
	else
		remote_user="$default_user"
		remote_host="$remote_raw"
	fi

	if ! kj_ssh_validate_user "$remote_user"; then
		echo "錯誤: SSH 使用者名稱格式不正確。"
		return 1
	fi

	if ! kj_ssh_validate_host "$remote_host"; then
		echo "錯誤: SSH 主機位址格式不正確。"
		return 1
	fi

	KJ_SSH_USER="$remote_user"
	KJ_SSH_HOST="$remote_host"
	KJ_SSH_REMOTE="$remote_user@$remote_host"
}

kj_ssh_read_auth() {
	local key_file="$1"
	local password_or_key=""

	echo "請選擇身份驗證方式:"
	echo "1. 密碼"
	echo "2. 密鑰"
	read -e -p "請輸入選擇 (1/2):" auth_choice

	case $auth_choice in
		1)
			read -s -p "請輸入密碼:" password_or_key
			echo
			if [ -z "$password_or_key" ]; then
				echo "錯誤: 密碼不能為空。"
				return 1
			fi
			KJ_SSH_AUTH_METHOD="password"
			KJ_SSH_AUTH_SECRET="$password_or_key"
			;;
		2)
			echo "請貼上金鑰內容 (貼上完成後按兩次回車)："
			while IFS= read -r line; do
				if [[ -z "$line" && "$password_or_key" == *"-----BEGIN"* ]]; then
					break
				fi
				if [[ -n "$line" || "$password_or_key" == *"-----BEGIN"* ]]; then
					password_or_key+="${line}"$'\n'
				fi
			done

			if [[ "$password_or_key" != *"-----BEGIN"* || "$password_or_key" != *"PRIVATE KEY-----"* ]]; then
				echo "無效的密鑰內容！"
				return 1
			fi

			mkdir -p "$(dirname "$key_file")"
			echo -n "$password_or_key" > "$key_file"
			chmod 600 "$key_file"
			KJ_SSH_AUTH_METHOD="key"
			KJ_SSH_AUTH_SECRET="$key_file"
			;;
		*)
			echo "無效的選擇！"
			return 1
			;;
	esac
}

kj_ssh_read_password() {
	local prompt="${1:-请输入密码: }"
	while true; do
		read -e -s -p "$prompt" KJ_SSH_PASSWORD
		echo
		[ -n "$KJ_SSH_PASSWORD" ] && break
		echo "錯誤: 密碼不能為空。"
	done
}

kj_ssh_read_port() {
	local port_prompt="$1"
	local default_port="${2:-22}"
	while true; do
		read -e -p "$port_prompt" KJ_SSH_PORT
		KJ_SSH_PORT=${KJ_SSH_PORT:-$default_port}
		if kj_ssh_validate_port "$KJ_SSH_PORT"; then
			return 0
		fi
		echo "錯誤: 連接埠必須是 1-65535 之間的數字。"
	done
}

# 顯示連線清單
list_connections() {
	echo "已儲存的連線:"
	echo "------------------------"
	cat "$CONFIG_FILE" | awk -F'|' '{print NR " - " $1 " (" $2 ")"}'
	echo "------------------------"
}


# 新增連接
add_connection() {
	send_stats "新增連接"
	echo "建立新連接範例："
	echo "- 連線名稱: my_server"
	echo "- IP位址: 192.168.1.100"
	echo "- 使用者名稱: root"
	echo "- 連接埠: 22"
	echo "------------------------"
	read -e -p "請輸入連線名稱:" name

	kj_ssh_read_host_user_port "請輸入IP位址:" "請輸入使用者名稱 (預設: root):" "請輸入連接埠號碼 (預設: 22):" "root" "22"
	if ! kj_ssh_read_auth "$KEY_DIR/$name.key"; then
		return
	fi

	echo "$name|$KJ_SSH_HOST|$KJ_SSH_USER|$KJ_SSH_PORT|$KJ_SSH_AUTH_SECRET" >> "$CONFIG_FILE"
	echo "連線已儲存!"
}



# 刪除連接
delete_connection() {
	send_stats "刪除連接"
	read -e -p "請輸入要刪除的連接編號:" num

	local connection=$(sed -n "${num}p" "$CONFIG_FILE")
	if [[ -z "$connection" ]]; then
		echo "錯誤：未找到對應的連線。"
		return
	fi

	IFS='|' read -r name ip user port password_or_key <<< "$connection"

	# 如果連接使用的是密鑰文件，則刪除該密鑰文件
	if [[ "$password_or_key" == "$KEY_DIR"* ]]; then
		rm -f "$password_or_key"
	fi

	sed -i "${num}d" "$CONFIG_FILE"
	echo "連線已刪除!"
}

# 使用連接
use_connection() {
	send_stats "使用連接"
	read -e -p "請輸入要使用的連接編號:" num

	local connection=$(sed -n "${num}p" "$CONFIG_FILE")
	if [[ -z "$connection" ]]; then
		echo "錯誤：未找到對應的連線。"
		return
	fi

	IFS='|' read -r name ip user port password_or_key <<< "$connection"

	echo "正在連接到$name ($ip)..."
	if [[ -f "$password_or_key" ]]; then
		# 使用密鑰連接
		ssh -o StrictHostKeyChecking=no -i "$password_or_key" -p "$port" "$user@$ip"
		if [[ $? -ne 0 ]]; then
			echo "連線失敗！請檢查以下內容："
			echo "1. 密鑰檔案路徑是否正確：$password_or_key"
			echo "2. 密鑰檔案權限是否正確（應為 600）。"
			echo "3. 目標伺服器是否允許使用金鑰登入。"
		fi
	else
		# 使用密碼連接
		if ! command -v sshpass &> /dev/null; then
			echo "錯誤：未安裝 sshpass，請先安裝 sshpass。"
			echo "安裝方法："
			echo "  - Ubuntu/Debian: apt install sshpass"
			echo "  - CentOS/RHEL: yum install sshpass"
			return
		fi
		sshpass -p "$password_or_key" ssh -o StrictHostKeyChecking=no -p "$port" "$user@$ip"
		if [[ $? -ne 0 ]]; then
			echo "連線失敗！請檢查以下內容："
			echo "1. 使用者名稱和密碼是否正確。"
			echo "2. 目標伺服器是否允許密碼登入。"
			echo "3. 目標伺服器的 SSH 服務是否正常運作。"
		fi
	fi
}


ssh_manager() {
	send_stats "ssh遠端連線工具"

	CONFIG_FILE="$HOME/.ssh_connections"
	KEY_DIR="$HOME/.ssh/ssh_manager_keys"

	# 檢查設定檔和金鑰目錄是否存在，如果不存在則創建
	if [[ ! -f "$CONFIG_FILE" ]]; then
		touch "$CONFIG_FILE"
	fi

	if [[ ! -d "$KEY_DIR" ]]; then
		mkdir -p "$KEY_DIR"
		chmod 700 "$KEY_DIR"
	fi

	while true; do
		clear
		echo "SSH 遠端連線工具"
		echo "可以透過SSH連接到其他Linux系統上"
		echo "------------------------"
		list_connections
		echo "1. 建立新連接 2. 使用連接 3. 刪除連接"
		echo "------------------------"
		echo "0. 返回上一級選單"
		echo "------------------------"
		read -e -p "請輸入你的選擇:" choice
		case $choice in
			1) add_connection ;;
			2) use_connection ;;
			3) delete_connection ;;
			0) break ;;
			*) echo "無效的選擇，請重試。" ;;
		esac
	done
}












# 列出可用的硬碟分割區
list_partitions() {
	echo "可用的硬碟分割區："
	lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT | grep -v "sr\|loop"
}


# 持久化掛載分區
mount_partition() {
	send_stats "掛載分割區"
	read -e -p "請輸入要掛載的分割區名稱（例如 sda1）:" PARTITION

	DEVICE="/dev/$PARTITION"
	MOUNT_POINT="/mnt/$PARTITION"

	# 檢查分割區是否存在
	if ! lsblk -no NAME | grep -qw "$PARTITION"; then
		echo "分區不存在！"
		return 1
	fi

	# 檢查是否已掛載
	if mount | grep -qw "$DEVICE"; then
		echo "分區已經掛載！"
		return 1
	fi

	# 取得 UUID
	UUID=$(blkid -s UUID -o value "$DEVICE")
	if [ -z "$UUID" ]; then
		echo "無法取得 UUID！"
		return 1
	fi

	# 取得檔案系統類型
	FSTYPE=$(blkid -s TYPE -o value "$DEVICE")
	if [ -z "$FSTYPE" ]; then
		echo "無法取得檔案系統類型！"
		return 1
	fi

	# 建立掛載點
	mkdir -p "$MOUNT_POINT"

	# 掛載
	if ! mount "$DEVICE" "$MOUNT_POINT"; then
		echo "分區掛載失敗！"
		rmdir "$MOUNT_POINT"
		return 1
	fi

	echo "分割區已成功掛載到$MOUNT_POINT"

	# 檢查 /etc/fstab 是否已經存在 UUID 或掛載點
	if grep -qE "UUID=$UUID|[[:space:]]$MOUNT_POINT[[:space:]]" /etc/fstab; then
		echo "/etc/fstab 中已存在該分區記錄，跳過寫入"
		return 0
	fi

	# 寫入 /etc/fstab
	echo "UUID=$UUID $MOUNT_POINT $FSTYPE defaults,nofail 0 2" >> /etc/fstab

	echo "已寫入 /etc/fstab，實現持久化掛載"
}


# 解除安裝分割區
unmount_partition() {
	send_stats "解除安裝分割區"
	read -e -p "請輸入要卸載的分割區名稱（例如 sda1）:" PARTITION

	# 檢查分割區是否已經掛載
	MOUNT_POINT=$(lsblk -o MOUNTPOINT | grep -w "$PARTITION")
	if [ -z "$MOUNT_POINT" ]; then
		echo "分區未掛載！"
		return
	fi

	# 解除安裝分割區
	umount "/dev/$PARTITION"

	if [ $? -eq 0 ]; then
		echo "分割區卸載成功:$MOUNT_POINT"
		rmdir "$MOUNT_POINT"
	else
		echo "分區卸載失敗！"
	fi
}

# 列出已掛載的分割區
list_mounted_partitions() {
	echo "已掛載的分割區："
	df -h | grep -v "tmpfs\|udev\|overlay"
}

# 格式化分割區
format_partition() {
	send_stats "格式化分割區"
	read -e -p "請輸入要格式化的分割區名稱（例如 sda1）:" PARTITION

	# 檢查分割區是否存在
	if ! lsblk -o NAME | grep -w "$PARTITION" > /dev/null; then
		echo "分區不存在！"
		return
	fi

	# 檢查分割區是否已經掛載
	if lsblk -o MOUNTPOINT | grep -w "$PARTITION" > /dev/null; then
		echo "分割區已經掛載，請先卸載！"
		return
	fi

	# 選擇檔案系統類型
	echo "請選擇檔案系統類型："
	echo "1. ext4"
	echo "2. xfs"
	echo "3. ntfs"
	echo "4. vfat"
	read -e -p "請輸入你的選擇:" FS_CHOICE

	case $FS_CHOICE in
		1) FS_TYPE="ext4" ;;
		2) FS_TYPE="xfs" ;;
		3) FS_TYPE="ntfs" ;;
		4) FS_TYPE="vfat" ;;
		*) echo "無效的選擇！"; return ;;
	esac

	# 確認格式化
	read -e -p "確認格式化分割區 /dev/$PARTITION為$FS_TYPE嗎？ (y/n):" CONFIRM
	if [ "$CONFIRM" != "y" ]; then
		echo "操作已取消。"
		return
	fi

	# 格式化分割區
	echo "正在格式化分割區 /dev/$PARTITION為$FS_TYPE ..."
	mkfs.$FS_TYPE "/dev/$PARTITION"

	if [ $? -eq 0 ]; then
		echo "分割區格式化成功！"
	else
		echo "分割區格式化失敗！"
	fi
}

# 檢查分區狀態
check_partition() {
	send_stats "檢查分區狀態"
	read -e -p "請輸入要檢查的分割區名稱（例如 sda1）:" PARTITION

	# 檢查分割區是否存在
	if ! lsblk -o NAME | grep -w "$PARTITION" > /dev/null; then
		echo "分區不存在！"
		return
	fi

	# 檢查分區狀態
	echo "檢查分割區 /dev/$PARTITION的狀態："
	fsck "/dev/$PARTITION"
}

# 主選單
disk_manager() {
	send_stats "硬碟管理功能"
	while true; do
		clear
		echo "硬碟分割管理"
		echo -e "${gl_huang}此功能內部測試階段，請勿在生產環境使用。${gl_bai}"
		echo "------------------------"
		list_partitions
		echo "------------------------"
		echo "1. 掛載分割區 2. 卸載分割區 3. 檢視已掛載分割區"
		echo "4. 格式化分割區 5. 檢查分割區狀態"
		echo "------------------------"
		echo "0. 返回上一級選單"
		echo "------------------------"
		read -e -p "請輸入你的選擇:" choice
		case $choice in
			1) mount_partition ;;
			2) unmount_partition ;;
			3) list_mounted_partitions ;;
			4) format_partition ;;
			5) check_partition ;;
			*) break ;;
		esac
		read -e -p "按下回車鍵繼續..."
	done
}




# 顯示任務列表
list_tasks() {
	echo "已儲存的同步任務:"
	echo "---------------------------------"
	awk -F'|' '{print NR " - " $1 " ( " $2 " -> " $3":"$4 " )"}' "$CONFIG_FILE"
	echo "---------------------------------"
}

# 新增任務
add_task() {
	send_stats "新增同步任務"
	echo "建立新同步任務範例："
	echo "- 任務名稱: backup_www"
	echo "- 本機目錄: /var/www"
	echo "- 遠端位址: user@192.168.1.100"
	echo "- 遠端目錄: /backup/www"
	echo "- 連接埠號碼 (預設 22)"
	echo "---------------------------------"
	read -e -p "請輸入任務名稱:" name
	read -e -p "請輸入本地目錄:" local_path
	read -e -p "請輸入遠端目錄:" remote_path

	while true; do
		read -e -p "請輸入遠端使用者@IP:" remote
		if kj_ssh_parse_remote "$remote" "root"; then
			remote="$KJ_SSH_REMOTE"
			break
		fi
	done

	kj_ssh_read_port "請輸入 SSH 連接埠 (預設 22):" "22"
	port="$KJ_SSH_PORT"

	if ! kj_ssh_read_auth "$KEY_DIR/${name}_sync.key"; then
		return
	fi
	auth_method="$KJ_SSH_AUTH_METHOD"
	password_or_key="$KJ_SSH_AUTH_SECRET"

	echo "請選擇同步模式:"
	echo "1. 標準模式 (-avz)"
	echo "2. 刪除目標檔 (-avz --delete)"
	read -e -p "請選擇 (1/2):" mode
	case $mode in
		1) options="-avz" ;;
		2) options="-avz --delete" ;;
		*) echo "無效選擇，使用預設 -avz"; options="-avz" ;;
	esac

	echo "$name|$local_path|$remote|$remote_path|$port|$options|$auth_method|$password_or_key" >> "$CONFIG_FILE"

	install rsync rsync

	echo "任務已儲存!"
}


# 刪除任務
delete_task() {
	send_stats "刪除同步任務"
	read -e -p "請輸入要刪除的任務編號:" num

	local task=$(sed -n "${num}p" "$CONFIG_FILE")
	if [[ -z "$task" ]]; then
		echo "錯誤：未找到對應的任務。"
		return
	fi

	IFS='|' read -r name local_path remote remote_path port options auth_method password_or_key <<< "$task"

	# 如果任務使用的是金鑰文件，則刪除該金鑰文件
	if [[ "$auth_method" == "key" && "$password_or_key" == "$KEY_DIR"* ]]; then
		rm -f "$password_or_key"
	fi

	sed -i "${num}d" "$CONFIG_FILE"
	echo "任務已刪除!"
}


run_task() {
	send_stats "執行同步任務"

	CONFIG_FILE="$HOME/.rsync_tasks"
	CRON_FILE="$HOME/.rsync_cron"

	# 解析參數
	local direction="push"  # 默认是推送到远端
	local num

	if [[ "$1" == "push" || "$1" == "pull" ]]; then
		direction="$1"
		num="$2"
	else
		num="$1"
	fi

	# 如果沒有傳入任務編號，提示使用者輸入
	if [[ -z "$num" ]]; then
		read -e -p "請輸入要執行的任務編號:" num
	fi

	local task=$(sed -n "${num}p" "$CONFIG_FILE")
	if [[ -z "$task" ]]; then
		echo "錯誤: 未找到該任務!"
		return
	fi

	IFS='|' read -r name local_path remote remote_path port options auth_method password_or_key <<< "$task"

	# 根據同步方向調整來源和目標路徑
	if [[ "$direction" == "pull" ]]; then
		echo "正在拉取同步到本地:$remote:$local_path -> $remote_path"
		source="$remote:$local_path"
		destination="$remote_path"
	else
		echo "正在推送同步到遠端:$local_path -> $remote:$remote_path"
		source="$local_path"
		destination="$remote:$remote_path"
	fi

	# 新增 SSH 連線通用參數
	local ssh_options="-p $port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

	if [[ "$auth_method" == "password" ]]; then
		if ! command -v sshpass &> /dev/null; then
			echo "錯誤：未安裝 sshpass，請先安裝 sshpass。"
			echo "安裝方法："
			echo "  - Ubuntu/Debian: apt install sshpass"
			echo "  - CentOS/RHEL: yum install sshpass"
			return
		fi
		sshpass -p "$password_or_key" rsync $options -e "ssh $ssh_options" "$source" "$destination"
	else
		# 檢查密鑰檔案是否存在和權限是否正確
		if [[ ! -f "$password_or_key" ]]; then
			echo "錯誤：密鑰檔案不存在：$password_or_key"
			return
		fi

		if [[ "$(stat -c %a "$password_or_key")" != "600" ]]; then
			echo "警告：密鑰檔案權限不正確，正在修復..."
			chmod 600 "$password_or_key"
		fi

		rsync $options -e "ssh -i $password_or_key $ssh_options" "$source" "$destination"
	fi

	if [[ $? -eq 0 ]]; then
		echo "同步完成!"
	else
		echo "同步失敗! 請檢查以下內容："
		echo "1. 網路連線是否正常"
		echo "2. 遠端主機是否可存取"
		echo "3. 認證資訊是否正確"
		echo "4. 本機和遠端目錄是否有正確的存取權限"
	fi
}


# 建立定時任務
schedule_task() {
	send_stats "新增同步定時任務"

	read -e -p "請輸入要定時同步的任務編號:" num
	if ! [[ "$num" =~ ^[0-9]+$ ]]; then
		echo "錯誤: 請輸入有效的任務編號！"
		return
	fi

	echo "請選擇定時執行間隔："
	echo "1) 每小時執行一次"
	echo "2) 每天執行一次"
	echo "3) 每週執行一次"
	read -e -p "請輸入選項 (1/2/3):" interval

	local random_minute=$(shuf -i 0-59 -n 1)  # 生成 0-59 之间的随机分钟数
	local cron_time=""
	case "$interval" in
		1) cron_time="$random_minute * * * *" ;;  # 每小时，随机分钟执行
		2) cron_time="$random_minute 0 * * *" ;;  # 每天，随机分钟执行
		3) cron_time="$random_minute 0 * * 1" ;;  # 每周，随机分钟执行
		*) echo "錯誤: 請輸入有效的選項！" ; return ;;
	esac

	local cron_job="$cron_time k rsync_run $num"
	local cron_job="$cron_time k rsync_run $num"

	# 檢查是否已存在相同任務
	if crontab -l | grep -q "k rsync_run $num"; then
		echo "錯誤: 該任務的定時同步已存在！"
		return
	fi

	# 建立到使用者的 crontab
	(crontab -l 2>/dev/null; echo "$cron_job") | crontab -
	echo "定時任務已建立:$cron_job"
}

# 查看定時任務
view_tasks() {
	echo "目前的定時任務:"
	echo "---------------------------------"
	crontab -l | grep "k rsync_run"
	echo "---------------------------------"
}

# 刪除定時任務
delete_task_schedule() {
	send_stats "刪除同步定時任務"
	read -e -p "請輸入要刪除的任務編號:" num
	if ! [[ "$num" =~ ^[0-9]+$ ]]; then
		echo "錯誤: 請輸入有效的任務編號！"
		return
	fi

	crontab -l | grep -v "k rsync_run $num" | crontab -
	echo "已刪除任務編號$num的定時任務"
}


# 工作管理員主選單
rsync_manager() {
	CONFIG_FILE="$HOME/.rsync_tasks"
	CRON_FILE="$HOME/.rsync_cron"

	while true; do
		clear
		echo "Rsync 遠端同步工具"
		echo "遠端目錄之間同步，支援增量同步，高效穩定。"
		echo "---------------------------------"
		list_tasks
		echo
		view_tasks
		echo
		echo "1. 建立新任務 2. 刪除任務"
		echo "3. 執行本地同步到遠端 4. 執行遠端同步到本地"
		echo "5. 建立定時任務 6. 刪除定時任務"
		echo "---------------------------------"
		echo "0. 返回上一級選單"
		echo "---------------------------------"
		read -e -p "請輸入你的選擇:" choice
		case $choice in
			1) add_task ;;
			2) delete_task ;;
			3) run_task push;;
			4) run_task pull;;
			5) schedule_task ;;
			6) delete_task_schedule ;;
			0) break ;;
			*) echo "無效的選擇，請重試。" ;;
		esac
		read -e -p "按下回車鍵繼續..."
	done
}









linux_info() {



	clear
	echo -e "${gl_kjlan}正在查詢系統資訊…${gl_bai}"
	send_stats "系統資訊查詢"

	ip_address

	local cpu_info=$(lscpu | awk -F': +' '/Model name:/ {print $2; exit}')

	local cpu_usage_percent=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else printf "%.0f\n", (($2+$4-u1) * 100 / (t-t1))}' \
		<(grep 'cpu ' /proc/stat) <(sleep 1; grep 'cpu ' /proc/stat))

	local cpu_cores=$(nproc)

	local cpu_freq=$(cat /proc/cpuinfo | grep "MHz" | head -n 1 | awk '{printf "%.1f GHz\n", $4/1000}')

	local mem_info=$(free -b | awk 'NR==2{printf "%.2f/%.2fM (%.2f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2}')

	local disk_info=$(df -h | awk '$NF=="/"{printf "%s/%s (%s)", $3, $2, $5}')

	local ipinfo=$(curl -s ipinfo.io)
	local country=$(echo "$ipinfo" | grep 'country' | awk -F': ' '{print $2}' | tr -d '",')
	local city=$(echo "$ipinfo" | grep 'city' | awk -F': ' '{print $2}' | tr -d '",')
	local isp_info=$(echo "$ipinfo" | grep 'org' | awk -F': ' '{print $2}' | tr -d '",')

	local load=$(uptime | awk '{print $(NF-2), $(NF-1), $NF}')
	local dns_addresses=$(awk '/^nameserver/{printf "%s ", $2} END {print ""}' /etc/resolv.conf)


	local cpu_arch=$(uname -m)

	local hostname=$(uname -n)

	local kernel_version=$(uname -r)

	local congestion_algorithm=$(sysctl -n net.ipv4.tcp_congestion_control)
	local queue_algorithm=$(sysctl -n net.core.default_qdisc)

	local os_info=$(grep PRETTY_NAME /etc/os-release | cut -d '=' -f2 | tr -d '"')

	output_status

	local current_time=$(date "+%Y-%m-%d %I:%M %p")


	local swap_info=$(free -m | awk 'NR==3{used=$3; total=$2; if (total == 0) {percentage=0} else {percentage=used*100/total}; printf "%dM/%dM (%d%%)", used, total, percentage}')

	local runtime=$(cat /proc/uptime | awk -F. '{run_days=int($1 / 86400);run_hours=int(($1 % 86400) / 3600);run_minutes=int(($1% 3600) / 60); if (run_days > 0) printf("%d天 ", run_days); if (run_hours > 0) printf("%d時 ", run_hours); printf("%d分\n", run_minutes)}')

	local timezone=$(current_timezone)

	local tcp_count=$(ss -t | wc -l)
	local udp_count=$(ss -u | wc -l)

	clear
	echo -e "系統資訊查詢"
	echo -e "${gl_kjlan}-------------"
	echo -e "${gl_kjlan}主機名稱:${gl_bai}$hostname"
	echo -e "${gl_kjlan}系統版本:${gl_bai}$os_info"
	echo -e "${gl_kjlan}Linux版本:${gl_bai}$kernel_version"
	echo -e "${gl_kjlan}-------------"
	echo -e "${gl_kjlan}CPU架構:${gl_bai}$cpu_arch"
	echo -e "${gl_kjlan}CPU型號:${gl_bai}$cpu_info"
	echo -e "${gl_kjlan}CPU核心數:${gl_bai}$cpu_cores"
	echo -e "${gl_kjlan}CPU頻率:${gl_bai}$cpu_freq"
	echo -e "${gl_kjlan}-------------"
	echo -e "${gl_kjlan}CPU佔用:${gl_bai}$cpu_usage_percent%"
	echo -e "${gl_kjlan}系統負載:${gl_bai}$load"
	echo -e "${gl_kjlan}TCP|UDP連線數:${gl_bai}$tcp_count|$udp_count"
	echo -e "${gl_kjlan}實體記憶體:${gl_bai}$mem_info"
	echo -e "${gl_kjlan}虛擬記憶體:${gl_bai}$swap_info"
	echo -e "${gl_kjlan}硬碟佔用:${gl_bai}$disk_info"
	echo -e "${gl_kjlan}-------------"
	echo -e "${gl_kjlan}總接收:${gl_bai}$rx"
	echo -e "${gl_kjlan}總發送:${gl_bai}$tx"
	echo -e "${gl_kjlan}-------------"
	echo -e "${gl_kjlan}網路演算法:${gl_bai}$congestion_algorithm $queue_algorithm"
	echo -e "${gl_kjlan}-------------"
	echo -e "${gl_kjlan}運營商:${gl_bai}$isp_info"
	if [ -n "$ipv4_address" ]; then
		echo -e "${gl_kjlan}IPv4位址:${gl_bai}$ipv4_address"
	fi

	if [ -n "$ipv6_address" ]; then
		echo -e "${gl_kjlan}IPv6位址:${gl_bai}$ipv6_address"
	fi
	echo -e "${gl_kjlan}DNS位址:${gl_bai}$dns_addresses"
	echo -e "${gl_kjlan}地理位置:${gl_bai}$country $city"
	echo -e "${gl_kjlan}系統時間:${gl_bai}$timezone $current_time"
	echo -e "${gl_kjlan}-------------"
	echo -e "${gl_kjlan}運行時長:${gl_bai}$runtime"
	echo



}



linux_tools() {

  while true; do
	  clear
	  # send_stats "基礎工具"
	  echo -e "基礎工具"

	  tools=(
		curl wget sudo socat htop iftop unzip tar tmux ffmpeg
		btop ranger ncdu fzf cmatrix sl bastet nsnake ninvaders
		vim nano git
	  )

	  if command -v apt >/dev/null 2>&1; then
		PM="apt"
	  elif command -v dnf >/dev/null 2>&1; then
		PM="dnf"
	  elif command -v yum >/dev/null 2>&1; then
		PM="yum"
	  elif command -v pacman >/dev/null 2>&1; then
		PM="pacman"
	  elif command -v apk >/dev/null 2>&1; then
		PM="apk"
	  elif command -v zypper >/dev/null 2>&1; then
		PM="zypper"
	  elif command -v opkg >/dev/null 2>&1; then
		PM="opkg"
	  elif command -v pkg >/dev/null 2>&1; then
		PM="pkg"
	  else
		echo "❌ 未識別的套件管理器"
		exit 1
	  fi

	  echo "📦 使用套件管理器:$PM"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"

	  for ((i=0; i<${#tools[@]}; i+=2)); do
		# 左列
		if command -v "${tools[i]}" >/dev/null 2>&1; then
		  left=$(printf "✅ %-12s 已安裝" "${tools[i]}")
		else
		  left=$(printf "❌ %-12s 未安裝" "${tools[i]}")
		fi

		# 右列（防止數組越界）
		if [[ -n "${tools[i+1]}" ]]; then
		  if command -v "${tools[i+1]}" >/dev/null 2>&1; then
			right=$(printf "✅ %-12s 已安裝" "${tools[i+1]}")
		  else
			right=$(printf "❌ %-12s 未安裝" "${tools[i+1]}")
		  fi
		  printf "%-42s %s\n" "$left" "$right"
		else
		  printf "%s\n" "$left"
		fi
	  done

	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}1.   ${gl_bai}curl 下載工具${gl_huang}★${gl_bai}                   ${gl_kjlan}2.   ${gl_bai}wget 下載工具${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}3.   ${gl_bai}sudo 超級管理權限工具${gl_kjlan}4.   ${gl_bai}socat 通訊連接工具"
	  echo -e "${gl_kjlan}5.   ${gl_bai}htop 系統監控工具${gl_kjlan}6.   ${gl_bai}iftop 網路流量監控工具"
	  echo -e "${gl_kjlan}7.   ${gl_bai}unzip ZIP壓縮解壓縮工具${gl_kjlan}8.   ${gl_bai}tar GZ壓縮解壓縮工具"
	  echo -e "${gl_kjlan}9.   ${gl_bai}tmux 多路後台運行工具${gl_kjlan}10.  ${gl_bai}ffmpeg 視訊編碼直播推流工具"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}11.  ${gl_bai}btop 現代化監控工具${gl_huang}★${gl_bai}             ${gl_kjlan}12.  ${gl_bai}ranger 檔案管理工具"
	  echo -e "${gl_kjlan}13.  ${gl_bai}ncdu 磁碟佔用檢視工具${gl_kjlan}14.  ${gl_bai}fzf 全域搜尋工具"
	  echo -e "${gl_kjlan}15.  ${gl_bai}vim 文字編輯器${gl_kjlan}16.  ${gl_bai}nano 文字編輯器${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}17.  ${gl_bai}git 版本控制系統${gl_kjlan}18.  ${gl_bai}opencode AI程式設計助手${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}21.  ${gl_bai}駭客任務螢幕保${gl_kjlan}22.  ${gl_bai}跑火車屏保"
	  echo -e "${gl_kjlan}26.  ${gl_bai}俄羅斯方塊小遊戲${gl_kjlan}27.  ${gl_bai}貪吃蛇小遊戲"
	  echo -e "${gl_kjlan}28.  ${gl_bai}太空入侵者小遊戲"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}31.  ${gl_bai}全部安裝${gl_kjlan}32.  ${gl_bai}全部安裝（不含螢幕保護程式和遊戲）${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}33.  ${gl_bai}全部解除安裝"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}41.  ${gl_bai}安裝指定工具${gl_kjlan}42.  ${gl_bai}解除安裝指定工具"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}0.   ${gl_bai}返回主選單"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "請輸入你的選擇:" sub_choice

	  case $sub_choice in
		  1)
			  clear
			  install curl
			  clear
			  echo "工具已安裝，使用方法如下："
			  curl --help
			  send_stats "安裝curl"
			  ;;
		  2)
			  clear
			  install wget
			  clear
			  echo "工具已安裝，使用方法如下："
			  wget --help
			  send_stats "安裝wget"
			  ;;
			3)
			  clear
			  install sudo
			  clear
			  echo "工具已安裝，使用方法如下："
			  sudo --help
			  send_stats "安裝sudo"
			  ;;
			4)
			  clear
			  install socat
			  clear
			  echo "工具已安裝，使用方法如下："
			  socat -h
			  send_stats "安裝socat"
			  ;;
			5)
			  clear
			  install htop
			  clear
			  htop
			  send_stats "安裝htop"
			  ;;
			6)
			  clear
			  install iftop
			  clear
			  iftop
			  send_stats "安裝iftop"
			  ;;
			7)
			  clear
			  install unzip
			  clear
			  echo "工具已安裝，使用方法如下："
			  unzip
			  send_stats "安裝unzip"
			  ;;
			8)
			  clear
			  install tar
			  clear
			  echo "工具已安裝，使用方法如下："
			  tar --help
			  send_stats "安裝tar"
			  ;;
			9)
			  clear
			  install tmux
			  clear
			  echo "工具已安裝，使用方法如下："
			  tmux --help
			  send_stats "安裝tmux"
			  ;;
			10)
			  clear
			  install ffmpeg
			  clear
			  echo "工具已安裝，使用方法如下："
			  ffmpeg --help
			  send_stats "安裝ffmpeg"
			  ;;

			11)
			  clear
			  install btop
			  clear
			  btop
			  send_stats "安裝btop"
			  ;;
			12)
			  clear
			  install ranger
			  cd /
			  clear
			  ranger
			  cd ~
			  send_stats "安裝ranger"
			  ;;
			13)
			  clear
			  install ncdu
			  cd /
			  clear
			  ncdu
			  cd ~
			  send_stats "安裝ncdu"
			  ;;
			14)
			  clear
			  install fzf
			  cd /
			  clear
			  fzf
			  cd ~
			  send_stats "安裝fzf"
			  ;;
			15)
			  clear
			  install vim
			  cd /
			  clear
			  vim -h
			  cd ~
			  send_stats "安裝vim"
			  ;;
			16)
			  clear
			  install nano
			  cd /
			  clear
			  nano -h
			  cd ~
			  send_stats "安裝nano"
			  ;;


			17)
			  clear
			  install git
			  cd /
			  clear
			  git --help
			  cd ~
			  send_stats "安裝git"
			  ;;

			18)
			  clear
			  cd ~
			  curl -fsSL https://opencode.ai/install | bash
			  source ~/.bashrc
			  source ~/.profile
			  opencode
			  send_stats "安裝opencode"
			  ;;


			21)
			  clear
			  install cmatrix
			  clear
			  cmatrix
			  send_stats "安裝cmatrix"
			  ;;
			22)
			  clear
			  install sl
			  clear
			  sl
			  send_stats "安裝sl"
			  ;;
			26)
			  clear
			  install bastet
			  clear
			  bastet
			  send_stats "安裝bastet"
			  ;;
			27)
			  clear
			  install nsnake
			  clear
			  nsnake
			  send_stats "安裝nsnake"
			  ;;

			28)
			  clear
			  install ninvaders
			  clear
			  ninvaders
			  send_stats "安裝ninvaders"
			  ;;

		  31)
			  clear
			  send_stats "全部安裝"
			  install curl wget sudo socat htop iftop unzip tar tmux ffmpeg btop ranger ncdu fzf cmatrix sl bastet nsnake ninvaders vim nano git
			  ;;

		  32)
			  clear
			  send_stats "全部安裝（不含遊戲和螢幕保護程式）"
			  install curl wget sudo socat htop iftop unzip tar tmux ffmpeg btop ranger ncdu fzf vim nano git
			  ;;


		  33)
			  clear
			  send_stats "全部解除安裝"
			  remove htop iftop tmux ffmpeg btop ranger ncdu fzf cmatrix sl bastet nsnake ninvaders vim nano git
			  opencode uninstall
			  rm -rf ~/.opencode
			  ;;

		  41)
			  clear
			  read -e -p "請輸入已安裝的工具名稱（wget curl sudo htop）:" installname
			  install $installname
			  send_stats "安裝指定軟體"
			  ;;
		  42)
			  clear
			  read -e -p "請輸入卸載的工具名稱（htop ufw tmux cmatrix）:" removename
			  remove $removename
			  send_stats "解除安裝指定軟體"
			  ;;

		  0)
			  kejilion
			  ;;

		  *)
			  echo "無效的輸入!"
			  ;;
	  esac
	  break_end
  done




}


linux_bbr() {
	clear
	send_stats "bbr管理"
	if [ -f "/etc/alpine-release" ]; then
		while true; do
			  clear
			  local congestion_algorithm=$(sysctl -n net.ipv4.tcp_congestion_control)
			  local queue_algorithm=$(sysctl -n net.core.default_qdisc)
			  echo "當前TCP阻塞演算法:$congestion_algorithm $queue_algorithm"

			  echo ""
			  echo "BBR管理"
			  echo "------------------------"
			  echo "1. 開啟BBRv3 2. 關閉BBRv3（會重新啟動）"
			  echo "------------------------"
			  echo "0. 返回上一級選單"
			  echo "------------------------"
			  read -e -p "請輸入你的選擇:" sub_choice

			  case $sub_choice in
				  1)
					bbr_on
					send_stats "alpine開啟bbr3"
					  ;;
				  2)
					sed -i '/net.ipv4.tcp_congestion_control=/d' /etc/sysctl.conf
					sysctl -p
					server_reboot
					  ;;
				  *)
					  break  # 跳出循环，退出菜单
					  ;;

			  esac
		done
	else
		install wget
		wget --no-check-certificate -O tcpx.sh ${gh_proxy}raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcpx.sh
		chmod +x tcpx.sh
		./tcpx.sh
	fi


}





docker_ssh_migration() {

	is_compose_container() {
		local container=$1
		docker inspect "$container" | jq -e '.[0].Config.Labels["com.docker.compose.project"]' >/dev/null 2>&1
	}

	list_backups() {
		local BACKUP_ROOT="/tmp"
		echo -e "${gl_kjlan}目前備份清單:${gl_bai}"
		ls -1dt ${BACKUP_ROOT}/docker_backup_* 2>/dev/null || echo "無備份"
	}



	# ----------------------------
	# 備份
	# ----------------------------
	backup_docker() {
		send_stats "Docker備份"

		echo -e "${gl_kjlan}正在備份 Docker 容器...${gl_bai}"
		docker ps --format '{{.Names}}'
		read -e -p  "請輸入要備份的容器名稱（多個空格分隔，回車備份全部運行中容器）:" containers

		install tar jq gzip
		install_docker

		local BACKUP_ROOT="/tmp"
		local DATE_STR=$(date +%Y%m%d_%H%M%S)
		local TARGET_CONTAINERS=()
		if [ -z "$containers" ]; then
			mapfile -t TARGET_CONTAINERS < <(docker ps --format '{{.Names}}')
		else
			read -ra TARGET_CONTAINERS <<< "$containers"
		fi
		[[ ${#TARGET_CONTAINERS[@]} -eq 0 ]] && { echo -e "${gl_hong}沒有找到容器${gl_bai}"; return; }

		local BACKUP_DIR="${BACKUP_ROOT}/docker_backup_${DATE_STR}"
		mkdir -p "$BACKUP_DIR"

		local RESTORE_SCRIPT="${BACKUP_DIR}/docker_restore.sh"
		echo "#!/bin/bash" > "$RESTORE_SCRIPT"
		echo "set -e" >> "$RESTORE_SCRIPT"
		echo "# 自動產生的還原腳本" >> "$RESTORE_SCRIPT"

		# 記錄已打包過的 Compose 專案路徑，避免重複打包
		declare -A PACKED_COMPOSE_PATHS=()

		for c in "${TARGET_CONTAINERS[@]}"; do
			echo -e "${gl_lv}備份容器:$c${gl_bai}"
			local inspect_file="${BACKUP_DIR}/${c}_inspect.json"
			docker inspect "$c" > "$inspect_file"

			if is_compose_container "$c"; then
				echo -e "${gl_kjlan}檢測到$c是 docker-compose 容器${gl_bai}"
				local project_dir=$(docker inspect "$c" | jq -r '.[0].Config.Labels["com.docker.compose.project.working_dir"] // empty')
				local project_name=$(docker inspect "$c" | jq -r '.[0].Config.Labels["com.docker.compose.project"] // empty')

				if [ -z "$project_dir" ]; then
					read -e -p  "未偵測到 compose 目錄，請手動輸入路徑:" project_dir
				fi

				# 如果該 Compose 項目已經打包過，跳過
				if [[ -n "${PACKED_COMPOSE_PATHS[$project_dir]}" ]]; then
					echo -e "${gl_huang}Compose 項目 [$project_name] 已備份過，跳過重複打包...${gl_bai}"
					continue
				fi

				if [ -f "$project_dir/docker-compose.yml" ]; then
					echo "compose" > "${BACKUP_DIR}/backup_type_${project_name}"
					echo "$project_dir" > "${BACKUP_DIR}/compose_path_${project_name}.txt"
					tar -czf "${BACKUP_DIR}/compose_project_${project_name}.tar.gz" -C "$project_dir" .
					echo "# docker-compose 恢復:$project_name" >> "$RESTORE_SCRIPT"
					echo "cd \"$project_dir\" && docker compose up -d" >> "$RESTORE_SCRIPT"
					PACKED_COMPOSE_PATHS["$project_dir"]=1
					echo -e "${gl_lv}Compose 項目 [$project_name] 已打包:${project_dir}${gl_bai}"
				else
					echo -e "${gl_hong}未找到 docker-compose.yml，跳過此容器...${gl_bai}"
				fi
			else
				# 普通容器備份卷
				local VOL_PATHS
				VOL_PATHS=$(docker inspect "$c" --format '{{range .Mounts}}{{.Source}} {{end}}')
				for path in $VOL_PATHS; do
					echo "打包卷:$path"
					tar -czpf "${BACKUP_DIR}/${c}_$(basename $path).tar.gz" -C / "$(echo $path | sed 's/^\///')"
				done

				# 連接埠
				local PORT_ARGS=""
				mapfile -t PORTS < <(jq -r '.[0].HostConfig.PortBindings | to_entries[] | "\(.value[0].HostPort):\(.key | split("/")[0])"' "$inspect_file" 2>/dev/null)
				for p in "${PORTS[@]}"; do PORT_ARGS+="-p $p "; done

				# 環境變數
				local ENV_VARS=""
				mapfile -t ENVS < <(jq -r '.[0].Config.Env[] | @sh' "$inspect_file")
				for e in "${ENVS[@]}"; do ENV_VARS+="-e $e "; done

				# 卷映射
				local VOL_ARGS=""
				for path in $VOL_PATHS; do VOL_ARGS+="-v $path:$path "; done

				# 鏡像
				local IMAGE
				IMAGE=$(jq -r '.[0].Config.Image' "$inspect_file")

				echo -e "\n# 還原容器:$c" >> "$RESTORE_SCRIPT"
				echo "docker run -d --name $c $PORT_ARGS $VOL_ARGS $ENV_VARS $IMAGE" >> "$RESTORE_SCRIPT"
			fi
		done


		# 備份 /home/docker 下的所有檔案（不含子目錄）
		if [ -d "/home/docker" ]; then
			echo -e "${gl_kjlan}備份 /home/docker 下的檔案...${gl_bai}"
			find /home/docker -maxdepth 1 -type f | tar -czf "${BACKUP_DIR}/home_docker_files.tar.gz" -T -
			echo -e "${gl_lv}/home/docker 下的檔案已打包到:${BACKUP_DIR}/home_docker_files.tar.gz${gl_bai}"
		fi

		chmod +x "$RESTORE_SCRIPT"
		echo -e "${gl_lv}備份完成:${BACKUP_DIR}${gl_bai}"
		echo -e "${gl_lv}可用還原腳本:${RESTORE_SCRIPT}${gl_bai}"


	}

	# ----------------------------
	# 還原
	# ----------------------------
	restore_docker() {

		send_stats "Docker還原"
		read -e -p  "請輸入要還原的備份目錄:" BACKUP_DIR
		[[ ! -d "$BACKUP_DIR" ]] && { echo -e "${gl_hong}備份目錄不存在${gl_bai}"; return; }

		echo -e "${gl_kjlan}開始執行還原操作...${gl_bai}"

		install tar jq gzip
		install_docker

		# --------- 優先還原 Compose 專案 ---------
		for f in "$BACKUP_DIR"/backup_type_*; do
			[[ ! -f "$f" ]] && continue
			if grep -q "compose" "$f"; then
				project_name=$(basename "$f" | sed 's/backup_type_//')
				path_file="$BACKUP_DIR/compose_path_${project_name}.txt"
				[[ -f "$path_file" ]] && original_path=$(cat "$path_file") || original_path=""
				[[ -z "$original_path" ]] && read -e -p  "未找到原始路徑，請輸入還原目錄路徑:" original_path

				# 檢查該 compose 項目的容器是否已在運作
				running_count=$(docker ps --filter "label=com.docker.compose.project=$project_name" --format '{{.Names}}' | wc -l)
				if [[ "$running_count" -gt 0 ]]; then
					echo -e "${gl_huang}Compose 項目 [$project_name] 已有容器在運行，跳過還原...${gl_bai}"
					continue
				fi

				read -e -p  "確認還原 Compose 項目 [$project_name] 到路徑 [$original_path] ? (y/n): " confirm
				[[ "$confirm" != "y" ]] && read -e -p  "請輸入新的還原路徑:" original_path

				mkdir -p "$original_path"
				tar -xzf "$BACKUP_DIR/compose_project_${project_name}.tar.gz" -C "$original_path"
				echo -e "${gl_lv}Compose 項目 [$project_name] 已解壓縮到:$original_path${gl_bai}"

				cd "$original_path" || return
				docker compose down || true
				docker compose up -d
				echo -e "${gl_lv}Compose 項目 [$project_name] 還原完成！${gl_bai}"
			fi
		done

		# --------- 繼續還原一般容器 ---------
		echo -e "${gl_kjlan}檢查並還原普通 Docker 容器...${gl_bai}"
		local has_container=false
		for json in "$BACKUP_DIR"/*_inspect.json; do
			[[ ! -f "$json" ]] && continue
			has_container=true
			container=$(basename "$json" | sed 's/_inspect.json//')
			echo -e "${gl_lv}處理容器:$container${gl_bai}"

			# 檢查容器是否已經存在且正在運行
			if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
				echo -e "${gl_huang}容器 [$container] 已在運行，跳過還原...${gl_bai}"
				continue
			fi

			IMAGE=$(jq -r '.[0].Config.Image' "$json")
			[[ -z "$IMAGE" || "$IMAGE" == "null" ]] && { echo -e "${gl_hong}未找到鏡像訊息，跳過:$container${gl_bai}"; continue; }

			# 連接埠映射
			PORT_ARGS=""
			mapfile -t PORTS < <(jq -r '.[0].HostConfig.PortBindings | to_entries[]? | "\(.value[0].HostPort):\(.key | split("/")[0])"' "$json")
			for p in "${PORTS[@]}"; do
				[[ -n "$p" ]] && PORT_ARGS="$PORT_ARGS -p $p"
			done

			# 環境變數
			ENV_ARGS=""
			mapfile -t ENVS < <(jq -r '.[0].Config.Env[]' "$json")
			for e in "${ENVS[@]}"; do
				ENV_ARGS="$ENV_ARGS -e \"$e\""
			done

			# 卷映射 + 卷資料恢復
			VOL_ARGS=""
			mapfile -t VOLS < <(jq -r '.[0].Mounts[] | "\(.Source):\(.Destination)"' "$json")
			for v in "${VOLS[@]}"; do
				VOL_SRC=$(echo "$v" | cut -d':' -f1)
				VOL_DST=$(echo "$v" | cut -d':' -f2)
				mkdir -p "$VOL_SRC"
				VOL_ARGS="$VOL_ARGS -v $VOL_SRC:$VOL_DST"

				VOL_FILE="$BACKUP_DIR/${container}_$(basename $VOL_SRC).tar.gz"
				if [[ -f "$VOL_FILE" ]]; then
					echo "恢復卷宗資料:$VOL_SRC"
					tar -xzf "$VOL_FILE" -C /
				fi
			done

			# 刪除已存在但未運行的容器
			if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
				echo -e "${gl_huang}容器 [$container] 存在但未運行，刪除舊容器...${gl_bai}"
				docker rm -f "$container"
			fi

			# 啟動容器
			echo "執行還原指令: docker run -d --name \"$container\" $PORT_ARGS $VOL_ARGS $ENV_ARGS \"$IMAGE\""
			eval "docker run -d --name \"$container\" $PORT_ARGS $VOL_ARGS $ENV_ARGS \"$IMAGE\""
		done

		[[ "$has_container" == false ]] && echo -e "${gl_huang}未找到普通容器的備份訊息${gl_bai}"

		# 還原 /home/docker 下的文件
		if [ -f "$BACKUP_DIR/home_docker_files.tar.gz" ]; then
			echo -e "${gl_kjlan}正在還原 /home/docker 下的檔案...${gl_bai}"
			mkdir -p /home/docker
			tar -xzf "$BACKUP_DIR/home_docker_files.tar.gz" -C /
			echo -e "${gl_lv}/home/docker 下的檔案已還原完成${gl_bai}"
		else
			echo -e "${gl_huang}未找到 /home/docker 下檔案的備份，跳過...${gl_bai}"
		fi


	}


	# ----------------------------
	# 遷移
	# ----------------------------
	migrate_docker() {
		send_stats "Docker遷移"
		install jq
		read -e -p  "請輸入要遷移的備份目錄:" BACKUP_DIR
		[[ ! -d "$BACKUP_DIR" ]] && { echo -e "${gl_hong}備份目錄不存在${gl_bai}"; return; }

		kj_ssh_read_host_user_port "目標伺服器IP:" "目標伺服器SSH用戶名 [預設root]:" "目標伺服器SSH連接埠 [預設22]:" "root" "22"
		local TARGET_IP="$KJ_SSH_HOST"
		local TARGET_USER="$KJ_SSH_USER"
		local TARGET_PORT="$KJ_SSH_PORT"

		local LATEST_TAR="$BACKUP_DIR"

		echo -e "${gl_huang}傳輸備份中...${gl_bai}"
		if [[ -z "$TARGET_PASS" ]]; then
			# 使用密鑰登入
			scp -P "$TARGET_PORT" -o StrictHostKeyChecking=no -r "$LATEST_TAR" "$TARGET_USER@$TARGET_IP:/tmp/"
		fi

	}

	# ----------------------------
	# 刪除備份
	# ----------------------------
	delete_backup() {
		send_stats "Docker備份檔案刪除"
		read -e -p  "請輸入要刪除的備份目錄:" BACKUP_DIR
		[[ ! -d "$BACKUP_DIR" ]] && { echo -e "${gl_hong}備份目錄不存在${gl_bai}"; return; }
		rm -rf "$BACKUP_DIR"
		echo -e "${gl_lv}已刪除備份:${BACKUP_DIR}${gl_bai}"
	}

	# ----------------------------
	# 主選單
	# ----------------------------
	main_menu() {
		send_stats "Docker備份遷移還原"
		while true; do
			clear
			echo "------------------------"
			echo -e "Docker備份/遷移/還原工具"
			echo "------------------------"
			list_backups
			echo -e ""
			echo "------------------------"
			echo -e "1. 備份docker項目"
			echo -e "2. 遷移docker項目"
			echo -e "3. 還原docker項目"
			echo -e "4. 刪除docker專案的備份文件"
			echo "------------------------"
			echo -e "0. 返回上一級選單"
			echo "------------------------"
			read -e -p  "請選擇:" choice
			case $choice in
				1) backup_docker ;;
				2) migrate_docker ;;
				3) restore_docker ;;
				4) delete_backup ;;
				0) return ;;
				*) echo -e "${gl_hong}無效選項${gl_bai}" ;;
			esac
		break_end
		done
	}

	main_menu
}





linux_docker() {

	while true; do
	  clear
	  # send_stats "docker管理"
	  echo -e "Docker管理"
	  docker_tato
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}1.   ${gl_bai}安裝更新Docker環境${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}2.   ${gl_bai}查看Docker全域狀態${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}3.   ${gl_bai}Docker容器管理${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}4.   ${gl_bai}Docker映像管理"
	  echo -e "${gl_kjlan}5.   ${gl_bai}Docker網路管理"
	  echo -e "${gl_kjlan}6.   ${gl_bai}Docker磁碟區管理"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}7.   ${gl_bai}清理無用的docker容器和映像網路資料卷"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}8.   ${gl_bai}更換Docker源"
	  echo -e "${gl_kjlan}9.   ${gl_bai}編輯daemon.json文件"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}11.  ${gl_bai}開啟Docker-ipv6訪問"
	  echo -e "${gl_kjlan}12.  ${gl_bai}關閉Docker-ipv6訪問"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}19.  ${gl_bai}備份/遷移/還原Docker環境"
	  echo -e "${gl_kjlan}20.  ${gl_bai}解除安裝Docker環境"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}0.   ${gl_bai}返回主選單"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "請輸入你的選擇:" sub_choice

	  case $sub_choice in
		  1)
			clear
			send_stats "安裝docker環境"
			install_add_docker

			  ;;
		  2)
			  clear
			  local container_count=$(docker ps -a -q 2>/dev/null | wc -l)
			  local image_count=$(docker images -q 2>/dev/null | wc -l)
			  local network_count=$(docker network ls -q 2>/dev/null | wc -l)
			  local volume_count=$(docker volume ls -q 2>/dev/null | wc -l)

			  send_stats "docker全域狀態"
			  echo "Docker版本"
			  docker -v
			  docker compose version

			  echo ""
			  echo -e "Docker映像:${gl_lv}$image_count${gl_bai} "
			  docker image ls
			  echo ""
			  echo -e "Docker容器:${gl_lv}$container_count${gl_bai}"
			  docker ps -a
			  echo ""
			  echo -e "Docker磁碟區:${gl_lv}$volume_count${gl_bai}"
			  docker volume ls
			  echo ""
			  echo -e "Docker網路:${gl_lv}$network_count${gl_bai}"
			  docker network ls
			  echo ""

			  ;;
		  3)
			  docker_ps
			  ;;
		  4)
			  docker_image
			  ;;

		  5)
			  while true; do
				  clear
				  send_stats "Docker網路管理"
				  echo "Docker網路列表"
				  echo "------------------------------------------------------------"
				  docker network ls
				  echo ""

				  echo "------------------------------------------------------------"
				  container_ids=$(docker ps -q)
				  printf "%-25s %-25s %-25s\n" "容器名稱" "網路名稱" "IP位址"

				  for container_id in $container_ids; do
					  local container_info=$(docker inspect --format '{{ .Name }}{{ range $network, $config := .NetworkSettings.Networks }} {{ $network }} {{ $config.IPAddress }}{{ end }}' "$container_id")

					  local container_name=$(echo "$container_info" | awk '{print $1}')
					  local network_info=$(echo "$container_info" | cut -d' ' -f2-)

					  while IFS= read -r line; do
						  local network_name=$(echo "$line" | awk '{print $1}')
						  local ip_address=$(echo "$line" | awk '{print $2}')

						  printf "%-20s %-20s %-15s\n" "$container_name" "$network_name" "$ip_address"
					  done <<< "$network_info"
				  done

				  echo ""
				  echo "網路操作"
				  echo "------------------------"
				  echo "1. 建立網絡"
				  echo "2. 加入網絡"
				  echo "3. 退出網絡"
				  echo "4. 刪除網絡"
				  echo "------------------------"
				  echo "0. 返回上一級選單"
				  echo "------------------------"
				  read -e -p "請輸入你的選擇:" sub_choice

				  case $sub_choice in
					  1)
						  send_stats "創建網路"
						  read -e -p "設定新網路名稱:" dockernetwork
						  docker network create $dockernetwork
						  ;;
					  2)
						  send_stats "加入網路"
						  read -e -p "加入網路名稱:" dockernetwork
						  read -e -p "那些容器加入該網路（多個容器名稱請以空格分隔）:" dockernames

						  for dockername in $dockernames; do
							  docker network connect $dockernetwork $dockername
						  done
						  ;;
					  3)
						  send_stats "加入網路"
						  read -e -p "退出網路名稱:" dockernetwork
						  read -e -p "那些容器退出該網路（多個容器名稱請以空格分隔）:" dockernames

						  for dockername in $dockernames; do
							  docker network disconnect $dockernetwork $dockername
						  done

						  ;;

					  4)
						  send_stats "刪除網絡"
						  read -e -p "請輸入要刪除的網路名稱:" dockernetwork
						  docker network rm $dockernetwork
						  ;;

					  *)
						  break  # 跳出循环，退出菜单
						  ;;
				  esac
			  done
			  ;;

		  6)
			  while true; do
				  clear
				  send_stats "Docker磁碟區管理"
				  echo "Docker卷列表"
				  docker volume ls
				  echo ""
				  echo "卷操作"
				  echo "------------------------"
				  echo "1. 建立新卷"
				  echo "2. 刪除指定卷"
				  echo "3. 刪除所有捲"
				  echo "------------------------"
				  echo "0. 返回上一級選單"
				  echo "------------------------"
				  read -e -p "請輸入你的選擇:" sub_choice

				  case $sub_choice in
					  1)
						  send_stats "新磁碟區"
						  read -e -p "設定新卷名:" dockerjuan
						  docker volume create $dockerjuan

						  ;;
					  2)
						  read -e -p "輸入刪除卷名（多個卷名請以空格分隔）:" dockerjuans

						  for dockerjuan in $dockerjuans; do
							  docker volume rm $dockerjuan
						  done

						  ;;

					   3)
						  send_stats "刪除所有捲"
						  read -e -p "$(echo -e "${gl_hong}注意: ${gl_bai}确定删除所有未使用的卷吗？(Y/N): ")" choice
						  case "$choice" in
							[Yy])
							  docker volume prune -f
							  ;;
							[Nn])
							  ;;
							*)
							  echo "無效的選擇，請輸入 Y 或 N。"
							  ;;
						  esac
						  ;;

					  *)
						  break  # 跳出循环，退出菜单
						  ;;
				  esac
			  done
			  ;;
		  7)
			  clear
			  send_stats "Docker清理"
			  read -e -p "$(echo -e "${gl_huang}提示: ${gl_bai}将清理无用的镜像容器网络，包括停止的容器，确定清理吗？(Y/N): ")" choice
			  case "$choice" in
				[Yy])
				  docker system prune -af --volumes
				  ;;
				[Nn])
				  ;;
				*)
				  echo "無效的選擇，請輸入 Y 或 N。"
				  ;;
			  esac
			  ;;
		  8)
			  clear
			  send_stats "Docker來源"
			  bash <(curl -sSL https://linuxmirrors.cn/docker.sh)
			  ;;

		  9)
			  clear
			  install nano
			  mkdir -p /etc/docker && nano /etc/docker/daemon.json
			  restart docker
			  ;;




		  11)
			  clear
			  send_stats "Docker v6 開"
			  docker_ipv6_on
			  ;;

		  12)
			  clear
			  send_stats "Docker v6 關"
			  docker_ipv6_off
			  ;;

		  19)
			  docker_ssh_migration
			  ;;


		  20)
			  clear
			  send_stats "Docker解除安裝"
			  read -e -p "$(echo -e "${gl_hong}注意: ${gl_bai}确定卸载docker环境吗？(Y/N): ")" choice
			  case "$choice" in
				[Yy])
				  docker ps -a -q | xargs -r docker rm -f && docker images -q | xargs -r docker rmi && docker network prune -f && docker volume prune -f
				  remove docker docker-compose docker-ce docker-ce-cli containerd.io
				  rm -f /etc/docker/daemon.json
				  hash -r
				  ;;
				[Nn])
				  ;;
				*)
				  echo "無效的選擇，請輸入 Y 或 N。"
				  ;;
			  esac
			  ;;

		  0)
			  kejilion
			  ;;
		  *)
			  echo "無效的輸入!"
			  ;;
	  esac
	  break_end


	done


}



linux_test() {

	while true; do
	  clear
	  # send_stats "測試腳本集合"
	  echo -e "測試腳本合集"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}IP及解鎖狀態偵測"
	  echo -e "${gl_kjlan}1.   ${gl_bai}ChatGPT 解鎖狀態偵測"
	  echo -e "${gl_kjlan}2.   ${gl_bai}Region 串流解鎖測試"
	  echo -e "${gl_kjlan}3.   ${gl_bai}yeahwu 串流媒體解鎖偵測"
	  echo -e "${gl_kjlan}4.   ${gl_bai}xykt IP品質體檢腳本${gl_huang}★${gl_bai}"

	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}網路線路測速"
	  echo -e "${gl_kjlan}11.  ${gl_bai}besttrace 三網回程延遲路由測試"
	  echo -e "${gl_kjlan}12.  ${gl_bai}mtr_trace 三網回程線路測試"
	  echo -e "${gl_kjlan}13.  ${gl_bai}Superspeed 三網測速"
	  echo -e "${gl_kjlan}14.  ${gl_bai}nxtrace 快速回程測試腳本"
	  echo -e "${gl_kjlan}15.  ${gl_bai}nxtrace 指定IP回程測試腳本"
	  echo -e "${gl_kjlan}16.  ${gl_bai}ludashi2020 三線線路測試"
	  echo -e "${gl_kjlan}17.  ${gl_bai}i-abc 多功能測速腳本"
	  echo -e "${gl_kjlan}18.  ${gl_bai}NetQuality 網路品質體檢腳本${gl_huang}★${gl_bai}"

	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}硬體效能測試"
	  echo -e "${gl_kjlan}21.  ${gl_bai}yabs 效能測試"
	  echo -e "${gl_kjlan}22.  ${gl_bai}icu/gb5 CPU效能測試腳本"

	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}綜合性測試"
	  echo -e "${gl_kjlan}31.  ${gl_bai}bench 效能測試"
	  echo -e "${gl_kjlan}32.  ${gl_bai}spiritysdx 融合怪測評${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}33.  ${gl_bai}nodequality 融合怪測評${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}0.   ${gl_bai}返回主選單"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "請輸入你的選擇:" sub_choice

	  case $sub_choice in
		  1)
			  clear
			  send_stats "ChatGPT解鎖狀態偵測"
			  bash <(curl -Ls https://cdn.jsdelivr.net/gh/missuo/OpenAI-Checker/openai.sh)
			  ;;
		  2)
			  clear
			  send_stats "Region串流解鎖測試"
			  bash <(curl -L -s check.unlock.media)
			  ;;
		  3)
			  clear
			  send_stats "yeahwu串流解鎖偵測"
			  install wget
			  wget -qO- ${gh_proxy}github.com/yeahwu/check/raw/main/check.sh | bash
			  ;;
		  4)
			  clear
			  send_stats "xykt_IP品質體檢腳本"
			  bash <(curl -Ls IP.Check.Place)
			  ;;


		  11)
			  clear
			  send_stats "besttrace三網回程延遲路由測試"
			  install wget
			  wget -qO- git.io/besttrace | bash
			  ;;
		  12)
			  clear
			  send_stats "mtr_trace三網回程線路測試"
			  curl ${gh_proxy}raw.githubusercontent.com/zhucaidan/mtr_trace/main/mtr_trace.sh | bash
			  ;;
		  13)
			  clear
			  send_stats "Superspeed三網測速"
			  bash <(curl -Lso- https://git.io/superspeed_uxh)
			  ;;
		  14)
			  clear
			  send_stats "nxtrace快速回程測試腳本"
			  curl nxtrace.org/nt |bash
			  nexttrace --fast-trace --tcp
			  ;;
		  15)
			  clear
			  send_stats "nxtrace指定IP回程測試腳本"
			  echo "可參考的IP列表"
			  echo "------------------------"
			  echo "北京電信: 219.141.136.12"
			  echo "北京聯通: 202.106.50.1"
			  echo "北京移動: 221.179.155.161"
			  echo "上海電信: 202.96.209.133"
			  echo "上海聯通: 210.22.97.1"
			  echo "上海移動: 211.136.112.200"
			  echo "廣州電信: 58.60.188.222"
			  echo "廣州聯通: 210.21.196.6"
			  echo "廣州移動: 120.196.165.24"
			  echo "成都電信: 61.139.2.69"
			  echo "成都聯通: 119.6.6.6"
			  echo "成都移動: 211.137.96.205"
			  echo "湖南電信: 36.111.200.100"
			  echo "湖南聯通: 42.48.16.100"
			  echo "湖南移動: 39.134.254.6"
			  echo "------------------------"

			  read -e -p "輸入一個指定IP:" testip
			  curl nxtrace.org/nt |bash
			  nexttrace $testip
			  ;;

		  16)
			  clear
			  send_stats "ludashi2020三線線路測試"
			  curl ${gh_proxy}raw.githubusercontent.com/ludashi2020/backtrace/main/install.sh -sSf | sh
			  ;;

		  17)
			  clear
			  send_stats "i-abc多功能測速腳本"
			  bash <(curl -sL ${gh_proxy}raw.githubusercontent.com/i-abc/Speedtest/main/speedtest.sh)
			  ;;

		  18)
			  clear
			  send_stats "網路品質測試腳本"
			  bash <(curl -sL Net.Check.Place)
			  ;;

		  21)
			  clear
			  send_stats "yabs效能測試"
			  check_swap
			  curl -sL yabs.sh | bash -s -- -i -5
			  ;;
		  22)
			  clear
			  send_stats "icu/gb5 CPU效能測試腳本"
			  check_swap
			  bash <(curl -sL bash.icu/gb5)
			  ;;

		  31)
			  clear
			  send_stats "bench效能測試"
			  curl -Lso- bench.sh | bash
			  ;;
		  32)
			  send_stats "spiritysdx融合怪測評"
			  clear
			  curl -L ${gh_proxy}github.com/spiritLHLS/ecs/raw/main/ecs.sh -o ecs.sh && chmod +x ecs.sh && bash ecs.sh
			  ;;

		  33)
			  send_stats "nodequality融合怪測評"
			  clear
			  bash <(curl -sL https://run.NodeQuality.com)
			  ;;



		  0)
			  kejilion

			  ;;
		  *)
			  echo "無效的輸入!"
			  ;;
	  esac
	  break_end

	done


}


linux_Oracle() {


	 while true; do
	  clear
	  send_stats "甲骨文雲腳本合集"
	  echo -e "甲骨文雲腳本合集"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}1.   ${gl_bai}安裝閒置機器活躍腳本"
	  echo -e "${gl_kjlan}2.   ${gl_bai}卸載閒置機器活躍腳本"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}3.   ${gl_bai}DD重裝系統腳本"
	  echo -e "${gl_kjlan}4.   ${gl_bai}R探長開機腳本"
	  echo -e "${gl_kjlan}5.   ${gl_bai}開啟ROOT密碼登入模式"
	  echo -e "${gl_kjlan}6.   ${gl_bai}IPV6恢復工具"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}0.   ${gl_bai}返回主選單"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "請輸入你的選擇:" sub_choice

	  case $sub_choice in
		  1)
			  clear
			  echo "活躍腳本: CPU佔用10-20% 記憶體佔用20%"
			  read -e -p "確定安裝嗎？ (Y/N):" choice
			  case "$choice" in
				[Yy])

				  install_docker

				  # 設定預設值
				  local DEFAULT_CPU_CORE=1
				  local DEFAULT_CPU_UTIL="10-20"
				  local DEFAULT_MEM_UTIL=20
				  local DEFAULT_SPEEDTEST_INTERVAL=120

				  # 提示使用者輸入CPU核心數和占用百分比，如果回車則使用預設值
				  read -e -p "請輸入CPU核心數 [預設:$DEFAULT_CPU_CORE]: " cpu_core
				  local cpu_core=${cpu_core:-$DEFAULT_CPU_CORE}

				  read -e -p "請輸入CPU佔用百分比範圍（例如10-20） [預設:$DEFAULT_CPU_UTIL]: " cpu_util
				  local cpu_util=${cpu_util:-$DEFAULT_CPU_UTIL}

				  read -e -p "請輸入記憶體佔用百分比 [預設:$DEFAULT_MEM_UTIL]: " mem_util
				  local mem_util=${mem_util:-$DEFAULT_MEM_UTIL}

				  read -e -p "請輸入Speedtest間隔時間（秒） [預設:$DEFAULT_SPEEDTEST_INTERVAL]: " speedtest_interval
				  local speedtest_interval=${speedtest_interval:-$DEFAULT_SPEEDTEST_INTERVAL}

				  # 運行Docker容器
				  docker run -d --name=lookbusy --restart=always \
					  -e TZ=Asia/Shanghai \
					  -e CPU_UTIL="$cpu_util" \
					  -e CPU_CORE="$cpu_core" \
					  -e MEM_UTIL="$mem_util" \
					  -e SPEEDTEST_INTERVAL="$speedtest_interval" \
					  fogforest/lookbusy
				  send_stats "甲骨文雲安裝活躍腳本"

				  ;;
				[Nn])

				  ;;
				*)
				  echo "無效的選擇，請輸入 Y 或 N。"
				  ;;
			  esac
			  ;;
		  2)
			  clear
			  docker rm -f lookbusy
			  docker rmi fogforest/lookbusy
			  send_stats "甲骨文雲端卸載活躍腳本"
			  ;;

		  3)
		  clear
		  echo "重裝系統"
		  echo "--------------------------------"
		  echo -e "${gl_hong}注意:${gl_bai}重裝有風險失聯，不放心者慎用。重裝預計花費15分鐘，請提前備份資料。"
		  read -e -p "確定繼續嗎？ (Y/N):" choice

		  case "$choice" in
			[Yy])
			  while true; do
				read -e -p "請選擇要重裝的系統: 1. Debian12 | 2. Ubuntu20.04 :" sys_choice

				case "$sys_choice" in
				  1)
					local xitong="-d 12"
					break  # 结束循环
					;;
				  2)
					local xitong="-u 20.04"
					break  # 结束循环
					;;
				  *)
					echo "無效的選擇，請重新輸入。"
					;;
				esac
			  done

			  read -e -p "請輸入你重裝後的密碼:" vpspasswd
			  install wget
			  bash <(wget --no-check-certificate -qO- "${gh_proxy}raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh") $xitong -v 64 -p $vpspasswd -port 22
			  send_stats "甲骨文雲端重裝系統腳本"
			  ;;
			[Nn])
			  echo "已取消"
			  ;;
			*)
			  echo "無效的選擇，請輸入 Y 或 N。"
			  ;;
		  esac
			  ;;

		  4)
			  clear
			  send_stats "R探長開機腳本"
			  bash <(wget -qO- ${gh_proxy}github.com/Yohann0617/oci-helper/releases/latest/download/sh_oci-helper_install.sh)
			  ;;
		  5)
			  clear
			  add_sshpasswd
			  ;;
		  6)
			  clear
			  bash <(curl -L -s jhb.ovh/jb/v6.sh)
			  echo "此功能由jhb大神提供，感謝他！"
			  send_stats "ipv6修復"
			  ;;
		  0)
			  kejilion

			  ;;
		  *)
			  echo "無效的輸入!"
			  ;;
	  esac
	  break_end

	done



}





docker_tato() {

	local container_count=$(docker ps -a -q 2>/dev/null | wc -l)
	local image_count=$(docker images -q 2>/dev/null | wc -l)
	local network_count=$(docker network ls -q 2>/dev/null | wc -l)
	local volume_count=$(docker volume ls -q 2>/dev/null | wc -l)

	if command -v docker &> /dev/null; then
		echo -e "${gl_kjlan}------------------------"
		echo -e "${gl_lv}環境已經安裝${gl_bai}容器:${gl_lv}$container_count${gl_bai}鏡像:${gl_lv}$image_count${gl_bai}網路:${gl_lv}$network_count${gl_bai}卷:${gl_lv}$volume_count${gl_bai}"
	fi
}



ldnmp_tato() {
local cert_count=$(ls /home/web/certs/*_cert.pem 2>/dev/null | wc -l)
local output="${gl_lv}${cert_count}${gl_bai}"

local dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml 2>/dev/null | tr -d '[:space:]')
if [ -n "$dbrootpasswd" ]; then
	local db_count=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -e "SHOW DATABASES;" 2>/dev/null | grep -Ev "Database|information_schema|mysql|performance_schema|sys" | wc -l)
fi

local db_output="${gl_lv}${db_count}${gl_bai}"


if command -v docker &>/dev/null; then
	if docker ps --filter "name=nginx" --filter "status=running" | grep -q nginx; then
		echo -e "${gl_huang}------------------------"
		echo -e "${gl_lv}環境已安裝${gl_bai}站點:$output資料庫:$db_output"
	fi
fi

}


fix_phpfpm_conf() {
	local container_name=$1
	docker exec "$container_name" sh -c "mkdir -p /run/$container_name && chmod 777 /run/$container_name"
	docker exec "$container_name" sh -c "sed -i '1i [global]\\ndaemonize = no' /usr/local/etc/php-fpm.d/www.conf"
	docker exec "$container_name" sh -c "sed -i '/^listen =/d' /usr/local/etc/php-fpm.d/www.conf"
	docker exec "$container_name" sh -c "echo -e '\nlisten = /run/$container_name/php-fpm.sock\nlisten.owner = www-data\nlisten.group = www-data\nlisten.mode = 0777' >> /usr/local/etc/php-fpm.d/www.conf"
	docker exec "$container_name" sh -c "rm -f /usr/local/etc/php-fpm.d/zz-docker.conf"

	find /home/web/conf.d/ -type f -name "*.conf" -exec sed -i "s#fastcgi_pass ${container_name}:9000;#fastcgi_pass unix:/run/${container_name}/php-fpm.sock;#g" {} \;

}






linux_ldnmp() {
  while true; do

	clear
	# send_stats "LDNMP建置站"
	echo -e "${gl_huang}LDNMP建站"
	ldnmp_tato
	echo -e "${gl_huang}------------------------"
	echo -e "${gl_huang}1.   ${gl_bai}安裝LDNMP環境${gl_huang}★${gl_bai}                   ${gl_huang}2.   ${gl_bai}安裝WordPress${gl_huang}★${gl_bai}"
	echo -e "${gl_huang}3.   ${gl_bai}安裝Discuz論壇${gl_huang}4.   ${gl_bai}安裝可道雲桌面"
	echo -e "${gl_huang}5.   ${gl_bai}安裝蘋果CMS影視站${gl_huang}6.   ${gl_bai}安裝獨角數發卡網"
	echo -e "${gl_huang}7.   ${gl_bai}安裝flarum論壇網站${gl_huang}8.   ${gl_bai}安裝typecho輕量部落格網站"
	echo -e "${gl_huang}9.   ${gl_bai}安裝LinkStack分享連結平台${gl_huang}20.  ${gl_bai}自訂動態站點"
	echo -e "${gl_huang}------------------------"
	echo -e "${gl_huang}21.  ${gl_bai}僅安裝nginx${gl_huang}★${gl_bai}                     ${gl_huang}22.  ${gl_bai}網站重定向"
	echo -e "${gl_huang}23.  ${gl_bai}站點反向代理-IP+端口${gl_huang}★${gl_bai}            ${gl_huang}24.  ${gl_bai}站點反向代理-域名"
	echo -e "${gl_huang}25.  ${gl_bai}安裝Bitwarden密碼管理平台${gl_huang}26.  ${gl_bai}安裝Halo部落格網站"
	echo -e "${gl_huang}27.  ${gl_bai}安裝AI繪畫提示詞產生器${gl_huang}28.  ${gl_bai}站點反向代理-負載平衡"
	echo -e "${gl_huang}29.  ${gl_bai}Stream四層代理轉發${gl_huang}30.  ${gl_bai}自訂靜態站點"
	echo -e "${gl_huang}------------------------"
	echo -e "${gl_huang}31.  ${gl_bai}站點資料管理${gl_huang}★${gl_bai}                    ${gl_huang}32.  ${gl_bai}備份全站數據"
	echo -e "${gl_huang}33.  ${gl_bai}定時遠端備份${gl_huang}34.  ${gl_bai}還原全站數據"
	echo -e "${gl_huang}------------------------"
	echo -e "${gl_huang}35.  ${gl_bai}防護LDNMP環境${gl_huang}36.  ${gl_bai}優化LDNMP環境"
	echo -e "${gl_huang}37.  ${gl_bai}更新LDNMP環境${gl_huang}38.  ${gl_bai}解除安裝LDNMP環境"
	echo -e "${gl_huang}------------------------"
	echo -e "${gl_huang}0.   ${gl_bai}返回主選單"
	echo -e "${gl_huang}------------------------${gl_bai}"
	read -e -p "請輸入你的選擇:" sub_choice


	case $sub_choice in
	  1)
	  ldnmp_install_status_one
	  ldnmp_install_all
		;;
	  2)
	  ldnmp_wp
		;;

	  3)
	  clear
	  # Discuz論壇
	  webname="Discuz論壇"
	  send_stats "安裝$webname"
	  echo "開始部署$webname"
	  add_yuming
	  repeat_add_yuming
	  ldnmp_install_status


	  install_ssltls
	  certs_status
	  add_db


	  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/discuz.com.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming
	  wget -O latest.zip ${gh_proxy}github.com/kejilion/Website_source_code/raw/main/Discuz_X3.5_SC_UTF8_20250901.zip
	  unzip latest.zip
	  rm latest.zip

	  restart_ldnmp


	  ldnmp_web_on
	  echo "資料庫位址: mysql"
	  echo "資料庫名稱:$dbname"
	  echo "使用者名稱:$dbuse"
	  echo "密碼:$dbusepasswd"
	  echo "表前綴: discuz_"


		;;

	  4)
	  clear
	  # 可道雲桌面
	  webname="可道雲桌面"
	  send_stats "安裝$webname"
	  echo "開始部署$webname"
	  add_yuming
	  repeat_add_yuming
	  ldnmp_install_status

	  install_ssltls
	  certs_status
	  add_db

	  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/kdy.com.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming
	  wget -O latest.zip ${gh_proxy}github.com/kalcaddle/kodbox/archive/refs/tags/1.50.02.zip
	  unzip -o latest.zip
	  rm latest.zip
	  mv /home/web/html/$yuming/kodbox* /home/web/html/$yuming/kodbox
	  restart_ldnmp

	  ldnmp_web_on
	  echo "資料庫位址: mysql"
	  echo "使用者名稱:$dbuse"
	  echo "密碼:$dbusepasswd"
	  echo "資料庫名稱:$dbname"
	  echo "redis主機: redis"

		;;

	  5)
	  clear
	  # 蘋果CMS
	  webname="蘋果CMS"
	  send_stats "安裝$webname"
	  echo "開始部署$webname"
	  add_yuming
	  repeat_add_yuming
	  ldnmp_install_status



	  install_ssltls
	  certs_status
	  add_db

	  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/maccms.com.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming
	  # wget ${gh_proxy}github.com/magicblack/maccms_down/raw/master/maccms10.zip && unzip maccms10.zip && rm maccms10.zip
	  wget ${gh_proxy}github.com/magicblack/maccms_down/raw/master/maccms10.zip && unzip maccms10.zip && mv maccms10-*/* . && rm -r maccms10-* && rm maccms10.zip
	  cd /home/web/html/$yuming/template/ && wget ${gh_proxy}github.com/kejilion/Website_source_code/raw/main/DYXS2.zip && unzip DYXS2.zip && rm /home/web/html/$yuming/template/DYXS2.zip
	  cp /home/web/html/$yuming/template/DYXS2/asset/admin/Dyxs2.php /home/web/html/$yuming/application/admin/controller
	  cp /home/web/html/$yuming/template/DYXS2/asset/admin/dycms.html /home/web/html/$yuming/application/admin/view/system
	  mv /home/web/html/$yuming/admin.php /home/web/html/$yuming/vip.php && wget -O /home/web/html/$yuming/application/extra/maccms.php ${gh_proxy}raw.githubusercontent.com/kejilion/Website_source_code/main/maccms.php

	  restart_ldnmp


	  ldnmp_web_on
	  echo "資料庫位址: mysql"
	  echo "資料庫連接埠: 3306"
	  echo "資料庫名稱:$dbname"
	  echo "使用者名稱:$dbuse"
	  echo "密碼:$dbusepasswd"
	  echo "資料庫前綴: mac_"
	  echo "------------------------"
	  echo "安裝成功後登入後台位址"
	  echo "https://$yuming/vip.php"

		;;

	  6)
	  clear
	  # 獨腳數卡
	  webname="獨腳數卡"
	  send_stats "安裝$webname"
	  echo "開始部署$webname"
	  add_yuming
	  repeat_add_yuming
	  ldnmp_install_status



	  install_ssltls
	  certs_status
	  add_db


	  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/dujiaoka.com.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming
	  wget ${gh_proxy}github.com/assimon/dujiaoka/releases/download/2.0.6/2.0.6-antibody.tar.gz && tar -zxvf 2.0.6-antibody.tar.gz && rm 2.0.6-antibody.tar.gz

	  restart_ldnmp


	  ldnmp_web_on
	  echo "資料庫位址: mysql"
	  echo "資料庫連接埠: 3306"
	  echo "資料庫名稱:$dbname"
	  echo "使用者名稱:$dbuse"
	  echo "密碼:$dbusepasswd"
	  echo ""
	  echo "redis地址: redis"
	  echo "redis密碼: 預設不填寫"
	  echo "redis 埠: 6379"
	  echo ""
	  echo "網址url: https://$yuming"
	  echo "後台登入路徑: /admin"
	  echo "------------------------"
	  echo "使用者名稱: admin"
	  echo "密碼: admin"
	  echo "------------------------"
	  echo "登入時右上角如果出現紅色error0請使用下列指令:"
	  echo "我也很氣憤獨角數卡為啥這麼麻煩，會有這樣的問題！"
	  echo "sed -i 's/ADMIN_HTTPS=false/ADMIN_HTTPS=true/g' /home/web/html/$yuming/dujiaoka/.env"

		;;

	  7)
	  clear
	  # flarum論壇
	  webname="flarum論壇"
	  send_stats "安裝$webname"
	  echo "開始部署$webname"
	  add_yuming
	  repeat_add_yuming
	  ldnmp_install_status



	  install_ssltls
	  certs_status
	  add_db

	  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/flarum.com.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf


	  nginx_http_on

	  docker exec php rm -f /usr/local/etc/php/conf.d/optimized_php.ini

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming

	  docker exec php sh -c "php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\""
	  docker exec php sh -c "php composer-setup.php"
	  docker exec php sh -c "php -r \"unlink('composer-setup.php');\""
	  docker exec php sh -c "mv composer.phar /usr/local/bin/composer"

	  docker exec php composer create-project flarum/flarum /var/www/html/$yuming
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require flarum-lang/chinese-simplified"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require flarum/extension-manager:*"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require fof/polls"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require fof/sitemap"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require fof/oauth"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require fof/best-answer:*"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require fof/upload"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require fof/gamification"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require fof/byobu:*"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require v17development/flarum-seo"
	  docker exec php sh -c "cd /var/www/html/$yuming && composer require clarkwinkelmann/flarum-ext-emojionearea"


	  restart_ldnmp


	  ldnmp_web_on
	  echo "資料庫位址: mysql"
	  echo "資料庫名稱:$dbname"
	  echo "使用者名稱:$dbuse"
	  echo "密碼:$dbusepasswd"
	  echo "表字首: flarum_"
	  echo "管理員資訊自行設定"

		;;

	  8)
	  clear
	  # typecho
	  webname="typecho"
	  send_stats "安裝$webname"
	  echo "開始部署$webname"
	  add_yuming
	  repeat_add_yuming
	  ldnmp_install_status




	  install_ssltls
	  certs_status
	  add_db

	  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/typecho.com.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming
	  wget -O latest.zip ${gh_proxy}github.com/typecho/typecho/releases/latest/download/typecho.zip
	  unzip latest.zip
	  rm latest.zip

	  restart_ldnmp


	  clear
	  ldnmp_web_on
	  echo "資料庫前綴: typecho_"
	  echo "資料庫位址: mysql"
	  echo "使用者名稱:$dbuse"
	  echo "密碼:$dbusepasswd"
	  echo "資料庫名稱:$dbname"

		;;


	  9)
	  clear
	  # LinkStack
	  webname="LinkStack"
	  send_stats "安裝$webname"
	  echo "開始部署$webname"
	  add_yuming
	  repeat_add_yuming
	  ldnmp_install_status


	  install_ssltls
	  certs_status
	  add_db

	  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/refs/heads/main/index_php.conf
	  sed -i "s|/var/www/html/yuming.com/|/var/www/html/yuming.com/linkstack|g" /home/web/conf.d/$yuming.conf
	  sed -i "s|yuming.com|$yuming|g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming
	  wget -O latest.zip ${gh_proxy}github.com/linkstackorg/linkstack/releases/latest/download/linkstack.zip
	  unzip latest.zip
	  rm latest.zip

	  restart_ldnmp


	  clear
	  ldnmp_web_on
	  echo "資料庫位址: mysql"
	  echo "資料庫連接埠: 3306"
	  echo "資料庫名稱:$dbname"
	  echo "使用者名稱:$dbuse"
	  echo "密碼:$dbusepasswd"
		;;

	  20)
	  clear
	  webname="PHP動態站點"
	  send_stats "安裝$webname"
	  echo "開始部署$webname"
	  add_yuming
	  repeat_add_yuming
	  ldnmp_install_status

	  install_ssltls
	  certs_status
	  add_db

	  wget -O /home/web/conf.d/map.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/map.conf
	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/index_php.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming

	  clear
	  echo -e "[${gl_huang}1/6${gl_bai}] 上傳PHP原始碼"
	  echo "-------------"
	  echo "目前只允許上傳zip格式的源碼包，請將源碼包放到/home/web/html/${yuming}目錄下"
	  read -e -p "也可以輸入下載鏈接，遠端下載源碼包，直接回車將跳過遠端下載：" url_download

	  if [ -n "$url_download" ]; then
		  wget "$url_download"
	  fi

	  unzip $(ls -t *.zip | head -n 1)
	  rm -f $(ls -t *.zip | head -n 1)

	  clear
	  echo -e "[${gl_huang}2/6${gl_bai}] index.php所在路徑"
	  echo "-------------"
	  # find "$(realpath .)" -name "index.php" -print
	  find "$(realpath .)" -name "index.php" -print | xargs -I {} dirname {}

	  read -e -p "請輸入index.php的路徑，類似（/home/web/html/$yuming/wordpress/）： " index_lujing

	  sed -i "s#root /var/www/html/$yuming/#root $index_lujing#g" /home/web/conf.d/$yuming.conf
	  sed -i "s#/home/web/#/var/www/#g" /home/web/conf.d/$yuming.conf

	  clear
	  echo -e "[${gl_huang}3/6${gl_bai}] 請選擇PHP版本"
	  echo "-------------"
	  read -e -p "1. php最新版 | 2. php7.4 :" pho_v
	  case "$pho_v" in
		1)
		  sed -i "s#php:9000#php:9000#g" /home/web/conf.d/$yuming.conf
		  local PHP_Version="php"
		  ;;
		2)
		  sed -i "s#php:9000#php74:9000#g" /home/web/conf.d/$yuming.conf
		  local PHP_Version="php74"
		  ;;
		*)
		  echo "無效的選擇，請重新輸入。"
		  ;;
	  esac


	  clear
	  echo -e "[${gl_huang}4/6${gl_bai}] 安裝指定擴充"
	  echo "-------------"
	  echo "已經安裝的擴充"
	  docker exec php php -m

	  read -e -p "$(echo -e "输入需要安装的扩展名称，如 ${gl_huang}SourceGuardian imap ftp${gl_bai} 等等。直接回车将跳过安装 ： ")" php_extensions
	  if [ -n "$php_extensions" ]; then
		  docker exec $PHP_Version install-php-extensions $php_extensions
	  fi


	  clear
	  echo -e "[${gl_huang}5/6${gl_bai}] 編輯網站配置"
	  echo "-------------"
	  echo "按任一鍵繼續，可詳細設定網站配置，如偽靜態等內容"
	  read -n 1 -s -r -p ""
	  install nano
	  nano /home/web/conf.d/$yuming.conf


	  clear
	  echo -e "[${gl_huang}6/6${gl_bai}] 資料庫管理"
	  echo "-------------"
	  read -e -p "1. 我搭建新站 2. 我搭建老站有資料庫備份：" use_db
	  case $use_db in
		  1)
			  echo
			  ;;
		  2)
			  echo "資料庫備份必須是.gz結尾的壓縮包。請放到/home/目錄下，支援寶塔/1panel備份資料導入。"
			  read -e -p "也可以輸入下載鏈接，遠端下載備份數據，直接回車將跳過遠端下載：" url_download_db

			  cd /home/
			  if [ -n "$url_download_db" ]; then
				  wget "$url_download_db"
			  fi
			  gunzip $(ls -t *.gz | head -n 1)
			  latest_sql=$(ls -t *.sql | head -n 1)
			  dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
			  docker exec -i mysql mysql -u root -p"$dbrootpasswd" $dbname < "/home/$latest_sql"
			  echo "資料庫匯入的表數據"
			  docker exec -i mysql mysql -u root -p"$dbrootpasswd" -e "USE $dbname; SHOW TABLES;"
			  rm -f *.sql
			  echo "資料庫導入完成"
			  ;;
		  *)
			  echo
			  ;;
	  esac

	  docker exec php rm -f /usr/local/etc/php/conf.d/optimized_php.ini

	  restart_ldnmp
	  ldnmp_web_on
	  prefix="web$(shuf -i 10-99 -n 1)_"
	  echo "資料庫位址: mysql"
	  echo "資料庫名稱:$dbname"
	  echo "使用者名稱:$dbuse"
	  echo "密碼:$dbusepasswd"
	  echo "表前綴:$prefix"
	  echo "管理員登入資訊自行設定"

		;;


	  21)
	  ldnmp_install_status_one
	  nginx_install_all
		;;

	  22)
	  clear
	  webname="網站重定向"
	  send_stats "安裝$webname"
	  echo "開始部署$webname"
	  add_yuming
	  read -e -p "請輸入跳轉域名:" reverseproxy
	  nginx_install_status



	  install_ssltls
	  certs_status


	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/rewrite.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
	  sed -i "s/baidu.com/$reverseproxy/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  docker exec nginx nginx -s reload

	  nginx_web_on


		;;

	  23)
	  ldnmp_Proxy
	  find_container_by_host_port "$port"
	  if [ -z "$docker_name" ]; then
		close_port "$port"
		echo "已阻止IP+連接埠存取該服務"
	  else
	  	ip_address
		close_port "$port"
		block_container_port "$docker_name" "$ipv4_address"
	  fi

		;;

	  24)
	  clear
	  webname="反向代理-域名"
	  send_stats "安裝$webname"
	  echo "開始部署$webname"
	  add_yuming
	  echo -e "域名格式:${gl_huang}google.com${gl_bai}"
	  read -e -p "請輸入你的反代網域:" fandai_yuming
	  nginx_install_status

	  install_ssltls
	  certs_status


	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/reverse-proxy-domain.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
	  sed -i "s|fandaicom|$fandai_yuming|g" /home/web/conf.d/$yuming.conf


	  nginx_http_on

	  docker exec nginx nginx -s reload

	  nginx_web_on

		;;


	  25)
	  clear
	  webname="Bitwarden"
	  send_stats "安裝$webname"
	  echo "開始部署$webname"
	  add_yuming

	  docker run -d \
		--name bitwarden \
		--restart=always \
		-p 3280:80 \
		-v /home/web/html/$yuming/bitwarden/data:/data \
		vaultwarden/server

	  duankou=3280
	  ldnmp_Proxy ${yuming} 127.0.0.1 $duankou


		;;

	  26)
	  clear
	  webname="halo"
	  send_stats "安裝$webname"
	  echo "開始部署$webname"
	  add_yuming

	  docker run -d --name halo --restart=always -p 8010:8090 -v /home/web/html/$yuming/.halo2:/root/.halo2 halohub/halo:2

	  duankou=8010
	  ldnmp_Proxy ${yuming} 127.0.0.1 $duankou

		;;

	  27)
	  clear
	  webname="AI繪畫提示詞產生器"
	  send_stats "安裝$webname"
	  echo "開始部署$webname"
	  add_yuming
	  nginx_install_status


	  install_ssltls
	  certs_status

	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/html.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming

	  wget ${gh_proxy}github.com/kejilion/Website_source_code/raw/refs/heads/main/ai_prompt_generator.zip
	  unzip $(ls -t *.zip | head -n 1)
	  rm -f $(ls -t *.zip | head -n 1)

	  docker exec nginx chmod -R nginx:nginx /var/www/html
	  docker exec nginx nginx -s reload

	  nginx_web_on

		;;

	  28)
	  ldnmp_Proxy_backend
		;;


	  29)
	  stream_panel
		;;

	  30)
	  clear
	  webname="靜態站點"
	  send_stats "安裝$webname"
	  echo "開始部署$webname"
	  add_yuming
	  repeat_add_yuming
	  nginx_install_status


	  install_ssltls
	  certs_status

	  wget -O /home/web/conf.d/$yuming.conf ${gh_proxy}raw.githubusercontent.com/kejilion/nginx/main/html.conf
	  sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

	  nginx_http_on

	  cd /home/web/html
	  mkdir $yuming
	  cd $yuming


	  clear
	  echo -e "[${gl_huang}1/2${gl_bai}] 上傳靜態原始碼"
	  echo "-------------"
	  echo "目前只允許上傳zip格式的源碼包，請將源碼包放到/home/web/html/${yuming}目錄下"
	  read -e -p "也可以輸入下載鏈接，遠端下載源碼包，直接回車將跳過遠端下載：" url_download

	  if [ -n "$url_download" ]; then
		  wget "$url_download"
	  fi

	  unzip $(ls -t *.zip | head -n 1)
	  rm -f $(ls -t *.zip | head -n 1)

	  clear
	  echo -e "[${gl_huang}2/2${gl_bai}] index.html所在路徑"
	  echo "-------------"
	  # find "$(realpath .)" -name "index.html" -print
	  find "$(realpath .)" -name "index.html" -print | xargs -I {} dirname {}

	  read -e -p "請輸入index.html的路徑，類似（/home/web/html/$yuming/index/）： " index_lujing

	  sed -i "s#root /var/www/html/$yuming/#root $index_lujing#g" /home/web/conf.d/$yuming.conf
	  sed -i "s#/home/web/#/var/www/#g" /home/web/conf.d/$yuming.conf

	  docker exec nginx chmod -R nginx:nginx /var/www/html
	  docker exec nginx nginx -s reload

	  nginx_web_on

		;;







	31)
	  ldnmp_web_status
	  ;;


	32)
	  clear
	  send_stats "LDNMP環境備份"

	  local backup_filename="web_$(date +"%Y%m%d%H%M%S").tar.gz"
	  echo -e "${gl_kjlan}正在備份$backup_filename ...${gl_bai}"
	  cd /home/ && tar czvf "$backup_filename" web

	  while true; do
		clear
		echo "備份檔案已建立: /home/$backup_filename"
		read -e -p "要傳送備份資料到遠端伺服器嗎？ (Y/N):" choice
		case "$choice" in
		  [Yy])
			kj_ssh_read_host_port "請輸入遠端伺服器IP:" "目標伺服器SSH連接埠 [預設22]:" "22"
			local remote_ip="$KJ_SSH_HOST"
			local TARGET_PORT="$KJ_SSH_PORT"
			local latest_tar=$(ls -t /home/*.tar.gz | head -1)
			if [ -n "$latest_tar" ]; then
			  ssh-keygen -f "/root/.ssh/known_hosts" -R "$remote_ip"
			  sleep 2  # 添加等待时间
			  scp -P "$TARGET_PORT" -o StrictHostKeyChecking=no "$latest_tar" "root@$remote_ip:/home/"
			  echo "檔案已傳送至遠端伺服器home目錄。"
			else
			  echo "未找到要傳送的文件。"
			fi
			break
			;;
		  [Nn])
			break
			;;
		  *)
			echo "無效的選擇，請輸入 Y 或 N。"
			;;
		esac
	  done
	  ;;

	33)
	  clear
	  send_stats "定時遠端備份"
	  read -e -p "輸入遠端伺服器IP:" useip
	  read -e -p "輸入遠端伺服器密碼:" usepasswd

	  cd ~
	  wget -O ${useip}_beifen.sh ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/beifen.sh > /dev/null 2>&1
	  chmod +x ${useip}_beifen.sh

	  sed -i "s/0.0.0.0/$useip/g" ${useip}_beifen.sh
	  sed -i "s/123456/$usepasswd/g" ${useip}_beifen.sh

	  echo "------------------------"
	  echo "1. 每週備份 2. 每天備份"
	  read -e -p "請輸入你的選擇:" dingshi

	  case $dingshi in
		  1)
			  check_crontab_installed
			  read -e -p "選擇每週備份的星期幾 (0-6，0代表星期日):" weekday
			  (crontab -l ; echo "0 0 * * $weekday ./${useip}_beifen.sh") | crontab - > /dev/null 2>&1
			  ;;
		  2)
			  check_crontab_installed
			  read -e -p "選擇每天備份的時間（小時，0-23）:" hour
			  (crontab -l ; echo "0 $hour * * * ./${useip}_beifen.sh") | crontab - > /dev/null 2>&1
			  ;;
		  *)
			  break  # 跳出
			  ;;
	  esac

	  install sshpass

	  ;;

	34)
	  root_use
	  send_stats "LDNMP環境還原"
	  echo "可用的站點備份"
	  echo "-------------------------"
	  ls -lt /home/*.gz | awk '{print $NF}'
	  echo ""
	  read -e -p  "回車鍵還原最新的備份，輸入備份檔案名稱還原指定的備份，輸入0退出：" filename

	  if [ "$filename" == "0" ]; then
		  break_end
		  linux_ldnmp
	  fi

	  # 如果使用者沒有輸入檔名，使用最新的壓縮包
	  if [ -z "$filename" ]; then
		  local filename=$(ls -t /home/*.tar.gz | head -1)
	  fi

	  if [ -n "$filename" ]; then
		  cd /home/web/ > /dev/null 2>&1
		  docker compose down > /dev/null 2>&1
		  rm -rf /home/web > /dev/null 2>&1

		  echo -e "${gl_kjlan}正在解壓縮$filename ...${gl_bai}"
		  cd /home/ && tar -xzf "$filename"

		  install_dependency
		  install_docker
		  install_certbot
		  install_ldnmp
	  else
		  echo "沒有找到壓縮包。"
	  fi

	  ;;

	35)
		web_security
		;;

	36)
		web_optimization
		;;


	37)
	  root_use
	  while true; do
		  clear
		  send_stats "更新LDNMP環境"
		  echo "更新LDNMP環境"
		  echo "------------------------"
		  ldnmp_v
		  echo "發現新版本的元件"
		  echo "------------------------"
		  check_docker_image_update nginx
		  if [ -n "$update_status" ]; then
			echo -e "${gl_huang}nginx $update_status${gl_bai}"
		  fi
		  check_docker_image_update php
		  if [ -n "$update_status" ]; then
			echo -e "${gl_huang}php $update_status${gl_bai}"
		  fi
		  check_docker_image_update mysql
		  if [ -n "$update_status" ]; then
			echo -e "${gl_huang}mysql $update_status${gl_bai}"
		  fi
		  check_docker_image_update redis
		  if [ -n "$update_status" ]; then
			echo -e "${gl_huang}redis $update_status${gl_bai}"
		  fi
		  echo "------------------------"
		  echo
		  echo "1. 更新nginx 2. 更新mysql 3. 更新php 4. 更新redis"
		  echo "------------------------"
		  echo "5. 更新完整環境"
		  echo "------------------------"
		  echo "0. 返回上一級選單"
		  echo "------------------------"
		  read -e -p "請輸入你的選擇:" sub_choice
		  case $sub_choice in
			  1)
			  nginx_upgrade

				  ;;

			  2)
			  local ldnmp_pods="mysql"
			  read -e -p "請輸入${ldnmp_pods}版本號碼 （如: 8.0 8.3 8.4 9.0）（回車取得最新版）:" version
			  local version=${version:-latest}

			  cd /home/web/
			  cp /home/web/docker-compose.yml /home/web/docker-compose1.yml
			  sed -i "s/image: mysql/image: mysql:${version}/" /home/web/docker-compose.yml
			  docker rm -f $ldnmp_pods
			  docker images --filter=reference="$ldnmp_pods*" -q | xargs docker rmi > /dev/null 2>&1
			  docker compose up -d --force-recreate $ldnmp_pods
			  docker restart $ldnmp_pods
			  cp /home/web/docker-compose1.yml /home/web/docker-compose.yml
			  send_stats "更新$ldnmp_pods"
			  echo "更新${ldnmp_pods}完成"

				  ;;
			  3)
			  local ldnmp_pods="php"
			  read -e -p "請輸入${ldnmp_pods}版本號 （如: 7.4 8.0 8.1 8.2 8.3）（回車取得最新版）:" version
			  local version=${version:-8.3}
			  cd /home/web/
			  cp /home/web/docker-compose.yml /home/web/docker-compose1.yml
			  sed -i "s/kjlion\///g" /home/web/docker-compose.yml > /dev/null 2>&1
			  sed -i "s/image: php:fpm-alpine/image: php:${version}-fpm-alpine/" /home/web/docker-compose.yml
			  docker rm -f $ldnmp_pods
			  docker images --filter=reference="$ldnmp_pods*" -q | xargs docker rmi > /dev/null 2>&1
  			  docker images --filter=reference="kjlion/${ldnmp_pods}*" -q | xargs docker rmi > /dev/null 2>&1
			  docker compose up -d --force-recreate $ldnmp_pods
			  docker exec php chown -R www-data:www-data /var/www/html

			  run_command docker exec php sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories > /dev/null 2>&1

			  docker exec php apk update
			  curl -sL ${gh_proxy}github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions -o /usr/local/bin/install-php-extensions
			  docker exec php mkdir -p /usr/local/bin/
			  docker cp /usr/local/bin/install-php-extensions php:/usr/local/bin/
			  docker exec php chmod +x /usr/local/bin/install-php-extensions
			  docker exec php install-php-extensions mysqli pdo_mysql gd intl zip exif bcmath opcache redis imagick soap


			  docker exec php sh -c 'echo "upload_max_filesize=50M " > /usr/local/etc/php/conf.d/uploads.ini' > /dev/null 2>&1
			  docker exec php sh -c 'echo "post_max_size=50M " > /usr/local/etc/php/conf.d/post.ini' > /dev/null 2>&1
			  docker exec php sh -c 'echo "memory_limit=512M" > /usr/local/etc/php/conf.d/memory.ini' > /dev/null 2>&1
			  docker exec php sh -c 'echo "max_execution_time=1200" > /usr/local/etc/php/conf.d/max_execution_time.ini' > /dev/null 2>&1
			  docker exec php sh -c 'echo "max_input_time=600" > /usr/local/etc/php/conf.d/max_input_time.ini' > /dev/null 2>&1
			  docker exec php sh -c 'echo "max_input_vars=5000" > /usr/local/etc/php/conf.d/max_input_vars.ini' > /dev/null 2>&1

			  fix_phpfpm_con $ldnmp_pods

			  docker restart $ldnmp_pods > /dev/null 2>&1
			  cp /home/web/docker-compose1.yml /home/web/docker-compose.yml
			  send_stats "更新$ldnmp_pods"
			  echo "更新${ldnmp_pods}完成"

				  ;;
			  4)
			  local ldnmp_pods="redis"
			  cd /home/web/
			  docker rm -f $ldnmp_pods
			  docker images --filter=reference="$ldnmp_pods*" -q | xargs docker rmi > /dev/null 2>&1
			  docker compose up -d --force-recreate $ldnmp_pods
			  docker restart $ldnmp_pods > /dev/null 2>&1
			  send_stats "更新$ldnmp_pods"
			  echo "更新${ldnmp_pods}完成"

				  ;;
			  5)
				read -e -p "$(echo -e "${gl_huang}提示: ${gl_bai}长时间不更新环境的用户，请慎重更新LDNMP环境，会有数据库更新失败的风险。确定更新LDNMP环境吗？(Y/N): ")" choice
				case "$choice" in
				  [Yy])
					send_stats "完整更新LDNMP環境"
					cd /home/web/
					docker compose down --rmi all

					install_dependency
					install_docker
					install_certbot
					install_ldnmp
					;;
				  *)
					;;
				esac
				  ;;
			  *)
				  break
				  ;;
		  esac
		  break_end
	  done


	  ;;

	38)
		root_use
		send_stats "解除安裝LDNMP環境"
		read -e -p "$(echo -e "${gl_hong}强烈建议：${gl_bai}先备份全部网站数据，再卸载LDNMP环境。确定删除所有网站数据吗？(Y/N): ")" choice
		case "$choice" in
		  [Yy])
			cd /home/web/
			docker compose down --rmi all
			docker compose -f docker-compose.phpmyadmin.yml down > /dev/null 2>&1
			docker compose -f docker-compose.phpmyadmin.yml down --rmi all > /dev/null 2>&1
			rm -rf /home/web
			;;
		  [Nn])

			;;
		  *)
			echo "無效的選擇，請輸入 Y 或 N。"
			;;
		esac
		;;

	0)
		kejilion
	  ;;

	*)
		echo "無效的輸入!"
	esac
	break_end

  done

}






moltbot_menu() {
	local app_id="114"

	send_stats "clawdbot/moltbot管理"

	check_openclaw_update() {
		if ! command -v npm >/dev/null 2>&1; then
			return 1
		fi

		# 加上 --no-update-notifier，並確保錯誤重定向位置正確
		local_version=$(npm list -g openclaw --depth=0 --no-update-notifier 2>/dev/null | grep openclaw | awk '{print $NF}' | sed 's/^.*@//')

		if [ -z "$local_version" ]; then
			return 1
		fi

		remote_version=$(npm view openclaw version --no-update-notifier 2>/dev/null)

		if [ -z "$remote_version" ]; then
			return 1
		fi

		if [ "$local_version" != "$remote_version" ]; then
			echo "${gl_huang}偵測到新版本:$remote_version${gl_bai}"
		else
			echo "${gl_lv}目前版本已是最新:$local_version${gl_bai}"
		fi
	}


	get_install_status() {
		if command -v openclaw >/dev/null 2>&1; then
			echo "${gl_lv}已安裝${gl_bai}"
		else
			echo "${gl_hui}未安裝${gl_bai}"
		fi
	}

	get_running_status() {
		if pgrep -f "openclaw-gatewa" >/dev/null 2>&1; then
			echo "${gl_lv}運作中${gl_bai}"
		else
			echo "${gl_hui}未運行${gl_bai}"
		fi
	}


	show_menu() {


		clear

		local install_status=$(get_install_status)
		local running_status=$(get_running_status)
		local update_message=$(check_openclaw_update)

		echo "======================================="
		echo -e "🦞 OPENCLAW 管理工具 by KEJILION 🦞"
		echo -e "💡 終端執行 \033[1;33mk claw\033[0m 快速進入選單"
		echo -e "$install_status $running_status $update_message"
		echo "======================================="
		echo "1. 安裝"
		echo "2. 啟動"
		echo "3. 停止"
		echo "--------------------"
		echo "4. 狀態日誌查看"
		echo "5. 換模型"
		echo "6. API管理"
		echo "7. 機器人連線對接"
		echo "8. 插件管理（安裝/刪除）"
		echo "9. 技能管理（安裝/刪除）"
		echo "10. 編輯主設定文件"
		echo "11. 配置精靈"
		echo "12. 健康檢測與修復"
		echo "13. WebUI存取與設置"
		echo "14. TUI命令列對話窗口"
		echo "15. 記憶/Memory"
		echo "16. 權限管理"
		echo "17. 多智能體管理"
		echo "--------------------"
		echo "18. 備份與還原"
		echo "19. 更新"
		echo "20. 卸載"
		echo "--------------------"
		echo "0. 返回上一級選單"
		echo "--------------------"
		printf "請輸入選項並回車:"
	}


	start_gateway() {
		openclaw gateway stop
		openclaw gateway start
		sleep 3
	}


	install_node_and_tools() {
		if command -v dnf &>/dev/null; then
			curl -fsSL https://rpm.nodesource.com/setup_24.x | sudo bash -
			dnf update -y
			dnf group install -y "Development Tools" "Development Libraries"
			dnf install -y cmake libatomic nodejs
		fi

		if command -v apt &>/dev/null; then
			curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
			apt update -y
			apt install build-essential python3 libatomic1 nodejs -y
		fi
	}

	configure_openclaw_session_policy() {
		local config_file
		config_file=$(openclaw_get_config_file)

		[ ! -f "$config_file" ] && return 1

		python3 - "$config_file" <<'PY'
import json, sys
path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    obj = json.load(f)

session = obj.setdefault('session', {})
session['dmScope'] = session.get('dmScope', 'per-channel-peer')
session['resetTriggers'] = ['/new', '/reset']
session['reset'] = {
    'mode': 'idle',
    'idleMinutes': 10080
}
session['resetByType'] = {
    'direct': {'mode': 'idle', 'idleMinutes': 10080},
    'thread': {'mode': 'idle', 'idleMinutes': 1440},
    'group': {'mode': 'idle', 'idleMinutes': 120}
}

with open(path, 'w', encoding='utf-8') as f:
    json.dump(obj, f, ensure_ascii=False, indent=2)
    f.write('\n')
PY
	}


	sync_openclaw_api_models() {
		local config_file
		config_file=$(openclaw_get_config_file)

		[ ! -f "$config_file" ] && return 0

		install jq curl >/dev/null 2>&1

		python3 - "$config_file" "$ENABLE_STATS" "$sh_v" <<'PY'
import copy
import json
import os
import platform
import sys
import time
import urllib.request
from datetime import datetime, timezone

path = sys.argv[1]
stats_enabled = (sys.argv[2].lower() == "true") if len(sys.argv) > 2 else True
script_version = sys.argv[3] if len(sys.argv) > 3 else ""

def send_stat(action):
    if not stats_enabled:
        return
    payload = {
        "action": action,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S"),
        "country": "",
        "os_info": platform.platform(),
        "cpu_arch": platform.machine(),
        "version": script_version,
    }
    try:
        req = urllib.request.Request(
            "https://api.kejilion.pro/api/log",
            data=json.dumps(payload).encode("utf-8"),
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=3):
            pass
    except Exception:
        pass

with open(path, 'r', encoding='utf-8') as f:
    obj = json.load(f)

work = copy.deepcopy(obj)
models_cfg = work.setdefault('models', {})
providers = models_cfg.get('providers', {})
if not isinstance(providers, dict) or not providers:
    print('ℹ️ 未偵測到 API providers，跳過模型同步')
    raise SystemExit(0)

agents = work.setdefault('agents', {})
defaults = agents.setdefault('defaults', {})
defaults_models_raw = defaults.get('models')
if isinstance(defaults_models_raw, dict):
    defaults_models = defaults_models_raw
elif isinstance(defaults_models_raw, list):
    defaults_models = {str(x): {} for x in defaults_models_raw if isinstance(x, str)}
else:
    defaults_models = {}
defaults['models'] = defaults_models

SUPPORTED_APIS = {'openai-completions', 'openai-responses'}

changed = False
fatal_errors = []
summary = []


def model_ref(provider_name, model_id):
    return f"{provider_name}/{model_id}"


def get_primary_ref(defaults_obj):
    model_obj = defaults_obj.get('model')
    if isinstance(model_obj, str):
        return model_obj
    if isinstance(model_obj, dict):
        primary = model_obj.get('primary')
        if isinstance(primary, str):
            return primary
    return None


def set_primary_ref(defaults_obj, new_ref):
    model_obj = defaults_obj.get('model')
    if isinstance(model_obj, str):
        defaults_obj['model'] = new_ref
    elif isinstance(model_obj, dict):
        model_obj['primary'] = new_ref
    else:
        defaults_obj['model'] = {'primary': new_ref}


def ref_provider(ref):
    if not isinstance(ref, str) or '/' not in ref:
        return None
    return ref.split('/', 1)[0]


def collect_available_refs(exclude_provider=None):
    refs = []
    if not isinstance(providers, dict):
        return refs
    for pname, p in providers.items():
        if exclude_provider and pname == exclude_provider:
            continue
        if not isinstance(p, dict):
            continue
        for m in p.get('models', []) or []:
            if isinstance(m, dict) and m.get('id'):
                refs.append(model_ref(pname, str(m['id'])))
    return refs


def prompt_delete_provider(name):
    prompt = f"⚠️ {name} /models 偵測連續失敗 3 次。是否刪除該 API 供應商及其全部相關模型？ [y/N]:"
    try:
        ans = input(prompt).strip().lower()
    except EOFError:
        return False
    return ans in ('y', 'yes')


def rebind_defaults_before_delete(name):
    global changed

    replacement = None

    def get_replacement():
        nonlocal replacement
        if replacement is None:
            candidates = collect_available_refs(exclude_provider=name)
            replacement = candidates[0] if candidates else None
        return replacement

    primary_ref = get_primary_ref(defaults)
    if ref_provider(primary_ref) == name:
        repl = get_replacement()
        if not repl:
            summary.append(f'❌ {name}: 預設主模型指向該 provider，但無可用替代模型，已中止刪除')
            return False
        set_primary_ref(defaults, repl)
        changed = True
        summary.append(f'🔁 刪除前已切換預設主模型: {primary_ref} -> {repl}')

    for fk in ('modelFallback', 'imageModelFallback'):
        val = defaults.get(fk)
        if ref_provider(val) == name:
            repl = get_replacement()
            if not repl:
                summary.append(f'❌ {name}: {fk} 指向該 provider，但無可用替代模型，已中止刪除')
                return False
            defaults[fk] = repl
            changed = True
            summary.append(f'🔁 刪除前已切換 {fk}: {val} -> {repl}')

    return True


def delete_provider_and_refs(name):
    global changed

    if not rebind_defaults_before_delete(name):
        return False

    removed_refs = [r for r in list(defaults_models.keys()) if r.startswith(name + '/')]
    for r in removed_refs:
        defaults_models.pop(r, None)
    if removed_refs:
        changed = True

    if name in providers:
        providers.pop(name, None)
        changed = True

    summary.append(f'🗑️ 已刪除 provider {name}，並移除 defaults.models 下 {len(removed_refs)} 個模型引用')
    return True


def fetch_remote_models_with_retry(name, base_url, api_key, retries=3):
    last_error = None
    for attempt in range(1, retries + 1):
        req = urllib.request.Request(
            base_url.rstrip('/') + '/models',
            headers={
                'Authorization': f'Bearer {api_key}',
                'User-Agent': 'Mozilla/5.0',
            },
        )
        try:
            with urllib.request.urlopen(req, timeout=12) as resp:
                payload = resp.read().decode('utf-8', 'ignore')
            data = json.loads(payload)
            return data, None, attempt
        except Exception as e:
            last_error = e
            if attempt < retries:
                time.sleep(1)
    return None, last_error, retries


for name, provider in list(providers.items()):
    if not isinstance(provider, dict):
        summary.append(f'ℹ️ 跳過 {name}: provider 結構非法')
        continue

    api = provider.get('api', '')
    base_url = provider.get('baseUrl')
    api_key = provider.get('apiKey')
    model_list = provider.get('models', [])

    if not base_url or not api_key or not isinstance(model_list, list) or not model_list:
        summary.append(f'ℹ️ 跳過 {name}: 無 baseUrl/apiKey/models')
        continue

    if api not in SUPPORTED_APIS:
        summary.append(f'🔁 {name}: 發現非法協定 {api or "(unset)"}，將重新探測')
        provider['api'] = ''
        api = ''
        changed = True

    data, err, attempts = fetch_remote_models_with_retry(name, base_url, api_key, retries=3)
    if err is not None:
        summary.append(f'⚠️ {name}: /models 偵測失敗，已重試 {attempts} 次 ({type(err).__name__}: {err})')
        send_stat('OpenClaw API確認介入')
        if prompt_delete_provider(name):
            deleted = delete_provider_and_refs(name)
            if deleted:
                send_stat('OpenClaw API刪失敗Provider-確認')
                summary.append(f'✅ {name}: 使用者已確認刪除該 provider 及全部相關模型引用')
        else:
            send_stat('OpenClaw API刪失敗Provider-拒絕')
            summary.append(f'ℹ️ {name}: 使用者未確認刪除，保留現有 provider 配置')
        continue

    if attempts > 1:
        summary.append(f'🔁 {name}: /models 第 {attempts} 次重試後成功')

    if not (isinstance(data, dict) and isinstance(data.get('data'), list)):
        summary.append(f'⚠️ 跳過 {name}: /models 回傳結構不可識別')
        continue

    remote_ids = []
    for item in data['data']:
        if isinstance(item, dict) and item.get('id'):
            remote_ids.append(str(item['id']))
    remote_set = set(remote_ids)

    if not remote_set:
        fatal_errors.append(f'❌ {name} 上游 /models 為空，無法為該 provider 提供兜底模型')
        continue

    local_models = [m for m in model_list if isinstance(m, dict) and m.get('id')]
    local_ids = [str(m['id']) for m in local_models]
    local_set = set(local_ids)

    template = None
    for m in local_models:
        template = copy.deepcopy(m)
        break
    if template is None:
        summary.append(f'⚠️ 跳過 {name}: 本地 models 無有效模板模型')
        continue

    removed_ids = [mid for mid in local_ids if mid not in remote_set]
    added_ids = [mid for mid in remote_ids if mid not in local_set]

    kept_models = [copy.deepcopy(m) for m in local_models if str(m['id']) in remote_set]
    new_models = kept_models[:]

    for mid in added_ids:
        nm = copy.deepcopy(template)
        nm['id'] = mid
        if isinstance(nm.get('name'), str):
            nm['name'] = f'{name} / {mid}'
        new_models.append(nm)

    if not new_models:
        fatal_errors.append(f'❌ {name} 同步後無可用模型，無法保障預設模型/回退模型兜底')
        continue

    expected_refs = {model_ref(name, str(m['id'])) for m in new_models if isinstance(m, dict) and m.get('id')}
    local_refs = {model_ref(name, mid) for mid in local_ids}

    first_ref = model_ref(name, str(new_models[0]['id']))

    primary_ref = get_primary_ref(defaults)
    if isinstance(primary_ref, str) and primary_ref in (local_refs - expected_refs):
        set_primary_ref(defaults, first_ref)
        changed = True
        summary.append(f'🔁 預設模型已兜底替換: {primary_ref} -> {first_ref}')

    for fk in ('modelFallback', 'imageModelFallback'):
        val = defaults.get(fk)
        if isinstance(val, str) and val in (local_refs - expected_refs):
            defaults[fk] = first_ref
            changed = True
            summary.append(f'🔁 {fk} 已兜底替換: {val} -> {first_ref}')

    stale_refs = [r for r in list(defaults_models.keys()) if r.startswith(name + '/') and r not in expected_refs]
    for r in stale_refs:
        defaults_models.pop(r, None)
        changed = True

    for r in sorted(expected_refs):
        if r not in defaults_models:
            defaults_models[r] = {}
            changed = True

    if removed_ids or added_ids or len(local_models) != len(new_models):
        provider['models'] = new_models
        changed = True

    summary.append(f'✅ {name}: 新增 {len(added_ids)} 個，刪除 {len(removed_ids)} 個，目前 {len(new_models)} 個')

    if added_ids:
        summary.append(f'➕ 新增模型({len(added_ids)}):')
        for mid in added_ids:
            summary.append(f'  + {mid}')
    if removed_ids:
        summary.append(f'➖ 刪除模型({len(removed_ids)}):')
        for mid in removed_ids:
            summary.append(f'  - {mid}')


if fatal_errors:
    for line in summary:
        print(line)
    for err in fatal_errors:
        print(err)
    print('❌ 模型同步失敗：存在 provider 同步後無可用模型，已中止寫入')
    raise SystemExit(2)

if changed:
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(work, f, ensure_ascii=False, indent=2)
        f.write('\n')
    for line in summary:
        print(line)
    print('✅ OpenClaw API 模型一致性同步完成並已寫入配置')
else:
    for line in summary:
        print(line)
    print('ℹ️ 無需同步：配置已與上游 /models 保持一致')
PY
	}



	install_moltbot() {
		echo "開始安裝 OpenClaw..."
		send_stats "開始安裝 OpenClaw..."
		install git jq

		install_node_and_tools

		country=$(curl -s ipinfo.io/country)
		if [[ "$country" == "CN" || "$country" == "HK" ]]; then
			npm config set registry https://registry.npmmirror.com
		fi

		git config --global url."${gh_proxy}github.com/".insteadOf ssh://git@github.com/
		git config --global url."${gh_proxy}github.com/".insteadOf git@github.com:

		npm install -g openclaw@latest
		openclaw onboard --install-daemon
		openclaw config set tools.profile full
		openclaw config set tools.elevated.enabled true
		# 提示：修改配置後如需立即生效，可重新啟動 gateway：openclaw gateway restart
		configure_openclaw_session_policy
		start_gateway
		add_app_id
		break_end

	}


	start_bot() {
		echo "啟動 OpenClaw..."
		send_stats "啟動 OpenClaw..."
		start_gateway
		break_end
	}

	stop_bot() {
		echo "停止 OpenClaw..."
		send_stats "停止 OpenClaw..."
		tmux kill-session -t gateway > /dev/null 2>&1
		openclaw gateway stop
		break_end
	}

	view_logs() {
		echo "查看 OpenClaw 狀態日誌"
		send_stats "查看 OpenClaw 日誌"
		openclaw status
		openclaw gateway status
		openclaw logs
		break_end
	}





	# OpenClaw API 協定偵測邏輯已移除：不再自動偵測/判定 API 類型。
	# 說明：API 類型由使用者明確配置（models.providers.<name>.api），腳本不再嘗試呼叫 /responses 做推論。

	# 建構模型配置 JSON
	build-openclaw-provider-models-json() {
		local provider_name="$1"
		local model_ids="$2"
		local models_array="["
		local first=true

		while read -r model_id; do
			[ -z "$model_id" ] && continue
			[[ $first == false ]] && models_array+=","
			first=false

			local context_window=1048576
			local max_tokens=128000
			local input_cost=0.15
			local output_cost=0.60

			case "$model_id" in
				*opus*|*pro*|*preview*|*thinking*|*sonnet*)
					input_cost=2.00
					output_cost=12.00
					;;
				*gpt-5*|*codex*)
					input_cost=1.25
					output_cost=10.00
					;;
				*flash*|*lite*|*haiku*|*mini*|*nano*)
					input_cost=0.10
					output_cost=0.40
					;;
			esac

			models_array+=$(cat <<EOF
{
	"id": "$model_id",
	"name": "$provider_name / $model_id",
	"input": ["text", "image"],
	"contextWindow": $context_window,
	"maxTokens": $max_tokens,
	"cost": {
		"input": $input_cost,
		"output": $output_cost,
		"cacheRead": 0,
		"cacheWrite": 0
	}
}
EOF
)
		done <<< "$model_ids"

		models_array+="]"
		echo "$models_array"
	}

	# 寫入 provider 與模型配置
	write-openclaw-provider-models() {
		local provider_name="$1"
		local base_url="$2"
		local api_key="$3"
		local models_array="$4"
		local config_file
		config_file=$(openclaw_get_config_file)

		# 不再自動探測/修正 API 協定；保持使用者配置為準
		DETECTED_API="openai-completions"

		[[ -f "$config_file" ]] && cp "$config_file" "${config_file}.bak.$(date +%s)"

		jq --arg prov "$provider_name" \
		   --arg url "$base_url" \
		   --arg key "$api_key" \
		   --arg api "$DETECTED_API" \
		   --argjson models "$models_array" \
		'
		.models |= (
			(. // { mode: "merge", providers: {} })
			| .mode = "merge"
			| .providers[$prov] = {
				baseUrl: $url,
				apiKey: $key,
				api: $api,
				models: $models
			}
		)
		| .agents |= (. // {})
		| .agents.defaults |= (. // {})
		| .agents.defaults.models |= (
			(if type == "object" then .
			 elif type == "array" then reduce .[] as $m ({}; if ($m|type) == "string" then .[$m] = {} else . end)
			 else {}
			 end) as $existing
			| reduce ($models[]? | .id? // empty | tostring) as $mid (
				$existing;
				if ($mid | length) > 0 then
					.["\($prov)/\($mid)"] //= {}
				else
					.
				end
			)
		)
		' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
	}

	# 核心函數：取得並加入所有模型
	add-all-models-from-provider() {
		local provider_name="$1"
		local base_url="$2"
		local api_key="$3"

		echo "🔍 正在獲取$provider_name的所有可用模型..."

		local models_json=$(curl -s -m 10 \
			-H "Authorization: Bearer $api_key" \
			"${base_url}/models")

		if [[ -z "$models_json" ]]; then
			echo "❌ 無法取得模型列表"
			return 1
		fi

		local model_ids=$(echo "$models_json" | grep -oP '"id":\s*"\K[^"]+')

		if [[ -z "$model_ids" ]]; then
			echo "❌ 未找到任何模型"
			return 1
		fi

		local model_count=$(echo "$model_ids" | wc -l)
		echo "✅ 發現$model_count個模型"

		local models_array
		models_array=$(build-openclaw-provider-models-json "$provider_name" "$model_ids")

		write-openclaw-provider-models "$provider_name" "$base_url" "$api_key" "$models_array"

		if [[ $? -eq 0 ]]; then
			echo "✅ 成功添加$model_count個模型到$provider_name"
			echo "📦 模型引用格式:$provider_name/<model-id>"
			return 0
		else
			echo "❌ 配置注入失敗"
			return 1
		fi
	}

	# 僅添加預設模型並保留 provider
	add-default-model-only-to-provider() {
		local provider_name="$1"
		local base_url="$2"
		local api_key="$3"
		local default_model="$4"

		if [[ -z "$default_model" ]]; then
			echo "❌ 預設模型不能為空"
			return 1
		fi

		local models_array
		models_array=$(build-openclaw-provider-models-json "$provider_name" "$default_model")

		write-openclaw-provider-models "$provider_name" "$base_url" "$api_key" "$models_array"

		if [[ $? -eq 0 ]]; then
			echo "✅ 已新增 provider：$provider_name"
			echo "✅ 僅寫入預設模型：$default_model"
			return 0
		else
			echo "❌ 配置注入失敗"
			return 1
		fi
	}

	add-openclaw-provider-interactive() {
		send_stats "OpenClaw API新增"
		echo "=== 互動式新增 OpenClaw Provider (全量模型) ==="

		# 1. Provider 名稱
		read -erp "請輸入 Provider 名稱 (如: deepseek):" provider_name
		while [[ -z "$provider_name" ]]; do
			echo "❌ Provider 名稱不能為空"
			read -erp "請輸入 Provider 名稱:" provider_name
		done

		# 2. Base URL
		read -erp "請輸入 Base URL (如: https://api.xxx.com/v1):" base_url
		while [[ -z "$base_url" ]]; do
			echo "❌ Base URL 不能為空"
			read -erp "請輸入 Base URL:" base_url
		done
		base_url="${base_url%/}"

		# 3. API Key
		read -rsp "請輸入 API Key (輸入不顯示):" api_key
		echo
		while [[ -z "$api_key" ]]; do
			echo "❌ API Key 不能為空"
			read -rsp "請輸入 API Key:" api_key
			echo
		done

		# 4. 不再偵測/判斷 API 類型；協定由使用者自行選擇與維護

		# 5. 取得模型列表
		echo "🔍 正在取得可用模型清單..."
		models_json=$(curl -s -m 10 \
			-H "Authorization: Bearer $api_key" \
			"${base_url}/models")

		if [[ -n "$models_json" ]]; then
			available_models=$(echo "$models_json" | grep -oP '"id":\s*"\K[^"]+' | sort)

			if [[ -n "$available_models" ]]; then
				model_count=$(echo "$available_models" | wc -l)
				echo "✅ 發現$model_count個可用模型："
				echo "--------------------------------"
				# 全部顯示，附序號
				i=1
				model_list=()
				while read -r model; do
					echo "[$i] $model"
					model_list+=("$model")
					((i++))
				done <<< "$available_models"
				echo "--------------------------------"
			fi
		fi

		# 5. 選擇預設模型
		echo
		read -erp "請輸入預設 Model ID (或序號，留空則使用第一個):" input_model

		if [[ -z "$input_model" && -n "$available_models" ]]; then
			default_model=$(echo "$available_models" | head -1)
			echo "🎯 使用第一個模型:$default_model"
		elif [[ "$input_model" =~ ^[0-9]+$ ]] && [ "${#model_list[@]}" -gt 0 ] && [ "$input_model" -ge 1 ] && [ "$input_model" -le "${#model_list[@]}" ]; then
			default_model="${model_list[$((input_model-1))]}"
			echo "🎯 已選擇模型:$default_model"
		else
			default_model="$input_model"
		fi

		# 6. 確認訊息
		echo
		echo "====== 確認訊息 ======"
		echo "Provider    : $provider_name"
		echo "Base URL    : $base_url"
		echo "API Key     : ${api_key:0:8}****"
		echo "預設模型 :$default_model"
		echo "模型總數 :$model_count"
		echo "======================"

		read -erp "是否同時新增其他所有可用模型？ (y/N):" confirm

		install jq
		if [[ "$confirm" =~ ^[Yy]$ ]]; then
			add-all-models-from-provider "$provider_name" "$base_url" "$api_key"
			add_result=$?
			finish_msg="✅ 完成！所有$model_count個模型已載入"
		else
			add-default-model-only-to-provider "$provider_name" "$base_url" "$api_key" "$default_model"
			add_result=$?
			finish_msg="✅ 完成！已保留 provider，並僅載入預設模型：$default_model"
		fi

		if [[ $add_result -eq 0 ]]; then
			echo
			echo "🔄 設定預設模型並重新啟動網關..."
			openclaw models set "$provider_name/$default_model"
			openclaw_sync_sessions_model "$provider_name/$default_model"
			start_gateway
			echo "$finish_msg"
			echo "✅ 當前 API 協定類型:$DETECTED_API"
		fi

		break_end
	}


	
openclaw_api_manage_list() {
	local config_file="${HOME}/.openclaw/openclaw.json"
	send_stats "OpenClaw API列表"

	while IFS=$'\t' read -r rec_type idx name base_url model_count api_type latency_txt latency_level; do
		case "$rec_type" in
			MSG)
				echo "$idx"
				;;
			ROW)
				local latency_color="$gl_bai"
				case "$latency_level" in
					low) latency_color="$gl_lv" ;;
					medium) latency_color="$gl_huang" ;;
					high|unavailable) latency_color="$gl_hong" ;;
					unchecked) latency_color="$gl_bai" ;;
				esac

				printf '%b\n' "[$idx] ${name} | API: ${base_url}| 協議:${api_type}| 模型數量:${gl_huang}${model_count}${gl_bai}| 延遲/狀態:${latency_color}${latency_txt}${gl_bai}"
				;;
		esac
	done < <(python3 - "$config_file" <<-'PY'
import json
import sys
import time
import urllib.request

path = sys.argv[1]
SUPPORTED_APIS = {'openai-completions', 'openai-responses'}


def ping_models(base_url, api_key):
    req = urllib.request.Request(
        base_url.rstrip('/') + '/models',
        headers={
            'Authorization': f'Bearer {api_key}',
            'User-Agent': 'OpenClaw-API-Manage/1.0',
        },
    )
    start = time.perf_counter()
    with urllib.request.urlopen(req, timeout=4) as resp:
        resp.read(2048)
    return int((time.perf_counter() - start) * 1000)


def classify_latency(latency):
    if latency == '不可用':
        return '不可用', 'unavailable'
    if latency == '未檢測':
        return '未檢測', 'unchecked'
    if isinstance(latency, int):
        if latency <= 800:
            level = 'low'
        elif latency <= 2000:
            level = 'medium'
        else:
            level = 'high'
        return f'{latency}ms', level
    return str(latency), 'unchecked'


try:
    with open(path, 'r', encoding='utf-8') as f:
        obj = json.load(f)
except FileNotFoundError:
    print('MSG\tℹ️ 未找到 openclaw.json，請先完成安裝/初始化。')
    raise SystemExit(0)
except Exception as e:
    print(f'MSG\t❌ 讀取設定失敗: {type(e).__name__}: {e}')
    raise SystemExit(0)

providers = ((obj.get('models') or {}).get('providers') or {})
if not isinstance(providers, dict) or not providers:
    print('MSG\tℹ️ 目前未配置任何 API provider。')
    raise SystemExit(0)

print('MSG\t--- 已設定 API 清單 ---')

for idx, name in enumerate(sorted(providers.keys()), start=1):
    provider = providers.get(name)
    if not isinstance(provider, dict):
        base_url = '-'
        model_count = 0
        latency_raw = '不可用'
    else:
        base_url = provider.get('baseUrl') or provider.get('url') or provider.get('endpoint') or '-'
        models = provider.get('models') if isinstance(provider.get('models'), list) else []
        model_count = sum(1 for m in models if isinstance(m, dict) and m.get('id'))
        api = provider.get('api', '')
        api_key = provider.get('apiKey')

        latency_raw = '未檢測'
        if api in SUPPORTED_APIS:
            if isinstance(base_url, str) and base_url != '-' and isinstance(api_key, str) and api_key:
                try:
                    latency_raw = ping_models(base_url, api_key)
                except Exception:
                    latency_raw = '不可用'
            else:
                latency_raw = '不可用'

    latency_text, latency_level = classify_latency(latency_raw)
    api_label = api if api in SUPPORTED_APIS else '-'
    print(
        'ROW\t' + '\t'.join([
            str(idx),
            str(name),
            str(base_url),
            str(model_count),
            str(api_label),
            str(latency_text),
            str(latency_level),
        ])
    )
PY
)
}
sync-openclaw-provider-interactive() {
	local config_file="${HOME}/.openclaw/openclaw.json"
	send_stats "OpenClaw API按Provider同步"

	if [ ! -f "$config_file" ]; then
		echo "❌ 未找到設定檔:$config_file"
		break_end
		return 1
	fi

	read -erp "請輸入要同步的 API 名稱(provider)，直接回車同步全部:" provider_name
	if [ -z "$provider_name" ]; then
		if sync_openclaw_api_models; then
			start_gateway
		else
			echo "❌ API 模型同步失敗，已中止重新啟動網關。請檢查 provider /models 返回後重試。"
			return 1
		fi
		break_end
		return 0
	fi

	install jq curl >/dev/null 2>&1

	python3 - "$config_file" "$provider_name" <<'PY2'
import copy
import json
import sys
import time
import urllib.request

path = sys.argv[1]
target = sys.argv[2]
SUPPORTED_APIS = {'openai-completions', 'openai-responses'}

with open(path, 'r', encoding='utf-8') as f:
    obj = json.load(f)

work = copy.deepcopy(obj)
models_cfg = work.setdefault('models', {})
providers = models_cfg.get('providers', {})
if not isinstance(providers, dict) or not providers:
    print('❌ 未偵測到 API providers，無法同步')
    raise SystemExit(2)

provider = providers.get(target)
if not isinstance(provider, dict):
    print(f'❌ 未找到 provider: {target}')
    raise SystemExit(2)

agents = work.setdefault('agents', {})
defaults = agents.setdefault('defaults', {})
defaults_models_raw = defaults.get('models')
if isinstance(defaults_models_raw, dict):
    defaults_models = defaults_models_raw
elif isinstance(defaults_models_raw, list):
    defaults_models = {str(x): {} for x in defaults_models_raw if isinstance(x, str)}
else:
    defaults_models = {}
defaults['models'] = defaults_models


def model_ref(provider_name, model_id):
    return f"{provider_name}/{model_id}"


def get_primary_ref(defaults_obj):
    model_obj = defaults_obj.get('model')
    if isinstance(model_obj, str):
        return model_obj
    if isinstance(model_obj, dict):
        primary = model_obj.get('primary')
        if isinstance(primary, str):
            return primary
    return None


def set_primary_ref(defaults_obj, new_ref):
    model_obj = defaults_obj.get('model')
    if isinstance(model_obj, str):
        defaults_obj['model'] = new_ref
    elif isinstance(model_obj, dict):
        model_obj['primary'] = new_ref
    else:
        defaults_obj['model'] = {'primary': new_ref}


def fetch_remote_models_with_retry(base_url, api_key, retries=3):
    last_error = None
    for attempt in range(1, retries + 1):
        req = urllib.request.Request(
            base_url.rstrip('/') + '/models',
            headers={
                'Authorization': f'Bearer {api_key}',
                'User-Agent': 'Mozilla/5.0',
            },
        )
        try:
            with urllib.request.urlopen(req, timeout=12) as resp:
                payload = resp.read().decode('utf-8', 'ignore')
            return json.loads(payload), None, attempt
        except Exception as e:
            last_error = e
            if attempt < retries:
                time.sleep(1)
    return None, last_error, retries


api = provider.get('api', '')
base_url = provider.get('baseUrl')
api_key = provider.get('apiKey')
model_list = provider.get('models', [])

if not base_url or not api_key or not isinstance(model_list, list) or not model_list:
    print(f'❌ provider {target} 缺少 baseUrl/apiKey/models，無法執行同步')
    raise SystemExit(3)

if api not in SUPPORTED_APIS:
    print(f'ℹ️ provider {target} 目前 api={api}，但腳本已不再探測/修正協定；請手動設定為 openai-completions 或 openai-responses')

protocol_msg = None

data, err, attempts = fetch_remote_models_with_retry(base_url, api_key, retries=3)
if err is not None:
    print(f'❌ {target}: /models 探測失敗，已重試 {attempts} 次 ({type(err).__name__}: {err})')
    raise SystemExit(4)

if not (isinstance(data, dict) and isinstance(data.get('data'), list)):
    print(f'❌ {target}: /models 回傳結構不可識別')
    raise SystemExit(4)

remote_ids = []
for item in data['data']:
    if isinstance(item, dict) and item.get('id'):
        remote_ids.append(str(item['id']))
remote_set = set(remote_ids)
if not remote_set:
    print(f'❌ {target}: 上游 /models 為空，已中止同步')
    raise SystemExit(5)

local_models = [m for m in model_list if isinstance(m, dict) and m.get('id')]
local_ids = [str(m['id']) for m in local_models]
local_set = set(local_ids)

template = copy.deepcopy(local_models[0]) if local_models else None
if template is None:
    print(f'❌ {target}: 本地 models 無有效模板模型，無法補全新增模型')
    raise SystemExit(3)

removed_ids = [mid for mid in local_ids if mid not in remote_set]
added_ids = [mid for mid in remote_ids if mid not in local_set]

kept_models = [copy.deepcopy(m) for m in local_models if str(m['id']) in remote_set]
new_models = kept_models[:]
for mid in added_ids:
    nm = copy.deepcopy(template)
    nm['id'] = mid
    if isinstance(nm.get('name'), str):
        nm['name'] = f'{target} / {mid}'
    new_models.append(nm)

if not new_models:
    print(f'❌ {target}: 同步後無可用模型，已中止寫入')
    raise SystemExit(5)

expected_refs = {model_ref(target, str(m['id'])) for m in new_models if isinstance(m, dict) and m.get('id')}
local_refs = {model_ref(target, mid) for mid in local_ids}
removed_refs = local_refs - expected_refs
first_ref = model_ref(target, str(new_models[0]['id']))

changed = False
primary_ref = get_primary_ref(defaults)
if isinstance(primary_ref, str) and primary_ref in removed_refs:
    set_primary_ref(defaults, first_ref)
    changed = True
    print(f'🔁 預設模型已兜底替換: {primary_ref} -> {first_ref}')

for fk in ('modelFallback', 'imageModelFallback'):
    val = defaults.get(fk)
    if isinstance(val, str) and val in removed_refs:
        defaults[fk] = first_ref
        changed = True
        print(f'🔁 {fk} 已兜底替換: {val} -> {first_ref}')

stale_refs = [r for r in list(defaults_models.keys()) if r.startswith(target + '/') and r not in expected_refs]
for r in stale_refs:
    defaults_models.pop(r, None)
    changed = True

for r in sorted(expected_refs):
    if r not in defaults_models:
        defaults_models[r] = {}
        changed = True

if removed_ids or added_ids or len(local_models) != len(new_models):
    provider['models'] = new_models
    changed = True


if changed:
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(work, f, ensure_ascii=False, indent=2)
        f.write('\n')

print(f'✅ {target}: 新增 {len(added_ids)} 個，刪除 {len(removed_ids)} 個，目前 {len(new_models)} 個')

if added_ids:
    print(f'➕ 新增模型({len(added_ids)}):')
    for mid in added_ids:
        print(f'  + {mid}')
if removed_ids:
    print(f'➖ 刪除模型({len(removed_ids)}):')
    for mid in removed_ids:
        print(f'  - {mid}')

if changed:
    print('✅ 指定 provider 模型一致性同步完成並已寫入配置')
else:
    print('ℹ️ 無需同步：此 provider 配置已與上游 /models 保持一致')
PY2
	local rc=$?
	case "$rc" in
		0)
			echo "✅ 同步執行完成"
			start_gateway
			;;
		2)
			echo "❌ 同步失敗：provider 不存在或未配置"
			;;
		3)
			echo "❌ 同步失敗：provider 配置不完整或類型不支持"
			;;
		4)
			echo "❌ 同步失敗：上游 /models 請求失敗"
			;;
		5)
			echo "❌ 同步失敗：上游模型為空或同步後無可用模型"
			;;
		*)
			echo "❌ 同步失敗：請檢查設定檔結構或日誌輸出"
			;;
	esac

	break_end
}

openclaw_detect_api_protocol_by_provider() {
	# 協定探測邏輯已移除：腳本不再自動偵測/判定 API 類型。
	# 保留函數以相容選單調用，但不做任何改寫。
	echo "ℹ️ 已關閉協議探測：請手動在${HOME}/.openclaw/openclaw.json 中設定 provider.api 為 openai-completions 或 openai-responses"
	return 0
}

fix-openclaw-provider-protocol-interactive() {
	local config_file="${HOME}/.openclaw/openclaw.json"
	send_stats "OpenClaw API協定切換"

	if [ ! -f "$config_file" ]; then
		echo "❌ 未找到設定檔:$config_file"
		break_end
		return 1
	fi

	read -erp "請輸入要切換協定的 API 名稱(provider):" provider_name
	if [ -z "$provider_name" ]; then
		echo "❌ provider 名稱不能為空"
		break_end
		return 1
	fi

	echo "請選擇要設定的 API 類型："
	echo "1. openai-completions"
	echo "2. openai-responses"
	read -erp "請輸入你的選擇 (1/2):" proto_choice

	local new_api=""
	case "$proto_choice" in
		1) new_api="openai-completions" ;;
		2) new_api="openai-responses" ;;
		*)
			echo "❌ 無效選擇"
			break_end
			return 1
			;;
	esac

	install python3 >/dev/null 2>&1

	python3 - "$config_file" "$provider_name" "$new_api" <<'PY'
import copy
import json
import sys

path = sys.argv[1]
name = sys.argv[2]
new_api = sys.argv[3]

SUPPORTED_APIS = {'openai-completions', 'openai-responses'}
if new_api not in SUPPORTED_APIS:
    print('❌ 非法協議值')
    raise SystemExit(3)

with open(path, 'r', encoding='utf-8') as f:
    obj = json.load(f)

work = copy.deepcopy(obj)
providers = ((work.get('models') or {}).get('providers') or {})
if not isinstance(providers, dict) or name not in providers or not isinstance(providers.get(name), dict):
    print(f'❌ 未找到 provider: {name}')
    raise SystemExit(2)

providers[name]['api'] = new_api

with open(path, 'w', encoding='utf-8') as f:
    json.dump(work, f, ensure_ascii=False, indent=2)
    f.write('\n')

print(f'✅ 已更新 provider {name} 協定為: {new_api}')
PY
	local rc=$?
	case "$rc" in
		0)
			start_gateway
			;;
		2)
			echo "❌ 切換失敗：provider 不存在或未配置"
			;;
		3)
			echo "❌ 切換失敗：協定值非法"
			;;
		*)
			echo "❌ 切換失敗：請檢查設定檔結構或日誌輸出"
			;;
	esac

	break_end
}

	delete-openclaw-provider-interactive() {
		local config_file
		config_file=$(openclaw_get_config_file)
		send_stats "OpenClaw API刪除入口"

		if [ ! -f "$config_file" ]; then
			echo "❌ 未找到設定檔:$config_file"
			break_end
			return 1
		fi

		read -erp "請輸入要刪除的 API 名稱(provider):" provider_name
		if [ -z "$provider_name" ]; then
			send_stats "OpenClaw API刪除取消"
			echo "❌ provider 名稱不能為空"
			break_end
			return 1
		fi

		python3 - "$config_file" "$provider_name" <<'PY'
import copy
import json
import sys

path = sys.argv[1]
name = sys.argv[2]

with open(path, 'r', encoding='utf-8') as f:
    obj = json.load(f)

work = copy.deepcopy(obj)
models_cfg = work.setdefault('models', {})
providers = models_cfg.get('providers', {})
if not isinstance(providers, dict) or name not in providers:
    print(f'❌ 未找到 provider: {name}')
    raise SystemExit(2)

agents = work.setdefault('agents', {})
defaults = agents.setdefault('defaults', {})
defaults_models_raw = defaults.get('models')
if isinstance(defaults_models_raw, dict):
    defaults_models = defaults_models_raw
elif isinstance(defaults_models_raw, list):
    defaults_models = {str(x): {} for x in defaults_models_raw if isinstance(x, str)}
else:
    defaults_models = {}
defaults['models'] = defaults_models


def model_ref(provider_name, model_id):
    return f"{provider_name}/{model_id}"


def ref_provider(ref):
    if not isinstance(ref, str) or '/' not in ref:
        return None
    return ref.split('/', 1)[0]


def get_primary_ref(defaults_obj):
    model_obj = defaults_obj.get('model')
    if isinstance(model_obj, str):
        return model_obj
    if isinstance(model_obj, dict):
        primary = model_obj.get('primary')
        if isinstance(primary, str):
            return primary
    return None


def set_primary_ref(defaults_obj, new_ref):
    model_obj = defaults_obj.get('model')
    if isinstance(model_obj, str):
        defaults_obj['model'] = new_ref
    elif isinstance(model_obj, dict):
        model_obj['primary'] = new_ref
    else:
        defaults_obj['model'] = {'primary': new_ref}


def collect_available_refs(exclude_provider=None):
    refs = []
    if not isinstance(providers, dict):
        return refs
    for pname, p in providers.items():
        if exclude_provider and pname == exclude_provider:
            continue
        if not isinstance(p, dict):
            continue
        for m in p.get('models', []) or []:
            if isinstance(m, dict) and m.get('id'):
                refs.append(model_ref(pname, str(m['id'])))
    return refs


replacement_candidates = collect_available_refs(exclude_provider=name)
replacement = replacement_candidates[0] if replacement_candidates else None

primary_ref = get_primary_ref(defaults)
if ref_provider(primary_ref) == name:
    if not replacement:
        print('❌ 刪除中止：預設主模型指向該 provider，且無可用替代模型')
        raise SystemExit(3)
    set_primary_ref(defaults, replacement)
    print(f'🔁 預設主模型切換: {primary_ref} -> {replacement}')

for fk in ('modelFallback', 'imageModelFallback'):
    val = defaults.get(fk)
    if ref_provider(val) == name:
        if not replacement:
            print(f'❌ 刪除中止：{fk} 指向該 provider，且無可用替代模型')
            raise SystemExit(3)
        defaults[fk] = replacement
        print(f'🔁 {fk} 切換: {val} -> {replacement}')

removed_refs = [r for r in list(defaults_models.keys()) if r.startswith(name + '/')]
for r in removed_refs:
    defaults_models.pop(r, None)

providers.pop(name, None)

with open(path, 'w', encoding='utf-8') as f:
    json.dump(work, f, ensure_ascii=False, indent=2)
    f.write('\n')

print(f'🗑️ 已刪除 provider: {name}')
print(f'🧹 已清理 defaults.models 中 {len(removed_refs)} 個關聯模型引用')
PY
		local rc=$?
		case "$rc" in
			0)
				send_stats "OpenClaw API刪除確認"
				echo "✅ 刪除完成"
				start_gateway
				;;
			2)
				echo "❌ 刪除失敗：provider 不存在"
				;;
			3)
				send_stats "OpenClaw API刪除取消"
				echo "❌ 刪除失敗：無可用替代模型，已保持原始配置"
				;;
			*)
				echo "❌ 刪除失敗：請檢查設定檔結構或日誌輸出"
				;;
		esac

		break_end
	}

	openclaw_api_providers_showcase() {
		send_stats "OpenClaw API廠商推薦"

		clear
		echo ""
		echo -e "${gl_kjlan}╔════════════════════════════════════════════════════════════╗${gl_bai}"
		echo -e "${gl_kjlan}║${gl_bai}            ${gl_huang}🌟 API 廠商推薦列表${gl_bai}                          ${gl_kjlan}║${gl_bai}"
		echo -e "${gl_kjlan}║${gl_bai}            ${gl_zi}部分入口含 AFF${gl_bai}                            ${gl_kjlan}║${gl_bai}"
		echo -e "${gl_kjlan}╚════════════════════════════════════════════════════════════╝${gl_bai}"
		echo ""
		echo -e "  ${gl_lv}● DeepSeek${gl_bai}"
		echo -e "    ${gl_kjlan}https://api-docs.deepseek.com/${gl_bai}"
		echo ""
		echo -e "  ${gl_lv}● OpenRouter${gl_bai}"
		echo -e "    ${gl_kjlan}https://openrouter.ai/${gl_bai}"
		echo ""
		echo -e "  ${gl_lv}● Kimi${gl_bai}"
		echo -e "    ${gl_kjlan}https://platform.moonshot.cn/docs/guide/start-using-kimi-api${gl_bai}"
		echo ""
		echo -e "  ${gl_lv}● 超算互聯網${gl_bai}"
		echo -e "    ${gl_kjlan}https://www.scnet.cn/${gl_bai}"
		echo ""
		echo -e "  ${gl_huang}● 優雲智算${gl_bai} ${gl_zi}[AFF]${gl_bai}"
		echo -e "    ${gl_kjlan}https://passport.compshare.cn/register?referral_code=4mscFZXfutfFi8swMVsPuf${gl_bai}"
		echo ""
		echo -e "  ${gl_huang}● 矽基流動${gl_bai} ${gl_zi}[AFF]${gl_bai}"
		echo -e "    ${gl_kjlan}https://cloud.siliconflow.cn/i/irWVdPic${gl_bai}"
		echo ""
		echo -e "  ${gl_huang}● 智譜 GLM${gl_bai} ${gl_zi}[AFF]${gl_bai}"
		echo -e "    ${gl_kjlan}https://www.bigmodel.cn/glm-coding?ic=HYOTDOAJMR${gl_bai}"
		echo ""
		echo -e "  ${gl_huang}● PackyAPI${gl_bai} ${gl_zi}[AFF]${gl_bai}"
		echo -e "    ${gl_kjlan}https://www.packyapi.com/register?aff=wHri${gl_bai}"
		echo ""
		echo -e "  ${gl_huang}● 雲霧 API${gl_bai} ${gl_zi}[AFF]${gl_bai}"
		echo -e "    ${gl_kjlan}https://yunwu.ai/register?aff=ZuyK${gl_bai}"
		echo ""
		echo -e "  ${gl_huang}●柏拉圖AI${gl_bai} ${gl_zi}[AFF]${gl_bai}"
		echo -e "    ${gl_kjlan}https://api.bltcy.ai/register?aff=TBzb114019${gl_bai}"
		echo ""
		echo -e "  ${gl_lv}● MiniMax${gl_bai}"
		echo -e "    ${gl_kjlan}https://www.minimaxi.com/${gl_bai}"
		echo ""
		echo -e "  ${gl_lv}● NVIDIA${gl_bai}"
		echo -e "    ${gl_kjlan}https://build.nvidia.com/settings/api-keys${gl_bai}"
		echo ""
		echo -e "  ${gl_lv}● Ollama${gl_bai}"
		echo -e "    ${gl_kjlan}https://ollama.com/${gl_bai}"
		echo ""
		echo -e "  ${gl_lv}● 白山雲${gl_bai}"
		echo -e "    ${gl_kjlan}https://ai.baishan.com/${gl_bai}"
		echo ""
		echo -e "${gl_kjlan}────────────────────────────────────────────────────────────${gl_bai}"
		echo -e "  ${gl_zi}圖例：${gl_lv}● 官方入口${gl_bai}  ${gl_huang}● AFF 推薦入口${gl_bai}"
		echo ""
		echo -e "${gl_huang}提示：複製連結到瀏覽器開啟即可訪問${gl_bai}"
		echo ""
		read -erp "按回車鍵返回..." dummy
	}

	openclaw_api_manage_menu() {
		send_stats "OpenClaw API入口"
		while true; do
			clear
			echo "======================================="
			echo "OpenClaw API 管理"
			echo "======================================="
			openclaw_api_manage_list
			echo "---------------------------------------"
			echo "1. 新增API"
			echo "2. 同步API供應商模型列表"
			echo "3. 切換 API 類型（completions / responses）"
			echo "4. 刪除API"
			echo "5. API 廠商推薦"
			echo "0. 退出"
			echo "---------------------------------------"
			read -erp "請輸入你的選擇:" api_choice

			case "$api_choice" in
				1)
					add-openclaw-provider-interactive
					;;
				2)
					sync-openclaw-provider-interactive
					;;
				3)
					fix-openclaw-provider-protocol-interactive
					;;
				4)
					delete-openclaw-provider-interactive
					;;
				5)
					openclaw_api_providers_showcase
					;;
				0)
					return 0
					;;
				*)
					echo "無效的選擇，請重試。"
					sleep 1
					;;
			esac
		done
	}



	install_gum() {
	    if command -v gum >/dev/null 2>&1; then
	        return 0
	    fi
		
 		if command -v apt >/dev/null 2>&1; then
	        mkdir -p /etc/apt/keyrings
	        curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg
	        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | tee /etc/apt/sources.list.d/charm.list > /dev/null
	        apt update && apt install -y gum
	    elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
	        cat > /etc/yum.repos.d/charm.repo <<'REPO'
[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key
REPO
	        rpm --import https://repo.charm.sh/yum/gpg.key
	        if command -v dnf >/dev/null 2>&1; then
	            dnf install -y gum
	        else
	            yum install -y gum
	        fi
	    elif command -v zypper >/dev/null 2>&1; then
	        zypper --non-interactive refresh
	        zypper --non-interactive install gum
	    fi
	}


	
	change_model() {
		send_stats "換模型"

		local orange="#FF8C00"

		openclaw_probe_status_line() {
			local status_text="$1"
			local status_color_ok='[32m'
			local status_color_fail='[31m'
			local status_color_reset='[0m'
			if [ "$status_text" = "可用" ]; then
				printf "%b最小检测结果：%s%b
" "$status_color_ok" "$status_text" "$status_color_reset"
			else
				printf "%b最小检测结果：%s%b
" "$status_color_fail" "$status_text" "$status_color_reset"
			fi
		}

		openclaw_model_probe() {
			local target_model="$1"
			local probe_timeout=25
			local tmp_payload tmp_response probe_result probe_status reply_preview reply_trimmed
			local oc_config provider_name base_url api_key request_model
			local first_endpoint second_endpoint
			local first_exit first_http first_latency second_exit second_http second_latency
			local first_reply second_reply

			oc_config=$(openclaw_get_config_file)
			[ ! -f "$oc_config" ] && {
				OPENCLAW_PROBE_STATUS="ERROR"
				OPENCLAW_PROBE_MESSAGE="未找到 openclaw 設定文件"
				OPENCLAW_PROBE_LATENCY="-"
				OPENCLAW_PROBE_REPLY="-"
				return 1
			}

			provider_name="${target_model%%/*}"
			request_model="${target_model#*/}"
			base_url=$(jq -r --arg provider "$provider_name" '.models.providers[$provider].baseUrl // empty' "$oc_config" 2>/dev/null)
			api_key=$(jq -r --arg provider "$provider_name" '.models.providers[$provider].apiKey // empty' "$oc_config" 2>/dev/null)
			if [ -z "$provider_name" ] || [ -z "$base_url" ] || [ -z "$api_key" ]; then
				OPENCLAW_PROBE_STATUS="ERROR"
				OPENCLAW_PROBE_MESSAGE="未讀取到 provider/baseUrl/apiKey"
				OPENCLAW_PROBE_LATENCY="-"
				OPENCLAW_PROBE_REPLY="-"
				return 1
			fi

			base_url="${base_url%/}"
			first_endpoint="/responses"
			second_endpoint="/chat/completions"

			openclaw_extract_probe_reply() {
				python3 - "$1" <<'PYTHON_EOF'
import json
import sys
from pathlib import Path
path = Path(sys.argv[1])
raw = path.read_text(encoding='utf-8', errors='replace').strip()
reply = ''
if raw:
    try:
        data = json.loads(raw)
        if isinstance(data, dict):
            choices = data.get('choices') or []
            if choices and isinstance(choices[0], dict):
                message = choices[0].get('message') or {}
                if isinstance(message, dict):
                    reply = message.get('content') or ''
            if not reply:
                output = data.get('output') or []
                if isinstance(output, list):
                    texts = []
                    for item in output:
                        if not isinstance(item, dict):
                            continue
                        for content in item.get('content') or []:
                            if not isinstance(content, dict):
                                continue
                            text = content.get('text')
                            if isinstance(text, str) and text.strip():
                                texts.append(text.strip())
                        if texts:
                            break
                    if texts:
                        reply = ' '.join(texts)
            if not reply:
                for key in ('error', 'message', 'detail'):
                    value = data.get(key)
                    if isinstance(value, str) and value.strip():
                        reply = value.strip()
                        break
                    if isinstance(value, dict):
                        nested = value.get('message')
                        if isinstance(nested, str) and nested.strip():
                            reply = nested.strip()
                            break
    except Exception:
        reply = raw
reply = ' '.join(str(reply).split())
print(reply)
PYTHON_EOF
			}

			openclaw_run_probe() {
				local endpoint="$1"
				tmp_payload=$(mktemp)
				tmp_response=$(mktemp)
				if [ "$endpoint" = "/responses" ]; then
					printf '{"model":"%s","input":"hi","temperature":0,"max_output_tokens":16}' "$request_model" > "$tmp_payload"
				else
					printf '{"model":"%s","messages":[{"role":"user","content":"hi"}],"temperature":0,"max_tokens":16}' "$request_model" > "$tmp_payload"
				fi

				probe_result=$(python3 - "$base_url" "$api_key" "$tmp_payload" "$tmp_response" "$probe_timeout" "$endpoint" <<'PYTHON_EOF'
import sys
import time
import urllib.error
import urllib.request

base_url, api_key, payload_path, response_path, timeout, endpoint = sys.argv[1:7]
timeout = int(timeout)
url = base_url + endpoint
payload = open(payload_path, 'rb').read()
req = urllib.request.Request(
    url,
    data=payload,
    headers={
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {api_key}',
    },
    method='POST',
)
start = time.time()
body = b''
status = 0
exit_code = 0
try:
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        status = getattr(resp, 'status', 200)
        body = resp.read()
except urllib.error.HTTPError as e:
    status = getattr(e, 'code', 0) or 0
    body = e.read()
    exit_code = 22
except Exception as e:
    body = str(e).encode('utf-8', errors='replace')
    exit_code = 1
elapsed = int((time.time() - start) * 1000)
with open(response_path, 'wb') as f:
    f.write(body)
print(f"{exit_code}|{status}|{elapsed}")
PYTHON_EOF
)
				probe_status=$?
				reply_preview=$(openclaw_extract_probe_reply "$tmp_response")
				rm -f "$tmp_payload" "$tmp_response"
				return $probe_status
			}

			openclaw_run_probe "$first_endpoint"
			first_exit=${probe_result%%|*}
			first_http=${probe_result#*|}
			first_http=${first_http%%|*}
			first_latency=${probe_result##*|}
			first_reply="$reply_preview"

			reply_trimmed=$(printf '%s' "$first_reply" | cut -c1-120)
			[ -z "$reply_trimmed" ] && reply_trimmed="(空返回)"

			if [ "$first_exit" = "0" ] && [ "$first_http" -ge 200 ] && [ "$first_http" -lt 300 ]; then
				OPENCLAW_PROBE_STATUS="OK"
				OPENCLAW_PROBE_MESSAGE="${first_endpoint} -> HTTP ${first_http}"
				OPENCLAW_PROBE_LATENCY="${first_latency}ms"
				OPENCLAW_PROBE_REPLY="$reply_trimmed"
				return 0
			fi

			openclaw_run_probe "$second_endpoint"
			second_exit=${probe_result%%|*}
			second_http=${probe_result#*|}
			second_http=${second_http%%|*}
			second_latency=${probe_result##*|}
			second_reply="$reply_preview"

			reply_trimmed=$(printf '%s' "$second_reply" | cut -c1-120)
			[ -z "$reply_trimmed" ] && reply_trimmed="(空返回)"

			if [ "$second_exit" = "0" ] && [ "$second_http" -ge 200 ] && [ "$second_http" -lt 300 ]; then
				OPENCLAW_PROBE_STATUS="OK"
				OPENCLAW_PROBE_MESSAGE="${first_endpoint}-> HTTP ${first_http:-0}，切換${second_endpoint} -> HTTP ${second_http}"
				OPENCLAW_PROBE_LATENCY="${second_latency}ms"
				OPENCLAW_PROBE_REPLY="$reply_trimmed"
				return 0
			fi

			reply_trimmed=$(printf '%s' "$first_reply" | cut -c1-120)
			[ -z "$reply_trimmed" ] && reply_trimmed=$(printf '%s' "$second_reply" | cut -c1-120)
			[ -z "$reply_trimmed" ] && reply_trimmed="(空返回)"

			OPENCLAW_PROBE_STATUS="FAIL"
			OPENCLAW_PROBE_MESSAGE="${first_endpoint} -> HTTP ${first_http:-0} / exit ${first_exit:-1}；${second_endpoint} -> HTTP ${second_http:-0} / exit ${second_exit:-1}"
			OPENCLAW_PROBE_LATENCY="${first_latency:-?}ms -> ${second_latency:-?}ms"
			OPENCLAW_PROBE_REPLY="$reply_trimmed"
			return 1
		}

		clear

		while true; do
			local models_raw models_list default_model model_count selected_model confirm_switch

			# 從設定檔讀取模型鍵（不呼叫 openclaw models list）
			local oc_config
			oc_config=$(openclaw_get_config_file)

			models_raw=$(jq -r '.agents.defaults.models | if type == "object" then keys[] else .[] end' "$oc_config" 2>/dev/null | sed '/^\s*$/d')
			if [ -z "$models_raw" ]; then
				echo "取得模型清單失敗：設定檔中未找到 agents.defaults.models。"
				break_end
				return 1
			fi

			# 為每個模型加編號，方便快速定位（例如："(10) or-api/...:free"）
			models_list=$(echo "$models_raw" | awk '{print "(" NR ") " $0}')
			model_count=$(echo "$models_list" | sed '/^\s*$/d' | wc -l | tr -d ' ')

			# 從設定檔讀取預設模型（更快）；失敗再回退到 openclaw 指令
			default_model=$(jq -r '.agents.defaults.model.primary // empty' "$oc_config" 2>/dev/null)
			[ -z "$default_model" ] && default_model="(unknown)"

			clear

			install_gum
			install gum
			
			# 若 gum 不存在，降級為原始手動輸入流程
			if ! command -v gum >/dev/null 2>&1 || ! gum --version >/dev/null 2>&1; then
				echo "--- 模型管理 ---"
				echo "目前可用模型:"
				jq -r '.agents.defaults.models | if type == "object" then keys[] else .[] end' "$oc_config" 2>/dev/null | sed '/^\s*$/d'
				echo "----------------"
				read -e -p "請輸入要設定的模型名稱 (例如 openrouter/openai/gpt-4o)（輸入 0 退出）：" selected_model

				if [ "$selected_model" = "0" ]; then
					echo "操作已取消，正在退出..."
					break
				fi

				if [ -z "$selected_model" ]; then
					echo "錯誤：模型名稱不能為空。請重試。"
					echo ""
					continue
				fi

				echo "正在切換模型為:$selected_model ..."
				if ! openclaw models set "$selected_model"; then
					echo "切換失敗：openclaw models set 回傳錯誤。"
					break_end
					return 1
				fi
				openclaw_sync_sessions_model "$selected_model"
				start_gateway

				break_end
				return 0
			else
				if ! command -v gum >/dev/null 2>&1 || ! gum --version >/dev/null 2>&1; then
					echo "gum 不可用，傳回舊版輸入模式。"
					sleep 1
					continue
				fi
				gum style --foreground "$orange" --bold "模型管理"
				gum style --foreground "$orange" "可用模型（Auth=yes）：${model_count}"
				gum style --foreground "$orange" "目前預設：${default_model}"
				echo ""
				gum style --faint "↑↓ 選擇 / Enter 測試 / Esc 退出"
				echo ""

				selected_model=$(echo "$models_list" | gum filter 					--placeholder "搜尋模型（如 cli-api/gpt-5.2）" 					--prompt "選擇模型 >" 					--indicator "➜ " 					--prompt.foreground "$orange" 					--indicator.foreground "$orange" 					--cursor-text.foreground "$orange" 					--match.foreground "$orange" 					--header "" 					--height 35)

				if [ -z "$selected_model" ] || echo "$selected_model" | head -n 1 | grep -iqE '^(error|usage|gum:)'; then
					echo "操作已取消，正在退出..."
					break
				fi
			fi

			selected_model=$(echo "$selected_model" | sed -E 's/^\([0-9]+\)[[:space:]]+//')

			echo ""
			echo "正在檢測模型:$selected_model"
			if openclaw_model_probe "$selected_model"; then
				openclaw_probe_status_line "可用"
			else
				openclaw_probe_status_line "不可用"
			fi
			echo "狀態：$OPENCLAW_PROBE_MESSAGE"
			echo "延遲：$OPENCLAW_PROBE_LATENCY"
			echo "摘要：$OPENCLAW_PROBE_REPLY"
			echo ""

			printf "是否切換到該模型？ [y/N，Esc 返回列表]:"
			IFS= read -rsn1 confirm_switch
			echo ""
			if [ "$confirm_switch" = $'' ]; then
				confirm_switch="no"
			else
				case "$confirm_switch" in
					[yY])
						IFS= read -rsn1 -t 5 _enter_key
						confirm_switch="yes"
						;;
					[nN]|"") confirm_switch="no" ;;
					*) confirm_switch="no" ;;
				esac
			fi

			if [ "$confirm_switch" != "yes" ]; then
				echo "已返回模型選擇清單。"
				sleep 1
				continue
			fi

			echo "正在切換模型為:$selected_model ..."
			if ! openclaw models set "$selected_model"; then
				echo "切換失敗：openclaw models set 回傳錯誤。"
				break_end
				return 1
			fi
			openclaw_sync_sessions_model "$selected_model"
			start_gateway

			break_end
			done
		}


		openclaw_get_config_file() {
			local user_config="${HOME}/.openclaw/openclaw.json"
			local root_config="/root/.openclaw/openclaw.json"
			if [ -f "$user_config" ]; then
				echo "$user_config"
			elif [ "$HOME" = "/root" ] && [ -f "$root_config" ]; then
				echo "$root_config"
			else
				echo "$user_config"
			fi
		}

		openclaw_get_agents_dir() {
			local user_agents="${HOME}/.openclaw/agents"
			local root_agents="/root/.openclaw/agents"
			if [ -d "$user_agents" ]; then
				echo "$user_agents"
			elif [ "$HOME" = "/root" ] && [ -d "$root_agents" ]; then
				echo "$root_agents"
			else
				echo "$user_agents"
			fi
		}

		openclaw_sync_sessions_model() {
			local model_ref="$1"
			[ -z "$model_ref" ] && return 1

			local agents_dir
			agents_dir=$(openclaw_get_agents_dir)
			[ ! -d "$agents_dir" ] && return 0

			local provider="${model_ref%%/*}"
			local model="${model_ref#*/}"
			[ "$provider" = "$model_ref" ] && { provider=""; model="$model_ref"; }

			local count=0
			local agent_dir sessions_file backup_file

			for agent_dir in "$agents_dir"/*/; do
				[ ! -d "$agent_dir" ] && continue
				sessions_file="$agent_dir/sessions/sessions.json"
				[ ! -f "$sessions_file" ] && continue

				backup_file="${sessions_file}.bak"
				cp "$sessions_file" "$backup_file" 2>/dev/null || continue

				if command -v jq >/dev/null 2>&1; then
					local tmp_json
					tmp_json=$(mktemp)
					if [ -n "$provider" ]; then
						jq --arg model "$model" --arg provider "$provider" \
							'to_entries | map(.value.modelOverride = $model | .value.providerOverride = $provider) | from_entries' \
							"$sessions_file" > "$tmp_json" 2>/dev/null && \
							mv "$tmp_json" "$sessions_file" && \
							count=$((count + 1))
					else
						jq --arg model "$model" \
							'to_entries | map(.value.modelOverride = $model | del(.value.providerOverride)) | from_entries' \
							"$sessions_file" > "$tmp_json" 2>/dev/null && \
							mv "$tmp_json" "$sessions_file" && \
							count=$((count + 1))
					fi
				fi
			done

			[ "$count" -gt 0 ] && echo "✅ 已同步$count個 agent 的會話模型為$model_ref"
			return 0
		}

		resolve_openclaw_plugin_id() {
			local raw_input="$1"
			local plugin_id="$raw_input"

			plugin_id="${plugin_id#@openclaw/}"
			if [[ "$plugin_id" == @*/* ]]; then
				plugin_id="${plugin_id##*/}"
			fi
			plugin_id="${plugin_id%%@*}"
			echo "$plugin_id"
		}

		sync_openclaw_plugin_allowlist() {
			local plugin_id="$1"
			[ -z "$plugin_id" ] && return 1

			local config_file
			config_file=$(openclaw_get_config_file)

			mkdir -p "$(dirname "$config_file")"
			if [ ! -s "$config_file" ]; then
				echo '{}' > "$config_file"
			fi

			if command -v jq >/dev/null 2>&1; then
				local tmp_json
				tmp_json=$(mktemp)
				if jq --arg pid "$plugin_id" '
					.plugins = (if (.plugins | type) == "object" then .plugins else {} end)
					| .plugins.allow = (if (.plugins.allow | type) == "array" then .plugins.allow else [] end)
					| if (.plugins.allow | index($pid)) == null then .plugins.allow += [$pid] else . end
				' "$config_file" > "$tmp_json" 2>/dev/null && mv "$tmp_json" "$config_file"; then
					echo "✅ 已同步 plugins.allow 白名單:$plugin_id"
					return 0
				fi
				rm -f "$tmp_json"
			fi

			if command -v python3 >/dev/null 2>&1; then
				if python3 - "$config_file" "$plugin_id" <<'PYTHON_EOF'
import json
import sys
from pathlib import Path

config_file = Path(sys.argv[1])
plugin_id = sys.argv[2]

try:
    data = json.loads(config_file.read_text(encoding='utf-8')) if config_file.exists() else {}
    if not isinstance(data, dict):
        data = {}
except Exception:
    data = {}

plugins = data.get('plugins')
if not isinstance(plugins, dict):
    plugins = {}

a = plugins.get('allow')
if not isinstance(a, list):
    a = []

if plugin_id not in a:
    a.append(plugin_id)

plugins['allow'] = a
data['plugins'] = plugins
config_file.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding='utf-8')
PYTHON_EOF
				then
					echo "✅ 已同步 plugins.allow 白名單:$plugin_id"
					return 0
				fi
			fi

			echo "⚠️ 已安裝插件，但同步 plugins.allow 失敗，請手動檢查:$config_file"
			return 1
		}

		sync_openclaw_plugin_denylist() {
			local plugin_id="$1"
			[ -z "$plugin_id" ] && return 1

			local config_file
			config_file=$(openclaw_get_config_file)

			mkdir -p "$(dirname "$config_file")"
			if [ ! -s "$config_file" ]; then
				echo '{}' > "$config_file"
			fi

			if command -v jq >/dev/null 2>&1; then
				local tmp_json
				tmp_json=$(mktemp)
				if jq --arg pid "$plugin_id" '
					.plugins = (if (.plugins | type) == "object" then .plugins else {} end)
					| .plugins.allow = (if (.plugins.allow | type) == "array" then .plugins.allow else [] end)
					| .plugins.allow = (.plugins.allow | map(select(. != $pid)))
				' "$config_file" > "$tmp_json" 2>/dev/null && mv "$tmp_json" "$config_file"; then
					echo "✅ 已從 plugins.allow 移除:$plugin_id"
					return 0
				fi
				rm -f "$tmp_json"
			fi

			if command -v python3 >/dev/null 2>&1; then
				if python3 - "$config_file" "$plugin_id" <<'PYTHON_EOF'
import json
import sys
from pathlib import Path

config_file = Path(sys.argv[1])
plugin_id = sys.argv[2]

try:
    data = json.loads(config_file.read_text(encoding='utf-8')) if config_file.exists() else {}
    if not isinstance(data, dict):
        data = {}
except Exception:
    data = {}

plugins = data.get('plugins')
if not isinstance(plugins, dict):
    plugins = {}

a = plugins.get('allow')
if not isinstance(a, list):
    a = []

a = [x for x in a if x != plugin_id]
plugins['allow'] = a
data['plugins'] = plugins
config_file.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding='utf-8')
PYTHON_EOF
				then
					echo "✅ 已從 plugins.allow 移除:$plugin_id"
					return 0
				fi
			fi

			echo "⚠️ plugins.allow 移除失敗，請手動檢查:$config_file"
			return 1
		}





		
		install_plugin() {
		send_stats "外掛管理"
		while true; do
			clear
			echo "========================================"
			echo "外掛程式管理 (安裝/刪除)"
			echo "========================================"
			echo "當前插件列表:"
			openclaw plugins list
			echo "--------------------------------------------------------"
			echo "推薦的常用外掛 ID (直接複製括號內的 ID 即可):"
			echo "--------------------------------------------------------"
			echo "📱 通訊頻道:"
			echo "- [feishu] # 飛書/Lark 集成"
			echo "- [telegram] # Telegram 機器人"
			echo "- [slack] # Slack 企業通訊"
			echo "  - [msteams]      	# Microsoft Teams"
			echo "- [discord] # Discord 社群管理"
			echo "- [whatsapp] # WhatsApp 自動化"
			echo ""
			echo "🧠 記憶與 AI:"
			echo "- [memory-core] # 基礎記憶 (文件檢索)"
			echo "- [memory-lancedb] # 增強記憶 (向量資料庫)"
			echo "- [copilot-proxy] # Copilot 介面轉發"
			echo ""
			echo "⚙️ 功能擴充:"
			echo "- [lobster] # 審批流 (附人工確認)"
			echo "- [voice-call] # 語音通話能力"
			echo "- [nostr] # 加密隱私聊天"
			echo "--------------------------------------------------------"

			echo "1) 安裝/啟用插件"
			echo "2) 刪除/停用插件"
			echo "0) 返回"
			read -e -p "請選擇操作：" plugin_action

			[ "$plugin_action" = "0" ] && break
			[ -z "$plugin_action" ] && continue

			read -e -p "請輸入插件 ID（空格分隔，輸入 0 退出）：" raw_input
			[ "$raw_input" = "0" ] && break
			[ -z "$raw_input" ] && continue

			local success_list=""
			local failed_list=""
			local skipped_list=""
			local changed=false
			local token

			for token in $raw_input; do
				local plugin_id
				local plugin_full
				plugin_id=$(resolve_openclaw_plugin_id "$token")
				plugin_full="$token"
				[ -z "$plugin_id" ] && continue

				if [ "$plugin_action" = "1" ]; then
					echo "🔍 正在檢查插件狀態:$plugin_id"
					local plugin_list
					plugin_list=$(openclaw plugins list 2>/dev/null)

					if echo "$plugin_list" | grep -qw "$plugin_id" && echo "$plugin_list" | grep "$plugin_id" | grep -q "disabled"; then
						echo "💡 插件 [$plugin_id] 已預先安裝，正在啟動..."
						if openclaw plugins enable "$plugin_id"; then
							sync_openclaw_plugin_allowlist "$plugin_id"
							success_list="$success_list $plugin_id"
							changed=true
						else
							failed_list="$failed_list $plugin_id"
						fi
						continue
					fi

					if [ -d "/usr/lib/node_modules/openclaw/extensions/$plugin_id" ]; then
						echo "💡 發現系統內建目錄存在該插件，嘗試直接啟用..."
						if openclaw plugins enable "$plugin_id"; then
							sync_openclaw_plugin_allowlist "$plugin_id"
							success_list="$success_list $plugin_id"
							changed=true
						else
							failed_list="$failed_list $plugin_id"
						fi
						continue
					fi

					echo "📥 本機未發現，嘗試下載安裝:$plugin_full"
					rm -rf "${HOME}/.openclaw/extensions/$plugin_id"
					[ "$HOME" != "/root" ] && rm -rf "/root/.openclaw/extensions/$plugin_id"
					if openclaw plugins install "$plugin_full"; then
						echo "✅ 下載成功，正在啟用..."
						if openclaw plugins enable "$plugin_id"; then
							sync_openclaw_plugin_allowlist "$plugin_id"
							success_list="$success_list $plugin_id"
							changed=true
						else
							failed_list="$failed_list $plugin_id"
						fi
					else
						echo "❌ 安裝失敗：$plugin_full"
						failed_list="$failed_list $plugin_id"
					fi
				else
					echo "🗑️ 正在刪除/停用插件:$plugin_id"
					openclaw plugins disable "$plugin_id" >/dev/null 2>&1
					if openclaw plugins uninstall "$plugin_id"; then
						echo "✅ 已卸載:$plugin_id"
					else
						echo "⚠️ 卸載失敗，可能為預先安裝插件，僅停用:$plugin_id"
					fi
					sync_openclaw_plugin_denylist "$plugin_id" >/dev/null 2>&1
					success_list="$success_list $plugin_id"
					changed=true
				fi
			done

			echo ""
			echo "====== 操作匯總 ======"
			echo "✅ 成功:$success_list"
			[ -n "$failed_list" ] && echo "❌ 失敗:$failed_list"
			[ -n "$skipped_list" ] && echo "⏭️ 跳過:$skipped_list"

			if [ "$changed" = true ]; then
				echo "🔄 正在重啟 OpenClaw 服務以載入變更..."
				start_gateway
			fi
			break_end
		done
	}


	install_skill() {
		send_stats "技能管理"
		while true; do
			clear
			echo "========================================"
			echo "技能管理 (安裝/刪除)"
			echo "========================================"
			echo "目前已安裝技能:"
			openclaw skills list
			echo "----------------------------------------"

			# 輸出建議的實用技能列表
			echo "建議的實用技能（可直接複製名稱輸入）："
			echo "github # 管理 GitHub Issues/PR/CI (gh CLI)"
			echo "notion # 操作 Notion 頁面、資料庫和區塊"
			echo "apple-notes # macOS 原生筆記管理 (建立/編輯/搜尋)"
			echo "apple-reminders # macOS 提醒事項管理 (待辦事項清單)"
			echo "1password # 自動化讀取和注入 1Password 金鑰"
			echo "gog # Google Workspace (Gmail/雲端盤/文件) 全能助手"
			echo "things-mac # 深度整合 Things 3 任務管理"
			echo "bluebubbles # 透過 BlueBubbles 完美收發 iMessage"
			echo "himalaya # 終端郵件管理 (IMAP/SMTP 強力工具)"
			echo "summarize # 網頁/播客/YouTube 影片內容一鍵總結"
			echo "openhue # 控制 Philips Hue 智慧燈光場景"
			echo "video-frames # 視訊抽幀與短片剪輯 (ffmpeg 驅動)"
			echo "openai-whisper # 本地音訊轉文字 (離線隱私保護)"
			echo "coding-agent # 自動運行 Claude Code/Codex 等程式設計助手"
			echo "----------------------------------------"

			echo "1) 安裝技能"
			echo "2) 刪除技能"
			echo "0) 返回"
			read -e -p "請選擇操作：" skill_action

			[ "$skill_action" = "0" ] && break
			[ -z "$skill_action" ] && continue

			read -e -p "請輸入技能名稱（空格分隔，輸入 0 退出）：" skill_input
			[ "$skill_input" = "0" ] && break
			[ -z "$skill_input" ] && continue

			local success_list=""
			local failed_list=""
			local skipped_list=""
			local changed=false
			local token

			if [ "$skill_action" = "2" ]; then
				read -e -p "二次確認：刪除僅影響使用者目錄 ~/.openclaw/workspace/skills，確認繼續？ (y/N):" confirm_del
				if [[ ! "$confirm_del" =~ ^[Yy]$ ]]; then
					echo "已取消刪除。"
					break_end
					continue
				fi
			fi

			for token in $skill_input; do
				local skill_name
				skill_name="$token"
				[ -z "$skill_name" ] && continue

				if [ "$skill_action" = "1" ]; then
					local skill_found=false
					if [ -d "${HOME}/.openclaw/workspace/skills/${skill_name}" ]; then
						echo "💡 技能 [$skill_name] 已在使用者目錄安裝。"
						skill_found=true
					elif [ -d "/usr/lib/node_modules/openclaw/skills/${skill_name}" ]; then
						echo "💡 技能 [$skill_name] 已在系統目錄安裝。"
						skill_found=true
					fi

					if [ "$skill_found" = true ]; then
						read -e -p "技能 [$skill_name] 已安裝，是否重新安裝？ (y/N):" reinstall
						if [[ ! "$reinstall" =~ ^[Yy]$ ]]; then
							skipped_list="$skipped_list $skill_name"
							continue
						fi
					fi

					echo "正在安裝技能：$skill_name ..."
					if npx clawhub install "$skill_name" --yes --no-input 2>/dev/null || npx clawhub install "$skill_name"; then
						echo "✅ 技能$skill_name安裝成功。"
						success_list="$success_list $skill_name"
						changed=true
					else
						echo "❌ 安裝失敗：$skill_name"
						failed_list="$failed_list $skill_name"
					fi
				else
					echo "🗑️ 正在刪除技能:$skill_name"
					npx clawhub uninstall "$skill_name" --yes --no-input 2>/dev/null || npx clawhub uninstall "$skill_name" >/dev/null 2>&1
					if [ -d "${HOME}/.openclaw/workspace/skills/${skill_name}" ]; then
						rm -rf "${HOME}/.openclaw/workspace/skills/${skill_name}"
						echo "✅ 已刪除使用者技能目錄:$skill_name"
						success_list="$success_list $skill_name"
						changed=true
					else
						echo "⏭️ 未發現使用者技能目錄:$skill_name"
						skipped_list="$skipped_list $skill_name"
					fi
				fi
			done

			echo ""
			echo "====== 操作匯總 ======"
			echo "✅ 成功:$success_list"
			[ -n "$failed_list" ] && echo "❌ 失敗:$failed_list"
			[ -n "$skipped_list" ] && echo "⏭️ 跳過:$skipped_list"

			if [ "$changed" = true ]; then
				echo "🔄 正在重啟 OpenClaw 服務以載入變更..."
				start_gateway
			fi
			break_end
		done
	}

openclaw_json_get_bool() {
		local expr="$1"
		local config_file
		config_file=$(openclaw_get_config_file)
		if [ ! -s "$config_file" ]; then
			echo "false"
			return
		fi
		jq -r "$expr" "$config_file" 2>/dev/null || echo "false"
	}

	openclaw_channel_has_cfg() {
		local channel="$1"
		local config_file
		config_file=$(openclaw_get_config_file)
		if [ ! -s "$config_file" ]; then
			echo "false"
			return
		fi
		jq -r --arg c "$channel" '
			(.channels[$c] // null) as $v
			| if ($v | type) != "object" then
				false
			  else
				([ $v
				   | to_entries[]
				   | select((.key == "enabled" or .key == "dmPolicy" or .key == "groupPolicy" or .key == "streaming") | not)
				   | .value
				   | select(. != null and . != "" and . != false)
				 ] | length) > 0
			  end
		' "$config_file" 2>/dev/null || echo "false"
	}

	openclaw_dir_has_files() {
		local dir="$1"
		[ -d "$dir" ] && find "$dir" -type f -print -quit 2>/dev/null | grep -q .
	}

	openclaw_plugin_local_installed() {
		local plugin="$1"
		local config_file
		config_file=$(openclaw_get_config_file)
		if [ -s "$config_file" ] && jq -e --arg p "$plugin" '.plugins.installs[$p]' "$config_file" >/dev/null 2>&1; then
			return 0
		fi

		# 相容於兩種常見目錄命名：
		# - ~/.openclaw/extensions/qqbot
		# - ~/.openclaw/extensions/openclaw-qqbot
		# 避免無腦 substring，優先精確匹配與 openclaw- 前綴相符。
		[ -d "${HOME}/.openclaw/extensions/${plugin}" ] \
			|| [ -d "${HOME}/.openclaw/extensions/openclaw-${plugin}" ] \
			|| [ -d "/usr/lib/node_modules/openclaw/extensions/${plugin}" ] \
			|| [ -d "/usr/lib/node_modules/openclaw/extensions/openclaw-${plugin}" ]
	}

	openclaw_bot_status_text() {
		local enabled="$1"
		local configured="$2"
		local connected="$3"
		local abnormal="$4"
		if [ "$abnormal" = "true" ]; then
			echo "例外"
		elif [ "$enabled" != "true" ]; then
			echo "未啟用"
		elif [ "$connected" = "true" ]; then
			echo "已連接"
		elif [ "$configured" = "true" ]; then
			echo "已配置"
		else
			echo "未配置"
		fi
	}

	openclaw_colorize_bot_status() {
		local status="$1"
		case "$status" in
			已连接) echo -e "${gl_lv}${status}${gl_bai}" ;;
			已配置) echo -e "${gl_huang}${status}${gl_bai}" ;;
			异常) echo -e "${gl_hong}${status}${gl_bai}" ;;
			*) echo "$status" ;;
		esac
	}

	openclaw_print_bot_status_line() {
		local label="$1"
		local status="$2"
		echo -e "- ${label}: $(openclaw_colorize_bot_status "$status")"
	}

	openclaw_show_bot_local_status_block() {
		local config_file
		config_file=$(openclaw_get_config_file)
		local json_ok="false"
		if [ -s "$config_file" ] && jq empty "$config_file" >/dev/null 2>&1; then
			json_ok="true"
		fi

		local tg_enabled tg_cfg tg_connected tg_abnormal tg_status
		tg_enabled=$(openclaw_json_get_bool '.channels.telegram.enabled // .plugins.entries.telegram.enabled // false')
		tg_cfg=$(openclaw_channel_has_cfg "telegram")
		tg_connected="false"
		if openclaw_dir_has_files "${HOME}/.openclaw/telegram"; then
			tg_connected="true"
		fi
		tg_abnormal="false"
		if [ "$tg_enabled" = "true" ] && [ "$json_ok" != "true" ]; then
			tg_abnormal="true"
		fi
		tg_status=$(openclaw_bot_status_text "$tg_enabled" "$tg_cfg" "$tg_connected" "$tg_abnormal")

		local feishu_enabled feishu_cfg feishu_connected feishu_abnormal feishu_status
		feishu_enabled=$(openclaw_json_get_bool '.plugins.entries.feishu.enabled // .plugins.entries["openclaw-lark"].enabled // .channels.feishu.enabled // .channels.lark.enabled // false')
		feishu_cfg=$(openclaw_channel_has_cfg "feishu")
		if [ "$feishu_cfg" != "true" ]; then
			feishu_cfg=$(openclaw_channel_has_cfg "lark")
		fi
		feishu_connected="false"
		if openclaw_dir_has_files "${HOME}/.openclaw/feishu" || openclaw_dir_has_files "${HOME}/.openclaw/lark" || openclaw_dir_has_files "${HOME}/.openclaw/openclaw-lark"; then
			feishu_connected="true"
		fi
		feishu_abnormal="false"
		if [ "$feishu_enabled" = "true" ] && ! openclaw_plugin_local_installed "feishu" && ! openclaw_plugin_local_installed "lark" && ! openclaw_plugin_local_installed "openclaw-lark"; then
			feishu_abnormal="true"
		fi
		if [ "$feishu_enabled" = "true" ] && [ "$json_ok" != "true" ]; then
			feishu_abnormal="true"
		fi
		if [ "$feishu_connected" != "true" ] && [ "$feishu_enabled" = "true" ] && [ "$feishu_cfg" = "true" ] && { openclaw_plugin_local_installed "feishu" || openclaw_plugin_local_installed "lark" || openclaw_plugin_local_installed "openclaw-lark"; }; then
			feishu_connected="true"
		fi
		feishu_status=$(openclaw_bot_status_text "$feishu_enabled" "$feishu_cfg" "$feishu_connected" "$feishu_abnormal")

		local wa_enabled wa_cfg wa_connected wa_abnormal wa_status
		wa_enabled=$(openclaw_json_get_bool '.plugins.entries.whatsapp.enabled // .channels.whatsapp.enabled // false')
		wa_cfg=$(openclaw_channel_has_cfg "whatsapp")
		wa_connected="false"
		if openclaw_dir_has_files "${HOME}/.openclaw/whatsapp"; then
			wa_connected="true"
		fi
		wa_abnormal="false"
		if [ "$wa_enabled" = "true" ] && ! openclaw_plugin_local_installed "whatsapp"; then
			wa_abnormal="true"
		fi
		if [ "$wa_enabled" = "true" ] && [ "$json_ok" != "true" ]; then
			wa_abnormal="true"
		fi
		wa_status=$(openclaw_bot_status_text "$wa_enabled" "$wa_cfg" "$wa_connected" "$wa_abnormal")

		local dc_enabled dc_cfg dc_connected dc_abnormal dc_status
		dc_enabled=$(openclaw_json_get_bool '.channels.discord.enabled // .plugins.entries.discord.enabled // false')
		dc_cfg=$(openclaw_channel_has_cfg "discord")
		dc_connected="false"
		if openclaw_dir_has_files "${HOME}/.openclaw/discord"; then
			dc_connected="true"
		fi
		dc_abnormal="false"
		if [ "$dc_enabled" = "true" ] && [ "$json_ok" != "true" ]; then
			dc_abnormal="true"
		fi
		dc_status=$(openclaw_bot_status_text "$dc_enabled" "$dc_cfg" "$dc_connected" "$dc_abnormal")

		local slack_enabled slack_cfg slack_connected slack_abnormal slack_status
		slack_enabled=$(openclaw_json_get_bool '.plugins.entries.slack.enabled // .channels.slack.enabled // false')
		slack_cfg=$(openclaw_channel_has_cfg "slack")
		slack_connected="false"
		if openclaw_dir_has_files "${HOME}/.openclaw/slack"; then
			slack_connected="true"
		fi
		slack_abnormal="false"
		if [ "$slack_enabled" = "true" ] && ! openclaw_plugin_local_installed "slack"; then
			slack_abnormal="true"
		fi
		if [ "$slack_enabled" = "true" ] && [ "$json_ok" != "true" ]; then
			slack_abnormal="true"
		fi
		slack_status=$(openclaw_bot_status_text "$slack_enabled" "$slack_cfg" "$slack_connected" "$slack_abnormal")

		local qq_enabled qq_cfg qq_connected qq_abnormal qq_status
		qq_enabled=$(openclaw_json_get_bool '.plugins.entries.qqbot.enabled // .channels.qqbot.enabled // false')
		qq_cfg=$(openclaw_channel_has_cfg "qqbot")
		qq_connected="false"
		if openclaw_dir_has_files "${HOME}/.openclaw/qqbot/sessions" || openclaw_dir_has_files "${HOME}/.openclaw/qqbot/data"; then
			qq_connected="true"
		fi
		qq_abnormal="false"
		if [ "$qq_enabled" = "true" ] && ! openclaw_plugin_local_installed "qqbot"; then
			qq_abnormal="true"
		fi
		if [ "$qq_enabled" = "true" ] && [ "$json_ok" != "true" ]; then
			qq_abnormal="true"
		fi
		qq_status=$(openclaw_bot_status_text "$qq_enabled" "$qq_cfg" "$qq_connected" "$qq_abnormal")

		local wx_enabled wx_cfg wx_connected wx_abnormal wx_status
		wx_enabled=$(openclaw_json_get_bool '.plugins.entries.weixin.enabled // .plugins.entries["openclaw-weixin"].enabled // .channels.weixin.enabled // .channels["openclaw-weixin"].enabled // false')
		wx_cfg=$(openclaw_channel_has_cfg "weixin")
		if [ "$wx_cfg" != "true" ]; then
			wx_cfg=$(openclaw_channel_has_cfg "openclaw-weixin")
		fi
		wx_connected="false"
		if openclaw_dir_has_files "${HOME}/.openclaw/weixin" || openclaw_dir_has_files "${HOME}/.openclaw/openclaw-weixin"; then
			wx_connected="true"
		fi
		wx_abnormal="false"
		if [ "$wx_enabled" = "true" ] && ! openclaw_plugin_local_installed "weixin" && ! openclaw_plugin_local_installed "openclaw-weixin"; then
			wx_abnormal="true"
		fi
		if [ "$wx_enabled" = "true" ] && [ "$json_ok" != "true" ]; then
			wx_abnormal="true"
		fi
		wx_status=$(openclaw_bot_status_text "$wx_enabled" "$wx_cfg" "$wx_connected" "$wx_abnormal")

		echo "本機狀態（僅本機配置/緩存，不做網路探測）："
		openclaw_print_bot_status_line "Telegram" "$tg_status"
		openclaw_print_bot_status_line "飛書(Lark)" "$feishu_status"
		openclaw_print_bot_status_line "WhatsApp" "$wa_status"
		openclaw_print_bot_status_line "Discord" "$dc_status"
		openclaw_print_bot_status_line "Slack" "$slack_status"
		openclaw_print_bot_status_line "QQ Bot" "$qq_status"
		openclaw_print_bot_status_line "微信 (Weixin)" "$wx_status"
	}

	change_tg_bot_code() {
		send_stats "機器人對接"
		while true; do
			clear
			echo "========================================"
			echo "機器人連線對接"
			echo "========================================"
			openclaw_show_bot_local_status_block
			echo "----------------------------------------"
			echo "1. Telegram 機器人對接"
			echo "2. 飛書 (Lark) 機器人對接"
			echo "3. WhatsApp 機器人對接"
			echo "4. QQ 機器人對接"
			echo "5. 微信機器人對接"
			echo "----------------------------------------"
			echo "0. 返回上一級選單"
			echo "----------------------------------------"
			read -e -p "請輸入你的選擇:" bot_choice

			case $bot_choice in
				1)
					read -e -p "請輸入TG機器人收到的連線碼 (例如 NYA99R2F)（輸入 0 退出）：" code
					if [ "$code" = "0" ]; then continue; fi
					if [ -z "$code" ]; then echo "錯誤：連接碼不能為空。"; sleep 1; continue; fi
					openclaw pairing approve telegram "$code"
					break_end
					;;
				2)
					npx -y @larksuite/openclaw-lark install
					openclaw config set channels.feishu.streaming true
					openclaw config set channels.feishu.requireMention true --json
					break_end
					;;
				3)
					read -e -p "請輸入WhatsApp收到的連線碼 (例如 NYA99R2F)（輸入 0 退出）：" code
					if [ "$code" = "0" ]; then continue; fi
					if [ -z "$code" ]; then echo "錯誤：連接碼不能為空。"; sleep 1; continue; fi
					openclaw pairing approve whatsapp "$code"
					break_end
					;;
				4)
					echo "QQ 官方對接位址："
					echo "https://q.qq.com/qqbot/openclaw/login.html"
					break_end
					;;
				5)
					npx -y @tencent-weixin/openclaw-weixin-cli@latest install
					break_end
					;;
				0)
					return 0
					;;
				*)
					echo "無效的選擇，請重試。"
					sleep 1
					;;
			esac
		done
	}


	openclaw_backup_root() {
		echo "${HOME}/.openclaw/backups"
	}

	openclaw_is_interactive_terminal() {
		[ -t 0 ] && [ -t 1 ]
	}

	openclaw_has_command() {
		command -v "$1" >/dev/null 2>&1
	}


	openclaw_is_safe_relpath() {
		local rel="$1"
		[ -z "$rel" ] && return 1
		[[ "$rel" = /* ]] && return 1
		[[ "$rel" == *"//"* ]] && return 1
		[[ "$rel" == *$'\n'* ]] && return 1
		[[ "$rel" == *$'\r'* ]] && return 1
		case "$rel" in
			../*|*/../*|*/..|..)
				return 1
				;;
		esac
		return 0
	}

	openclaw_restore_path_allowed() {
		local mode="$1"
		local rel="$2"
		case "$mode" in
			memory)
				case "$rel" in
					MEMORY.md|AGENTS.md|USER.md|SOUL.md|TOOLS.md|memory/*) return 0 ;;
					*) return 1 ;;
				esac
				;;
			project)
				case "$rel" in
					openclaw.json|workspace/*|extensions/*|skills/*|prompts/*|tools/*|telegram/*|feishu/*|whatsapp/*|discord/*|slack/*|qqbot/*|logs/*) return 0 ;;
					*) return 1 ;;
				esac
				;;
			*)
				return 1
				;;
		esac
	}

	openclaw_pack_backup_archive() {
		local backup_type="$1"
		local export_mode="$2"
		local payload_dir="$3"
		local output_file="$4"

		local tmp_root
		tmp_root=$(mktemp -d) || return 1
		local pack_dir="$tmp_root/package"
		mkdir -p "$pack_dir"

		cp -a "$payload_dir" "$pack_dir/payload"

		(
			cd "$pack_dir/payload" || exit 1
			find . -type f | sed 's|^\./||' | sort > "$pack_dir/manifest.files"
			: > "$pack_dir/manifest.sha256"
			while IFS= read -r f; do
				[ -z "$f" ] && continue
				sha256sum "$f" >> "$pack_dir/manifest.sha256"
			done < "$pack_dir/manifest.files"
		) || { rm -rf "$tmp_root"; return 1; }

		cat > "$pack_dir/backup.meta" <<EOF
TYPE=$backup_type
MODE=$export_mode
CREATED_AT=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
HOST=$(hostname)
EOF

		mkdir -p "$(dirname "$output_file")"
		tar -C "$pack_dir" -czf "$output_file" backup.meta manifest.files manifest.sha256 payload
		local rc=$?
		rm -rf "$tmp_root"
		return $rc
	}

	openclaw_offer_transfer_hint() {
		local file_path="$1"

		echo "可使用以下方式下載備份檔："
		echo "- 本地路徑:$file_path"
		echo "- scp 範例: scp root@你的伺服器:$file_path ./"
		echo "- 或使用 SFTP 用戶端下載"
	}

	openclaw_prepare_import_archive() {
		local expected_type="$1"
		local archive_path="$2"
		local unpack_root="$3"

		[ ! -f "$archive_path" ] && { echo "❌ 文件不存在:$archive_path"; return 1; }
		mkdir -p "$unpack_root"
		tar -xzf "$archive_path" -C "$unpack_root" || { echo "❌ 備份包解壓縮失敗"; return 1; }

		local pkg_dir="$unpack_root/package"
		if [ -f "$unpack_root/backup.meta" ]; then
			pkg_dir="$unpack_root"
		fi

		for required in backup.meta manifest.files manifest.sha256 payload; do
			[ -e "$pkg_dir/$required" ] || { echo "❌ 備份包缺少必要檔:$required"; return 1; }
		done

		local real_type
		real_type=$(grep '^TYPE=' "$pkg_dir/backup.meta" | head -n1 | cut -d'=' -f2-)
		if [ "$real_type" != "$expected_type" ]; then
			echo "❌ 備份類型不匹配，期望:$expected_type，實際: ${real_type:-未知}"
			return 1
		fi

		(
			cd "$pkg_dir/payload" || exit 1
			sha256sum -c ../manifest.sha256 >/dev/null
		) || { echo "❌ sha256 校驗失敗，拒絕還原"; return 1; }

		echo "$pkg_dir"
		return 0
	}

	openclaw_get_all_agent_workspaces() {
		local config_file
		config_file=$(openclaw_get_config_file)
		if [ -f "$config_file" ]; then
			python3 - "$config_file" <<'PY'
import json, sys, os
try:
    with open(sys.argv[1]) as f: data = json.load(f)
    agents = data.get("agents", {}).get("list", [])
    results = [{"id": "main", "ws": os.path.expanduser("~/.openclaw/workspace")}]
    for a in agents:
        aid = a.get("id"); ws = a.get("workspace")
        if aid and ws and aid != "main": results.append({"id": aid, "ws": os.path.expanduser(ws)})
    print(json.dumps(results))
except: print("[]")
PY
		else
			echo '[{"id": "main", "ws": "'"${HOME}"'/.openclaw/workspace"}]'
		fi
	}

	openclaw_memory_backup_export() {
		send_stats "OpenClaw記憶全量備份"
		local backup_root=$(openclaw_backup_root)
		local ts=$(date +%Y%m%d-%H%M%S)
		local out_file="$backup_root/openclaw-memory-full-${ts}.tar.gz"
		mkdir -p "$backup_root"
		local tmp_payload=$(mktemp -d) || return 1
		local workspaces_json=$(openclaw_get_all_agent_workspaces)
		python3 -c "import json, sys, os, shutil; 
workspaces = json.loads(sys.argv[1]); tmp_payload = sys.argv[2]
for item in workspaces:
    aid = item['id']; ws = item['ws']
    if not os.path.isdir(ws): continue
    target_dir = os.path.join(tmp_payload, 'agents', aid)
    os.makedirs(target_dir, exist_ok=True)
    for f in ['MEMORY.md', 'memory']:
        src = os.path.join(ws, f)
        if os.path.exists(src):
            if os.path.isfile(src): shutil.copy2(src, target_dir)
            else: shutil.copytree(src, os.path.join(target_dir, f), dirs_exist_ok=True)
" "$workspaces_json" "$tmp_payload"
		if ! find "$tmp_payload" -mindepth 1 -print -quit | grep -q .; then
			echo "❌ 未找到可備份的記憶文件"; rm -rf "$tmp_payload"; break_end; return 1
		fi
		if openclaw_pack_backup_archive "memory-full" "multi-agent" "$tmp_payload" "$out_file"; then
			echo "✅ 記憶全量備份完成 (含多智能體):$out_file"; openclaw_offer_transfer_hint "$out_file"
		else
			echo "❌ 記憶全量備份失敗"
		fi
		rm -rf "$tmp_payload"; break_end
	}

	openclaw_memory_backup_import() {
		send_stats "OpenClaw記憶全量還原"
		local archive_path=$(openclaw_read_import_path "還原記憶全量 (支援多智能體)")
		[ -z "$archive_path" ] && { echo "❌ 未輸入路徑"; break_end; return 1; }
		local tmp_unpack=$(mktemp -d) || return 1
		local pkg_dir=$(openclaw_prepare_import_archive "memory-full" "$archive_path" "$tmp_unpack") || { rm -rf "$tmp_unpack"; break_end; return 1; }
		local workspaces_json=$(openclaw_get_all_agent_workspaces)
		python3 -c 'import json, sys, os, shutil;
workspaces = {item["id"]: item["ws"] for item in json.loads(sys.argv[1])};
payload_dir = sys.argv[2]; agents_root = os.path.join(payload_dir, "agents")
if os.path.isdir(agents_root):
    for aid in os.listdir(agents_root):
        if aid in workspaces:
            src_agent_dir = os.path.join(agents_root, aid); dest_ws = workspaces[aid]
            os.makedirs(dest_ws, exist_ok=True)
            for f in os.listdir(src_agent_dir):
                src = os.path.join(src_agent_dir, f); dest = os.path.join(dest_ws, f)
                if os.path.isfile(src): shutil.copy2(src, dest)
                else: shutil.copytree(src, dest, dirs_exist_ok=True)
            print(f"✅ 已還原智能體記憶: {aid}")' "$workspaces_json" "$pkg_dir/payload"
		rm -rf "$tmp_unpack"; echo "✅ 記憶全量還原完成"; break_end
	}


	openclaw_project_backup_export() {
		send_stats "OpenClaw專案備份"
		local config_file
		config_file=$(openclaw_get_config_file)
		local openclaw_root
		openclaw_root=$(dirname "$config_file")
		if [ ! -d "$openclaw_root" ]; then
			echo "❌ 未找到 OpenClaw 根目錄:$openclaw_root"
			break_end
			return 1
		fi

		echo "備份模式："
		echo "1. 安全模式（默認，建議）：workspace + openclaw.json + extensions/skills/prompts/tools（如存在）"
		echo "2. 完整模式（含更多狀態，敏感風險較高）"
		read -e -p "請選擇備份模式（預設 1）:" export_mode
		[ -z "$export_mode" ] && export_mode="1"

		local mode_label="safe"
		local tmp_payload
		tmp_payload=$(mktemp -d) || return 1

		if [ "$export_mode" = "2" ]; then
			mode_label="full"
			for d in workspace extensions skills prompts tools; do
				[ -e "$openclaw_root/$d" ] && cp -a "$openclaw_root/$d" "$tmp_payload/"
			done
			[ -f "$openclaw_root/openclaw.json" ] && cp -a "$openclaw_root/openclaw.json" "$tmp_payload/"
			for d in telegram feishu whatsapp discord slack qqbot logs; do
				[ -e "$openclaw_root/$d" ] && cp -a "$openclaw_root/$d" "$tmp_payload/"
			done
		else
			[ -d "$openclaw_root/workspace" ] && cp -a "$openclaw_root/workspace" "$tmp_payload/"
			[ -f "$openclaw_root/openclaw.json" ] && cp -a "$openclaw_root/openclaw.json" "$tmp_payload/"
			for d in extensions skills prompts tools; do
				[ -e "$openclaw_root/$d" ] && cp -a "$openclaw_root/$d" "$tmp_payload/"
			done
		fi

		if ! find "$tmp_payload" -mindepth 1 -print -quit | grep -q .; then
			echo "❌ 未找到可備份的 OpenClaw 專案內容"
			rm -rf "$tmp_payload"
			break_end
			return 1
		fi

		local backup_root
		backup_root=$(openclaw_backup_root)
		mkdir -p "$backup_root"
		local out_file="$backup_root/openclaw-project-${mode_label}-$(date +%Y%m%d-%H%M%S).tar.gz"

		if openclaw_pack_backup_archive "openclaw-project" "$mode_label" "$tmp_payload" "$out_file"; then
			echo "✅ OpenClaw 專案備份完成 (${mode_label}): $out_file"
			openclaw_offer_transfer_hint "$out_file"
		else
			echo "❌ OpenClaw 專案備份失敗"
		fi

		rm -rf "$tmp_payload"
		break_end
	}

	openclaw_project_backup_import() {
		send_stats "OpenClaw專案還原"
		local config_file
		config_file=$(openclaw_get_config_file)
		local openclaw_root
		openclaw_root=$(dirname "$config_file")
		mkdir -p "$openclaw_root"

		echo "⚠️ 高風險操作：專案還原會涵蓋 OpenClaw 設定與工作區內容。"
		echo "⚠️ 還原前將執行 manifest/sha256 校驗、白名單恢復、gateway 停啟與健康檢查。"
		read -e -p "請輸入確認詞【我已知高風險並繼續還原】後繼續:" confirm_text
		if [ "$confirm_text" != "我已知高風險並持續還原" ]; then
			echo "❌ 確認詞不匹配，已取消還原"
			break_end
			return 1
		fi

		local archive_path
		archive_path=$(openclaw_read_import_path "請輸入 OpenClaw 專案備份包路徑")
		[ -z "$archive_path" ] && { echo "❌ 未輸入備份路徑"; break_end; return 1; }

		local tmp_unpack
		tmp_unpack=$(mktemp -d) || return 1
		local pkg_dir
		pkg_dir=$(openclaw_prepare_import_archive "openclaw-project" "$archive_path" "$tmp_unpack") || { rm -rf "$tmp_unpack"; break_end; return 1; }

		local invalid=0
		local valid_list
		valid_list=$(mktemp)
		while IFS= read -r rel; do
			[ -z "$rel" ] && continue
			if ! openclaw_is_safe_relpath "$rel" || ! openclaw_restore_path_allowed project "$rel"; then
				echo "❌ 偵測到非法或越權路徑:$rel"
				invalid=1
				break
			fi
			echo "$rel" >> "$valid_list"
		done < "$pkg_dir/manifest.files"

		if [ "$invalid" -ne 0 ]; then
			rm -f "$valid_list"
			rm -rf "$tmp_unpack"
			echo "❌ 還原中止：存在不安全路徑"
			break_end
			return 1
		fi


		if command -v openclaw >/dev/null 2>&1; then
			echo "⏸️ 還原前停止 OpenClaw gateway..."
			openclaw gateway stop >/dev/null 2>&1
		fi

		while IFS= read -r rel; do
			mkdir -p "$openclaw_root/$(dirname "$rel")"
			cp -a "$pkg_dir/payload/$rel" "$openclaw_root/$rel"
		done < "$valid_list"

		if command -v openclaw >/dev/null 2>&1; then
			echo "▶️ 還原後啟動 OpenClaw gateway..."
			openclaw gateway start >/dev/null 2>&1
			sleep 2
			echo "🩺 gateway 健康檢查："
			openclaw gateway status || true
		fi

		rm -f "$valid_list"
		rm -rf "$tmp_unpack"
		echo "✅ OpenClaw 專案還原完成"
		break_end
	}

	openclaw_backup_detect_type() {
		local file_name="$1"
		if [[ "$file_name" == openclaw-memory-full-*.tar.gz ]]; then
			echo "記憶備份文件"
		elif [[ "$file_name" == openclaw-project-*.tar.gz ]]; then
			echo "專案備份文件"
		else
			echo "其他備份文件"
		fi
	}

	openclaw_backup_collect_files() {
		local backup_root
		backup_root=$(openclaw_backup_root)
		mkdir -p "$backup_root"
		mapfile -t OPENCLAW_BACKUP_FILES < <(find "$backup_root" -maxdepth 1 -type f -name '*.tar.gz' -printf '%f\n' | sort -r)
	}


	openclaw_backup_render_file_list() {
		local backup_root i file_name file_path file_type file_size file_time
		local has_memory=0 has_project=0 has_other=0
		backup_root=$(openclaw_backup_root)
		openclaw_backup_collect_files

		echo "備份目錄:$backup_root"
		if [ ${#OPENCLAW_BACKUP_FILES[@]} -eq 0 ]; then
			echo "暫無備份文件"
			return 0
		fi

		for i in "${!OPENCLAW_BACKUP_FILES[@]}"; do
			file_type=$(openclaw_backup_detect_type "${OPENCLAW_BACKUP_FILES[$i]}")
			case "$file_type" in
				"記憶備份文件") has_memory=1 ;;
				"專案備份文件") has_project=1 ;;
				"其他備份文件") has_other=1 ;;
			esac
		done

		if [ "$has_memory" -eq 1 ]; then
			echo "記憶備份文件"
			for i in "${!OPENCLAW_BACKUP_FILES[@]}"; do
				file_name="${OPENCLAW_BACKUP_FILES[$i]}"
				file_type=$(openclaw_backup_detect_type "$file_name")
				[ "$file_type" != "記憶備份文件" ] && continue
				file_path="$backup_root/$file_name"
				file_size=$(ls -lh "$file_path" | awk '{print $5}')
				file_time=$(date -d "$(stat -c %y "$file_path")" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || stat -c %y "$file_path" | awk '{print $1" "$2}')
				printf "%s | %s | %s\n" "$file_name" "$file_size" "$file_time"
			done
		fi

		if [ "$has_project" -eq 1 ]; then
			echo "專案備份文件"
			for i in "${!OPENCLAW_BACKUP_FILES[@]}"; do
				file_name="${OPENCLAW_BACKUP_FILES[$i]}"
				file_type=$(openclaw_backup_detect_type "$file_name")
				[ "$file_type" != "專案備份文件" ] && continue
				file_path="$backup_root/$file_name"
				file_size=$(ls -lh "$file_path" | awk '{print $5}')
				file_time=$(date -d "$(stat -c %y "$file_path")" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || stat -c %y "$file_path" | awk '{print $1" "$2}')
				printf "%s | %s | %s\n" "$file_name" "$file_size" "$file_time"
			done
		fi

		if [ "$has_other" -eq 1 ]; then
			echo "其他備份文件"
			for i in "${!OPENCLAW_BACKUP_FILES[@]}"; do
				file_name="${OPENCLAW_BACKUP_FILES[$i]}"
				file_type=$(openclaw_backup_detect_type "$file_name")
				[ "$file_type" != "其他備份文件" ] && continue
				file_path="$backup_root/$file_name"
				file_size=$(ls -lh "$file_path" | awk '{print $5}')
				file_time=$(date -d "$(stat -c %y "$file_path")" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || stat -c %y "$file_path" | awk '{print $1" "$2}')
				printf "%s | %s | %s\n" "$file_name" "$file_size" "$file_time"
			done
		fi
	}

	openclaw_backup_file_exists_in_list() {
		local target_file="$1"
		local item
		for item in "${OPENCLAW_BACKUP_FILES[@]}"; do
			[ "$item" = "$target_file" ] && return 0
		done
		return 1
	}

	openclaw_backup_delete_file() {
		send_stats "OpenClaw刪除備份文件"
		local backup_root backup_root_real user_input target_file target_path target_type
		backup_root=$(openclaw_backup_root)

		openclaw_backup_render_file_list
		if [ ${#OPENCLAW_BACKUP_FILES[@]} -eq 0 ]; then
			break_end
			return 0
		fi

		read -e -p "請輸入要刪除的檔案名稱或完整路徑（0 取消）:" user_input
		if [ "$user_input" = "0" ]; then
			echo "已取消刪除。"
			break_end
			return 0
		fi
		if [ -z "$user_input" ]; then
			echo "❌ 輸入不能為空。"
			break_end
			return 1
		fi

		backup_root_real=$(realpath -m "$backup_root")
		if [[ "$user_input" == /* ]]; then
			target_path=$(realpath -m "$user_input")
			case "$target_path" in
				"$backup_root_real"/*) ;;
				*)
					echo "❌ 路徑越界：僅允許刪除備份根目錄內的檔案。"
					break_end
					return 1
					;;
			esac
			target_file=$(basename "$target_path")
		else
			target_file=$(basename -- "$user_input")
			target_path="$backup_root/$target_file"
		fi

		if [ ! -f "$target_path" ]; then
			echo "❌ 目標檔案不存在:$target_path"
			break_end
			return 1
		fi

		if ! openclaw_backup_file_exists_in_list "$target_file"; then
			echo "❌ 目標檔案不在目前備份清單中。"
			break_end
			return 1
		fi

		target_type=$(openclaw_backup_detect_type "$target_file")

		echo "即將刪除: [$target_type] $target_path"
		read -e -p "第一次確認：輸入 yes 確認繼續:" confirm_step1
		if [ "$confirm_step1" != "yes" ]; then
			echo "已取消刪除。"
			break_end
			return 0
		fi
		read -e -p "二次確認：輸入 DELETE 執行刪除:" confirm_step2
		if [ "$confirm_step2" != "DELETE" ]; then
			echo "已取消刪除。"
			break_end
			return 0
		fi

		if rm -f -- "$target_path"; then
			echo "✅ 刪除成功:$target_file"
		else
			echo "❌ 刪除失敗:$target_file"
		fi
		break_end
	}

	openclaw_backup_list_files() {
		openclaw_backup_render_file_list
		break_end
	}

	openclaw_memory_config_file() {
		local user_config="${HOME}/.openclaw/openclaw.json"
		local root_config="/root/.openclaw/openclaw.json"
		if [ -f "$user_config" ]; then
			echo "$user_config"
		elif [ "$HOME" = "/root" ] && [ -f "$root_config" ]; then
			echo "$root_config"
		else
			echo "$user_config"
		fi
	}

	openclaw_memory_config_get() {
		local key="$1"
		local default_value="${2:-}"
		local value
		value=$(openclaw config get "$key" 2>/dev/null | head -n 1 | sed -e 's/^"//' -e 's/"$//')
		if [ -z "$value" ] || [ "$value" = "null" ] || [ "$value" = "undefined" ]; then
			echo "$default_value"
			return 0
		fi
		echo "$value"
	}

	openclaw_memory_config_set() {
		local key="$1"
		shift
		openclaw config set "$key" "$@" >/dev/null 2>&1
	}

	openclaw_memory_config_unset() {
		local key="$1"
		openclaw config unset "$key" >/dev/null 2>&1
	}

	openclaw_memory_cleanup_legacy_keys() {
		openclaw_memory_config_unset "memory.local"
	}

	openclaw_memory_list_agents() {
		if command -v openclaw >/dev/null 2>&1; then
			local agents_json
			agents_json=$(openclaw agents list --json 2>/dev/null || true)
			if [ -n "$agents_json" ]; then
				python3 - "$agents_json" <<'PY'
import json, os, sys
raw = sys.argv[1]
try:
    data = json.loads(raw)
except Exception:
    data = None
seen = set()
results = []
if isinstance(data, list):
    for item in data:
        if not isinstance(item, dict):
            continue
        aid = item.get('id')
        if not aid or aid in seen:
            continue
        ws = item.get('workspace') or ("~/.openclaw/workspace" if aid == 'main' else f"~/.openclaw/workspace-{aid}")
        results.append((aid, os.path.expanduser(ws)))
        seen.add(aid)
if results:
    for aid, ws in results:
        print(f"{aid}\t{ws}")
    raise SystemExit(0)
raise SystemExit(1)
PY
				[ $? -eq 0 ] && return 0
			fi
		fi
		local config_path
		config_path=$(openclaw_memory_config_file)
		python3 - "$config_path" <<'PY'
import json, os, sys
config_path = sys.argv[1]
results = [("main", os.path.expanduser("~/.openclaw/workspace"))]
seen = {"main"}
try:
    if os.path.exists(config_path):
        with open(config_path, encoding='utf-8') as f:
            data = json.load(f)
        agents = data.get('agents', {}).get('list', [])
        if isinstance(agents, list):
            for item in agents:
                if not isinstance(item, dict):
                    continue
                aid = item.get('id')
                ws = item.get('workspace')
                if not aid or aid in seen:
                    continue
                if not ws:
                    ws = f"~/.openclaw/workspace-{aid}"
                results.append((aid, os.path.expanduser(ws)))
                seen.add(aid)
except Exception:
    pass
for aid, ws in results:
    print(f"{aid}\t{ws}")
PY
	}

	openclaw_memory_status_value() {
		local key="$1"
		local agent_id="${2:-}"
		if [ -n "$agent_id" ]; then
			openclaw memory status --agent "$agent_id" 2>/dev/null | awk -F': ' -v k="$key" '$1==k {print $2; exit}'
		else
			openclaw memory status 2>/dev/null | awk -F': ' -v k="$key" '$1==k {print $2; exit}'
		fi
	}

	openclaw_memory_expand_path() {
		local raw_path="$1"
		if [ -z "$raw_path" ]; then
			echo ""
			return 0
		fi
		raw_path=$(echo "$raw_path" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
		if [[ "$raw_path" == ~* ]]; then
			echo "${raw_path/#\~/$HOME}"
		else
			echo "$raw_path"
		fi
	}

	openclaw_memory_rebuild_index_single() {
		local agent_id="${1:-main}"
		local store_raw store_file ts backup_file
		store_raw=$(openclaw_memory_status_value "Store" "$agent_id")
		store_file=$(openclaw_memory_expand_path "$store_raw")
		if [ -z "$store_file" ] || [ ! -f "$store_file" ]; then
			echo "⚠️ [$agent_id] 未找到索引庫文件，可能為空或不存在。"
			echo "Store 原始值: ${store_raw:-<空>}"
			echo "仍將執行重建索引。"
		else
			ts=$(date +%Y%m%d_%H%M%S)
			backup_file="${store_file}.bak.${ts}"
			if mv "$store_file" "$backup_file"; then
				echo "✅ [$agent_id] 已備份索引:$backup_file"
			else
				echo "⚠️ [$agent_id] 索引備份失敗，繼續重建。"
			fi
		fi
		openclaw memory index --agent "$agent_id" --force
	}

	openclaw_memory_rebuild_index_safe() {
		local agent_id="${1:-main}"
		openclaw_memory_rebuild_index_single "$agent_id"
		openclaw gateway restart
		echo "✅ 索引已重建並自動重新啟動網關"
		echo ""
		openclaw_memory_render_status
	}

	openclaw_memory_rebuild_index_all() {
		local count=0
		local agent_lines agent_id workspace
		agent_lines=$(openclaw_memory_list_agents)
		while IFS=$'\t' read -r agent_id workspace; do
			[ -z "$agent_id" ] && continue
			openclaw_memory_rebuild_index_single "$agent_id"
			count=$((count+1))
		done <<EOF
$agent_lines
EOF
		openclaw gateway restart
		echo "✅ 索引已重建並自動重新啟動網關"
		echo "✅ 已為${count}個智能體重建索引"
		echo ""
		openclaw_memory_render_status
	}

	openclaw_memory_prepare_workspace() {
		local agent_id="${1:-main}"
		local workspace memory_dir
		workspace=$(openclaw_memory_status_value "Workspace" "$agent_id")
		if [ -z "$workspace" ]; then
			workspace="$HOME/.openclaw/workspace"
			[ "$agent_id" != "main" ] && workspace="$HOME/.openclaw/workspace-$agent_id"
		fi
		memory_dir="$workspace/memory"
		if [ ! -d "$memory_dir" ]; then
			echo "🔧 [$agent_id] 記憶目錄不存在，已自動建立:$memory_dir"
			mkdir -p "$memory_dir"
		fi
		return 0
	}

	openclaw_memory_prepare_workspace_all() {
		local count=0
		local agent_lines agent_id workspace
		agent_lines=$(openclaw_memory_list_agents)
		echo "檢查並準備 $(printf '%s\n'"$agent_lines"| sed '/^\s*$/d' | wc -l | tr -d ' ') 個智能體工作區"
		while IFS=$'\t' read -r agent_id workspace; do
			[ -z "$agent_id" ] && continue
			openclaw_memory_prepare_workspace "$agent_id"
			count=$((count+1))
		done <<EOF
$agent_lines
EOF
		return 0
	}

	openclaw_memory_render_status() {
		local agent_lines agent_id workspace status_output status_lines first="true"
		agent_lines=$(openclaw_memory_list_agents)
		while IFS=$'\t' read -r agent_id workspace; do
			[ -z "$agent_id" ] && continue
			status_output=$(openclaw memory status --agent "$agent_id" 2>/dev/null)
			[ "$first" = "true" ] || echo ""
			first="false"
			echo "Agent: $agent_id"
			if [ $? -ne 0 ] || [ -z "$status_output" ]; then
				echo "獲取狀態失敗"
				continue
			fi
			status_lines=$(echo "$status_output" | grep -E "^(Provider|Vector|Indexed|Workspace|Store)" | head -n 5 | sed -e 's/^Provider: /底層方案: /' -e 's/^Vector: /向量庫狀態: /' -e 's/^Indexed: /已收錄文件: /' -e 's/^Workspace: /工作區: /' -e 's/^Store: /索引庫: /')
			if [ -z "$status_lines" ]; then
				echo "未安裝/未啟動"
			else
				echo "$status_lines"
			fi
		done <<EOF
$agent_lines
EOF
	}

	openclaw_memory_get_backend() {
		local backend
		backend=$(openclaw_memory_config_get "memory.backend")
		if [ "$backend" = "local" ]; then
			echo "builtin"
		else
			echo "$backend"
		fi
	}

	openclaw_memory_get_local_model_path() {
		openclaw_memory_config_get "agents.defaults.memorySearch.local.modelPath"
	}

	openclaw_memory_local_model_status() {
		local model_path="$1"
		if [ -z "$model_path" ]; then
			echo "missing"
			return
		fi
		if [[ "$model_path" == hf:* ]]; then
			echo "hf"
			return
		fi
		if [ -f "$model_path" ]; then
			echo "ok"
		else
			echo "missing"
		fi
	}

	openclaw_memory_qmd_available() {
		if command -v qmd >/dev/null 2>&1; then
			echo "true"
			return
		fi
		local backend
		backend=$(openclaw_memory_config_get "memory.backend")
		if [ "$backend" = "qmd" ]; then
			echo "true"
			return
		fi
		echo "false"
	}

	openclaw_memory_probe_url() {
		local url="$1"
		if ! command -v curl >/dev/null 2>&1; then
			echo "unknown"
			return
		fi
		if [ -z "$url" ]; then
			echo "unknown"
			return
		fi
		if curl -I -m 2 -s "$url" >/dev/null 2>&1; then
			echo "ok"
		else
			echo "fail"
		fi
	}

	openclaw_memory_recommend() {
		local qmd_ok model_path model_status hf_ok mirror_ok
		qmd_ok=$(openclaw_memory_qmd_available)
		model_path=$(openclaw_memory_get_local_model_path)
		model_status=$(openclaw_memory_local_model_status "$model_path")
		hf_ok=$(openclaw_memory_probe_url "https://huggingface.co")
		mirror_ok=$(openclaw_memory_probe_url "https://hf-mirror.com")

		OPENCLAW_MEMORY_RECOMMEND_REASON=()
		if [ "$qmd_ok" = "true" ]; then
			OPENCLAW_MEMORY_RECOMMEND_REASON+=("QMD 可用")
		else
			OPENCLAW_MEMORY_RECOMMEND_REASON+=("未檢測到 QMD")
		fi
		if [ -n "$model_path" ]; then
			OPENCLAW_MEMORY_RECOMMEND_REASON+=("本地模型路徑:$model_path")
		else
			OPENCLAW_MEMORY_RECOMMEND_REASON+=("未配置本地模型路徑")
		fi
		case "$model_status" in
			ok) OPENCLAW_MEMORY_RECOMMEND_REASON+=("本地模型檔案存在") ;;
			hf) OPENCLAW_MEMORY_RECOMMEND_REASON+=("模型來自 HF 下載來源（國內可能慢/失敗）") ;;
			*) OPENCLAW_MEMORY_RECOMMEND_REASON+=("本地模型檔案不存在或不可用") ;;
		esac
		if [ "$hf_ok" = "ok" ]; then
			OPENCLAW_MEMORY_RECOMMEND_REASON+=("huggingface.co 可訪問")
		elif [ "$mirror_ok" = "ok" ]; then
			OPENCLAW_MEMORY_RECOMMEND_REASON+=("hf-mirror.com 可訪問")
		else
			OPENCLAW_MEMORY_RECOMMEND_REASON+=("huggingface.co / hf-mirror.com 可能不可達（疑似國內/受限網路）")
		fi

		if [ "$qmd_ok" = "true" ]; then
			if [ "$model_status" = "ok" ]; then
				OPENCLAW_MEMORY_RECOMMEND="local"
			elif [ "$model_status" = "hf" ] && { [ "$hf_ok" = "ok" ] || [ "$mirror_ok" = "ok" ]; }; then
				OPENCLAW_MEMORY_RECOMMEND="local"
			elif [ "$model_status" = "hf" ] && [ "$hf_ok" = "fail" ] && [ "$mirror_ok" = "fail" ]; then
				OPENCLAW_MEMORY_RECOMMEND="qmd"
			else
				OPENCLAW_MEMORY_RECOMMEND="qmd"
			fi
		else
			if [ "$model_status" = "ok" ]; then
				OPENCLAW_MEMORY_RECOMMEND="local"
			else
				OPENCLAW_MEMORY_RECOMMEND="qmd"
			fi
		fi
	}


	openclaw_memory_detect_region() {
		OPENCLAW_MEMORY_COUNTRY="unknown"
		OPENCLAW_MEMORY_USE_MIRROR="false"
		if command -v curl >/dev/null 2>&1; then
			OPENCLAW_MEMORY_COUNTRY=$(curl -s -m 2 ipinfo.io/country | tr -d '
' | tr -d '
')
		fi
		case "$OPENCLAW_MEMORY_COUNTRY" in
			CN|HK)
				OPENCLAW_MEMORY_USE_MIRROR="true"
				;;
		esac
	}

	openclaw_memory_select_sources() {
		local hf_ok mirror_ok
		hf_ok=$(openclaw_memory_probe_url "https://huggingface.co")
		mirror_ok=$(openclaw_memory_probe_url "https://hf-mirror.com")
		OPENCLAW_MEMORY_HF_OK="$hf_ok"
		OPENCLAW_MEMORY_MIRROR_OK="$mirror_ok"
		if [ "$OPENCLAW_MEMORY_USE_MIRROR" = "true" ]; then
			if [ "$mirror_ok" = "ok" ]; then
				OPENCLAW_MEMORY_HF_BASE="https://hf-mirror.com"
			elif [ "$hf_ok" = "ok" ]; then
				OPENCLAW_MEMORY_HF_BASE="https://huggingface.co"
			else
				OPENCLAW_MEMORY_HF_BASE="https://hf-mirror.com"
			fi
			OPENCLAW_MEMORY_GH_PROXY="https://gh.kejilion.pro/"
		else
			if [ "$hf_ok" = "ok" ]; then
				OPENCLAW_MEMORY_HF_BASE="https://huggingface.co"
			elif [ "$mirror_ok" = "ok" ]; then
				OPENCLAW_MEMORY_HF_BASE="https://hf-mirror.com"
			else
				OPENCLAW_MEMORY_HF_BASE="https://huggingface.co"
			fi
			OPENCLAW_MEMORY_GH_PROXY="https://"
		fi
	}

	openclaw_memory_download_file() {
		local url="$1"
		local dest="$2"
		mkdir -p "$(dirname "$dest")"
		if command -v curl >/dev/null 2>&1; then
			curl -L --fail --retry 2 -o "$dest" "$url"
			return $?
		fi
		if command -v wget >/dev/null 2>&1; then
			wget -O "$dest" "$url"
			return $?
		fi
		echo "❌ 未偵測到 curl 或 wget，無法下載。"
		return 1
	}

	openclaw_memory_check_sqlite() {
		if ! command -v sqlite3 >/dev/null 2>&1; then
			echo "⚠️ 未偵測到 sqlite3，QMD 可能無法正常運作。"
			return 1
		fi
		local ver
		ver=$(sqlite3 --version 2>/dev/null | awk '{print $1}')
		echo "✅ sqlite3 可用: ${ver:-unknown}"
		echo "ℹ️ sqlite 擴充支援無法可靠檢測，將持續。"
		return 0
	}

	openclaw_memory_ensure_bun() {
		if [ -x "$HOME/.bun/bin/bun" ]; then
			export PATH="$HOME/.bun/bin:$PATH"
		fi
		if command -v bun >/dev/null 2>&1; then
			echo "✅ bun 已存在"
			return 0
		fi
		echo "⬇️ 安裝 bun..."
		if command -v curl >/dev/null 2>&1; then
			curl -fsSL https://bun.sh/install | bash
		elif command -v wget >/dev/null 2>&1; then
			wget -qO- https://bun.sh/install | bash
		else
			echo "❌ 未偵測到 curl 或 wget，無法安裝 bun。"
			return 1
		fi
		if [ -d "$HOME/.bun/bin" ]; then
			export PATH="$HOME/.bun/bin:$PATH"
		fi
		if command -v bun >/dev/null 2>&1; then
			echo "✅ bun 安裝完成"
			return 0
		fi
		echo "❌ bun 安裝失敗"
		return 1
	}

	openclaw_memory_ensure_qmd() {
		local qmd_path
		qmd_path=$(command -v qmd 2>/dev/null || true)
		if [ -n "$qmd_path" ]; then
			if qmd --version >/dev/null 2>&1; then
				echo "✅ qmd 已存在且可用:$qmd_path"
				OPENCLAW_MEMORY_QMD_PATH="$qmd_path"
				return 0
			else
				echo "⚠️ qmd 指令存在但模組損壞，重新安裝..."
			fi
		fi
		echo "⬇️ 透過 npm 安裝 qmd: @tobilu/qmd"
		npm install -g @tobilu/qmd
		qmd_path=$(command -v qmd 2>/dev/null || true)
		if [ -z "$qmd_path" ]; then
			echo "❌ qmd 安裝失敗"
			return 1
		fi
		if ! qmd --version >/dev/null 2>&1; then
			echo "❌ qmd 安裝後仍無法運作"
			return 1
		fi
		OPENCLAW_MEMORY_QMD_PATH="$qmd_path"
		echo "✅ qmd 安裝完成:$qmd_path"
		return 0
	}

	openclaw_memory_render_auto_summary() {
		echo "---------------------------------------"
		echo "✅ 環境就緒"
		echo "方案: ${OPENCLAW_MEMORY_AUTO_SCHEME:-unknown}"
		if [ "$OPENCLAW_MEMORY_CONFIG_ONLY" = "true" ]; then
			echo "模式: 僅寫入配置（未安裝/未下載）"
		fi
		if [ "$OPENCLAW_MEMORY_PREHEAT" = "true" ]; then
			echo "索引: 已執行"
		else
			echo "索引: 已跳過"
		fi
		if [ "$OPENCLAW_MEMORY_RESTARTED" = "true" ]; then
			echo "重啟: 已執行"
		else
			echo "重啟: 已跳過"
		fi
		if [ -n "$OPENCLAW_MEMORY_QMD_PATH" ]; then
			echo "qmd: $OPENCLAW_MEMORY_QMD_PATH"
		fi
		if [ -n "$OPENCLAW_MEMORY_MODEL_PATH" ]; then
			echo "模型:$OPENCLAW_MEMORY_MODEL_PATH"
		fi
		if [ -n "$OPENCLAW_MEMORY_COUNTRY" ]; then
			echo "地區:$OPENCLAW_MEMORY_COUNTRY"
		fi
		if [ -n "$OPENCLAW_MEMORY_HF_BASE" ]; then
			echo "下載來源:$OPENCLAW_MEMORY_HF_BASE"
		fi
		echo "最終狀態:"
		openclaw_memory_render_status
		echo "---------------------------------------"
	}

	openclaw_memory_auto_confirm() {
		local scheme_label="$1"
		OPENCLAW_MEMORY_PREHEAT="true"
		OPENCLAW_MEMORY_RESTARTED="false"
		OPENCLAW_MEMORY_CONFIG_ONLY="false"
		echo "即將執行自動部署（詳細模式）"
		echo "目標方案:$scheme_label"
		echo "地區: ${OPENCLAW_MEMORY_COUNTRY:-unknown}"
		echo "鏡像來源探測: huggingface.co=${OPENCLAW_MEMORY_HF_OK:-unknown} hf-mirror.com=${OPENCLAW_MEMORY_MIRROR_OK:-unknown}"
		echo "下載來源: ${OPENCLAW_MEMORY_HF_BASE:-unknown}"
		if [ -n "$OPENCLAW_MEMORY_EXPECT_PATH" ]; then
			echo "預計下載路徑:$OPENCLAW_MEMORY_EXPECT_PATH"
		fi
		if [ -n "$OPENCLAW_MEMORY_EXPECT_SIZE" ]; then
			echo "可能流量/磁碟佔用:$OPENCLAW_MEMORY_EXPECT_SIZE"
		else
			echo "可能流量/磁碟佔用: 視實際情況而定"
		fi
		echo "確認後將自動安裝/下載、寫入設定、建置索引並重新啟動網關"
		echo "進階選項: 輸入 config 僅寫入設定（不安裝不下載、不索引、不重新啟動）"
		read -e -p "輸入 yes 確認繼續（預設 N）:" confirm_step
		case "$confirm_step" in
			yes|YES)
				OPENCLAW_MEMORY_PREHEAT="true"
				;;
			config|CONFIG)
				OPENCLAW_MEMORY_CONFIG_ONLY="true"
				OPENCLAW_MEMORY_PREHEAT="false"
				;;
			*)
				echo "已取消自動部署。"
				return 1
				;;
		esac
		if [ "$OPENCLAW_MEMORY_CONFIG_ONLY" = "true" ]; then
			echo "⚠️ 已选择仅写配置，不安装不下载"
		else
			echo "✅ 將自動建立索引並重新啟動網關"
		fi
		return 0
	}

	openclaw_memory_auto_setup_qmd() {
		echo "🔍 檢測 QMD 環境"
		openclaw_memory_cleanup_legacy_keys
		openclaw_memory_check_sqlite || true
		if [ "$OPENCLAW_MEMORY_CONFIG_ONLY" = "true" ]; then
			if command -v qmd >/dev/null 2>&1; then
				OPENCLAW_MEMORY_QMD_PATH=$(command -v qmd)
			else
				OPENCLAW_MEMORY_QMD_PATH="qmd"
			fi
		else
			openclaw_memory_ensure_qmd || return 1
		fi
		local backend
		backend=$(openclaw_memory_get_backend)
		if [ "$backend" = "qmd" ]; then
			echo "✅ memory.backend 已是 qmd"
		else
			openclaw_memory_config_set "memory.backend" "qmd"
			echo "✅ 已設定 memory.backend=qmd"
		fi
		local qmd_cmd
		qmd_cmd=$(openclaw_memory_config_get "memory.qmd.command")
		if [ -z "$qmd_cmd" ] || [[ "$qmd_cmd" != /* ]] || [ "$qmd_cmd" != "$OPENCLAW_MEMORY_QMD_PATH" ]; then
			openclaw_memory_config_set "memory.qmd.command" "$OPENCLAW_MEMORY_QMD_PATH"
			echo "✅ 已寫入 memory.qmd.command:$OPENCLAW_MEMORY_QMD_PATH"
		else
			echo "✅ memory.qmd.command 已正確"
		fi
		if [ "$OPENCLAW_MEMORY_PREHEAT" = "true" ]; then
			echo "🔥 預熱索引（可能下載模型）"
			openclaw_memory_prepare_workspace_all
			local preh_agent_lines preh_agent_id preh_workspace
			preh_agent_lines=$(openclaw_memory_list_agents)
			while IFS=$'\t' read -r preh_agent_id preh_workspace; do
				[ -z "$preh_agent_id" ] && continue
				openclaw memory index --agent "$preh_agent_id" --force
			done <<EOF
$preh_agent_lines
EOF
		else
			echo "⏭️ 已跳過預熱"
		fi
		echo "✅ QMD 自動部署完成"
	}

	openclaw_memory_auto_setup_local() {
		echo "🔍 偵測 Local 環境"
		openclaw_memory_cleanup_legacy_keys
		local backend provider
		backend=$(openclaw_memory_get_backend)
		if [ "$backend" = "builtin" ] || [ "$backend" = "local" ]; then
			echo "✅ memory.backend 已是 builtin"
		else
			openclaw_memory_config_set "memory.backend" "builtin"
			echo "✅ 已設定 memory.backend=builtin"
		fi
		provider=$(openclaw_memory_config_get "agents.defaults.memorySearch.provider")
		if [ "$provider" = "local" ]; then
			echo "✅ memorySearch.provider 已是 local"
		else
			openclaw_memory_config_set "agents.defaults.memorySearch.provider" "local"
			echo "✅ 已設定 agents.defaults.memorySearch.provider=local"
		fi

		local model_path model_status
		model_path=$(openclaw_memory_get_local_model_path)
		model_path=$(openclaw_memory_expand_path "$model_path")
		model_status=$(openclaw_memory_local_model_status "$model_path")
		if [ "$model_status" = "ok" ]; then
			echo "✅ 模型檔已存在:$model_path"
			OPENCLAW_MEMORY_MODEL_PATH="$model_path"
		else
			local model_name="embeddinggemma-300M-Q8_0.gguf"
			local model_dir="$HOME/.openclaw/models/embedding"
			local model_dest="$model_dir/$model_name"
			local model_url="${OPENCLAW_MEMORY_HF_BASE}/ggml-org/embeddinggemma-300M-GGUF/resolve/main/$model_name"
			if [ "$OPENCLAW_MEMORY_CONFIG_ONLY" = "true" ]; then
				echo "ℹ️ 僅寫入設定模式：跳過模型下載"
				OPENCLAW_MEMORY_MODEL_PATH="$model_dest"
			else
				if [ -f "$model_dest" ]; then
					echo "✅ 已發現預設模型檔:$model_dest"
				else
					echo "⬇️ 下載模型:$model_url"
					openclaw_memory_download_file "$model_url" "$model_dest" || return 1
					echo "✅ 模型已下載:$model_dest"
				fi
				OPENCLAW_MEMORY_MODEL_PATH="$model_dest"
			fi
			openclaw_memory_config_set "agents.defaults.memorySearch.local.modelPath" "$model_dest"
			echo "✅ 已寫入模型路徑"
		fi
		if [ "$OPENCLAW_MEMORY_PREHEAT" = "true" ]; then
			echo "🔥 預熱索引（可能下載模型）"
			openclaw_memory_prepare_workspace_all
			local preh_agent_lines preh_agent_id preh_workspace
			preh_agent_lines=$(openclaw_memory_list_agents)
			while IFS=$'\t' read -r preh_agent_id preh_workspace; do
				[ -z "$preh_agent_id" ] && continue
				openclaw memory index --agent "$preh_agent_id" --force
			done <<EOF
$preh_agent_lines
EOF
		else
			echo "⏭️ 已跳過預熱"
		fi
		echo "✅ Local 自動部署完成"
	}

	openclaw_memory_auto_setup_run() {
		local scheme="$1"
		local scheme_label
		OPENCLAW_MEMORY_QMD_PATH=""
		OPENCLAW_MEMORY_MODEL_PATH=""
		OPENCLAW_MEMORY_EXPECT_PATH=""
		OPENCLAW_MEMORY_EXPECT_SIZE=""
		openclaw_memory_detect_region
		openclaw_memory_select_sources
		if [ "$scheme" = "auto" ]; then
			openclaw_memory_recommend
			scheme="$OPENCLAW_MEMORY_RECOMMEND"
		fi
		case "$scheme" in
			qmd)
				scheme_label="QMD"
				OPENCLAW_MEMORY_EXPECT_PATH="$HOME/.bun (qmd 安裝目錄)"
				OPENCLAW_MEMORY_EXPECT_SIZE="約 20-50MB"
				;;
			local)
				scheme_label="Local"
				OPENCLAW_MEMORY_EXPECT_PATH="$HOME/.openclaw/models/embedding/embeddinggemma-300M-Q8_0.gguf"
				OPENCLAW_MEMORY_EXPECT_SIZE="約 350-600MB"
				;;
			*)
				echo "❌ 未知方案:$scheme"
				return 1
				;;
		esac
		OPENCLAW_MEMORY_AUTO_SCHEME="$scheme_label"
		openclaw_memory_auto_confirm "$scheme_label" || return 0
		case "$scheme" in
			qmd) openclaw_memory_auto_setup_qmd || return 1 ;;
			local) openclaw_memory_auto_setup_local || return 1 ;;
			*) return 1 ;;
		esac
		if [ "$OPENCLAW_MEMORY_CONFIG_ONLY" = "true" ]; then
			OPENCLAW_MEMORY_RESTARTED="false"
			openclaw_memory_render_auto_summary
			return 0
		fi
		echo "♻️ 重啟 OpenClaw 網關"
		if declare -F start_gateway >/dev/null 2>&1; then
			start_gateway
		else
			openclaw gateway restart
		fi
		OPENCLAW_MEMORY_RESTARTED="true"
		openclaw_memory_render_auto_summary
		return 0
	}

	openclaw_memory_auto_setup_menu() {
		while true; do
			clear
			echo "======================================="
			echo "記憶方案自動部署"
			echo "======================================="
			echo "1. QMD"
			echo "2. Local"
			echo "3. Auto（自動選擇）"
			echo "0. 返回上一級"
			echo "---------------------------------------"
			read -e -p "請輸入你的選擇:" auto_choice
			case "$auto_choice" in
				1)
					openclaw_memory_auto_setup_run "qmd"
					break_end
					;;
				2)
					openclaw_memory_auto_setup_run "local"
					break_end
					;;
				3)
					openclaw_memory_auto_setup_run "auto"
					break_end
					;;
				0)
					return 0
					;;
				*)
					echo "無效的選擇，請重試。"
					sleep 1
					;;
			esac
		done
	}

	openclaw_memory_apply_scheme() {
		local scheme="$1"
		openclaw_memory_cleanup_legacy_keys
		case "$scheme" in
			qmd)
				openclaw_memory_config_set "memory.backend" "qmd"
				if [ $? -ne 0 ]; then
					echo "❌ 寫入配置失敗"
					return 1
				fi
				openclaw_memory_config_set "memory.qmd.command" "qmd" >/dev/null 2>&1
				;;
			local)
				openclaw_memory_config_set "memory.backend" "builtin"
				if [ $? -ne 0 ]; then
					echo "❌ 寫入配置失敗"
					return 1
				fi
				openclaw_memory_config_set "agents.defaults.memorySearch.provider" "local" >/dev/null 2>&1
				;;
			*)
				echo "❌ 未知方案:$scheme"
				return 1
			esac
		echo "✅ 已更新記憶方案配置"
		return 0
	}

	openclaw_memory_offer_restart() {
		echo "配置已寫入，需要重新啟動 OpenClaw 閘道後生效。"
		read -e -p "是否立即重新啟動 OpenClaw 網關？ (Y/n):" restart_choice
		if [[ "$restart_choice" =~ ^[Nn]$ ]]; then
			echo "已跳過重啟，可稍後執行: openclaw gateway restart"
			return 0
		fi
		if declare -F start_gateway >/dev/null 2>&1; then
			start_gateway
		else
			openclaw gateway restart
		fi
	}

	openclaw_memory_fix_index() {
		local backend include_dm
		backend=$(openclaw_memory_get_backend)
		if [ "$backend" = "qmd" ] && ! command -v qmd >/dev/null 2>&1; then
			echo "⚠️ 偵測到目前方案為 QMD，但未安裝 qmd 指令。"
			echo "可切換 Local，或安裝 bun + qmd 後再試。"
		fi
		include_dm=$(openclaw config get memory.qmd.includeDefaultMemory 2>/dev/null)
		echo "======================================="
		echo "索引修復診斷"
		echo "======================================="
		echo "目前 includeDefaultMemory: ${include_dm:-未設定}"
		echo ""
		if [ "$include_dm" = "false" ]; then
			echo "⚠️ 偵測到 includeDefaultMemory=false"
			echo "這會導致預設記憶檔案（MEMORY.md + memory/*.md）不被索引"
			echo "所以 Indexed 會一直顯示 0/N"
			echo ""
			read -e -p "是否恢復為 true 並重建索引？ (Y/n):" fix_choice
			if [[ ! "$fix_choice" =~ ^[Nn]$ ]]; then
				openclaw_memory_config_set "memory.qmd.includeDefaultMemory" true
				if [ $? -ne 0 ]; then
					echo "❌ 寫入配置失敗"
					break_end
					return 1
				fi
				echo "✅ 已恢復 includeDefaultMemory=true"
				openclaw_memory_rebuild_index_all
			else
				echo "已取消。"
			fi
		else
			echo "includeDefaultMemory 配置正常。"
			echo "將執行：清理舊索引 → 全量重建所有智能體索引"
			echo ""
			read -e -p "確認執行？ (Y/n):" confirm_fix
			if [[ ! "$confirm_fix" =~ ^[Nn]$ ]]; then
				openclaw_memory_rebuild_index_all
			else
				echo "已取消。"
			fi
		fi
		break_end
	}

	openclaw_memory_scheme_menu() {
		while true; do
			clear
			echo "======================================="
			echo "OpenClaw 記憶方案"
			echo "======================================="
			local backend current_label
			backend=$(openclaw_memory_get_backend)
			case "$backend" in
				qmd) current_label="QMD" ;;
				builtin|local) current_label="Local" ;;
				*) current_label="未配置" ;;
			esac
			echo "當前方案:$current_label"
			echo ""
			echo "QMD : 輕量索引，依賴 qmd 指令（適合網路受限）"
			echo "Local: 本機向量檢索，依賴 embedding 模型文件"
			echo "Auto : 自動推薦（基於可用性 + 網路探測）"
			echo "---------------------------------------"
			echo "1. 切換 QMD（自動部署/已安裝則跳過）"
			echo "2. 切換 Local（自動部署/已安裝則跳過）"
			echo "3. Auto（自動推薦並自動部署）"
			echo "0. 返回上一級"
			echo "---------------------------------------"
			read -e -p "請輸入你的選擇:" scheme_choice
			case "$scheme_choice" in
				1)
					openclaw_memory_auto_setup_run "qmd"
					break_end
					;;
				2)
					openclaw_memory_auto_setup_run "local"
					break_end
					;;
				3)
					openclaw_memory_auto_setup_run "auto"
					break_end
					;;
				0)
					return 0
					;;
				*)
					echo "無效的選擇，請重試。"
					sleep 1
					;;
			esac
		done
	}

	openclaw_memory_file_collect() {
		OPENCLAW_MEMORY_FILES=()
		OPENCLAW_MEMORY_FILE_LABELS=()
		local agent_lines agent_id base_dir memory_dir memory_file rel
		agent_lines=$(openclaw_memory_list_agents)
		while IFS=$'\t' read -r agent_id base_dir; do
			[ -z "$agent_id" ] && continue
			memory_dir="$base_dir/memory"
			memory_file="$base_dir/MEMORY.md"
			if [ -f "$memory_file" ]; then
				OPENCLAW_MEMORY_FILES+=("$memory_file")
				OPENCLAW_MEMORY_FILE_LABELS+=("$agent_id/MEMORY.md")
			fi
			if [ -d "$memory_dir" ]; then
				while IFS= read -r file; do
					[ -f "$file" ] || continue
					rel="${file#$base_dir/}"
					OPENCLAW_MEMORY_FILES+=("$file")
					OPENCLAW_MEMORY_FILE_LABELS+=("$agent_id/$rel")
				done < <(find "$memory_dir" -type f -name '*.md' | sort)
			fi
		done <<EOF
$agent_lines
EOF
	}

	openclaw_memory_file_render_list() {
		openclaw_memory_file_collect
		if [ ${#OPENCLAW_MEMORY_FILES[@]} -eq 0 ]; then
			echo "未找到記憶文件。"
			return 0
		fi
		echo "編號 | 歸屬 | 大小 | 修改時間"
		echo "---------------------------------------"
		local i file rel size mtime
		for i in "${!OPENCLAW_MEMORY_FILES[@]}"; do
			file="${OPENCLAW_MEMORY_FILES[$i]}"
			rel="${OPENCLAW_MEMORY_FILE_LABELS[$i]}"
			size=$(ls -lh "$file" | awk '{print $5}')
			mtime=$(date -d "$(stat -c %y "$file")" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || stat -c %y "$file" | awk '{print $1" "$2}')
			printf "%s | %s | %s | %s\\n" "$((i+1))" "$rel" "$size" "$mtime"
		done
	}

	openclaw_memory_view_file() {
		local file="$1"
		[ -f "$file" ] || {
			echo "❌ 文件不存在:$file"
			return 1
		}
		local total_lines
		total_lines=$(wc -l < "$file" 2>/dev/null || echo 0)
		local default_lines=120
		local start_line count
		echo "文件:$file"
		echo "總行數:$total_lines"
		read -e -p "請輸入起始行（回車預設末尾$default_lines行）:" start_line
		read -e -p "請輸入顯示行數（回車預設$default_lines）: " count
		[ -z "$count" ] && count=$default_lines
		if [ -z "$start_line" ]; then
			if [ "$total_lines" -le "$count" ]; then
				start_line=1
			else
				start_line=$((total_lines - count + 1))
			fi
		fi
		if ! [[ "$start_line" =~ ^[0-9]+$ ]] || ! [[ "$count" =~ ^[0-9]+$ ]]; then
			echo "❌ 請輸入有效的數字。"
			return 1
		fi
		if [ "$start_line" -lt 1 ]; then
			start_line=1
		fi
		if [ "$count" -le 0 ]; then
			echo "❌ 行數必須大於 0。"
			return 1
		fi
		local end_line=$((start_line + count - 1))
		if [ "$end_line" -gt "$total_lines" ]; then
			end_line=$total_lines
		fi
		if [ "$total_lines" -eq 0 ]; then
			echo "(空白文件)"
			return 0
		fi
		echo "---------------------------------------"
		sed -n "${start_line},${end_line}p" "$file"
		echo "---------------------------------------"
	}

	openclaw_memory_files_menu() {
		while true; do
			clear
			echo "======================================="
			echo "OpenClaw 記憶文件"
			echo "======================================="
			openclaw_memory_file_render_list
			echo "---------------------------------------"
			read -e -p "請輸入文件編號查看（0 返回）:" file_choice
			if [ "$file_choice" = "0" ]; then
				return 0
			fi
			if ! [[ "$file_choice" =~ ^[0-9]+$ ]]; then
				echo "無效的選擇，請重試。"
				sleep 1
				continue
			fi
			openclaw_memory_file_collect
			if [ ${#OPENCLAW_MEMORY_FILES[@]} -eq 0 ]; then
				read -p "未找到記憶文件，按回車返回..."
				return 0
			fi
			local idx=$((file_choice-1))
			if [ "$idx" -lt 0 ] || [ "$idx" -ge ${#OPENCLAW_MEMORY_FILES[@]} ]; then
				echo "無效的編號，請重試。"
				sleep 1
				continue
			fi
			openclaw_memory_view_file "${OPENCLAW_MEMORY_FILES[$idx]}"
			read -p "按回車返回清單..."
			done
	}

	openclaw_memory_menu() {
		send_stats "OpenClaw記憶管理"
		while true; do
			clear
			echo "======================================="
			echo "OpenClaw 記憶管理"
			echo "======================================="
			openclaw_memory_render_status
			echo "1. 更新記憶索引"
			echo "2. 檢視記憶文件"
			echo "3. 索引修復（Indexed 異常）"
			echo "4. 記憶方案（QMD/Local/Auto）"
			echo "0. 返回上一級"
			echo "---------------------------------------"
			read -e -p "請輸入你的選擇:" memory_choice
			case "$memory_choice" in
				1)
					echo "即將更新記憶索引。"
					read -e -p "第一次確認：輸入 yes 繼續:" confirm_step1
					if [ "$confirm_step1" != "yes" ]; then
						echo "已取消。"
						break_end
						continue
					fi
				openclaw_memory_prepare_workspace_all
				read -e -p "二次確認：輸入 force 使用全量（留空為增量）:" confirm_step2
				if [ "$confirm_step2" = "force" ]; then
					echo "⚠️ 全量重建更徹底，但耗時更長。"
					echo "建議：輸入 rebuild 進行安全重建（先備份索引庫）。"
					read -e -p "第三次確認：輸入 rebuild 執行安全重建；直接回車繼續普通 force:" confirm_step3
					if [ "$confirm_step3" = "rebuild" ]; then
						openclaw_memory_rebuild_index_all
					else
						local fl_agent_lines fl_agent_id fl_workspace
						fl_agent_lines=$(openclaw_memory_list_agents)
						while IFS=$'\t' read -r fl_agent_id fl_workspace; do
							[ -z "$fl_agent_id" ] && continue
							openclaw memory index --agent "$fl_agent_id" --force
						done <<EOF
$fl_agent_lines
EOF
						openclaw gateway restart
						echo "✅ 已對所有智慧體執行 force 重建並自動重新啟動網關"
					fi
				else
					openclaw memory index
				fi
				break_end
					;;
				2)
					openclaw_memory_files_menu
					;;
				3)
					openclaw_memory_fix_index
					;;
				4)
					openclaw_memory_scheme_menu
					;;
				0)
					return 0
					;;
				*)
					echo "無效的選擇，請重試。"
					sleep 1
					;;
			esac
		done
	}

	openclaw_permission_config_file() {
		echo "$(openclaw_get_config_file)"
	}

	openclaw_permission_backup_file() {
		local backup_root
		backup_root=$(openclaw_backup_root)
		echo "${backup_root}/openclaw-permission-last.json"
	}

	openclaw_permission_require_openclaw() {
		if ! openclaw_has_command openclaw; then
			echo "❌ 未偵測到 openclaw 指令，請先安裝或初始化 OpenClaw。"
			return 1
		fi
		return 0
	}

	openclaw_permission_backup_current() {
		local config_file backup_file
		config_file=$(openclaw_permission_config_file)
		backup_file=$(openclaw_permission_backup_file)
		if [ ! -s "$config_file" ]; then
			echo "⚠️ 未找到 OpenClaw 設定文件，跳過權限備份。"
			return 1
		fi
		mkdir -p "$(dirname "$backup_file")"
		cp -f "$config_file" "$backup_file" >/dev/null 2>&1 || {
			echo "⚠️ 權限備份失敗：$backup_file"
			return 1
		}
		echo "✅ 已備份目前權限配置:$backup_file"
		return 0
	}

	openclaw_permission_restore_backup() {
		local config_file backup_file
		config_file=$(openclaw_permission_config_file)
		backup_file=$(openclaw_permission_backup_file)
		if [ ! -s "$backup_file" ]; then
			echo "❌ 未找到可還原的權限備份檔。"
			return 1
		fi
		cp -f "$backup_file" "$config_file" >/dev/null 2>&1 || {
			echo "❌ 權限恢復失敗：$backup_file"
			return 1
		}
		echo "✅ 已恢復切換前權限配置"
		openclaw_permission_restart_gateway || true
		return 0
	}

	openclaw_permission_restart_gateway() {
		if ! openclaw_has_command openclaw; then
			echo "❌ 未偵測到 openclaw，無法重新啟動 OpenClaw Gateway。"
			return 1
		fi
		echo "正在重啟 OpenClaw Gateway..."
		openclaw gateway restart >/dev/null 2>&1 || {
			openclaw gateway stop >/dev/null 2>&1
			openclaw gateway start >/dev/null 2>&1
		}
	}

	openclaw_permission_get_value() {
		local path="$1"
		local config_file
		config_file=$(openclaw_permission_config_file)

		if openclaw_has_command openclaw; then
			local value
			value=$(openclaw config get "$path" 2>&1 | head -n 1)
			if [ -n "$value" ]; then
				if echo "$value" | grep -qi "config path not found"; then
					echo "(unset)"
					return 0
				fi
				if [ "$value" = "null" ]; then
					echo "(unset)"
				else
					if echo "$value" | grep -q '^".*"$'; then
						value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//')
					fi
					echo "$value"
				fi
				return 0
			fi
		fi

		[ -f "$config_file" ] || { echo "(unset)"; return 0; }

		if openclaw_has_command jq; then
			local jq_value
			jq_value=$(jq -r --arg p "$path" 'getpath($p|split(".")) // "(unset)"' "$config_file" 2>/dev/null) || jq_value="(unset)"
			[ "$jq_value" = "null" ] && jq_value="(unset)"
			echo "$jq_value"
			return 0
		fi

		if openclaw_has_command python3; then
			python3 - "$config_file" "$path" <<'PY'
import json, sys
path = sys.argv[2]
with open(sys.argv[1], 'r', encoding='utf-8') as f:
    obj = json.load(f)
cur = obj
for part in path.split('.'):
    if isinstance(cur, dict) and part in cur:
        cur = cur[part]
    else:
        print('(unset)')
        raise SystemExit(0)
if isinstance(cur, bool):
    print('true' if cur else 'false')
elif cur is None:
    print('(unset)')
else:
    print(json.dumps(cur, ensure_ascii=False) if isinstance(cur, (dict, list)) else str(cur))
PY
			return 0
		fi

		echo "(unset)"
		return 0
	}

	openclaw_permission_unset_optional() {
		local key="$1"
		local probe
		if ! openclaw_has_command openclaw; then
			return 1
		fi
		if openclaw config unset "$key" >/dev/null 2>&1; then
			return 0
		fi
		probe=$(openclaw config get "$key" 2>&1 | head -n 1)
		if [ -z "$probe" ] || [ "$probe" = "null" ] || [ "$probe" = "(unset)" ] || echo "$probe" | grep -qi "config path not found"; then
			return 0
		fi
		return 1
	}

	openclaw_permission_detect_mode() {
		local config_file
		config_file=$(openclaw_permission_config_file)
		[ ! -f "$config_file" ] && { echo "未知模式"; return; }

		python3 - "$config_file" <<'PY'
import json, sys

def get_v(o, p):
    for k in p.split('.'):
        if isinstance(o, dict) and k in o:
            o = o[k]
        else:
            return "(unset)"
    return str(o).lower()

try:
    with open(sys.argv[1], 'r', encoding='utf-8') as f:
        d = json.load(f)
    p = get_v(d, "tools.profile")
    s = get_v(d, "tools.exec.security")
    a = get_v(d, "tools.exec.ask")
    e = get_v(d, "tools.elevated.enabled")
    b = get_v(d, "commands.bash")
    ap = get_v(d, "tools.exec.applyPatch.enabled")
    w = get_v(d, "tools.exec.applyPatch.workspaceOnly")

    if p == "coding" and s == "allowlist" and a == "on-miss" and e == "false" and b == "false" and ap == "false":
        print("標準安全模式")
    elif p == "coding" and s == "allowlist" and a == "on-miss" and e == "true" and b == "true" and ap == "true" and w == "true":
        print("開發增強模式")
    elif (p == "full" or p == "(unset)") and s == "full" and a == "off" and e == "true" and b == "true" and ap == "true":
        print("完全開放模式")
    else:
        print("自訂模式")
except Exception:
    print("自訂模式")
PY
	}

		openclaw_permission_update_exec_approvals() {
		local sec="$1"
		local ask="$2"
		local fallback="$3"
		local approvals_file="$HOME/.openclaw/exec-approvals.json"
		
		mkdir -p "$HOME/.openclaw"
		
		# 使用 Python 安全性更新或建立 exec-approvals.json
		python3 -c "
import json, sys, os
path = sys.argv[1]
try:
    if os.path.exists(path):
        with open(path, 'r') as f:
            data = json.load(f)
    else:
        data = {'version': 1, 'defaults': {}}
except Exception:
    data = {'version': 1, 'defaults': {}}

if 'defaults' not in data:
    data['defaults'] = {}

data['defaults']['security'] = sys.argv[2]
data['defaults']['ask'] = sys.argv[3]
data['defaults']['askFallback'] = sys.argv[4]
data['defaults']['autoAllowSkills'] = True

with open(path, 'w') as f:
    json.dump(data, f, indent=2)
" "$approvals_file" "$sec" "$ask" "$fallback"
	}

	openclaw_permission_render_status() {
		echo "應用層配置: ~/.openclaw/openclaw.json"
		echo "宿主機核准: ~/.openclaw/exec-approvals.json"
		echo "---------------------------------------"
		local current_profile=$(openclaw config get tools.profile 2>/dev/null)
		local sec_val
		if [ -f "$HOME/.openclaw/exec-approvals.json" ]; then
			sec_val=$(python3 -c "import json, sys; print(json.load(open('$HOME/.openclaw/exec-approvals.json')).get('defaults', {}).get('security', 'unset'))" 2>/dev/null || echo "unset")
		else
			sec_val="unset"
		fi

		local current_mode="未知 / 自訂"
		if [ "$current_profile" = "coding" ] && [ "$sec_val" = "allowlist" ]; then
			current_mode="\033[1;32m標準安全模式\033[0m"
		elif [ "$current_profile" = "full" ] && [ "$sec_val" = "full" ]; then
			current_mode="\033[1;31m完全開放模式\033[0m"
		elif [ "$current_profile" = "coding" ] && [ "$sec_val" = "full" ]; then
			current_mode="\033[1;33m開發增強模式\033[0m"
		elif [ -z "$current_profile" ] && [ "$sec_val" = "unset" ]; then
			current_mode="\033[1;36m官方沙盒兜底\033[0m"
		fi
		echo -e "當前綜合安全等級:${current_mode}"
		echo "---------------------------------------"
		echo -e "${gl_huang}[應用層 Tool Policy 狀態]${gl_bai}"
		openclaw config get tools.profile 2>/dev/null | sed 's/^/ Profile (預設): /' || echo "  Profile: (unset)"
		openclaw config get tools.exec.security 2>/dev/null | sed 's/^/ Exec 限制: /' || echo "Exec 限制: (unset)"
		openclaw config get tools.exec.ask 2>/dev/null | sed 's/^/ 審核提示: /' || echo "審核提示: (unset)"
		openclaw config get tools.elevated.enabled 2>/dev/null | sed 's/^/ 提權開關: /' || echo "提權開關: (unset)"
		
		echo -e "\n${gl_huang}[底層 Exec Approvals 狀態]${gl_bai}"
		if [ -f "$HOME/.openclaw/exec-approvals.json" ]; then
			python3 -c "
import json, sys
try:
    with open('$HOME/.openclaw/exec-approvals.json') as f:
        d = json.load(f).get('defaults', {})
        print('攔截策略 (Security):' + str(d.get('security', '(unset)')))
        print('提示策略 (Ask):' + str(d.get('ask', '(unset)')))
        print('無UI兜底 (AskFallback):' + str(d.get('askFallback', '(unset)')))
except Exception:
    print('(設定檔解析失敗)')
"
		else
			echo "(未配置，強制使用系統內建安全兜底策略)"
		fi
	}

	openclaw_permission_apply_standard() {
		send_stats "OpenClaw權限-標準安全模式"
		openclaw_permission_require_openclaw || return 1
		
		echo "正在設定應用層策略..."
		openclaw config set tools.profile coding >/dev/null 2>&1
		openclaw config set tools.exec.security allowlist >/dev/null 2>&1
		openclaw config set tools.exec.ask on-miss >/dev/null 2>&1
		openclaw config set tools.elevated.enabled false >/dev/null 2>&1
		openclaw config set tools.exec.strictInlineEval true >/dev/null 2>&1  # 拦截危险的内联代码
		openclaw config unset commands.bash >/dev/null 2>&1 # 废弃旧版参数
		
		echo "正在設定宿主機審批攔截..."
		openclaw_permission_update_exec_approvals "allowlist" "on-miss" "deny"
		
		openclaw_permission_restart_gateway
		echo -e "${gl_lv}✅ 已切換為標準安全模式 (所有危險命令將透過UI/TG請求你的批准)${gl_bai}"
	}

	openclaw_permission_apply_developer() {
		send_stats "OpenClaw權限-開發增強模式"
		openclaw_permission_require_openclaw || return 1
		
		echo "正在設定應用層策略..."
		openclaw config set tools.profile coding >/dev/null 2>&1
		openclaw config set tools.exec.security allowlist >/dev/null 2>&1
		openclaw config set tools.exec.ask on-miss >/dev/null 2>&1
		openclaw config set tools.elevated.enabled true >/dev/null 2>&1 # 允许智能体申请提权
		openclaw config set tools.exec.strictInlineEval false >/dev/null 2>&1
		
		echo "正在設定宿主機審批攔截..."
		openclaw_permission_update_exec_approvals "allowlist" "on-miss" "deny"
		
		openclaw_permission_restart_gateway
		echo -e "${gl_lv}✅ 已切換為開發增強模式 (允許提權，但常規危險命令仍需審批)${gl_bai}"
	}

	openclaw_permission_apply_full() {
		send_stats "OpenClaw權限-完全開放模式"
		openclaw_permission_require_openclaw || return 1
		
		echo "正在設定應用層策略..."
		openclaw config set tools.profile full >/dev/null 2>&1
		openclaw config set tools.exec.security full >/dev/null 2>&1
		openclaw config set tools.exec.ask off >/dev/null 2>&1
		openclaw config set tools.elevated.enabled true >/dev/null 2>&1
		openclaw config set tools.exec.strictInlineEval false >/dev/null 2>&1
		
		echo "正在瓦解宿主機攔截防禦..."
		# 這裡的 full 和 off 將徹底繞過底層宿主機的 exec 審批系統
		openclaw_permission_update_exec_approvals "full" "off" "full"
		
		openclaw_permission_restart_gateway
		echo -e "${gl_lv}✅ 已切換為完全開放模式 (警告：所有宿主機指令攔截已失效，智能體具有最高權限)${gl_bai}"
	}

	openclaw_permission_restore_official_defaults() {
		send_stats "OpenClaw權限-恢復官方默認"
		openclaw_permission_require_openclaw || return 1
		
		echo "清理應用層強制覆蓋..."
		openclaw config unset tools.profile >/dev/null 2>&1
		openclaw config unset tools.exec.security >/dev/null 2>&1
		openclaw config unset tools.exec.ask >/dev/null 2>&1
		openclaw config unset tools.elevated.enabled >/dev/null 2>&1
		openclaw config unset tools.exec.strictInlineEval >/dev/null 2>&1
		
		echo "清理宿主機攔截配置..."
		rm -f "$HOME/.openclaw/exec-approvals.json"
		
		openclaw_permission_restart_gateway
		echo -e "${gl_lv}✅ 已恢復到 OpenClaw 官方安全沙盒防禦機制${gl_bai}"
	}

	openclaw_permission_run_audit() {
		echo "======================================="
		echo "運行 OpenClaw 官方安全審計與體檢..."
		echo "======================================="
		openclaw security audit
		echo "---------------------------------------"
		read -e -p "是否嘗試自動修復發現的安全隱患？ (y/n):" fix_choice
		if [[ "$fix_choice" == "y" || "$fix_choice" == "Y" || "$fix_choice" == "yes" ]]; then
			openclaw security audit --fix
			echo -e "${gl_lv}✅ 自動修復完成。${gl_bai}"
		fi
		echo "按任意鍵返回..."
		read -n 1 -s
	}

	openclaw_permission_menu() {
		send_stats "OpenClaw權限管理"
		while true; do
			clear
			echo "======================================="
			echo "OpenClaw 權限管理 (雙層架構深度適配)"
			echo "======================================="
			openclaw_permission_render_status
			echo "---------------------------------------"
			echo -e "${gl_kjlan}1.${gl_bai}切換為標準安全模式（日常推薦，彈卡核准）"
			echo -e "${gl_kjlan}2.${gl_bai}切換為開發增強模式（允許智能體申請提權）"
			echo -e "${gl_kjlan}3.${gl_bai}切換為完全開放模式（${gl_hong}高風險！徹底解除所有宿主機攔截${gl_bai}）"
			echo -e "${gl_kjlan}4.${gl_bai}恢復官方預設沙盒防禦策略"
			echo -e "${gl_kjlan}5.${gl_bai}運行底層安全審計與自動修復"
			echo -e "${gl_kjlan}0.${gl_bai}回上一級"
			echo "---------------------------------------"
			read -e -p "請輸入你的選擇:" perm_choice
			case "$perm_choice" in
				1)
					echo "準備應用：標準安全模式"
					read -e -p "輸入 yes 確認:" confirm
					[ "$confirm" = "yes" ] && openclaw_permission_apply_standard || echo "已取消"
					break_end
					;;
				2)
					echo "準備應用：開發增強模式"
					read -e -p "輸入 yes 確認:" confirm
					[ "$confirm" = "yes" ] && openclaw_permission_apply_developer || echo "已取消"
					break_end
					;;
				3)
					echo -e "${gl_hong}⚠️ 完全開放模式會徹底瓦解 exec 審核並自動放行高風險程式碼。${gl_bai}"
					read -e -p "輸入 FULL 確認繼續:" confirm
					[ "$confirm" = "FULL" ] && openclaw_permission_apply_full || echo "已取消"
					break_end
					;;
				4)
					echo "將清除所有自訂覆蓋，恢復 OpenClaw 剛安裝時的嚴格沙盒狀態。"
					read -e -p "輸入 yes 確認:" confirm
					[ "$confirm" = "yes" ] && openclaw_permission_restore_official_defaults || echo "已取消"
					break_end
					;;
				5)
					openclaw_permission_run_audit
					;;
				0)
					return 0
					;;
				*)
					echo "無效的選擇，請重試。"
					sleep 1
					;;
			esac
		done
	}

	openclaw_multiagent_config_file() {
		local config_file
		config_file=$(openclaw_permission_config_file)
		if [ -s "$config_file" ]; then
			echo "$config_file"
			return 0
		fi
		openclaw config file 2>/dev/null | tail -n 1
	}

	openclaw_multiagent_default_agent() {
		local config_file
		config_file=$(openclaw_permission_config_file)
		if [ -s "$config_file" ]; then
			python3 - "$config_file" <<'PY'
import json,sys,os
path=sys.argv[1]
value="(unset)"
try:
    with open(path) as f:
        data=json.load(f)
    defaults=data.get("agents",{}).get("defaults",{}) if isinstance(data,dict) else {}
    value=defaults.get("agent") or None
    if not value:
        for item in data.get("agents",{}).get("list",[]) or []:
            if isinstance(item,dict) and (item.get("isDefault") or item.get("default")):
                value=item.get("id")
                break
    if not value:
        for item in data.get("agents",{}).get("list",[]) or []:
            if isinstance(item,dict) and item.get("id"):
                value=item.get("id")
                break
except Exception:
    value="(unset)"
print(value or "(unset)")
PY
			return 0
		fi
		local value
		value=$(openclaw config get agents.defaults.agent 2>&1 | head -n 1)
		if [ -z "$value" ] || echo "$value" | grep -qi "config path not found"; then
			value=$(openclaw agents list --json 2>/dev/null | python3 -c 'import json,sys
try:
 data=json.load(sys.stdin)
 print(next((x.get("id","(unset)") for x in data if x.get("isDefault")), "(unset)"))
except Exception:
 print("(unset)")' 2>/dev/null)
		fi
		[ -z "$value" ] && value="(unset)"
		if echo "$value" | grep -q '^".*"$'; then
			value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//')
		fi
		echo "$value"
	}

	openclaw_multiagent_require_openclaw() {
		if ! openclaw_has_command openclaw; then
			echo "❌ 未偵測到 openclaw 指令，請先安裝或初始化 OpenClaw。"
			return 1
		fi
		return 0
	}

	openclaw_multiagent_agents_json() {
		local config_file
		config_file=$(openclaw_permission_config_file)
		if [ -s "$config_file" ]; then
			python3 - "$config_file" <<'PY'
import json,sys,os
path=sys.argv[1]
try:
    with open(path) as f:
        data=json.load(f)
    agents=data.get("agents",{}).get("list",[])
    if not isinstance(agents,list):
        agents=[]
    print(json.dumps(agents, ensure_ascii=False))
except Exception:
    print("[]")
PY
			return 0
		fi
		openclaw agents list --json 2>/dev/null || echo '[]'
	}

	openclaw_multiagent_bindings_json() {
		local config_file
		config_file=$(openclaw_permission_config_file)
		if [ -s "$config_file" ]; then
			python3 - "$config_file" <<'PY'
import json,sys,os
path=sys.argv[1]
results=[]

def add_item(item):
    if not isinstance(item,dict):
        return
    bind=item.get("bind") or item.get("binding") or item.get("scope") or item.get("route")
    agent=item.get("agentId") or item.get("agent")
    if agent or bind:
        results.append({"agentId": agent or "?", "bind": bind or "-"})

def walk(obj):
    if isinstance(obj,dict):
        if "agentId" in obj and any(k in obj for k in ("bind","binding","scope","route")):
            add_item(obj)
        for v in obj.values():
            walk(v)
    elif isinstance(obj,list):
        for v in obj:
            walk(v)

try:
    with open(path) as f:
        data=json.load(f)
    bindings=data.get("agents",{}).get("bindings") if isinstance(data,dict) else None
    if isinstance(bindings,list):
        for item in bindings:
            add_item(item)
    walk(data)
    print(json.dumps(results, ensure_ascii=False))
except Exception:
    print("[]")
PY
			return 0
		fi
		openclaw agents bindings --json 2>/dev/null || echo '[]'
	}

	openclaw_multiagent_sessions_json() {
		local config_file
		config_file=$(openclaw_permission_config_file)
		python3 - "$config_file" <<'PY'
import json,sys,os
config_path=sys.argv[1] if len(sys.argv)>1 else ""

def load_agents(path):
    if path and os.path.exists(path):
        try:
            with open(path) as f:
                data=json.load(f)
            agents=data.get("agents",{}).get("list",[])
            if isinstance(agents,list) and agents:
                ids=[a.get("id") for a in agents if isinstance(a,dict) and a.get("id")]
                if ids:
                    return ids
        except Exception:
            pass
    base=os.path.expanduser("~/.openclaw/agents")
    try:
        return [d for d in os.listdir(base) if os.path.isdir(os.path.join(base,d))]
    except Exception:
        return []

agent_ids=load_agents(config_path)
sessions=[]
for agent_id in agent_ids:
    path=os.path.expanduser(f"~/.openclaw/agents/{agent_id}/sessions/sessions.json")
    if not os.path.exists(path):
        continue
    try:
        with open(path) as f:
            data=json.load(f)
    except Exception:
        continue
    if isinstance(data,dict):
        items=data.items()
    elif isinstance(data,list):
        items=[(item.get("key") or item.get("sessionKey") or "?", item) for item in data if isinstance(item,dict)]
    else:
        continue
    for key,item in items:
        if not isinstance(item,dict):
            continue
        model=item.get("model")
        if not model:
            report=item.get("systemPromptReport") or {}
            if isinstance(report,dict):
                model=report.get("model") or report.get("modelProvider") or report.get("provider")
        sessions.append({"agentId": agent_id, "key": key, "model": model or "-"})
print(json.dumps({"sessions": sessions}, ensure_ascii=False))
PY
	}

	openclaw_multiagent_render_status() {
		local config_file default_agent
		config_file=$(openclaw_multiagent_config_file)
		default_agent=$(openclaw_multiagent_default_agent)
		echo "設定檔: ${config_file:-$(openclaw_permission_config_file)}"
		echo "預設智能體:$default_agent"
		python3 -c 'import json,sys; agents=json.loads(sys.argv[1] or "[]"); bindings=json.loads(sys.argv[2] or "[]"); obj=json.loads(sys.argv[3] or "{}"); sessions=obj.get("sessions",[]) if isinstance(obj,dict) else []; print("已配置智能體數: %s" % len(agents)); print("路由綁定數: %s" % len(bindings)); print("會話總數: %s" % len(sessions)); print("---------------------------------------");
if not agents: print("目前未配置任何多智能體。")
else:
 import itertools
 for item in itertools.islice(agents, 8):
  ident_obj=item.get("identity") if isinstance(item.get("identity"),dict) else {}; identity=ident_obj.get("name") or item.get("identityName") or item.get("name") or "-"; emoji=item.get("identityEmoji") or ""; ws=item.get("workspace") or "-"; print("- 智能體ID: [1;36m%s [0m" % item.get("id","?")); print("身份名稱: %s %s" % (identity, emoji)); print("工作目錄: %s" % ws)' "$(openclaw_multiagent_agents_json)" "$(openclaw_multiagent_bindings_json)" "$(openclaw_multiagent_sessions_json)"
	}

	openclaw_multiagent_list_agents() {
		send_stats "OpenClaw多智能體-列出Agent"
		python3 -c 'import json,sys; agents=json.loads(sys.argv[1] or "[]");
if not agents: print("暫無已配置 Agent。"); raise SystemExit(0)
for idx,item in enumerate(agents,1):
 print("%s. %s" % (idx, item.get("id","?"))); print("   workspace : %s" % item.get("workspace","-")); ident=(item.get("identityName") or "-") + ((" " + item.get("identityEmoji")) if item.get("identityEmoji") else ""); print("   identity  : %s" % ident.strip()); print("   model     : %s" % (item.get("model") or "-")); print("   bindings  : %s" % item.get("bindings",0)); print("   default   : %s" % ("yes" if item.get("isDefault") else "no"))' "$(openclaw_multiagent_agents_json)"
	}

	openclaw_multiagent_add_agent() {
		send_stats "OpenClaw多智能體-新增Agent"
		openclaw_multiagent_require_openclaw || return 1
		local agent_id workspace confirm
		read -e -p "請輸入新的 Agent ID:" agent_id
		[ -z "$agent_id" ] && echo "已取消：Agent ID 不能為空。" && return 1
		read -e -p "請輸入 workspace 路徑（預設為 ~/.openclaw/workspace-${agent_id}）: " workspace
		[ -z "$workspace" ] && workspace="~/.openclaw/workspace-${agent_id}"
		echo "將創建智能體:$agent_id"
		echo "工作目錄:$workspace"
		read -e -p "輸入 yes 確認繼續:" confirm
		[ "$confirm" = "yes" ] || { echo "已取消"; return 1; }
		if openclaw agents add "$agent_id" --workspace "$workspace"; then
			echo "✅ 智能體創建成功:$agent_id"
			local name theme
			read -e -p "請輸入智能體身分名稱 (如: 代碼專家):" name
			[ -z "$name" ] && name="$agent_id"
			read -e -p "請輸入智能體性格主題 (如: 嚴謹、有效率):" theme
			[ -z "$theme" ] && theme="助理"
			echo "正在配置智能體身份..."
			openclaw agents set-identity --agent "$agent_id" --name "$name" --theme "$theme"
		else
			echo "❌ 智能體創建失敗"
			return 1
		fi
	}

	openclaw_multiagent_delete_agent() {
		send_stats "OpenClaw多智能體-刪除Agent"
		openclaw_multiagent_require_openclaw || return 1
		local agent_id confirm
		read -e -p "請輸入要刪除的 Agent ID:" agent_id
		[ -z "$agent_id" ] && echo "已取消：Agent ID 不能為空。" && return 1
		echo "⚠️ 刪除智能體可能會影響其工作目錄、路由綁定與會話路由。"
		read -e -p "輸入 DELETE 確認刪除${agent_id}: " confirm
		[ "$confirm" = "DELETE" ] || { echo "已取消"; return 1; }
		if openclaw agents delete "$agent_id"; then
			echo "✅ 智能體刪除成功:$agent_id"
		else
			echo "❌ 智能體刪除失敗"
			return 1
		fi
	}

	openclaw_multiagent_list_bindings() {
		send_stats "OpenClaw多智能體-檢視路由綁定"
		python3 -c 'import json,sys; bindings=json.loads(sys.argv[1] or "[]");
if not bindings: print("暫無路由綁定。"); raise SystemExit(0)
for idx,item in enumerate(bindings,1):
 bind=item.get("bind") or item.get("binding") or item.get("scope") or "-"; print("%s. agent=%s | bind=%s" % (idx, item.get("agentId","?"), bind))' "$(openclaw_multiagent_bindings_json)"
	}

	openclaw_multiagent_add_binding() {
		send_stats "OpenClaw多智能體-新增路由綁定"
		openclaw_multiagent_require_openclaw || return 1
		local agent_id bind_value confirm
		read -e -p "請輸入智能體 ID:" agent_id
		read -e -p "請輸入路由綁定值（如 telegram:ops / discord:guild-a）:" bind_value
		{ [ -z "$agent_id" ] || [ -z "$bind_value" ]; } && echo "已取消：參數不能為空​​。" && return 1
		echo "將綁定智能體 [$agent_id] -> [$bind_value]"
		read -e -p "輸入 yes 確認繼續:" confirm
		[ "$confirm" = "yes" ] || { echo "已取消"; return 1; }
		if openclaw agents bind --agent "$agent_id" --bind "$bind_value"; then
			echo "✅ 路由綁定新增成功"
		else
			echo "❌ 路由綁定新增失敗"
			return 1
		fi
	}

	openclaw_multiagent_remove_binding() {
		send_stats "OpenClaw多智能體-移除路由綁定"
		openclaw_multiagent_require_openclaw || return 1
		local agent_id bind_value confirm
		read -e -p "請輸入智能體 ID:" agent_id
		read -e -p "請輸入要移除的路由綁定值:" bind_value
		{ [ -z "$agent_id" ] || [ -z "$bind_value" ]; } && echo "已取消：參數不能為空​​。" && return 1
		echo "將移除智能體 [$agent_id] 的路由綁定 [$bind_value]"
		read -e -p "輸入 yes 確認繼續:" confirm
		[ "$confirm" = "yes" ] || { echo "已取消"; return 1; }
		if openclaw agents unbind --agent "$agent_id" --bind "$bind_value"; then
			echo "✅ 路由綁定移除成功"
		else
			echo "❌ 路由綁定移除失敗"
			return 1
		fi
	}


	openclaw_multiagent_show_sessions() {
		send_stats "OpenClaw多智能體-會話概況"
		python3 -c 'import json,sys; obj=json.loads(sys.argv[1] or "{}"); sessions=obj.get("sessions",[]) if isinstance(obj,dict) else [];
if not sessions: print("暫無 session 資料。"); raise SystemExit(0)
by_agent={}
for item in sessions: by_agent[item.get("agentId","?")]=by_agent.get(item.get("agentId","?"),0)+1
print("會話匯總:")
for agent_id,count in sorted(by_agent.items()): print("- %s: %s" % (agent_id, count))
print("---------------------------------------")
for item in sessions[:10]: print("%s | %s | %s" % (item.get("agentId","?"), item.get("key","-"), item.get("model") or "-"))' "$(openclaw_multiagent_sessions_json)"
	}

	openclaw_multiagent_health_check() {
		send_stats "OpenClaw多智能體-健康檢查"
		openclaw_multiagent_require_openclaw || return 1
		local config_file
		config_file=$(openclaw_multiagent_config_file)
		echo "檢查設定檔: ${config_file:-$(openclaw_permission_config_file)}"
		openclaw config validate || echo "⚠️ 配置校驗未通過，請檢查上方輸出。"
		python3 -c 'import json,sys,os; agents=json.loads(sys.argv[1] or "[]"); bindings=json.loads(sys.argv[2] or "[]"); print("---------------------------------------");
if not agents: print("⚠️ 未發現配置智能體。");
else:
 for item in agents:
  ws=item.get("workspace") or ""; aid=item.get("id","?"); state="OK" if ws and os.path.isdir(os.path.expanduser(ws)) else ("OK" if aid=="main" else "MISSING"); print("agent=%s workspace=%s [%s]" % (aid, ws or "-", state))
print("路由綁定數=%s" % len(bindings)); print("✅ 多智能體健康檢查完成")' "$(openclaw_multiagent_agents_json)" "$(openclaw_multiagent_bindings_json)"
	}

	openclaw_multiagent_menu() {
		send_stats "OpenClaw多智能體管理"
		while true; do
			clear
			echo "======================================="
			echo "OpenClaw 多智能體管理"
			echo "======================================="
			openclaw_multiagent_render_status
			echo "---------------------------------------"
			echo "1. 新增智能體"
			echo "2. 刪除智能體"
			echo "3. 查看路由綁定"
			echo "4. 新增路由綁定"
			echo "5. 移除路由綁定"
			echo "6. 查看會話概況"
			echo "7. 執行多智能體健康檢查"
			echo "0. 返回上一級"
			echo "---------------------------------------"
			read -e -p "請輸入你的選擇:" multi_choice
			case "$multi_choice" in
				1) openclaw_multiagent_add_agent; break_end ;;
				2) openclaw_multiagent_delete_agent; break_end ;;
				3) openclaw_multiagent_list_bindings; break_end ;;
				4) openclaw_multiagent_add_binding; break_end ;;
				5) openclaw_multiagent_remove_binding; break_end ;;
				6) openclaw_multiagent_show_sessions; break_end ;;
				7) openclaw_multiagent_health_check; break_end ;;
				0) return 0 ;;
				*) echo "無效的選擇，請重試。"; sleep 1 ;;
			esac
		done
	}


openclaw_backup_restore_menu() {

		send_stats "OpenClaw備份與還原"
		while true; do
			clear
			echo "======================================="
			echo "OpenClaw 備份與還原"
			echo "======================================="
			openclaw_backup_render_file_list
			echo "---------------------------------------"
			echo "1. 備份記憶全量"
			echo "2. 還原記憶全量"
			echo "3. 備份 OpenClaw 專案（預設安全模式）"
			echo "4. 還原 OpenClaw 專案（進階/高風險）"
			echo "5. 刪除備份文件"
			echo "0. 返回上一級"
			echo "---------------------------------------"
			read -e -p "請輸入你的選擇:" backup_choice

			case "$backup_choice" in
				1) openclaw_memory_backup_export ;;
				2) openclaw_memory_backup_import ;;
				3) openclaw_project_backup_export ;;
				4) openclaw_project_backup_import ;;
				5) openclaw_backup_delete_file ;;
				0) return 0 ;;
				*)
					echo "無效的選擇，請重試。"
					sleep 1
					;;
			esac
		done
	}


	update_moltbot() {
		echo "更新 OpenClaw..."
		send_stats "更新 OpenClaw..."
		install_node_and_tools
		git config --global url."${gh_proxy}github.com/".insteadOf ssh://git@github.com/
		git config --global url."${gh_proxy}github.com/".insteadOf git@github.com:
		npm install -g openclaw@latest
		crontab -l 2>/dev/null | grep -v "s gateway" | crontab -
		start_gateway
		hash -r
		add_app_id
		echo "更新完成"
		break_end
	}


	uninstall_moltbot() {
		echo "卸載 OpenClaw..."
		send_stats "卸載 OpenClaw..."
		openclaw uninstall
		npm uninstall -g openclaw
		crontab -l 2>/dev/null | grep -v "s gateway" | crontab -
		rm -rf "$HOME/.openclaw"
		[ "$HOME" != "/root" ] && [ -d /root/.openclaw ] && echo "⚠️ 偵測到 root 目錄下仍存在 /root/.openclaw，如需清理請手動處理"
		hash -r
		sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
		echo "卸載完成"
		break_end
	}

	nano_openclaw_json() {
		send_stats "編輯 OpenClaw 設定檔"
		install nano
		nano "$(openclaw_get_config_file)"
		start_gateway
	}






	openclaw_find_webui_domain() {
		local conf domain_list

		domain_list=$(
			grep -R "18789" /home/web/conf.d/*.conf 2>/dev/null \
			| awk -F: '{print $1}' \
			| sort -u \
			| while read conf; do
				basename "$conf" .conf
			done
		)

		if [ -n "$domain_list" ]; then
			echo "$domain_list"
		fi
	}



	openclaw_show_webui_addr() {
		local local_ip token domains

		echo "=================================="
		echo "OpenClaw WebUI 存取位址"
		local_ip="127.0.0.1"

		token=$(
			openclaw dashboard 2>/dev/null \
			| sed -n 's/.*:18789\/#token=\([a-f0-9]\+\).*/\1/p' \
			| head -n 1
		)
		echo
		echo "本機地址："
		echo "http://${local_ip}:18789/#token=${token}"

		domains=$(openclaw_find_webui_domain)
		if [ -n "$domains" ]; then
			echo "網域地址："
			echo "$domains" | while read d; do
				echo "https://${d}/#token=${token}"
			done
		fi

		echo "=================================="
	}



	# 新增網域（呼叫你給的函數）
	openclaw_domain_webui() {
		add_yuming
		ldnmp_Proxy ${yuming} 127.0.0.1 18789

		token=$(
			openclaw dashboard 2>/dev/null \
			| sed -n 's/.*:18789\/#token=\([a-f0-9]\+\).*/\1/p' \
			| head -n 1
		)

		clear
		echo "訪問地址:"
		echo "https://${yuming}/#token=$token"
		echo "先造訪URL觸發設備ID，然後回車下一步進行配對。"
		read
		echo -e "${gl_kjlan}正在載入設備列表…${gl_bai}"
		# 自動新增網域到 allowedOrigins
		config_file=$(openclaw_get_config_file)
		if [ -f "$config_file" ]; then
			new_origin="https://${yuming}"
			# 使用 jq 安全性修改 JSON，確保結構存在且不重複新增域名
			if command -v jq >/dev/null 2>&1; then
				tmp_json=$(mktemp)
				jq 'if .gateway.controlUi == null then .gateway.controlUi = {"allowedOrigins": ["http://127.0.0.1"]} else . end | if (.gateway.controlUi.allowedOrigins | contains([$origin]) | not) then .gateway.controlUi.allowedOrigins += [$origin] else . end' --arg origin "$new_origin" "$config_file" > "$tmp_json" && mv "$tmp_json" "$config_file"
				echo -e "${gl_kjlan}已將域名${yuming}加入 allowedOrigins 配置${gl_bai}"
				openclaw gateway restart >/dev/null 2>&1
			fi
		fi

		openclaw devices list

		read -e -p "請輸入 Request_Key:" Request_Key

		[ -z "$Request_Key" ] && {
			echo "Request_Key 不能為空"
			return 1
		}

		openclaw devices approve "$Request_Key"

	}

	# 刪除域名
	openclaw_remove_domain() {
		echo "網域格式 example.com 不含https://"
		web_del
	}

	# 主選單
	openclaw_webui_menu() {

		send_stats "WebUI存取與設定"
		while true; do
			clear
			openclaw_show_webui_addr
			echo
			echo "1. 添加網域訪問"
			echo "2. 刪除網域名稱訪問"
			echo "0. 退出"
			echo
			read -e -p "請選擇:" choice

			case "$choice" in
				1)
					openclaw_domain_webui
					echo
					read -p "按回車返回選單..."
					;;
				2)
					openclaw_remove_domain
					read -p "按回車返回選單..."
					;;
				0)
					break
					;;
				*)
					echo "無效選項"
					sleep 1
					;;
			esac
		done
	}



	# 主循環
	while true; do
		show_menu
		read choice
		case $choice in
			1) install_moltbot ;;
			2) start_bot ;;
			3) stop_bot ;;
			4) view_logs ;;
			5) change_model ;;
			6) openclaw_api_manage_menu ;;
			7) change_tg_bot_code ;;
			8) install_plugin ;;
			9) install_skill ;;
			10) nano_openclaw_json ;;
			11) send_stats "初始化配置精靈"
				openclaw onboard --install-daemon
				break_end
				;;
			12) send_stats "健康檢測與修復"
				openclaw doctor --fix
				send_stats "OpenClaw API同步觸發"
				if sync_openclaw_api_models; then
					start_gateway
				else
					echo "❌ API 模型同步失敗，已中止重新啟動網關。請檢查 provider /models 返回後重試。"
				fi
				break_end
			 	;;
			13) openclaw_webui_menu ;;
			14) send_stats "TUI命令列對話"
				openclaw tui
				break_end
			 	;;
			15) openclaw_memory_menu ;;
			16) openclaw_permission_menu ;;
			17) openclaw_multiagent_menu ;;
			18) openclaw_backup_restore_menu ;;
			19) update_moltbot ;;
			20) uninstall_moltbot ;;
			*) break ;;
		esac
	done

}




linux_panel() {

local sub_choice="$1"

clear
cd ~
install git
echo -e "${gl_kjlan}正在更新應用程式清單請稍等…${gl_bai}"
if [ ! -d apps/.git ]; then
	timeout 10s git clone ${gh_proxy}github.com/kejilion/apps.git
else
	cd apps
	# git pull origin main > /dev/null 2>&1
	timeout 10s git pull ${gh_proxy}github.com/kejilion/apps.git main > /dev/null 2>&1
fi

while true; do

	if [ -z "$sub_choice" ]; then
	  clear
	  echo -e "應用市場"
	  echo -e "${gl_kjlan}-------------------------"

	  local app_numbers=$([ -f /home/docker/appno.txt ] && cat /home/docker/appno.txt || echo "")

	  # 用循環設定顏色
	  for i in {1..150}; do
		  if echo "$app_numbers" | grep -q "^$i$"; then
			  declare "color$i=${gl_lv}"
		  else
			  declare "color$i=${gl_bai}"
		  fi
	  done

	  echo -e "${gl_kjlan}1.   ${color1}寶塔面板官方版${gl_kjlan}2.   ${color2}aaPanel寶塔國際版"
	  echo -e "${gl_kjlan}3.   ${color3}1Panel新一代管理面板${gl_kjlan}4.   ${color4}NginxProxyManager視覺化面板"
	  echo -e "${gl_kjlan}5.   ${color5}OpenList多重儲存文件列表程序${gl_kjlan}6.   ${color6}Ubuntu遠端桌面網頁版"
	  echo -e "${gl_kjlan}7.   ${color7}哪吒探針VPS監控面板${gl_kjlan}8.   ${color8}QB離線BT磁力下載面板"
	  echo -e "${gl_kjlan}9.   ${color9}Poste.io郵件伺服器程式${gl_kjlan}10.  ${color10}RocketChat多人線上聊天系統"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}11.  ${color11}禪道專案管理軟體${gl_kjlan}12.  ${color12}青龍面板定時任務管理平台"
	  echo -e "${gl_kjlan}13.  ${color13}Cloudreve網盤${gl_huang}★${gl_bai}                     ${gl_kjlan}14.  ${color14}簡單圖床圖片管理程序"
	  echo -e "${gl_kjlan}15.  ${color15}emby多媒體管理系統${gl_kjlan}16.  ${color16}Speedtest測速板"
	  echo -e "${gl_kjlan}17.  ${color17}AdGuardHome去廣告軟體${gl_kjlan}18.  ${color18}onlyoffice線上辦公OFFICE"
	  echo -e "${gl_kjlan}19.  ${color19}雷池WAF防火牆面板${gl_kjlan}20.  ${color20}portainer容器管理面板"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}21.  ${color21}VScode網頁版${gl_kjlan}22.  ${color22}UptimeKuma監控工具"
	  echo -e "${gl_kjlan}23.  ${color23}Memos網頁備忘錄${gl_kjlan}24.  ${color24}Webtop遠端桌面網頁版${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}25.  ${color25}Nextcloud網站${gl_kjlan}26.  ${color26}QD-Today定時任務管理框架"
	  echo -e "${gl_kjlan}27.  ${color27}Dockge容器堆疊管理面板${gl_kjlan}28.  ${color28}LibreSpeed測速工具"
	  echo -e "${gl_kjlan}29.  ${color29}searxng聚合搜尋站${gl_huang}★${gl_bai}                 ${gl_kjlan}30.  ${color30}PhotoPrism私有相簿系統"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}31.  ${color31}StirlingPDF工具大全${gl_kjlan}32.  ${color32}drawio免費的線上圖表軟體${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}33.  ${color33}Sun-Panel導航面板${gl_kjlan}34.  ${color34}Pingvin-Share文件分享平台"
	  echo -e "${gl_kjlan}35.  ${color35}極簡朋友圈${gl_kjlan}36.  ${color36}LobeChatAI聊天聚合網站"
	  echo -e "${gl_kjlan}37.  ${color37}MyIP工具箱${gl_huang}★${gl_bai}                        ${gl_kjlan}38.  ${color38}小雅alist全家桶"
	  echo -e "${gl_kjlan}39.  ${color39}Bililive直播錄影工具${gl_kjlan}40.  ${color40}webssh網頁版SSH連線工具"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}41.  ${color41}耗子管理面板${gl_kjlan}42.  ${color42}Nexterm遠端連線工具"
	  echo -e "${gl_kjlan}43.  ${color43}RustDesk遠端桌面(服務端)${gl_huang}★${gl_bai}          ${gl_kjlan}44.  ${color44}RustDesk遠端桌面(中繼端)${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}45.  ${color45}Docker加速站${gl_kjlan}46.  ${color46}GitHub加速站${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}47.  ${color47}普羅米修斯監控${gl_kjlan}48.  ${color48}普羅米修斯(主機監控)"
	  echo -e "${gl_kjlan}49.  ${color49}普羅米修斯(容器監控)${gl_kjlan}50.  ${color50}補貨監控工具"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}51.  ${color51}PVE開小雞面板${gl_kjlan}52.  ${color52}DPanel容器管理面板"
	  echo -e "${gl_kjlan}53.  ${color53}llama3聊天AI大模型${gl_kjlan}54.  ${color54}AMH主機建站管理面板"
	  echo -e "${gl_kjlan}55.  ${color55}FRP內網穿透(服務端)${gl_huang}★${gl_bai}	         ${gl_kjlan}56.  ${color56}FRP內網穿透(客戶端)${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}57.  ${color57}Deepseek聊天AI大模型${gl_kjlan}58.  ${color58}Dify大模型知識庫${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}59.  ${color59}NewAPI大模型資產管理${gl_kjlan}60.  ${color60}JumpServer開源堡壘機"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}61.  ${color61}線上翻譯伺服器${gl_kjlan}62.  ${color62}RAGFlow大模型知識庫"
	  echo -e "${gl_kjlan}63.  ${color63}OpenWebUI自架AI平台${gl_huang}★${gl_bai}             ${gl_kjlan}64.  ${color64}it-tools工具箱"
	  echo -e "${gl_kjlan}65.  ${color65}n8n自動化工作流程平台${gl_huang}★${gl_bai}               ${gl_kjlan}66.  ${color66}yt-dlp影片下載工具"
	  echo -e "${gl_kjlan}67.  ${color67}ddns-go動態DNS管理工具${gl_huang}★${gl_bai}            ${gl_kjlan}68.  ${color68}AllinSSL憑證管理平台"
	  echo -e "${gl_kjlan}69.  ${color69}SFTPGo檔案傳輸工具${gl_kjlan}70.  ${color70}AstrBot聊天機器人框架"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}71.  ${color71}Navidrome私有音樂伺服器${gl_kjlan}72.  ${color72}bitwarden密碼管理器${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}73.  ${color73}LibreTV私有影視${gl_kjlan}74.  ${color74}MoonTV私有影視"
	  echo -e "${gl_kjlan}75.  ${color75}Melody音樂精靈${gl_kjlan}76.  ${color76}線上DOS老遊戲"
	  echo -e "${gl_kjlan}77.  ${color77}迅雷離線下載工具${gl_kjlan}78.  ${color78}PandaWiki智慧文件管理系統"
	  echo -e "${gl_kjlan}79.  ${color79}Beszel伺服器監控${gl_kjlan}80.  ${color80}linkwarden書籤管理"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}81.  ${color81}JitsiMeet視訊會議${gl_kjlan}82.  ${color82}gpt-load高性能AI透明代理"
	  echo -e "${gl_kjlan}83.  ${color83}komari伺服器監控工具${gl_kjlan}84.  ${color84}Wallos個人財務管理工具"
	  echo -e "${gl_kjlan}85.  ${color85}immich圖片影片管理器${gl_kjlan}86.  ${color86}jellyfin媒體管理系統"
	  echo -e "${gl_kjlan}87.  ${color87}SyncTV一起看片神器${gl_kjlan}88.  ${color88}Owncast自架直播平台"
	  echo -e "${gl_kjlan}89.  ${color89}FileCodeBox檔案快遞${gl_kjlan}90.  ${color90}matrix去中心化聊天協議"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}91.  ${color91}gitea私有程式碼倉庫${gl_kjlan}92.  ${color92}FileBrowser文件管理器"
	  echo -e "${gl_kjlan}93.  ${color93}Dufs極簡靜態檔案伺服器${gl_kjlan}94.  ${color94}Gopeed高速下載工具"
	  echo -e "${gl_kjlan}95.  ${color95}paperless文件管理平台${gl_kjlan}96.  ${color96}2FAuth自架二步驟驗證器"
	  echo -e "${gl_kjlan}97.  ${color97}WireGuard組網(服務端)${gl_kjlan}98.  ${color98}WireGuard組網(客戶端)"
	  echo -e "${gl_kjlan}99.  ${color99}DSM群暉虛擬機${gl_kjlan}100. ${color100}Syncthing點對點檔案同步工具"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}101. ${color101}AI影片產生工具${gl_kjlan}102. ${color102}VoceChat多人線上聊天系統"
	  echo -e "${gl_kjlan}103. ${color103}Umami網站統計工具${gl_kjlan}104. ${color104}Stream四層代理轉送工具"
	  echo -e "${gl_kjlan}105. ${color105}思源筆記${gl_kjlan}106. ${color106}Drawnix開源白板工具"
	  echo -e "${gl_kjlan}107. ${color107}PanSou網盤搜尋${gl_kjlan}108. ${color108}LangBot聊天機器人"
	  echo -e "${gl_kjlan}109. ${color109}ZFile線上網路磁碟${gl_kjlan}110. ${color110}Karakeep書籤管理"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}111. ${color111}多格式檔案轉換工具${gl_kjlan}112. ${color112}Lucky大內網穿透工具"
	  echo -e "${gl_kjlan}113. ${color113}Firefox瀏覽器${gl_kjlan}114. ${color114}OpenClaw機器人管理工具${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}第三方應用程式列表"
  	  echo -e "${gl_kjlan}想要讓你的應用程式出現在這裡？查看開發者指南:${gl_huang}https://dev.kejilion.sh/${gl_bai}"

	  for f in "$HOME"/apps/*.conf; do
		  [ -e "$f" ] || continue
		  local base_name=$(basename "$f" .conf)
		  # 取得應用描述
		  local app_text=$(grep "app_text=" "$f" | cut -d'=' -f2 | tr -d '"' | tr -d "'")

		  # 檢查安裝狀態 (匹配 appno.txt 中的 ID)
		  # 這裡假設 appno.txt 中記錄的是 base_name (即檔名)
		  if echo "$app_numbers" | grep -q "^$base_name$"; then
			  # 如果已安裝：顯示 base_name - 描述 [已安裝] (綠色)
			  echo -e "${gl_kjlan}$base_name${gl_bai} - ${gl_lv}$app_text[已安裝]${gl_bai}"
		  else
			  # 如果未安裝：正常顯示
			  echo -e "${gl_kjlan}$base_name${gl_bai} - $app_text"
		  fi
	  done



	  echo -e "${gl_kjlan}-------------------------"
	  echo -e "${gl_kjlan}b.   ${gl_bai}備份全部應用數據${gl_kjlan}r.   ${gl_bai}還原全部應用數據"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}0.   ${gl_bai}返回主選單"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "請輸入你的選擇:" sub_choice
	fi

	case $sub_choice in
	  1|bt|baota)
		local app_id="1"
		local lujing="[ -d "/www/server/panel" ]"
		local panelname="寶塔面板"
		local panelurl="https://www.bt.cn/new/index.html"

		panel_app_install() {
			if [ -f /usr/bin/curl ];then curl -sSO https://download.bt.cn/install/install_panel.sh;else wget -O install_panel.sh https://download.bt.cn/install/install_panel.sh;fi;bash install_panel.sh ed8484bec
		}

		panel_app_manage() {
			bt
		}

		panel_app_uninstall() {
			curl -o bt-uninstall.sh http://download.bt.cn/install/bt-uninstall.sh > /dev/null 2>&1 && chmod +x bt-uninstall.sh && ./bt-uninstall.sh
			chmod +x bt-uninstall.sh
			./bt-uninstall.sh
		}

		install_panel



		  ;;
	  2|aapanel)


		local app_id="2"
		local lujing="[ -d "/www/server/panel" ]"
		local panelname="aapanel"
		local panelurl="https://www.aapanel.com/new/index.html"

		panel_app_install() {
			URL=https://www.aapanel.com/script/install_7.0_en.sh && if [ -f /usr/bin/curl ];then curl -ksSO "$URL" ;else wget --no-check-certificate -O install_7.0_en.sh "$URL";fi;bash install_7.0_en.sh aapanel
		}

		panel_app_manage() {
			bt
		}

		panel_app_uninstall() {
			curl -o bt-uninstall.sh http://download.bt.cn/install/bt-uninstall.sh > /dev/null 2>&1 && chmod +x bt-uninstall.sh && ./bt-uninstall.sh
			chmod +x bt-uninstall.sh
			./bt-uninstall.sh
		}

		install_panel

		  ;;
	  3|1p|1panel)

		local app_id="3"
		local lujing="command -v 1pctl"
		local panelname="1Panel"
		local panelurl="https://1panel.cn/"

		panel_app_install() {
			install bash
			bash -c "$(curl -sSL https://resource.fit2cloud.com/1panel/package/v2/quick_start.sh)"
		}

		panel_app_manage() {
			1pctl user-info
			1pctl update password
		}

		panel_app_uninstall() {
			1pctl uninstall
		}

		install_panel

		  ;;
	  4|npm)

		local app_id="4"
		local docker_name="npm"
		local docker_img="jc21/nginx-proxy-manager:latest"
		local docker_port=81

		docker_rum() {

			docker run -d \
			  --name=$docker_name \
			  -p ${docker_port}:81 \
			  -p 80:80 \
			  -p 443:443 \
			  -v /home/docker/npm/data:/data \
			  -v /home/docker/npm/letsencrypt:/etc/letsencrypt \
			  --restart=always \
			  $docker_img


		}

		local docker_describe="一個Nginx反向代理工具面板，不支援新增網域存取。"
		local docker_url="官網介紹: https://nginxproxymanager.com/"
		local docker_use="echo \"初始使用者名稱: admin@example.com\""
		local docker_passwd="echo \"初始密碼: changeme\""
		local app_size="1"

		docker_app

		  ;;

	  5|openlist)

		local app_id="5"
		local docker_name="openlist"
		local docker_img="openlistteam/openlist:latest-aria2"
		local docker_port=5244

		docker_rum() {

			mkdir -p /home/docker/openlist
			chmod -R 777 /home/docker/openlist

			docker run -d \
				--restart=always \
				-v /home/docker/openlist:/opt/openlist/data \
				-p ${docker_port}:5244 \
				-e PUID=0 \
				-e PGID=0 \
				-e UMASK=022 \
				--name="openlist" \
				openlistteam/openlist:latest-aria2

		}


		local docker_describe="一個支援多種存儲，支援網頁瀏覽和 WebDAV 的文件列表程序，由 gin 和 Solidjs 驅動"
		local docker_url="官網介紹:${gh_https_url}github.com/OpenListTeam/OpenList"
		local docker_use="docker exec openlist ./openlist admin random"
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;

	  6|webtop-ubuntu)

		local app_id="6"
		local docker_name="webtop-ubuntu"
		local docker_img="lscr.io/linuxserver/webtop:ubuntu-kde"
		local docker_port=3006

		docker_rum() {

			read -e -p "設定登入用戶名:" admin
			read -e -p "設定登入用戶密碼:" admin_password
			docker run -d \
			  --name=webtop-ubuntu \
			  --security-opt seccomp=unconfined \
			  -e PUID=1000 \
			  -e PGID=1000 \
			  -e TZ=Etc/UTC \
			  -e SUBFOLDER=/ \
			  -e TITLE=Webtop \
			  -e CUSTOM_USER=${admin} \
			  -e PASSWORD=${admin_password} \
			  -p ${docker_port}:3000 \
			  -v /home/docker/webtop/data:/config \
			  -v /var/run/docker.sock:/var/run/docker.sock \
			  --shm-size="1gb" \
			  --restart=always \
			  lscr.io/linuxserver/webtop:ubuntu-kde


		}


		local docker_describe="webtop基於Ubuntu的容器。若IP無法訪問，請新增網域訪問。"
		local docker_url="官網介紹: https://docs.linuxserver.io/images/docker-webtop/"
		local docker_use=""
		local docker_passwd=""
		local app_size="2"
		docker_app


		  ;;
	  7|nezha)
		clear
		send_stats "搭建哪吒"

		local app_id="7"
		local docker_name="nezha-dashboard"
		local docker_port=8008
		while true; do
			check_docker_app
			check_docker_image_update $docker_name
			clear
			echo -e "哪吒監控$check_docker $update_status"
			echo "開源、輕量、易用的伺服器監控與維運工具"
			echo "官網搭建文件: https://nezha.wiki/guide/dashboard.html"
			if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name"; then
				local docker_port=$(docker port $docker_name | awk -F'[:]' '/->/ {print $NF}' | uniq)
				check_docker_app_ip
			fi
			echo ""
			echo "------------------------"
			echo "1. 使用"
			echo "------------------------"
			echo "0. 返回上一級選單"
			echo "------------------------"
			read -e -p "輸入你的選擇:" choice

			case $choice in
				1)
					check_disk_space 1
					install unzip jq
					install_docker
					curl -sL ${gh_proxy}raw.githubusercontent.com/nezhahq/scripts/refs/heads/main/install.sh -o nezha.sh && chmod +x nezha.sh && ./nezha.sh
					local docker_port=$(docker port $docker_name | awk -F'[:]' '/->/ {print $NF}' | uniq)
					check_docker_app_ip
					;;

				*)
					break
					;;

			esac
			break_end
		done
		  ;;

	  8|qb|QB)

		local app_id="8"
		local docker_name="qbittorrent"
		local docker_img="lscr.io/linuxserver/qbittorrent:latest"
		local docker_port=8081

		docker_rum() {

			docker run -d \
			  --name=qbittorrent \
			  -e PUID=1000 \
			  -e PGID=1000 \
			  -e TZ=Etc/UTC \
			  -e WEBUI_PORT=${docker_port} \
			  -e TORRENTING_PORT=56881 \
			  -p ${docker_port}:${docker_port} \
			  -p 56881:56881 \
			  -p 56881:56881/udp \
			  -v /home/docker/qbittorrent/config:/config \
			  -v /home/docker/qbittorrent/downloads:/downloads \
			  --restart=always \
			  lscr.io/linuxserver/qbittorrent:latest

		}

		local docker_describe="qbittorrent離線BT磁力下載服務"
		local docker_url="官網介紹: https://hub.docker.com/r/linuxserver/qbittorrent"
		local docker_use="sleep 3"
		local docker_passwd="docker logs qbittorrent"
		local app_size="1"
		docker_app

		  ;;

	  9|mail)
		send_stats "搭建郵局"
		clear
		install telnet
		local app_id="9"
		local docker_name=“mailserver”
		while true; do
			check_docker_app
			check_docker_image_update $docker_name

			clear
			echo -e "郵局服務$check_docker $update_status"
			echo "poste.io 是一個開源的郵件伺服器解決方案，"
			echo "影片介紹: https://www.bilibili.com/video/BV1wv421C71t?t=0.1"

			echo ""
			echo "連接埠偵測"
			port=25
			timeout=3
			if echo "quit" | timeout $timeout telnet smtp.qq.com $port | grep 'Connected'; then
			  echo -e "${gl_lv}連接埠$port目前可用${gl_bai}"
			else
			  echo -e "${gl_hong}連接埠$port目前不可用${gl_bai}"
			fi
			echo ""

			if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name"; then
				yuming=$(cat /home/docker/mail.txt)
				echo "訪問地址:"
				echo "https://$yuming"
			fi

			echo "------------------------"
			echo "1. 安裝 2. 更新 3. 卸載"
			echo "------------------------"
			echo "0. 返回上一級選單"
			echo "------------------------"
			read -e -p "輸入你的選擇:" choice

			case $choice in
				1)
					setup_docker_dir
					check_disk_space 2 /home/docker
					read -e -p "請設定郵箱網域名稱 例如 mail.yuming.com :" yuming
					mkdir -p /home/docker
					echo "$yuming" > /home/docker/mail.txt
					echo "------------------------"
					ip_address
					echo "先解析這些DNS記錄"
					echo "A           mail            $ipv4_address"
					echo "CNAME       imap            $yuming"
					echo "CNAME       pop             $yuming"
					echo "CNAME       smtp            $yuming"
					echo "MX          @               $yuming"
					echo "TXT         @               v=spf1 mx ~all"
					echo "TXT         ?               ?"
					echo ""
					echo "------------------------"
					echo "按任意鍵繼續..."
					read -n 1 -s -r -p ""

					install jq
					install_docker

					docker run \
						--net=host \
						-e TZ=Europe/Prague \
						-v /home/docker/mail:/data \
						--name "mailserver" \
						-h "$yuming" \
						--restart=always \
						-d analogic/poste.io


					add_app_id

					clear
					echo "poste.io已經安裝完成"
					echo "------------------------"
					echo "您可以使用以下地址存取poste.io:"
					echo "https://$yuming"
					echo ""

					;;

				2)
					docker rm -f mailserver
					docker rmi -f analogic/poste.i
					yuming=$(cat /home/docker/mail.txt)
					docker run \
						--net=host \
						-e TZ=Europe/Prague \
						-v /home/docker/mail:/data \
						--name "mailserver" \
						-h "$yuming" \
						--restart=always \
						-d analogic/poste.i


					add_app_id

					clear
					echo "poste.io已經安裝完成"
					echo "------------------------"
					echo "您可以使用以下地址存取poste.io:"
					echo "https://$yuming"
					echo ""
					;;
				3)
					docker rm -f mailserver
					docker rmi -f analogic/poste.io
					rm /home/docker/mail.txt
					rm -rf /home/docker/mail

					sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
					echo "應用程式已解除安裝"
					;;

				*)
					break
					;;

			esac
			break_end
		done

		  ;;

	  10|rocketchat)

		local app_id="10"
		local app_name="Rocket.Chat聊天系統"
		local app_text="Rocket.Chat 是一個開源的團隊通訊平台，支援即時聊天、音訊視訊通話、檔案共享等多種功能，"
		local app_url="官方介紹: https://www.rocket.chat/"
		local docker_name="rocketchat"
		local docker_port="3897"
		local app_size="2"

		docker_app_install() {
			docker run --name db -d --restart=always \
				-v /home/docker/mongo/dump:/dump \
				mongo:latest --replSet rs5 --oplogSize 256
			sleep 1
			docker exec db mongosh --eval "printjson(rs.initiate())"
			sleep 5
			docker run --name rocketchat --restart=always -p ${docker_port}:3000 --link db --env ROOT_URL=http://localhost --env MONGO_OPLOG_URL=mongodb://db:27017/rs5 -d rocket.chat

			clear
			ip_address
			echo "已經安裝完成"
			check_docker_app_ip
		}

		docker_app_update() {
			docker rm -f rocketchat
			docker rmi -f rocket.chat:latest
			docker run --name rocketchat --restart=always -p ${docker_port}:3000 --link db --env ROOT_URL=http://localhost --env MONGO_OPLOG_URL=mongodb://db:27017/rs5 -d rocket.chat
			clear
			ip_address
			echo "rocket.chat已經安裝完成"
			check_docker_app_ip
		}

		docker_app_uninstall() {
			docker rm -f rocketchat
			docker rmi -f rocket.chat
			docker rm -f db
			docker rmi -f mongo:latest
			rm -rf /home/docker/mongo
			echo "應用程式已解除安裝"
		}

		docker_app_plus
		  ;;



	  11|zentao)
		local app_id="11"
		local docker_name="zentao-server"
		local docker_img="idoop/zentao:latest"
		local docker_port=82


		docker_rum() {


			docker run -d -p ${docker_port}:80 \
			  -e ADMINER_USER="root" -e ADMINER_PASSWD="password" \
			  -e BIND_ADDRESS="false" \
			  -v /home/docker/zentao-server/:/opt/zbox/ \
			  --add-host smtp.exmail.qq.com:163.177.90.125 \
			  --name zentao-server \
			  --restart=always \
			  idoop/zentao:latest


		}

		local docker_describe="禪道是通用的專案管理軟體"
		local docker_url="官網介紹: https://www.zentao.net/"
		local docker_use="echo \"初始使用者名稱: admin\""
		local docker_passwd="echo \"初始密碼: 123456\""
		local app_size="2"
		docker_app

		  ;;

	  12|qinglong)
		local app_id="12"
		local docker_name="qinglong"
		local docker_img="whyour/qinglong:latest"
		local docker_port=5700

		docker_rum() {


			docker run -d \
			  -v /home/docker/qinglong/data:/ql/data \
			  -p ${docker_port}:5700 \
			  --name qinglong \
			  --hostname qinglong \
			  --restart=always \
			  whyour/qinglong:latest


		}

		local docker_describe="青龍面板是一個定時任務管理平台"
		local docker_url="官網介紹:${gh_proxy}github.com/whyour/qinglong"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;
	  13|cloudreve)

		local app_id="13"
		local app_name="cloudreve網盤"
		local app_text="cloudreve是一個支援多家雲端儲存的網盤系統"
		local app_url="影片介紹: https://www.bilibili.com/video/BV13F4m1c7h7?t=0.1"
		local docker_name="cloudreve"
		local docker_port="5212"
		local app_size="2"

		docker_app_install() {
			cd /home/ && mkdir -p docker/cloud && cd docker/cloud && mkdir temp_data && mkdir -vp cloudreve/{uploads,avatar} && touch cloudreve/conf.ini && touch cloudreve/cloudreve.db && mkdir -p aria2/config && mkdir -p data/aria2 && chmod -R 777 data/aria2
			curl -o /home/docker/cloud/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/kejilion/docker/main/cloudreve-docker-compose.yml
			sed -i "s/5212:5212/${docker_port}:5212/g" /home/docker/cloud/docker-compose.yml
			cd /home/docker/cloud/
			docker compose up -d
			clear
			echo "已經安裝完成"
			check_docker_app_ip
		}


		docker_app_update() {
			cd /home/docker/cloud/ && docker compose down --rmi all
			cd /home/docker/cloud/ && docker compose up -d
		}


		docker_app_uninstall() {
			cd /home/docker/cloud/ && docker compose down --rmi all
			rm -rf /home/docker/cloud
			echo "應用程式已解除安裝"
		}

		docker_app_plus
		  ;;

	  14|easyimage)
		local app_id="14"
		local docker_name="easyimage"
		local docker_img="ddsderek/easyimage:latest"
		local docker_port=8014
		docker_rum() {

			docker run -d \
			  --name easyimage \
			  -p ${docker_port}:80 \
			  -e TZ=Asia/Shanghai \
			  -e PUID=1000 \
			  -e PGID=1000 \
			  -v /home/docker/easyimage/config:/app/web/config \
			  -v /home/docker/easyimage/i:/app/web/i \
			  --restart=always \
			  ddsderek/easyimage:latest

		}

		local docker_describe="簡單圖床是一個簡單的圖床程序"
		local docker_url="官網介紹:${gh_proxy}github.com/icret/EasyImages2.0"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  15|emby)
		local app_id="15"
		local docker_name="emby"
		local docker_img="linuxserver/emby:latest"
		local docker_port=8015

		docker_rum() {

			docker run -d --name=emby --restart=always \
				-v /home/docker/emby/config:/config \
				-v /home/docker/emby/share1:/mnt/share1 \
				-v /home/docker/emby/share2:/mnt/share2 \
				-v /mnt/notify:/mnt/notify \
				-p ${docker_port}:8096 \
				-e UID=1000 -e GID=100 -e GIDLIST=100 \
				linuxserver/emby:latest

		}


		local docker_describe="emby是一個主從式架構的媒體伺服器軟體，可以用來整理伺服器上的視訊和音頻，並將音頻和視訊串流傳輸到客戶端設備"
		local docker_url="官網介紹: https://emby.media/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  16|looking)
		local app_id="16"
		local docker_name="looking-glass"
		local docker_img="wikihostinc/looking-glass-server"
		local docker_port=8016


		docker_rum() {

			docker run -d --name looking-glass --restart=always -p ${docker_port}:80 wikihostinc/looking-glass-server

		}

		local docker_describe="Speedtest測速面板是VPS網路速度測試工具，多項測試功能，還可以即時監控VPS進出站流量"
		local docker_url="官網介紹:${gh_proxy}github.com/wikihost-opensource/als"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;
	  17|adguardhome)

		local app_id="17"
		local docker_name="adguardhome"
		local docker_img="adguard/adguardhome"
		local docker_port=8017

		docker_rum() {

			docker run -d \
				--name adguardhome \
				-v /home/docker/adguardhome/work:/opt/adguardhome/work \
				-v /home/docker/adguardhome/conf:/opt/adguardhome/conf \
				-p 53:53/tcp \
				-p 53:53/udp \
				-p ${docker_port}:3000/tcp \
				--restart=always \
				adguard/adguardhome


		}


		local docker_describe="AdGuardHome是一款全網廣告攔截與反追蹤軟體，未來不只一個DNS伺服器。"
		local docker_url="官網介紹: https://hub.docker.com/r/adguard/adguardhome"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  18|onlyoffice)

		local app_id="18"
		local docker_name="onlyoffice"
		local docker_img="onlyoffice/documentserver"
		local docker_port=8018

		docker_rum() {

			docker run -d -p ${docker_port}:80 \
				--restart=always \
				--name onlyoffice \
				-v /home/docker/onlyoffice/DocumentServer/logs:/var/log/onlyoffice  \
				-v /home/docker/onlyoffice/DocumentServer/data:/var/www/onlyoffice/Data  \
				 onlyoffice/documentserver


		}

		local docker_describe="onlyoffice是一款開源的線上office工具，太強大了！"
		local docker_url="官網介紹: https://www.onlyoffice.com/"
		local docker_use=""
		local docker_passwd=""
		local app_size="2"
		docker_app

		  ;;

	  19|safeline)
		send_stats "搭建雷池"

		local app_id="19"
		local docker_name=safeline-mgt
		local docker_port=9443
		while true; do
			check_docker_app
			clear
			echo -e "雷池服務$check_docker"
			echo "雷池是長亭科技開發的WAF站點防火牆程式面板，可反代站點進行自動化防禦"
			echo "影片介紹: https://www.bilibili.com/video/BV1mZ421T74c?t=0.1"
			if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "$docker_name"; then
				check_docker_app_ip
			fi
			echo ""

			echo "------------------------"
			echo "1. 安裝 2. 更新 3. 重設密碼 4. 解除安裝"
			echo "------------------------"
			echo "0. 返回上一級選單"
			echo "------------------------"
			read -e -p "輸入你的選擇:" choice

			case $choice in
				1)
					install_docker
					check_disk_space 5
					bash -c "$(curl -fsSLk https://waf-ce.chaitin.cn/release/latest/setup.sh)"

					add_app_id
					clear
					echo "雷池WAF面板已經安裝完成"
					check_docker_app_ip
					docker exec safeline-mgt resetadmin

					;;

				2)
					bash -c "$(curl -fsSLk https://waf-ce.chaitin.cn/release/latest/upgrade.sh)"
					docker rmi $(docker images | grep "safeline" | grep "none" | awk '{print $3}')
					echo ""

					add_app_id
					clear
					echo "雷池WAF面板已經更新完成"
					check_docker_app_ip
					;;
				3)
					docker exec safeline-mgt resetadmin
					;;
				4)
					cd /data/safeline
					docker compose down --rmi all

					sed -i "/\b${app_id}\b/d" /home/docker/appno.txt
					echo "如果你是預設安裝目錄那現在項目已經卸載。如果你是自訂安裝目錄你需要到安裝目錄下自行執行:"
					echo "docker compose down && docker compose down --rmi all"
					;;
				*)
					break
					;;

			esac
			break_end
		done

		  ;;

	  20|portainer)
		local app_id="20"
		local docker_name="portainer"
		local docker_img="portainer/portainer"
		local docker_port=8020

		docker_rum() {

			docker run -d \
				--name portainer \
				-p ${docker_port}:9000 \
				-v /var/run/docker.sock:/var/run/docker.sock \
				-v /home/docker/portainer:/data \
				--restart=always \
				portainer/portainer

		}


		local docker_describe="portainer是一個輕量級的docker容器管理面板"
		local docker_url="官網介紹: https://www.portainer.io/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;

	  21|vscode)
		local app_id="21"
		local docker_name="vscode-web"
		local docker_img="codercom/code-server"
		local docker_port=8021


		docker_rum() {

			docker run -d -p ${docker_port}:8080 -v /home/docker/vscode-web:/home/coder/.local/share/code-server --name vscode-web --restart=always codercom/code-server

		}


		local docker_describe="VScode是一款強大的線上程式碼編寫工具"
		local docker_url="官網介紹:${gh_proxy}github.com/coder/code-server"
		local docker_use="sleep 3"
		local docker_passwd="docker exec vscode-web cat /home/coder/.config/code-server/config.yaml"
		local app_size="1"
		docker_app
		  ;;


	  22|uptime-kuma)
		local app_id="22"
		local docker_name="uptime-kuma"
		local docker_img="louislam/uptime-kuma:latest"
		local docker_port=8022


		docker_rum() {

			docker run -d \
				--name=uptime-kuma \
				-p ${docker_port}:3001 \
				-v /home/docker/uptime-kuma/uptime-kuma-data:/app/data \
				--restart=always \
				louislam/uptime-kuma:latest

		}


		local docker_describe="Uptime Kuma 易於使用的自架監控工具"
		local docker_url="官網介紹:${gh_proxy}github.com/louislam/uptime-kuma"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  23|memos)
		local app_id="23"
		local docker_name="memos"
		local docker_img="neosmemo/memos:stable"
		local docker_port=8023

		docker_rum() {

			docker run -d --name memos -p ${docker_port}:5230 -v /home/docker/memos:/var/opt/memos --restart=always neosmemo/memos:stable

		}

		local docker_describe="Memos是一款輕量、自架的備忘錄中心"
		local docker_url="官網介紹:${gh_proxy}github.com/usememos/memos"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  24|webtop)
		local app_id="24"
		local docker_name="webtop"
		local docker_img="lscr.io/linuxserver/webtop:latest"
		local docker_port=8024

		docker_rum() {

			read -e -p "設定登入用戶名:" admin
			read -e -p "設定登入用戶密碼:" admin_password
			docker run -d \
			  --name=webtop \
			  --security-opt seccomp=unconfined \
			  -e PUID=1000 \
			  -e PGID=1000 \
			  -e TZ=Etc/UTC \
			  -e SUBFOLDER=/ \
			  -e TITLE=Webtop \
			  -e CUSTOM_USER=${admin} \
			  -e PASSWORD=${admin_password} \
			  -e LC_ALL=zh_CN.UTF-8 \
			  -e DOCKER_MODS=linuxserver/mods:universal-package-install \
			  -e INSTALL_PACKAGES=font-noto-cjk \
			  -p ${docker_port}:3000 \
			  -v /home/docker/webtop/data:/config \
			  -v /var/run/docker.sock:/var/run/docker.sock \
			  --shm-size="1gb" \
			  --restart=always \
			  lscr.io/linuxserver/webtop:latest

		}


		local docker_describe="webtop基於Alpine的中文版容器。若IP無法訪問，請新增網域訪問。"
		local docker_url="官網介紹: https://docs.linuxserver.io/images/docker-webtop/"
		local docker_use=""
		local docker_passwd=""
		local app_size="2"
		docker_app
		  ;;

	  25|nextcloud)
		local app_id="25"
		local docker_name="nextcloud"
		local docker_img="nextcloud:latest"
		local docker_port=8025
		local rootpasswd=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16)

		docker_rum() {

			docker run -d --name nextcloud --restart=always -p ${docker_port}:80 -v /home/docker/nextcloud:/var/www/html -e NEXTCLOUD_ADMIN_USER=nextcloud -e NEXTCLOUD_ADMIN_PASSWORD=$rootpasswd nextcloud

		}

		local docker_describe="Nextcloud擁有超過 400,000 個部署，是您可以下載的最受歡迎的本地內容協作平台"
		local docker_url="官網介紹: https://nextcloud.com/"
		local docker_use="echo \"帳號: nextcloud 密碼:$rootpasswd\""
		local docker_passwd=""
		local app_size="3"
		docker_app
		  ;;

	  26|qd)
		local app_id="26"
		local docker_name="qd"
		local docker_img="qdtoday/qd:latest"
		local docker_port=8026

		docker_rum() {

			docker run -d --name qd -p ${docker_port}:80 -v /home/docker/qd/config:/usr/src/app/config qdtoday/qd

		}

		local docker_describe="QD-Today是HTTP請求定時任務自動執行框架"
		local docker_url="官網介紹: https://qd-today.github.io/qd/zh_CN/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  27|dockge)
		local app_id="27"
		local docker_name="dockge"
		local docker_img="louislam/dockge:latest"
		local docker_port=8027

		docker_rum() {

			docker run -d --name dockge --restart=always -p ${docker_port}:5001 -v /var/run/docker.sock:/var/run/docker.sock -v /home/docker/dockge/data:/app/data -v  /home/docker/dockge/stacks:/home/docker/dockge/stacks -e DOCKGE_STACKS_DIR=/home/docker/dockge/stacks louislam/dockge

		}

		local docker_describe="dockge是一個可視化的docker-compose容器管理面板"
		local docker_url="官網介紹:${gh_proxy}github.com/louislam/dockge"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  28|speedtest)
		local app_id="28"
		local docker_name="speedtest"
		local docker_img="ghcr.io/librespeed/speedtest"
		local docker_port=8028

		docker_rum() {

			docker run -d -p ${docker_port}:8080 --name speedtest --restart=always ghcr.io/librespeed/speedtest

		}

		local docker_describe="librespeed是用Javascript實現的輕量級速度測試工具，即開即用"
		local docker_url="官網介紹:${gh_proxy}github.com/librespeed/speedtest"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  29|searxng)
		local app_id="29"
		local docker_name="searxng"
		local docker_img="searxng/searxng"
		local docker_port=8029

		docker_rum() {

			docker run -d \
			  --name searxng \
			  --restart=always \
			  -p ${docker_port}:8080 \
			  -v "/home/docker/searxng:/etc/searxng" \
			  searxng/searxng

		}

		local docker_describe="searxng是一個私有且隱私的搜尋引擎站點"
		local docker_url="官網介紹: https://hub.docker.com/r/alandoyle/searxng"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  30|photoprism)
		local app_id="30"
		local docker_name="photoprism"
		local docker_img="photoprism/photoprism:latest"
		local docker_port=8030
		local rootpasswd=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16)

		docker_rum() {

			docker run -d \
				--name photoprism \
				--restart=always \
				--security-opt seccomp=unconfined \
				--security-opt apparmor=unconfined \
				-p ${docker_port}:2342 \
				-e PHOTOPRISM_UPLOAD_NSFW="true" \
				-e PHOTOPRISM_ADMIN_PASSWORD="$rootpasswd" \
				-v /home/docker/photoprism/storage:/photoprism/storage \
				-v /home/docker/photoprism/Pictures:/photoprism/originals \
				photoprism/photoprism

		}


		local docker_describe="photoprism非常強大的私有相簿系統"
		local docker_url="官網介紹: https://www.photoprism.app/"
		local docker_use="echo \"帳號: admin 密碼:$rootpasswd\""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;


	  31|s-pdf)
		local app_id="31"
		local docker_name="s-pdf"
		local docker_img="frooodle/s-pdf:latest"
		local docker_port=8031

		docker_rum() {

			docker run -d \
				--name s-pdf \
				--restart=always \
				 -p ${docker_port}:8080 \
				 -v /home/docker/s-pdf/trainingData:/usr/share/tesseract-ocr/5/tessdata \
				 -v /home/docker/s-pdf/extraConfigs:/configs \
				 -v /home/docker/s-pdf/logs:/logs \
				 -e DOCKER_ENABLE_SECURITY=false \
				 frooodle/s-pdf:latest
		}

		local docker_describe="這是一個強大的本機託管基於 Web 的 PDF 操作工具，使用 docker，可讓您對 PDF 檔案執行各種操作，例如分割合併、轉換、重新組織、新增映像、旋轉、壓縮等。"
		local docker_url="官網介紹:${gh_proxy}github.com/Stirling-Tools/Stirling-PDF"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  32|drawio)
		local app_id="32"
		local docker_name="drawio"
		local docker_img="jgraph/drawio"
		local docker_port=8032

		docker_rum() {

			docker run -d --restart=always --name drawio -p ${docker_port}:8080 -v /home/docker/drawio:/var/lib/drawio jgraph/drawio

		}


		local docker_describe="這是一個強大圖表繪製軟體。心智圖，拓樸圖，流程圖，都能畫"
		local docker_url="官網介紹: https://www.drawio.com/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  33|sun-panel)
		local app_id="33"
		local docker_name="sun-panel"
		local docker_img="hslr/sun-panel"
		local docker_port=8033

		docker_rum() {

			docker run -d --restart=always -p ${docker_port}:3002 \
				-v /home/docker/sun-panel/conf:/app/conf \
				-v /home/docker/sun-panel/uploads:/app/uploads \
				-v /home/docker/sun-panel/database:/app/database \
				--name sun-panel \
				hslr/sun-panel

		}

		local docker_describe="Sun-Panel伺服器、NAS導覽面板、Homepage、瀏覽器首頁"
		local docker_url="官網介紹: https://doc.sun-panel.top/zh_cn/"
		local docker_use="echo \"帳號: admin@sun.cc 密碼: 12345678\""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  34|pingvin-share)
		local app_id="34"
		local docker_name="pingvin-share"
		local docker_img="stonith404/pingvin-share"
		local docker_port=8034

		docker_rum() {

			docker run -d \
				--name pingvin-share \
				--restart=always \
				-p ${docker_port}:3000 \
				-v /home/docker/pingvin-share/data:/opt/app/backend/data \
				stonith404/pingvin-share
		}

		local docker_describe="Pingvin Share 是一個可自建的文件分享平台，是 WeTransfer 的替代品"
		local docker_url="官網介紹:${gh_proxy}github.com/stonith404/pingvin-share"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;


	  35|moments)
		local app_id="35"
		local docker_name="moments"
		local docker_img="kingwrcy/moments:latest"
		local docker_port=8035

		docker_rum() {

			docker run -d --restart=always \
				-p ${docker_port}:3000 \
				-v /home/docker/moments/data:/app/data \
				-v /etc/localtime:/etc/localtime:ro \
				-v /etc/timezone:/etc/timezone:ro \
				--name moments \
				kingwrcy/moments:latest
		}


		local docker_describe="極簡朋友圈，高仿微信朋友圈，記錄你的美好生活"
		local docker_url="官網介紹:${gh_proxy}github.com/kingwrcy/moments?tab=readme-ov-file"
		local docker_use="echo \"帳號: admin 密碼: a123456\""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;



	  36|lobe-chat)
		local app_id="36"
		local docker_name="lobe-chat"
		local docker_img="lobehub/lobe-chat:latest"
		local docker_port=8036

		docker_rum() {

			docker run -d -p ${docker_port}:3210 \
				--name lobe-chat \
				--restart=always \
				lobehub/lobe-chat
		}

		local docker_describe="LobeChat聚合市面上主流的AI大模型，ChatGPT/Claude/Gemini/Groq/Ollama"
		local docker_url="官網介紹:${gh_proxy}github.com/lobehub/lobe-chat"
		local docker_use=""
		local docker_passwd=""
		local app_size="2"
		docker_app
		  ;;

	  37|myip)
		local app_id="37"
		local docker_name="myip"
		local docker_img="jason5ng32/myip:latest"
		local docker_port=8037

		docker_rum() {

			docker run -d -p ${docker_port}:18966 --name myip jason5ng32/myip:latest

		}


		local docker_describe="是多功能IP工具箱，可以查看自己IP資訊及連結性，用網頁面板呈現"
		local docker_url="官網介紹:${gh_proxy}github.com/jason5ng32/MyIP/blob/main/README_ZH.md"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  38|xiaoya)
		send_stats "小雅全家桶"
		clear
		install_docker
		check_disk_space 1
		bash -c "$(curl --insecure -fsSL https://ddsrem.com/xiaoya_install.sh)"
		  ;;

	  39|bililive)

		if [ ! -d /home/docker/bililive-go/ ]; then
			mkdir -p /home/docker/bililive-go/ > /dev/null 2>&1
			wget -O /home/docker/bililive-go/config.yml ${gh_proxy}raw.githubusercontent.com/hr3lxphr6j/bililive-go/master/config.yml > /dev/null 2>&1
		fi

		local app_id="39"
		local docker_name="bililive-go"
		local docker_img="chigusa/bililive-go"
		local docker_port=8039

		docker_rum() {

			docker run --restart=always --name bililive-go -v /home/docker/bililive-go/config.yml:/etc/bililive-go/config.yml -v /home/docker/bililive-go/Videos:/srv/bililive -p ${docker_port}:8080 -d chigusa/bililive-go

		}

		local docker_describe="Bililive-go是一個支援多種直播平台的直播錄製工具"
		local docker_url="官網介紹:${gh_proxy}github.com/hr3lxphr6j/bililive-go"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  40|webssh)
		local app_id="40"
		local docker_name="webssh"
		local docker_img="jrohy/webssh"
		local docker_port=8040
		docker_rum() {
			docker run -d -p ${docker_port}:5032 --restart=always --name webssh -e TZ=Asia/Shanghai jrohy/webssh
		}

		local docker_describe="簡易線上ssh連線工具和sftp工具"
		local docker_url="官網介紹:${gh_proxy}github.com/Jrohy/webssh"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  41|haozi|acepanel)

		local app_id="41"
		local lujing="[ -d "/www/server/panel" ]"
		local panelname="AcePanel 原耗子麵板"
		local panelurl="官方地址:${gh_proxy}github.com/acepanel/panel"

		panel_app_install() {
			cd ~
			bash <(curl -sSLm 10 https://dl.acepanel.net/helper.sh)
		}

		panel_app_manage() {
			acepanel help
		}

		panel_app_uninstall() {
			cd ~
			bash <(curl -sSLm 10 https://dl.acepanel.net/helper.sh)

		}

		install_panel

		  ;;


	  42|nexterm)
		local app_id="42"
		local docker_name="nexterm"
		local docker_img="germannewsmaker/nexterm:latest"
		local docker_port=8042

		docker_rum() {

			ENCRYPTION_KEY=$(openssl rand -hex 32)
			docker run -d \
			  --name nexterm \
			  -e ENCRYPTION_KEY=${ENCRYPTION_KEY} \
			  -p ${docker_port}:6989 \
			  -v /home/docker/nexterm:/app/data \
			  --restart=always \
			  germannewsmaker/nexterm:latest

		}

		local docker_describe="nexterm是一款強大的線上SSH/VNC/RDP連線工具。"
		local docker_url="官網介紹:${gh_proxy}github.com/gnmyt/Nexterm"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  43|hbbs)
		local app_id="43"
		local docker_name="hbbs"
		local docker_img="rustdesk/rustdesk-server"
		local docker_port=0000

		docker_rum() {

			docker run --name hbbs -v /home/docker/hbbs/data:/root -td --net=host --restart=always rustdesk/rustdesk-server hbbs

		}


		local docker_describe="rustdesk開源的遠端桌面(服務端)，類似自己的向日葵私服。"
		local docker_url="官網介紹: https://rustdesk.com/zh-cn/"
		local docker_use="docker logs hbbs"
		local docker_passwd="echo \"把你的IP和key記錄下，會在遠端桌面客戶端中用到。去44選項裝中繼端吧！\""
		local app_size="1"
		docker_app
		  ;;

	  44|hbbr)
		local app_id="44"
		local docker_name="hbbr"
		local docker_img="rustdesk/rustdesk-server"
		local docker_port=0000

		docker_rum() {

			docker run --name hbbr -v /home/docker/hbbr/data:/root -td --net=host --restart=always rustdesk/rustdesk-server hbbr

		}

		local docker_describe="rustdesk開源的遠端桌面(中繼端)，類似自己的向日葵私服。"
		local docker_url="官網介紹: https://rustdesk.com/zh-cn/"
		local docker_use="echo \"前往官網下載遠端桌面的客戶端: https://rustdesk.com/zh-cn/\""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  45|registry)
		local app_id="45"
		local docker_name="registry"
		local docker_img="registry:2"
		local docker_port=8045

		docker_rum() {

			docker run -d \
				-p ${docker_port}:5000 \
				--name registry \
				-v /home/docker/registry:/var/lib/registry \
				-e REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io \
				--restart=always \
				registry:2

		}

		local docker_describe="Docker Registry 是一個用於儲存和分發 Docker 映像的服務。"
		local docker_url="官網介紹: https://hub.docker.com/_/registry"
		local docker_use=""
		local docker_passwd=""
		local app_size="2"
		docker_app
		  ;;

	  46|ghproxy)
		local app_id="46"
		local docker_name="ghproxy"
		local docker_img="wjqserver/ghproxy:latest"
		local docker_port=8046

		docker_rum() {

			docker run -d --name ghproxy --restart=always -p ${docker_port}:8080 -v /home/docker/ghproxy/config:/data/ghproxy/config wjqserver/ghproxy:latest

		}

		local docker_describe="使用Go實現的GHProxy，用於加速部分地區Github倉庫的拉取。"
		local docker_url="官網介紹:${gh_https_url}github.com/WJQSERVER-STUDIO/ghproxy"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  47|prometheus|grafana)

		local app_id="47"
		local app_name="普羅米修斯監控"
		local app_text="Prometheus+Grafana企業級監控系統"
		local app_url="官網介紹: https://prometheus.io"
		local docker_name="grafana"
		local docker_port="8047"
		local app_size="2"

		docker_app_install() {
			prometheus_install
			clear
			ip_address
			echo "已經安裝完成"
			check_docker_app_ip
			echo "初始使用者名稱密碼均為: admin"
		}

		docker_app_update() {
			docker rm -f node-exporter prometheus grafana
			docker rmi -f prom/node-exporter
			docker rmi -f prom/prometheus:latest
			docker rmi -f grafana/grafana:latest
			docker_app_install
		}

		docker_app_uninstall() {
			docker rm -f node-exporter prometheus grafana
			docker rmi -f prom/node-exporter
			docker rmi -f prom/prometheus:latest
			docker rmi -f grafana/grafana:latest

			rm -rf /home/docker/monitoring
			echo "應用程式已解除安裝"
		}

		docker_app_plus
		  ;;

	  48|node-exporter)
		local app_id="48"
		local docker_name="node-exporter"
		local docker_img="prom/node-exporter"
		local docker_port=8048

		docker_rum() {

			docker run -d \
				--name=node-exporter \
				-p ${docker_port}:9100 \
				--restart=always \
				prom/node-exporter


		}

		local docker_describe="這是一個普羅米修斯的主機資料擷取元件，請部署在被監控主機上。"
		local docker_url="官網介紹:${gh_https_url}github.com/prometheus/node_exporter"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  49|cadvisor)
		local app_id="49"
		local docker_name="cadvisor"
		local docker_img="gcr.io/cadvisor/cadvisor:latest"
		local docker_port=8049

		docker_rum() {

			docker run -d \
				--name=cadvisor \
				--restart=always \
				-p ${docker_port}:8080 \
				--volume=/:/rootfs:ro \
				--volume=/var/run:/var/run:rw \
				--volume=/sys:/sys:ro \
				--volume=/var/lib/docker/:/var/lib/docker:ro \
				gcr.io/cadvisor/cadvisor:latest \
				-housekeeping_interval=10s \
				-docker_only=true

		}

		local docker_describe="這是一個普羅米修斯的容器資料擷取元件，請部署在被監控主機上。"
		local docker_url="官網介紹:${gh_https_url}github.com/google/cadvisor"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;


	  50|changedetection)
		local app_id="50"
		local docker_name="changedetection"
		local docker_img="dgtlmoon/changedetection.io:latest"
		local docker_port=8050

		docker_rum() {

			docker run -d --restart=always -p ${docker_port}:5000 \
				-v /home/docker/datastore:/datastore \
				--name changedetection dgtlmoon/changedetection.io:latest

		}

		local docker_describe="這是一個網站變更偵測、補貨監控和通知的小工具"
		local docker_url="官網介紹:${gh_https_url}github.com/dgtlmoon/changedetection.io"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;


	  51|pve)
		clear
		send_stats "PVE開小雞"
		check_disk_space 1
		curl -L ${gh_proxy}raw.githubusercontent.com/oneclickvirt/pve/main/scripts/install_pve.sh -o install_pve.sh && chmod +x install_pve.sh && bash install_pve.sh
		  ;;


	  52|dpanel)
		local app_id="52"
		local docker_name="dpanel"
		local docker_img="dpanel/dpanel:lite"
		local docker_port=8052

		docker_rum() {

			docker run -d --name dpanel --restart=always \
				-p ${docker_port}:8080 -e APP_NAME=dpanel \
				-v /var/run/docker.sock:/var/run/docker.sock \
				-v /home/docker/dpanel:/dpanel \
				dpanel/dpanel:lite

		}

		local docker_describe="Docker視覺化面板系統，提供完善的docker管理功能。"
		local docker_url="官網介紹:${gh_https_url}github.com/donknap/dpanel"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  53|llama3)
		local app_id="53"
		local docker_name="ollama"
		local docker_img="ghcr.io/open-webui/open-webui:ollama"
		local docker_port=8053

		docker_rum() {

			docker run -d -p ${docker_port}:8080 -v /home/docker/ollama:/root/.ollama -v /home/docker/ollama/open-webui:/app/backend/data --name ollama --restart=always ghcr.io/open-webui/open-webui:ollama

		}

		local docker_describe="OpenWebUI一款大語言模型網頁框架，連結全新的llama3大語言模型"
		local docker_url="官網介紹:${gh_https_url}github.com/open-webui/open-webui"
		local docker_use="docker exec ollama ollama run llama3.2:1b"
		local docker_passwd=""
		local app_size="5"
		docker_app
		  ;;

	  54|amh)

		local app_id="54"
		local lujing="[ -d "/www/server/panel" ]"
		local panelname="AMH面板"
		local panelurl="官方地址: https://amh.sh/index.htm?amh"

		panel_app_install() {
			cd ~
			wget https://dl.amh.sh/amh.sh && bash amh.sh
		}

		panel_app_manage() {
			panel_app_install
		}

		panel_app_uninstall() {
			panel_app_install
		}

		install_panel
		  ;;


	  55|frps)
		frps_panel
		  ;;

	  56|frpc)
		frpc_panel
		  ;;

	  57|deepseek)
		local app_id="57"
		local docker_name="ollama"
		local docker_img="ghcr.io/open-webui/open-webui:ollama"
		local docker_port=8053

		docker_rum() {

			docker run -d -p ${docker_port}:8080 -v /home/docker/ollama:/root/.ollama -v /home/docker/ollama/open-webui:/app/backend/data --name ollama --restart=always ghcr.io/open-webui/open-webui:ollama

		}

		local docker_describe="OpenWebUI一款大語言模型網頁框架，連結全新的DeepSeek R1大語言模型"
		local docker_url="官網介紹:${gh_https_url}github.com/open-webui/open-webui"
		local docker_use="docker exec ollama ollama run deepseek-r1:1.5b"
		local docker_passwd=""
		local app_size="5"
		docker_app
		  ;;


	  58|dify)
		local app_id="58"
		local app_name="Dify知識庫"
		local app_text="是一款開源的大語言模型(LLM) 應用開發平台。自託管訓練資料用於AI生成"
		local app_url="官方網站: https://docs.dify.ai/zh-hans"
		local docker_name="docker-nginx-1"
		local docker_port="8058"
		local app_size="3"

		docker_app_install() {
			install git
			mkdir -p  /home/docker/ && cd /home/docker/ && git clone ${gh_proxy}github.com/langgenius/dify.git && cd dify/docker && cp .env.example .env
			sed -i "s/^EXPOSE_NGINX_PORT=.*/EXPOSE_NGINX_PORT=${docker_port}/; s/^EXPOSE_NGINX_SSL_PORT=.*/EXPOSE_NGINX_SSL_PORT=8858/" /home/docker/dify/docker/.env

			docker compose up -d

			chown -R 1001:1001 /home/docker/dify/docker/volumes/app/storage
			chmod -R 755 /home/docker/dify/docker/volumes/app/storage
			docker compose down
			docker compose up -d

			clear
			echo "已經安裝完成"
			check_docker_app_ip
		}

		docker_app_update() {
			cd  /home/docker/dify/docker/ && docker compose down --rmi all
			cd  /home/docker/dify/
			git pull ${gh_proxy}github.com/langgenius/dify.git main > /dev/null 2>&1
			sed -i 's/^EXPOSE_NGINX_PORT=.*/EXPOSE_NGINX_PORT=8058/; s/^EXPOSE_NGINX_SSL_PORT=.*/EXPOSE_NGINX_SSL_PORT=8858/' /home/docker/dify/docker/.env
			cd  /home/docker/dify/docker/ && docker compose up -d
		}

		docker_app_uninstall() {
			cd  /home/docker/dify/docker/ && docker compose down --rmi all
			rm -rf /home/docker/dify
			echo "應用程式已解除安裝"
		}

		docker_app_plus

		  ;;

	  59|new-api)
		local app_id="59"
		local app_name="NewAPI"
		local app_text="新一代大模型閘道與AI資產管理系統"
		local app_url="官方網站:${gh_https_url}github.com/Calcium-Ion/new-api"
		local docker_name="new-api"
		local docker_port="8059"
		local app_size="3"

		docker_app_install() {
			install git
			mkdir -p  /home/docker/ && cd /home/docker/ && git clone ${gh_proxy}github.com/Calcium-Ion/new-api.git && cd new-api

			sed -i -e "s/- \"3000:3000\"/- \"${docker_port}:3000\"/g" \
				   -e 's/container_name: redis/container_name: redis-new-api/g' \
				   -e 's/container_name: mysql/container_name: mysql-new-api/g' \
				   docker-compose.yml


			docker compose up -d
			clear
			echo "已經安裝完成"
			check_docker_app_ip
		}

		docker_app_update() {
			cd  /home/docker/new-api/ && docker compose down --rmi all
			cd  /home/docker/new-api/

			git pull ${gh_proxy}github.com/Calcium-Ion/new-api.git main > /dev/null 2>&1
			sed -i -e "s/- \"3000:3000\"/- \"${docker_port}:3000\"/g" \
				   -e 's/container_name: redis/container_name: redis-new-api/g' \
				   -e 's/container_name: mysql/container_name: mysql-new-api/g' \
				   docker-compose.yml

			docker compose up -d
			clear
			echo "已經安裝完成"
			check_docker_app_ip

		}

		docker_app_uninstall() {
			cd  /home/docker/new-api/ && docker compose down --rmi all
			rm -rf /home/docker/new-api
			echo "應用程式已解除安裝"
		}

		docker_app_plus

		  ;;


	  60|jms)

		local app_id="60"
		local app_name="JumpServer開源堡壘機"
		local app_text="是一個開源的特權存取管理 (PAM) 工具，該程式佔用80連接埠不支援新增網域存取了"
		local app_url="官方介紹:${gh_https_url}github.com/jumpserver/jumpserver"
		local docker_name="jms_web"
		local docker_port="80"
		local app_size="2"

		docker_app_install() {
			curl -sSL ${gh_proxy}github.com/jumpserver/jumpserver/releases/latest/download/quick_start.sh | bash
			clear
			echo "已經安裝完成"
			check_docker_app_ip
			echo "初始使用者名稱: admin"
			echo "初始密碼: ChangeMe"
		}


		docker_app_update() {
			cd /opt/jumpserver-installer*/
			./jmsctl.sh upgrade
			echo "應用程式已更新"
		}


		docker_app_uninstall() {
			cd /opt/jumpserver-installer*/
			./jmsctl.sh uninstall
			cd /opt
			rm -rf jumpserver-installer*/
			rm -rf jumpserver
			echo "應用程式已解除安裝"
		}

		docker_app_plus
		  ;;

	  61|libretranslate)
		local app_id="61"
		local docker_name="libretranslate"
		local docker_img="libretranslate/libretranslate:latest"
		local docker_port=8061

		docker_rum() {

			docker run -d \
				-p ${docker_port}:5000 \
				--name libretranslate \
				libretranslate/libretranslate \
				--load-only ko,zt,zh,en,ja,pt,es,fr,de,ru

		}

		local docker_describe="免費開源機器翻譯 API，完全自託管，它的翻譯引擎由開源Argos Translate庫提供支援。"
		local docker_url="官網介紹:${gh_https_url}github.com/LibreTranslate/LibreTranslate"
		local docker_use=""
		local docker_passwd=""
		local app_size="5"
		docker_app
		  ;;



	  62|ragflow)
		local app_id="62"
		local app_name="RAGFlow知識庫"
		local app_text="基於深度文件理解的開源 RAG（檢索增強生成）引擎"
		local app_url="官方網站:${gh_https_url}github.com/infiniflow/ragflow"
		local docker_name="ragflow-server"
		local docker_port="8062"
		local app_size="8"

		docker_app_install() {
			install git
			mkdir -p  /home/docker/ && cd /home/docker/ && git clone ${gh_proxy}github.com/infiniflow/ragflow.git && cd ragflow/docker
			sed -i "s/- 80:80/- ${docker_port}:80/; /- 443:443/d" docker-compose.yml
			docker compose up -d
			clear
			echo "已經安裝完成"
			check_docker_app_ip
		}

		docker_app_update() {
			cd  /home/docker/ragflow/docker/ && docker compose down --rmi all
			cd  /home/docker/ragflow/
			git pull ${gh_proxy}github.com/infiniflow/ragflow.git main > /dev/null 2>&1
			cd  /home/docker/ragflow/docker/
			sed -i "s/- 80:80/- ${docker_port}:80/; /- 443:443/d" docker-compose.yml
			docker compose up -d
		}

		docker_app_uninstall() {
			cd  /home/docker/ragflow/docker/ && docker compose down --rmi all
			rm -rf /home/docker/ragflow
			echo "應用程式已解除安裝"
		}

		docker_app_plus

		  ;;


	  63|open-webui)
		local app_id="63"
		local docker_name="open-webui"
		local docker_img="ghcr.io/open-webui/open-webui:main"
		local docker_port=8063

		docker_rum() {

			docker run -d -p ${docker_port}:8080 -v /home/docker/open-webui:/app/backend/data --name open-webui --restart=always ghcr.io/open-webui/open-webui:main

		}

		local docker_describe="OpenWebUI一款大語言模型網頁框架，官方精簡版本，支援各大模型API接入"
		local docker_url="官網介紹:${gh_https_url}github.com/open-webui/open-webui"
		local docker_use=""
		local docker_passwd=""
		local app_size="3"
		docker_app
		  ;;

	  64|it-tools)
		local app_id="64"
		local docker_name="it-tools"
		local docker_img="corentinth/it-tools:latest"
		local docker_port=8064

		docker_rum() {
			docker run -d --name it-tools --restart=always -p ${docker_port}:80 corentinth/it-tools:latest
		}

		local docker_describe="對開發人員和 IT 工作者來說非常有用的工具"
		local docker_url="官網介紹:${gh_https_url}github.com/CorentinTh/it-tools"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;


	  65|n8n)
		local app_id="65"
		local docker_name="n8n"
		local docker_img="docker.n8n.io/n8nio/n8n"
		local docker_port=8065

		docker_rum() {

			add_yuming
			mkdir -p /home/docker/n8n
			chmod -R 777 /home/docker/n8n

			docker run -d --name n8n \
			  --restart=always \
			  -p ${docker_port}:5678 \
			  -v /home/docker/n8n:/home/node/.n8n \
			  -e N8N_HOST=${yuming} \
			  -e N8N_PORT=5678 \
			  -e N8N_PROTOCOL=https \
			  -e WEBHOOK_URL=https://${yuming}/ \
			  docker.n8n.io/n8nio/n8n

			ldnmp_Proxy ${yuming} 127.0.0.1 ${docker_port}
			block_container_port "$docker_name" "$ipv4_address"

		}

		local docker_describe="是一款功能強大的自動化工作流程平台"
		local docker_url="官網介紹:${gh_https_url}github.com/n8n-io/n8n"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  66|yt)
		yt_menu_pro
		  ;;


	  67|ddns)
		local app_id="67"
		local docker_name="ddns-go"
		local docker_img="jeessy/ddns-go"
		local docker_port=8067

		docker_rum() {
			docker run -d \
				--name ddns-go \
				--restart=always \
				-p ${docker_port}:9876 \
				-v /home/docker/ddns-go:/root \
				jeessy/ddns-go

		}

		local docker_describe="自動將你的公網 IP（IPv4/IPv6）即時更新到各大 DNS 服務商，實現動態網域解析。"
		local docker_url="官網介紹:${gh_https_url}github.com/jeessy2/ddns-go"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;

	  68|allinssl)
		local app_id="68"
		local docker_name="allinssl"
		local docker_img="allinssl/allinssl:latest"
		local docker_port=8068

		docker_rum() {
			docker run -d --name allinssl -p ${docker_port}:8888 -v /home/docker/allinssl/data:/www/allinssl/data -e ALLINSSL_USER=allinssl -e ALLINSSL_PWD=allinssldocker -e ALLINSSL_URL=allinssl allinssl/allinssl:latest
		}

		local docker_describe="開源免費的 SSL 憑證自動化管理平台"
		local docker_url="官網介紹: https://allinssl.com"
		local docker_use="echo \"安全入口: /allinssl\""
		local docker_passwd="echo \"使用者名稱: allinssl 密碼: allinssldocker\""
		local app_size="1"
		docker_app
		  ;;


	  69|sftpgo)
		local app_id="69"
		local docker_name="sftpgo"
		local docker_img="drakkan/sftpgo:latest"
		local docker_port=8069

		docker_rum() {

			mkdir -p /home/docker/sftpgo/data
			mkdir -p /home/docker/sftpgo/config
			chown -R 1000:1000 /home/docker/sftpgo

			docker run -d \
			  --name sftpgo \
			  --restart=always \
			  -p ${docker_port}:8080 \
			  -p 22022:2022 \
			  --mount type=bind,source=/home/docker/sftpgo/data,target=/srv/sftpgo \
			  --mount type=bind,source=/home/docker/sftpgo/config,target=/var/lib/sftpgo \
			  drakkan/sftpgo:latest

		}

		local docker_describe="開源免費隨時隨地SFTP FTP WebDAV 檔案傳輸工具"
		local docker_url="官網介紹: https://sftpgo.com/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;


	  70|astrbot)
		local app_id="70"
		local docker_name="astrbot"
		local docker_img="soulter/astrbot:latest"
		local docker_port=8070

		docker_rum() {

			mkdir -p /home/docker/astrbot/data

			docker run -d \
			  -p ${docker_port}:6185 \
			  -p 6195:6195 \
			  -p 6196:6196 \
			  -p 6199:6199 \
			  -p 11451:11451 \
			  -v /home/docker/astrbot/data:/AstrBot/data \
			  --restart=always \
			  --name astrbot \
			  soulter/astrbot:latest

		}

		local docker_describe="開源AI聊天機器人框架，支援微信，QQ，TG接入AI大模型"
		local docker_url="官網介紹: https://astrbot.app/"
		local docker_use="echo \"使用者名稱: astrbot 密碼: astrbot\""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;


	  71|navidrome)
		local app_id="71"
		local docker_name="navidrome"
		local docker_img="deluan/navidrome:latest"
		local docker_port=8071

		docker_rum() {

			docker run -d \
			  --name navidrome \
			  --restart=always \
			  --user $(id -u):$(id -g) \
			  -v /home/docker/navidrome/music:/music \
			  -v /home/docker/navidrome/data:/data \
			  -p ${docker_port}:4533 \
			  -e ND_LOGLEVEL=info \
			  deluan/navidrome:latest

		}

		local docker_describe="是一個輕量、高效能的音樂串流伺服器"
		local docker_url="官網介紹: https://www.navidrome.org/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app
		  ;;


	  72|bitwarden)

		local app_id="72"
		local docker_name="bitwarden"
		local docker_img="vaultwarden/server"
		local docker_port=8072

		docker_rum() {

			docker run -d \
				--name bitwarden \
				--restart=always \
				-p ${docker_port}:80 \
				-v /home/docker/bitwarden/data:/data \
				vaultwarden/server

		}

		local docker_describe="一個你可以控制資料的密碼管理器"
		local docker_url="官網導論: https://bitwarden.com/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app


		  ;;



	  73|libretv)

		local app_id="73"
		local docker_name="libretv"
		local docker_img="bestzwei/libretv:latest"
		local docker_port=8073

		docker_rum() {

			read -e -p "設定LibreTV的登入密碼:" app_passwd

			docker run -d \
			  --name libretv \
			  --restart=always \
			  -p ${docker_port}:8080 \
			  -e PASSWORD=${app_passwd} \
			  bestzwei/libretv:latest

		}

		local docker_describe="免費線上影片搜尋與觀看平台"
		local docker_url="官網介紹:${gh_https_url}github.com/LibreSpark/LibreTV"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;



	  74|moontv)

		local app_id="74"

		local app_name="moontv私有影視"
		local app_text="免費線上影片搜尋與觀看平台"
		local app_url="影片介紹:${gh_https_url}github.com/MoonTechLab/LunaTV"
		local docker_name="moontv-core"
		local docker_port="8074"
		local app_size="2"

		docker_app_install() {
			read -e -p "設定登入用戶名:" admin
			read -e -p "設定登入用戶密碼:" admin_password
			read -e -p "輸入授權碼:" shouquanma


			mkdir -p /home/docker/moontv
			mkdir -p /home/docker/moontv/config
			mkdir -p /home/docker/moontv/data
			cd /home/docker/moontv

			curl -o /home/docker/moontv/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/kejilion/docker/main/moontv-docker-compose.yml
			sed -i "s/3000:3000/${docker_port}:3000/g" /home/docker/moontv/docker-compose.yml
			sed -i "s|admin_password|${admin_password}|g" /home/docker/moontv/docker-compose.yml
			sed -i "s|admin|${admin}|g" /home/docker/moontv/docker-compose.yml
			sed -i "s|shouquanma|${shouquanma}|g" /home/docker/moontv/docker-compose.yml
			cd /home/docker/moontv/
			docker compose up -d
			clear
			echo "已經安裝完成"
			check_docker_app_ip
		}


		docker_app_update() {
			cd /home/docker/moontv/ && docker compose down --rmi all
			cd /home/docker/moontv/ && docker compose up -d
		}


		docker_app_uninstall() {
			cd /home/docker/moontv/ && docker compose down --rmi all
			rm -rf /home/docker/moontv
			echo "應用程式已解除安裝"
		}

		docker_app_plus

		  ;;


	  75|melody)

		local app_id="75"
		local docker_name="melody"
		local docker_img="foamzou/melody:latest"
		local docker_port=8075

		docker_rum() {

			docker run -d \
			  --name melody \
			  --restart=always \
			  -p ${docker_port}:5566 \
			  -v /home/docker/melody/.profile:/app/backend/.profile \
			  foamzou/melody:latest


		}

		local docker_describe="你的音樂精靈，旨在幫助你更好地管理音樂。"
		local docker_url="官網介紹:${gh_https_url}github.com/foamzou/melody"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app


		  ;;


	  76|dosgame)

		local app_id="76"
		local docker_name="dosgame"
		local docker_img="oldiy/dosgame-web-docker:latest"
		local docker_port=8076

		docker_rum() {
			docker run -d \
				--name dosgame \
				--restart=always \
				-p ${docker_port}:262 \
				oldiy/dosgame-web-docker:latest

		}

		local docker_describe="是一個中文DOS遊戲收藏網站"
		local docker_url="官網介紹:${gh_https_url}github.com/rwv/chinese-dos-games"
		local docker_use=""
		local docker_passwd=""
		local app_size="2"
		docker_app


		  ;;

	  77|xunlei)

		local app_id="77"
		local docker_name="xunlei"
		local docker_img="cnk3x/xunlei"
		local docker_port=8077

		docker_rum() {

			read -e -p "設定登入用戶名:" app_use
			read -e -p "設定登入密碼:" app_passwd

			docker run -d \
			  --name xunlei \
			  --restart=always \
			  --privileged \
			  -e XL_DASHBOARD_USERNAME=${app_use} \
			  -e XL_DASHBOARD_PASSWORD=${app_passwd} \
			  -v /home/docker/xunlei/data:/xunlei/data \
			  -v /home/docker/xunlei/downloads:/xunlei/downloads \
			  -p ${docker_port}:2345 \
			  cnk3x/xunlei

		}

		local docker_describe="迅雷你的離線高速BT磁力下載工具"
		local docker_url="官網介紹:${gh_https_url}github.com/cnk3x/xunlei"
		local docker_use="echo \"手機登入迅雷，再輸入邀請碼，邀請碼: 迅雷牛通\""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;



	  78|PandaWiki)

		local app_id="78"
		local app_name="PandaWiki"
		local app_text="PandaWiki是一款以AI大模型驅動的開源智慧文件管理系統，強烈建議不要自訂連接埠部署。"
		local app_url="官方介紹:${gh_https_url}github.com/chaitin/PandaWiki"
		local docker_name="panda-wiki-nginx"
		local docker_port="2443"
		local app_size="2"

		docker_app_install() {
			bash -c "$(curl -fsSLk https://release.baizhi.cloud/panda-wiki/manager.sh)"
		}

		docker_app_update() {
			docker_app_install
		}


		docker_app_uninstall() {
			docker_app_install
		}

		docker_app_plus
		  ;;



	  79|beszel)

		local app_id="79"
		local docker_name="beszel"
		local docker_img="henrygd/beszel"
		local docker_port=8079

		docker_rum() {

			mkdir -p /home/docker/beszel && \
			docker run -d \
			  --name beszel \
			  --restart=always \
			  -v /home/docker/beszel:/beszel_data \
			  -p ${docker_port}:8090 \
			  henrygd/beszel

		}

		local docker_describe="Beszel輕易易用的伺服器監控"
		local docker_url="官網介紹: https://beszel.dev/zh/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  80|linkwarden)

		  local app_id="80"
		  local app_name="linkwarden書籤管理"
		  local app_text="一個開源的自架書籤管理平台，支援標籤、搜尋和團隊協作。"
		  local app_url="官方網站: https://linkwarden.app/"
		  local docker_name="linkwarden-linkwarden-1"
		  local docker_port="8080"
		  local app_size="3"

		  docker_app_install() {
			  install git openssl
			  mkdir -p /home/docker/linkwarden && cd /home/docker/linkwarden

			  # 下載官方 docker-compose 和 env 文件
			  curl -O ${gh_proxy}raw.githubusercontent.com/linkwarden/linkwarden/refs/heads/main/docker-compose.yml
			  curl -L ${gh_proxy}raw.githubusercontent.com/linkwarden/linkwarden/refs/heads/main/.env.sample -o ".env"

			  # 產生隨機密鑰與密碼
			  local ADMIN_EMAIL="admin@example.com"
			  local ADMIN_PASSWORD=$(openssl rand -hex 8)

			  sed -i "s|^NEXTAUTH_URL=.*|NEXTAUTH_URL=http://localhost:${docker_port}/api/v1/auth|g" .env
			  sed -i "s|^NEXTAUTH_SECRET=.*|NEXTAUTH_SECRET=$(openssl rand -hex 32)|g" .env
			  sed -i "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$(openssl rand -hex 16)|g" .env
			  sed -i "s|^MEILI_MASTER_KEY=.*|MEILI_MASTER_KEY=$(openssl rand -hex 32)|g" .env

			  # 追加管理員帳號資訊
			  echo "ADMIN_EMAIL=${ADMIN_EMAIL}" >> .env
			  echo "ADMIN_PASSWORD=${ADMIN_PASSWORD}" >> .env

			  sed -i "s/3000:3000/${docker_port}:3000/g" /home/docker/linkwarden/docker-compose.yml

			  # 啟動容器
			  docker compose up -d

			  clear
			  echo "已經安裝完成"
		  	  check_docker_app_ip

		  }

		  docker_app_update() {
			  cd /home/docker/linkwarden && docker compose down --rmi all
			  curl -O ${gh_proxy}raw.githubusercontent.com/linkwarden/linkwarden/refs/heads/main/docker-compose.yml
			  curl -L ${gh_proxy}raw.githubusercontent.com/linkwarden/linkwarden/refs/heads/main/.env.sample -o ".env.new"

			  # 保留原本的變數
			  source .env
			  mv .env.new .env
			  echo "NEXTAUTH_URL=$NEXTAUTH_URL" >> .env
			  echo "NEXTAUTH_SECRET=$NEXTAUTH_SECRET" >> .env
			  echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> .env
			  echo "MEILI_MASTER_KEY=$MEILI_MASTER_KEY" >> .env
			  echo "ADMIN_EMAIL=$ADMIN_EMAIL" >> .env
			  echo "ADMIN_PASSWORD=$ADMIN_PASSWORD" >> .env
			  sed -i "s/3000:3000/${docker_port}:3000/g" /home/docker/linkwarden/docker-compose.yml

			  docker compose up -d
		  }

		  docker_app_uninstall() {
			  cd /home/docker/linkwarden && docker compose down --rmi all
			  rm -rf /home/docker/linkwarden
			  echo "應用程式已解除安裝"
		  }

		  docker_app_plus

		  ;;



	  81|jitsi)
		  local app_id="81"
		  local app_name="JitsiMeet視訊會議"
		  local app_text="一個開源的安全視訊會議解決方案，支援多人線上會議、螢幕分享與加密通訊。"
		  local app_url="官方網站: https://jitsi.org/"
		  local docker_name="jitsi"
		  local docker_port="8081"
		  local app_size="3"

		  docker_app_install() {

			  add_yuming
			  mkdir -p /home/docker/jitsi && cd /home/docker/jitsi
			  wget $(wget -q -O - https://api.github.com/repos/jitsi/docker-jitsi-meet/releases/latest | grep zip | cut -d\" -f4)
			  unzip "$(ls -t | head -n 1)"
			  cd "$(ls -dt */ | head -n 1)"
			  cp env.example .env
			  ./gen-passwords.sh
			  mkdir -p ~/.jitsi-meet-cfg/{web,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}
			  sed -i "s|^HTTP_PORT=.*|HTTP_PORT=${docker_port}|" .env
			  sed -i "s|^#PUBLIC_URL=https://meet.example.com:\${HTTPS_PORT}|PUBLIC_URL=https://$yuming:443|" .env
			  docker compose up -d

			  ldnmp_Proxy ${yuming} 127.0.0.1 ${docker_port}
			  block_container_port "$docker_name" "$ipv4_address"

		  }

		  docker_app_update() {
			  cd /home/docker/jitsi
			  cd "$(ls -dt */ | head -n 1)"
			  docker compose down --rmi all
			  docker compose up -d

		  }

		  docker_app_uninstall() {
			  cd /home/docker/jitsi
			  cd "$(ls -dt */ | head -n 1)"
			  docker compose down --rmi all
			  rm -rf /home/docker/jitsi
			  echo "應用程式已解除安裝"
		  }

		  docker_app_plus

		  ;;



	  82|gpt-load)

		local app_id="82"
		local docker_name="gpt-load"
		local docker_img="tbphp/gpt-load:latest"
		local docker_port=8082

		docker_rum() {

			read -e -p "設定${docker_name}的登入密鑰（sk-開頭字母和數字組合）如: sk-159kejilionyyds163:" app_passwd

			mkdir -p /home/docker/gpt-load && \
			docker run -d --name gpt-load \
				-p ${docker_port}:3001 \
				-e AUTH_KEY=${app_passwd} \
				-v "/home/docker/gpt-load/data":/app/data \
				tbphp/gpt-load:latest

		}

		local docker_describe="高效能AI介面透明代理服務"
		local docker_url="官網介紹: https://www.gpt-load.com/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;



	  83|komari)

		local app_id="83"
		local docker_name="komari"
		local docker_img="ghcr.io/komari-monitor/komari:latest"
		local docker_port=8083

		docker_rum() {

			mkdir -p /home/docker/komari && \
			docker run -d \
			  --name komari \
			  -p ${docker_port}:25774 \
			  -v /home/docker/komari:/app/data \
			  -e ADMIN_USERNAME=admin \
			  -e ADMIN_PASSWORD=1212156 \
			  -e TZ=Asia/Shanghai \
			  --restart=always \
			  ghcr.io/komari-monitor/komari:latest

		}

		local docker_describe="輕量級的自架伺服器監控工具"
		local docker_url="官網介紹:${gh_https_url}github.com/komari-monitor/komari/tree/main"
		local docker_use="echo \"預設帳號: admin 預設密碼: 1212156\""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;



	  84|wallos)

		local app_id="84"
		local docker_name="wallos"
		local docker_img="bellamy/wallos:latest"
		local docker_port=8084

		docker_rum() {

			mkdir -p /home/docker/wallos && \
			docker run -d --name wallos \
			  -v /home/docker/wallos/db:/var/www/html/db \
			  -v /home/docker/wallos/logos:/var/www/html/images/uploads/logos \
			  -e TZ=UTC \
			  -p ${docker_port}:80 \
			  --restart=always \
			  bellamy/wallos:latest

		}

		local docker_describe="開源個人訂閱追蹤器，可用於財務管理"
		local docker_url="官網介紹:${gh_https_url}github.com/ellite/Wallos"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;

	  85|immich)

		  local app_id="85"
		  local app_name="immich圖片影片管理器"
		  local app_text="高效能自架照片和影片管理解決方案。"
		  local app_url="官網介紹:${gh_https_url}github.com/immich-app/immich"
		  local docker_name="immich_server"
		  local docker_port="8085"
		  local app_size="3"

		  docker_app_install() {
			  install git openssl wget
			  mkdir -p /home/docker/${docker_name} && cd /home/docker/${docker_name}

			  wget -O docker-compose.yml ${gh_proxy}github.com/immich-app/immich/releases/latest/download/docker-compose.yml
			  wget -O .env ${gh_proxy}github.com/immich-app/immich/releases/latest/download/example.env
			  sed -i "s/2283:2283/${docker_port}:2283/g" /home/docker/${docker_name}/docker-compose.yml

			  docker compose up -d

			  clear
			  echo "已經安裝完成"
		  	  check_docker_app_ip

		  }

		  docker_app_update() {
				cd /home/docker/${docker_name} && docker compose down --rmi all
				docker_app_install
		  }

		  docker_app_uninstall() {
			  cd /home/docker/${docker_name} && docker compose down --rmi all
			  rm -rf /home/docker/${docker_name}
			  echo "應用程式已解除安裝"
		  }

		  docker_app_plus


		  ;;


	  86|jellyfin)

		local app_id="86"
		local docker_name="jellyfin"
		local docker_img="jellyfin/jellyfin"
		local docker_port=8086

		docker_rum() {

			mkdir -p /home/docker/jellyfin/media
			chmod -R 777 /home/docker/jellyfin

			docker run -d \
			  --name jellyfin \
			  --user root \
			  --volume /home/docker/jellyfin/config:/config \
			  --volume /home/docker/jellyfin/cache:/cache \
			  --mount type=bind,source=/home/docker/jellyfin/media,target=/media \
			  -p ${docker_port}:8096 \
			  -p 7359:7359/udp \
			  --restart=always \
			  jellyfin/jellyfin


		}

		local docker_describe="是一款開源媒體伺服器軟體"
		local docker_url="官網介紹: https://jellyfin.org/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  87|synctv)

		local app_id="87"
		local docker_name="synctv"
		local docker_img="synctvorg/synctv"
		local docker_port=8087

		docker_rum() {

			docker run -d \
				--name synctv \
				-v /home/docker/synctv:/root/.synctv \
				-p ${docker_port}:8080 \
				--restart=always \
				synctvorg/synctv

		}

		local docker_describe="遠端一起觀看電影和直播的程式。它提供了同步觀影、直播、聊天等功能"
		local docker_url="官網介紹:${gh_https_url}github.com/synctv-org/synctv"
		local docker_use="echo \"初始帳號與密碼: root 登陸後請及時修改登入密碼\""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  88|owncast)

		local app_id="88"
		local docker_name="owncast"
		local docker_img="owncast/owncast:latest"
		local docker_port=8088

		docker_rum() {

			docker run -d \
				--name owncast \
				-p ${docker_port}:8080 \
				-p 1935:1935 \
				-v /home/docker/owncast/data:/app/data \
				--restart=always \
				owncast/owncast:latest


		}

		local docker_describe="開源、免費的自建直播平台"
		local docker_url="官網介紹: https://owncast.online"
		local docker_use="echo \"訪問地址後面帶 /admin 訪問管理員頁面\""
		local docker_passwd="echo \"初始帳號: admin 初始密碼: abc123 登陸後請及時修改登入密碼\""
		local app_size="1"
		docker_app

		  ;;



	  89|file-code-box)

		local app_id="89"
		local docker_name="file-code-box"
		local docker_img="lanol/filecodebox:latest"
		local docker_port=8089

		docker_rum() {

			docker run -d \
			  --name file-code-box \
			  -p ${docker_port}:12345 \
			  -v /home/docker/file-code-box/data:/app/data \
			  --restart=always \
			  lanol/filecodebox:latest

		}

		local docker_describe="匿名口令分享文字和文件，像拿快遞一樣取文件"
		local docker_url="官網介紹:${gh_https_url}github.com/vastsa/FileCodeBox"
		local docker_use="echo \"訪問地址後面帶 /#/admin 訪問管理員頁面\""
		local docker_passwd="echo \"管理員密碼: FileCodeBox2023\""
		local app_size="1"
		docker_app

		  ;;




	  90|matrix)

		local app_id="90"
		local docker_name="matrix"
		local docker_img="matrixdotorg/synapse:latest"
		local docker_port=8090

		docker_rum() {

			add_yuming

			if [ ! -d /home/docker/matrix/data ]; then
				docker run --rm \
				  -v /home/docker/matrix/data:/data \
				  -e SYNAPSE_SERVER_NAME=${yuming} \
				  -e SYNAPSE_REPORT_STATS=yes \
				  --name matrix \
				  matrixdotorg/synapse:latest generate
			fi

			docker run -d \
			  --name matrix \
			  -v /home/docker/matrix/data:/data \
			  -p ${docker_port}:8008 \
			  --restart=always \
			  matrixdotorg/synapse:latest

			echo "建立初始使用者或管理員。請設定以下內容使用者名稱和密碼以及是否為管理員。"
			docker exec -it matrix register_new_matrix_user \
			  http://localhost:8008 \
			  -c /data/homeserver.yaml

			sed -i '/^enable_registration:/d' /home/docker/matrix/data/homeserver.yaml
			sed -i '/^# vim:ft=yaml/i enable_registration: true' /home/docker/matrix/data/homeserver.yaml
			sed -i '/^enable_registration_without_verification:/d' /home/docker/matrix/data/homeserver.yaml
			sed -i '/^# vim:ft=yaml/i enable_registration_without_verification: true' /home/docker/matrix/data/homeserver.yaml

			docker restart matrix

			ldnmp_Proxy ${yuming} 127.0.0.1 ${docker_port}
			block_container_port "$docker_name" "$ipv4_address"

		}

		local docker_describe="Matrix是一個去中心化的聊天協議"
		local docker_url="官網介紹: https://matrix.org/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;



	  91|gitea)

		local app_id="91"

		local app_name="gitea私有程式碼倉庫"
		local app_text="免費新一代的程式碼託管平台，提供接近 GitHub 的使用體驗。"
		local app_url="影片介紹:${gh_https_url}github.com/go-gitea/gitea"
		local docker_name="gitea"
		local docker_port="8091"
		local app_size="2"

		docker_app_install() {

			mkdir -p /home/docker/gitea
			mkdir -p /home/docker/gitea/gitea
			mkdir -p /home/docker/gitea/data
			mkdir -p /home/docker/gitea/postgres
			cd /home/docker/gitea

			curl -o /home/docker/gitea/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/kejilion/docker/main/gitea-docker-compose.yml
			sed -i "s/3000:3000/${docker_port}:3000/g" /home/docker/gitea/docker-compose.yml
			cd /home/docker/gitea/
			docker compose up -d
			clear
			echo "已經安裝完成"
			check_docker_app_ip
		}


		docker_app_update() {
			cd /home/docker/gitea/ && docker compose down --rmi all
			cd /home/docker/gitea/ && docker compose up -d
		}


		docker_app_uninstall() {
			cd /home/docker/gitea/ && docker compose down --rmi all
			rm -rf /home/docker/gitea
			echo "應用程式已解除安裝"
		}

		docker_app_plus

		  ;;




	  92|filebrowser)

		local app_id="92"
		local docker_name="filebrowser"
		local docker_img="hurlenko/filebrowser"
		local docker_port=8092

		docker_rum() {

			docker run -d \
				--name filebrowser \
				--restart=always \
				-p ${docker_port}:8080 \
				-v /home/docker/filebrowser/data:/data \
				-v /home/docker/filebrowser/config:/config \
				-e FB_BASEURL=/filebrowser \
				hurlenko/filebrowser

		}

		local docker_describe="是一個基於Web的文件管理器"
		local docker_url="官網介紹: https://filebrowser.org/"
		local docker_use="docker logs filebrowser"
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;

	93|dufs)

		local app_id="93"
		local docker_name="dufs"
		local docker_img="sigoden/dufs"
		local docker_port=8093

		docker_rum() {

			docker run -d \
			  --name ${docker_name} \
			  --restart=always \
			  -v /home/docker/${docker_name}:/data \
			  -p ${docker_port}:5000 \
			  ${docker_img} /data -A

		}

		local docker_describe="極簡靜態檔案伺服器，支援上傳下載"
		local docker_url="官網介紹:${gh_https_url}github.com/sigoden/dufs"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		;;

	94|gopeed)

		local app_id="94"
		local docker_name="gopeed"
		local docker_img="liwei2633/gopeed"
		local docker_port=8094

		docker_rum() {

			read -e -p "設定登入用戶名:" app_use
			read -e -p "設定登入密碼:" app_passwd

			docker run -d \
			  --name ${docker_name} \
			  --restart=always \
			  -v /home/docker/${docker_name}/downloads:/app/Downloads \
			  -v /home/docker/${docker_name}/storage:/app/storage \
			  -p ${docker_port}:9999 \
			  ${docker_img} -u ${app_use} -p ${app_passwd}

		}

		local docker_describe="分散式高速下載工具，支援多種協議"
		local docker_url="官網介紹:${gh_https_url}github.com/GopeedLab/gopeed"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		;;



	  95|paperless)

		local app_id="95"

		local app_name="paperless文件管理平台"
		local app_text="開源的電子文件管理系統，它的主要用途是把你的紙本文件數位化並管理起來。"
		local app_url="影片介紹: https://docs.paperless-ngx.com/"
		local docker_name="paperless-webserver-1"
		local docker_port="8095"
		local app_size="2"

		docker_app_install() {

			mkdir -p /home/docker/paperless
			mkdir -p /home/docker/paperless/export
			mkdir -p /home/docker/paperless/consume
			cd /home/docker/paperless

			curl -o /home/docker/paperless/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/paperless-ngx/paperless-ngx/refs/heads/main/docker/compose/docker-compose.postgres-tika.yml
			curl -o /home/docker/paperless/docker-compose.env ${gh_proxy}raw.githubusercontent.com/paperless-ngx/paperless-ngx/refs/heads/main/docker/compose/.env

			sed -i "s/8000:8000/${docker_port}:8000/g" /home/docker/paperless/docker-compose.yml
			cd /home/docker/paperless
			docker compose up -d
			clear
			echo "已經安裝完成"
			check_docker_app_ip
		}


		docker_app_update() {
			cd /home/docker/paperless/ && docker compose down --rmi all
			docker_app_install
		}


		docker_app_uninstall() {
			cd /home/docker/paperless/ && docker compose down --rmi all
			rm -rf /home/docker/paperless
			echo "應用程式已解除安裝"
		}

		docker_app_plus

		  ;;



	  96|2fauth)

		local app_id="96"

		local app_name="2FAuth自架二步驟驗證器"
		local app_text="自託管的雙重身分驗證 (2FA) 帳戶管理和驗證碼產生工具。"
		local app_url="官網:${gh_https_url}github.com/Bubka/2FAuth"
		local docker_name="2fauth"
		local docker_port="8096"
		local app_size="1"

		docker_app_install() {

			add_yuming

			mkdir -p /home/docker/2fauth
			mkdir -p /home/docker/2fauth/data
			chmod -R 777 /home/docker/2fauth/
			cd /home/docker/2fauth

			curl -o /home/docker/2fauth/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/kejilion/docker/main/2fauth-docker-compose.yml

			sed -i "s/8000:8000/${docker_port}:8000/g" /home/docker/2fauth/docker-compose.yml
			sed -i "s/yuming.com/${yuming}/g" /home/docker/2fauth/docker-compose.yml
			cd /home/docker/2fauth
			docker compose up -d

			ldnmp_Proxy ${yuming} 127.0.0.1 ${docker_port}
			block_container_port "$docker_name" "$ipv4_address"

			clear
			echo "已經安裝完成"
			check_docker_app_ip
		}


		docker_app_update() {
			cd /home/docker/2fauth/ && docker compose down --rmi all
			docker_app_install
		}


		docker_app_uninstall() {
			cd /home/docker/2fauth/ && docker compose down --rmi all
			rm -rf /home/docker/2fauth
			echo "應用程式已解除安裝"
		}

		docker_app_plus

		  ;;



	97|wgs)

		local app_id="97"
		local docker_name="wireguard"
		local docker_img="lscr.io/linuxserver/wireguard:latest"
		local docker_port=8097

		docker_rum() {

		read -e -p  "請輸入組網的用戶端數量 (預設 5):" COUNT
		COUNT=${COUNT:-5}
		read -e -p  "請輸入 WireGuard 網段 (預設 10.13.13.0):" NETWORK
		NETWORK=${NETWORK:-10.13.13.0}

		PEERS=$(seq -f "wg%02g" 1 "$COUNT" | paste -sd,)

		ip link delete wg0 &>/dev/null

		ip_address
		docker run -d \
		  --name=wireguard \
		  --network host \
		  --cap-add=NET_ADMIN \
		  --cap-add=SYS_MODULE \
		  -e PUID=1000 \
		  -e PGID=1000 \
		  -e TZ=Etc/UTC \
		  -e SERVERURL=${ipv4_address} \
		  -e SERVERPORT=51820 \
		  -e PEERS=${PEERS} \
		  -e INTERNAL_SUBNET=${NETWORK} \
		  -e ALLOWEDIPS=${NETWORK}/24 \
		  -e PERSISTENTKEEPALIVE_PEERS=all \
		  -e LOG_CONFS=true \
		  -v /home/docker/wireguard/config:/config \
		  -v /lib/modules:/lib/modules \
		  --restart=always \
		  lscr.io/linuxserver/wireguard:latest


		sleep 3

		docker exec wireguard sh -c "
		f='/config/wg_confs/wg0.conf'
		sed -i 's/51820/${docker_port}/g' \$f
		"

		docker exec wireguard sh -c "
		for d in /config/peer_*; do
		  sed -i 's/51820/${docker_port}/g' \$d/*.conf
		done
		"

		docker exec wireguard sh -c '
		for d in /config/peer_*; do
		  sed -i "/^DNS/d" "$d"/*.conf
		done
		'

		docker exec wireguard sh -c '
		for d in /config/peer_*; do
		  for f in "$d"/*.conf; do
			grep -q "^PersistentKeepalive" "$f" || \
			sed -i "/^AllowedIPs/ a PersistentKeepalive = 25" "$f"
		  done
		done
		'

		docker exec wireguard bash -c '
		for d in /config/peer_*; do
		  cd "$d" || continue
		  conf_file=$(ls *.conf)
		  base_name="${conf_file%.conf}"
		  qrencode -o "$base_name.png" < "$conf_file"
		done
		'

		docker restart wireguard

		sleep 2
		echo
		echo -e "${gl_huang}所有客戶端二維碼配置:${gl_bai}"
		docker exec wireguard bash -c 'for i in $(ls /config | grep peer_ | sed "s/peer_//"); do echo "--- $i ---"; /app/show-peer $i; done'
		sleep 2
		echo
		echo -e "${gl_huang}所有客戶端配置代碼:${gl_bai}"
		docker exec wireguard sh -c 'for d in /config/peer_*; do echo "# $(basename $d) "; cat $d/*.conf; echo; done'
		sleep 2
		echo -e "${gl_lv}${COUNT}個客戶端配置全部輸出，使用方法如下：${gl_bai}"
		echo -e "${gl_lv}1. 手機下載wg的APP，掃描上方二維碼，可快速連接網絡${gl_bai}"
		echo -e "${gl_lv}2. Windows下載客戶端，複製設定碼連接網路。${gl_bai}"
		echo -e "${gl_lv}3. Linux用腳本部署WG客戶端，複製設定碼連接網路。${gl_bai}"
		echo -e "${gl_lv}官方客戶端下載方式: https://www.wireguard.com/install/${gl_bai}"
		break_end

		}

		local docker_describe="現代化、高效能的虛擬專用網路工具"
		local docker_url="官網介紹: https://www.wireguard.com/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		;;


	98|wgc)

		local app_id="98"
		local docker_name="wireguardc"
		local docker_img="kjlion/wireguard:alpine"
		local docker_port=51820

		docker_rum() {

			mkdir -p /home/docker/wireguard/config/

			local CONFIG_FILE="/home/docker/wireguard/config/wg0.conf"

			# 建立目錄（如果不存在）
			mkdir -p "$(dirname "$CONFIG_FILE")"

			echo "請貼上你的客戶端配置，連續按兩次回車保存："

			# 初始化變數
			input=""
			empty_line_count=0

			# 逐行讀取使用者輸入
			while IFS= read -r line; do
				if [[ -z "$line" ]]; then
					((empty_line_count++))
					if [[ $empty_line_count -ge 2 ]]; then
						break
					fi
				else
					empty_line_count=0
					input+="$line"$'\n'
				fi
			done

			# 寫入設定檔
			echo "$input" > "$CONFIG_FILE"

			echo "客戶端配置已儲存到$CONFIG_FILE"

			ip link delete wg0 &>/dev/null

			docker run -d \
			  --name wireguardc \
			  --network host \
			  --cap-add NET_ADMIN \
			  --cap-add SYS_MODULE \
			  -v /home/docker/wireguard/config:/config \
			  -v /lib/modules:/lib/modules:ro \
			  --restart=always \
			  kjlion/wireguard:alpine

			sleep 3

			docker logs wireguardc

		break_end

		}

		local docker_describe="現代化、高效能的虛擬專用網路工具"
		local docker_url="官網介紹: https://www.wireguard.com/"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		;;


	  99|dsm)

		local app_id="99"

		local app_name="dsm群暉虛擬機"
		local app_text="Docker容器中的虛擬DSM"
		local app_url="官網:${gh_https_url}github.com/vdsm/virtual-dsm"
		local docker_name="dsm"
		local docker_port="8099"
		local app_size="16"

		docker_app_install() {

			read -e -p "設定 CPU 核數 (預設 2):" CPU_CORES
			local CPU_CORES=${CPU_CORES:-2}

			read -e -p "設定記憶體大小 (預設 4G):" RAM_SIZE
			local RAM_SIZE=${RAM_SIZE:-4}

			mkdir -p /home/docker/dsm
			mkdir -p /home/docker/dsm/dev
			chmod -R 777 /home/docker/dsm/
			cd /home/docker/dsm

			curl -o /home/docker/dsm/docker-compose.yml ${gh_proxy}raw.githubusercontent.com/kejilion/docker/main/dsm-docker-compose.yml

			sed -i "s/5000:5000/${docker_port}:5000/g" /home/docker/dsm/docker-compose.yml
			sed -i "s|CPU_CORES: "2"|CPU_CORES: "${CPU_CORES}"|g" /home/docker/dsm/docker-compose.yml
			sed -i "s|RAM_SIZE: "2G"|RAM_SIZE: "${RAM_SIZE}G"|g" /home/docker/dsm/docker-compose.yml
			cd /home/docker/dsm
			docker compose up -d

			clear
			echo "已經安裝完成"
			check_docker_app_ip
		}


		docker_app_update() {
			cd /home/docker/dsm/ && docker compose down --rmi all
			docker_app_install
		}


		docker_app_uninstall() {
			cd /home/docker/dsm/ && docker compose down --rmi all
			rm -rf /home/docker/dsm
			echo "應用程式已解除安裝"
		}

		docker_app_plus

		  ;;



	100|syncthing)

		local app_id="100"
		local docker_name="syncthing"
		local docker_img="syncthing/syncthing:latest"
		local docker_port=8100

		docker_rum() {
			docker run -d \
			  --name=syncthing \
			  --hostname=my-syncthing \
			  --restart=always \
			  -p ${docker_port}:8384 \
			  -p 22000:22000/tcp \
			  -p 22000:22000/udp \
			  -p 21027:21027/udp \
			  -v /home/docker/syncthing:/var/syncthing \
			  syncthing/syncthing:latest
		}

		local docker_describe="開源的點對點檔案同步工具，類似 Dropbox、Resilio Sync，但完全去中心化。"
		local docker_url="官網介紹:${gh_https_url}github.com/syncthing/syncthing"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		;;


	  101|moneyprinterturbo)
		local app_id="101"
		local app_name="AI影片產生工具"
		local app_text="MoneyPrinterTurbo是一款使用AI大模型合成高清短影片的工具"
		local app_url="官方網站:${gh_https_url}github.com/harry0703/MoneyPrinterTurbo"
		local docker_name="moneyprinterturbo"
		local docker_port="8101"
		local app_size="3"

		docker_app_install() {
			install git
			mkdir -p  /home/docker/ && cd /home/docker/ && git clone ${gh_proxy}github.com/harry0703/MoneyPrinterTurbo.git && cd MoneyPrinterTurbo/
			sed -i "s/8501:8501/${docker_port}:8501/g" /home/docker/MoneyPrinterTurbo/docker-compose.yml

			docker compose up -d
			clear
			echo "已經安裝完成"
			check_docker_app_ip
		}

		docker_app_update() {
			cd  /home/docker/MoneyPrinterTurbo/ && docker compose down --rmi all
			cd  /home/docker/MoneyPrinterTurbo/

			git pull ${gh_proxy}github.com/harry0703/MoneyPrinterTurbo.git main > /dev/null 2>&1
			sed -i "s/8501:8501/${docker_port}:8501/g" /home/docker/MoneyPrinterTurbo/docker-compose.yml
			cd  /home/docker/MoneyPrinterTurbo/ && docker compose up -d
		}

		docker_app_uninstall() {
			cd  /home/docker/MoneyPrinterTurbo/ && docker compose down --rmi all
			rm -rf /home/docker/MoneyPrinterTurbo
			echo "應用程式已解除安裝"
		}

		docker_app_plus

		  ;;



	  102|vocechat)

		local app_id="102"
		local docker_name="vocechat-server"
		local docker_img="privoce/vocechat-server:latest"
		local docker_port=8102

		docker_rum() {

			docker run -d --restart=always \
			  -p ${docker_port}:3000 \
			  --name vocechat-server \
			  -v /home/docker/vocechat/data:/home/vocechat-server/data \
			  privoce/vocechat-server:latest

		}

		local docker_describe="是一款支援獨立部署的個人雲端社群媒體聊天服務"
		local docker_url="官網介紹:${gh_https_url}github.com/Privoce/vocechat-web"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  103|umami)
		local app_id="103"
		local app_name="Umami網站統計工具"
		local app_text="開源、輕量、隱私友善的網站分析工具，類似GoogleAnalytics。"
		local app_url="官方網站:${gh_https_url}github.com/umami-software/umami"
		local docker_name="umami-umami-1"
		local docker_port="8103"
		local app_size="1"

		docker_app_install() {
			install git
			mkdir -p  /home/docker/ && cd /home/docker/ && git clone ${gh_proxy}github.com/umami-software/umami.git && cd umami
			sed -i "s/3000:3000/${docker_port}:3000/g" /home/docker/umami/docker-compose.yml

			docker compose up -d
			clear
			echo "已經安裝完成"
			check_docker_app_ip
			echo "初始使用者名稱: admin"
			echo "初始密碼: umami"
		}

		docker_app_update() {
			cd  /home/docker/umami/ && docker compose down --rmi all
			cd  /home/docker/umami/
			git pull ${gh_proxy}github.com/umami-software/umami.git main > /dev/null 2>&1
			sed -i "s/8501:8501/${docker_port}:8501/g" /home/docker/umami/docker-compose.yml
			cd  /home/docker/umami/ && docker compose up -d
		}

		docker_app_uninstall() {
			cd  /home/docker/umami/ && docker compose down --rmi all
			rm -rf /home/docker/umami
			echo "應用程式已解除安裝"
		}

		docker_app_plus

		  ;;

	  104|nginx-stream)
		stream_panel
		  ;;


	  105|siyuan)

		local app_id="105"
		local docker_name="siyuan"
		local docker_img="b3log/siyuan"
		local docker_port=8105

		docker_rum() {

			read -e -p "設定登入密碼:" app_passwd

			docker run -d \
			  --name siyuan \
			  --restart=always \
			  -v /home/docker/siyuan/workspace:/siyuan/workspace \
			  -p ${docker_port}:6806 \
			  -e PUID=1001 \
			  -e PGID=1002 \
			  b3log/siyuan \
			  --workspace=/siyuan/workspace/ \
			  --accessAuthCode="${app_passwd}"

		}

		local docker_describe="思源筆記是一款隱私優先的知識管理系統"
		local docker_url="官網介紹:${gh_https_url}github.com/siyuan-note/siyuan"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  106|drawnix)

		local app_id="106"
		local docker_name="drawnix"
		local docker_img="pubuzhixing/drawnix"
		local docker_port=8106

		docker_rum() {

			docker run -d \
			   --restart=always  \
			   --name drawnix \
			   -p ${docker_port}:80 \
			  pubuzhixing/drawnix

		}

		local docker_describe="是一款強大的開源白板工具，整合心智圖、流程圖等。"
		local docker_url="官網介紹:${gh_https_url}github.com/plait-board/drawnix"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  107|pansou)

		local app_id="107"
		local docker_name="pansou"
		local docker_img="ghcr.io/fish2018/pansou-web"
		local docker_port=8107

		docker_rum() {

			docker run -d \
			  --name pansou \
			  --restart=always \
			  -p ${docker_port}:80 \
			  -v /home/docker/pansou/data:/app/data \
			  -v /home/docker/pansou/logs:/app/logs \
			  -e ENABLED_PLUGINS="hunhepan,jikepan,panwiki,pansearch,panta,qupansou,
susu,thepiratebay,wanou,xuexizhinan,panyq,zhizhen,labi,muou,ouge,shandian,
duoduo,huban,cyg,erxiao,miaoso,fox4k,pianku,clmao,wuji,cldi,xiaozhang,
libvio,leijing,xb6v,xys,ddys,hdmoli,yuhuage,u3c3,javdb,clxiong,jutoushe,
sdso,xiaoji,xdyh,haisou,bixin,djgou,nyaa,xinjuc,aikanzy,qupanshe,xdpan,
discourse,yunsou,ahhhhfs,nsgame,gying" \
			  ghcr.io/fish2018/pansou-web

		}

		local docker_describe="PanSou是一個高效能的網盤資源搜尋API服務。"
		local docker_url="官網介紹:${gh_https_url}github.com/fish2018/pansou"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;




	  108|langbot)
		local app_id="108"
		local app_name="LangBot聊天機器人"
		local app_text="是一個開源的大語言模式原生即時通訊機器人開發平台"
		local app_url="官方網站:${gh_https_url}github.com/langbot-app/LangBot"
		local docker_name="langbot_plugin_runtime"
		local docker_port="8108"
		local app_size="1"

		docker_app_install() {
			install git
			mkdir -p  /home/docker/ && cd /home/docker/ && git clone ${gh_proxy}github.com/langbot-app/LangBot && cd LangBot/docker
			sed -i "s/5300:5300/${docker_port}:5300/g" /home/docker/LangBot/docker/docker-compose.yaml

			docker compose up -d
			clear
			echo "已經安裝完成"
			check_docker_app_ip
		}

		docker_app_update() {
			cd  /home/docker/LangBot/docker && docker compose down --rmi all
			cd  /home/docker/LangBot/
			git pull ${gh_proxy}github.com/langbot-app/LangBot main > /dev/null 2>&1
			sed -i "s/5300:5300/${docker_port}:5300/g" /home/docker/LangBot/docker/docker-compose.yaml
			cd  /home/docker/LangBot/docker/ && docker compose up -d
		}

		docker_app_uninstall() {
			cd  /home/docker/LangBot/docker/ && docker compose down --rmi all
			rm -rf /home/docker/LangBot
			echo "應用程式已解除安裝"
		}

		docker_app_plus

		  ;;


	  109|zfile)

		local app_id="109"
		local docker_name="zfile"
		local docker_img="zhaojun1998/zfile:latest"
		local docker_port=8109

		docker_rum() {


			docker run -d --name=zfile --restart=always \
				-p ${docker_port}:8080 \
				-v /home/docker/zfile/db:/root/.zfile-v4/db \
				-v /home/docker/zfile/logs:/root/.zfile-v4/logs \
				-v /home/docker/zfile/file:/data/file \
				-v /home/docker/zfile/application.properties:/root/.zfile-v4/application.properties \
				zhaojun1998/zfile:latest


		}

		local docker_describe="是一個適用於個人或小型團隊的線上網盤程式。"
		local docker_url="官網介紹:${gh_https_url}github.com/zfile-dev/zfile"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  110|karakeep)
		local app_id="110"
		local app_name="karakeep書籤管理"
		local app_text="是一款可自行託管的書籤應用，具有人工智慧功能，專為資料囤積者而設計。"
		local app_url="官方網站:${gh_https_url}github.com/karakeep-app/karakeep"
		local docker_name="docker-web-1"
		local docker_port="8110"
		local app_size="1"

		docker_app_install() {
			install git
			mkdir -p  /home/docker/ && cd /home/docker/ && git clone ${gh_proxy}github.com/karakeep-app/karakeep.git && cd karakeep/docker && cp .env.sample .env
			sed -i "s/3000:3000/${docker_port}:3000/g" /home/docker/karakeep/docker/docker-compose.yml

			docker compose up -d
			clear
			echo "已經安裝完成"
			check_docker_app_ip
		}

		docker_app_update() {
			cd  /home/docker/karakeep/docker/ && docker compose down --rmi all
			cd  /home/docker/karakeep/
			git pull ${gh_proxy}github.com/karakeep-app/karakeep.git main > /dev/null 2>&1
			sed -i "s/3000:3000/${docker_port}:3000/g" /home/docker/karakeep/docker/docker-compose.yml
			cd  /home/docker/karakeep/docker/ && docker compose up -d
		}

		docker_app_uninstall() {
			cd  /home/docker/karakeep/docker/ && docker compose down --rmi all
			rm -rf /home/docker/karakeep
			echo "應用程式已解除安裝"
		}

		docker_app_plus

		  ;;



	  111|convertx)

		local app_id="111"
		local docker_name="convertx"
		local docker_img="ghcr.io/c4illin/convertx:latest"
		local docker_port=8111

		docker_rum() {

			docker run -d --name=${docker_name} --restart=always \
				-p ${docker_port}:3000 \
				-v /home/docker/convertx:/app/data \
				${docker_img}

		}

		local docker_describe="是一個功能強大的多格式文件轉換工具（支援文件、圖像、音訊視訊等）強烈建議添加域名訪問"
		local docker_url="項目地址:${gh_https_url}github.com/c4illin/ConvertX"
		local docker_use=""
		local docker_passwd=""
		local app_size="2"
		docker_app

		  ;;


	  112|lucky)

		local app_id="112"
		local docker_name="lucky"
		local docker_img="gdy666/lucky:v2"
		# 由於 Lucky 使用 host 網路模式，這裡的連接埠僅作記錄/說明參考，實際上由應用自身控制（預設16601）
		local docker_port=8112

		docker_rum() {

			docker run -d --name=${docker_name} --restart=always \
				--network host \
				-v /home/docker/lucky/conf:/app/conf \
				-v /var/run/docker.sock:/var/run/docker.sock \
				${docker_img}

			echo "正在等待 Lucky 初始化..."
			sleep 10
			docker exec lucky /app/lucky -rSetHttpAdminPort ${docker_port}

		}

		local docker_describe="Lucky 是一個大內部網路穿透及連接埠轉送管理工具，支援 DDNS、反向代理、WOL 等功能。"
		local docker_url="項目地址:${gh_https_url}github.com/gdy666/lucky"
		local docker_use="echo \"預設帳號密碼: 666\""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;


	  113|firefox)

		local app_id="113"
		local docker_name="firefox"
		local docker_img="jlesage/firefox:latest"
		local docker_port=8113

		docker_rum() {

			read -e -p "設定登入密碼:" admin_password

			docker run -d --name=${docker_name} --restart=always \
				-p ${docker_port}:5800 \
				-v /home/docker/firefox:/config:rw \
				-e ENABLE_CJK_FONT=1 \
				-e WEB_AUDIO=1 \
				-e VNC_PASSWORD="${admin_password}" \
				${docker_img}
		}

		local docker_describe="是一個運行在 Docker 中的 Firefox 瀏覽器，支援透過網頁直接存取桌面版瀏覽器介面。"
		local docker_url="項目地址:${gh_https_url}github.com/jlesage/docker-firefox"
		local docker_use=""
		local docker_passwd=""
		local app_size="1"
		docker_app

		  ;;

	  114|Moltbot|ClawdBot|moltbot|clawdbot|openclaw|OpenClaw)
	  	  moltbot_menu
		  ;;


	  b)
	  	clear
	  	send_stats "全部應用程式備份"

	  	local backup_filename="app_$(date +"%Y%m%d%H%M%S").tar.gz"
	  	echo -e "${gl_kjlan}正在備份$backup_filename ...${gl_bai}"
	  	cd / && tar czvf "$backup_filename" home

	  	while true; do
			clear
			echo "備份檔案已建立: /$backup_filename"
			read -e -p "要傳送備份資料到遠端伺服器嗎？ (Y/N):" choice
			case "$choice" in
			  [Yy])
				kj_ssh_read_host_port "請輸入遠端伺服器IP:" "目標伺服器SSH連接埠 [預設22]:" "22"
				local remote_ip="$KJ_SSH_HOST"
				local TARGET_PORT="$KJ_SSH_PORT"
				local latest_tar=$(ls -t /app*.tar.gz | head -1)
				if [ -n "$latest_tar" ]; then
				  ssh-keygen -f "/root/.ssh/known_hosts" -R "$remote_ip"
				  sleep 2  # 添加等待时间
				  scp -P "$TARGET_PORT" -o StrictHostKeyChecking=no "$latest_tar" "root@$remote_ip:/"
				  echo "檔案已傳送至遠端伺服器/根目錄。"
				else
				  echo "未找到要傳送的文件。"
				fi
				break
				;;
			  *)
				echo "注意: 目前備份僅包含docker項目，不包含寶塔，1panel等建站面板的資料備份。"
				break
				;;
			esac
	  	done

		  ;;

	  r)
	  	root_use
	  	send_stats "全部應用還原"
	  	echo "可用的應用程式備份"
	  	echo "-------------------------"
	  	ls -lt /app*.gz | awk '{print $NF}'
	  	echo ""
	  	read -e -p  "回車鍵還原最新的備份，輸入備份檔案名稱還原指定的備份，輸入0退出：" filename

	  	if [ "$filename" == "0" ]; then
			  break_end
			  linux_panel
	  	fi

	  	# 如果使用者沒有輸入檔名，使用最新的壓縮包
	  	if [ -z "$filename" ]; then
			  local filename=$(ls -t /app*.tar.gz | head -1)
	  	fi

	  	if [ -n "$filename" ]; then
		  	  echo -e "${gl_kjlan}正在解壓縮$filename ...${gl_bai}"
		  	  cd / && tar -xzf "$filename"
			  echo "應用資料已還原，目前請手動進入指定應用程式選單，更新應用，即可還原應用程式。"
	  	else
			  echo "沒有找到壓縮包。"
	  	fi

		  ;;

	  0)
		  kejilion
		  ;;
	  *)
		cd ~
		install git
		if [ ! -d apps/.git ]; then
			timeout 10s git clone ${gh_proxy}github.com/kejilion/apps.git
		else
			cd apps
			# git pull origin main > /dev/null 2>&1
			timeout 10s git pull ${gh_proxy}github.com/kejilion/apps.git main > /dev/null 2>&1
		fi
		local custom_app="$HOME/apps/${sub_choice}.conf"
		if [ -f "$custom_app" ]; then
			. "$custom_app"
		else
			echo -e "${gl_hong}錯誤: 未找到編號為${sub_choice}的應用程式配置${gl_bai}"
		fi
		  ;;
	esac
	break_end
	sub_choice=""

done
}



linux_work() {

	while true; do
	  clear
	  send_stats "後台工作區"
	  echo -e "後台工作區"
	  echo -e "系統將為你提供可以後台常駐運作的工作區，你可以用來執行長時間的任務"
	  echo -e "即使你斷開SSH，工作區的任務也不會中斷，後台常駐任務。"
	  echo -e "${gl_huang}提示:${gl_bai}進入工作區後再使用Ctrl+b再單獨按d，退出工作區！"
	  echo -e "${gl_kjlan}------------------------"
	  echo "目前已存在的工作區列表"
	  echo -e "${gl_kjlan}------------------------"
	  tmux list-sessions
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}1.   ${gl_bai}1號工作區"
	  echo -e "${gl_kjlan}2.   ${gl_bai}2號工作區"
	  echo -e "${gl_kjlan}3.   ${gl_bai}3號工作區"
	  echo -e "${gl_kjlan}4.   ${gl_bai}4號工作區"
	  echo -e "${gl_kjlan}5.   ${gl_bai}5號工作區"
	  echo -e "${gl_kjlan}6.   ${gl_bai}6號工作區"
	  echo -e "${gl_kjlan}7.   ${gl_bai}7號工作區"
	  echo -e "${gl_kjlan}8.   ${gl_bai}8號工作區"
	  echo -e "${gl_kjlan}9.   ${gl_bai}9號工作區"
	  echo -e "${gl_kjlan}10.  ${gl_bai}10號工作區"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}21.  ${gl_bai}SSH常駐模式${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}22.  ${gl_bai}創建/進入工作區"
	  echo -e "${gl_kjlan}23.  ${gl_bai}注入指令到後台工作區"
	  echo -e "${gl_kjlan}24.  ${gl_bai}刪除指定工作區"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}0.   ${gl_bai}返回主選單"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "請輸入你的選擇:" sub_choice

	  case $sub_choice in

		  1)
			  clear
			  install tmux
			  local SESSION_NAME="work1"
			  send_stats "啟動工作區$SESSION_NAME"
			  tmux_run

			  ;;
		  2)
			  clear
			  install tmux
			  local SESSION_NAME="work2"
			  send_stats "啟動工作區$SESSION_NAME"
			  tmux_run
			  ;;
		  3)
			  clear
			  install tmux
			  local SESSION_NAME="work3"
			  send_stats "啟動工作區$SESSION_NAME"
			  tmux_run
			  ;;
		  4)
			  clear
			  install tmux
			  local SESSION_NAME="work4"
			  send_stats "啟動工作區$SESSION_NAME"
			  tmux_run
			  ;;
		  5)
			  clear
			  install tmux
			  local SESSION_NAME="work5"
			  send_stats "啟動工作區$SESSION_NAME"
			  tmux_run
			  ;;
		  6)
			  clear
			  install tmux
			  local SESSION_NAME="work6"
			  send_stats "啟動工作區$SESSION_NAME"
			  tmux_run
			  ;;
		  7)
			  clear
			  install tmux
			  local SESSION_NAME="work7"
			  send_stats "啟動工作區$SESSION_NAME"
			  tmux_run
			  ;;
		  8)
			  clear
			  install tmux
			  local SESSION_NAME="work8"
			  send_stats "啟動工作區$SESSION_NAME"
			  tmux_run
			  ;;
		  9)
			  clear
			  install tmux
			  local SESSION_NAME="work9"
			  send_stats "啟動工作區$SESSION_NAME"
			  tmux_run
			  ;;
		  10)
			  clear
			  install tmux
			  local SESSION_NAME="work10"
			  send_stats "啟動工作區$SESSION_NAME"
			  tmux_run
			  ;;

		  21)
			while true; do
			  clear
			  if grep -q 'tmux attach-session -t sshd || tmux new-session -s sshd' ~/.bashrc; then
				  local tmux_sshd_status="${gl_lv}開啟${gl_bai}"
			  else
				  local tmux_sshd_status="${gl_hui}關閉${gl_bai}"
			  fi
			  send_stats "SSH常駐模式"
			  echo -e "SSH常駐模式${tmux_sshd_status}"
			  echo "開啟後SSH連線後會直接進入常駐模式，直接回到先前的工作狀態。"
			  echo "------------------------"
			  echo "1. 開啟 2. 關閉"
			  echo "------------------------"
			  echo "0. 返回上一級選單"
			  echo "------------------------"
			  read -e -p "請輸入你的選擇:" gongzuoqu_del
			  case "$gongzuoqu_del" in
				1)
			  	  install tmux
			  	  local SESSION_NAME="sshd"
			  	  send_stats "啟動工作區$SESSION_NAME"
				  grep -q "tmux attach-session -t sshd" ~/.bashrc || echo -e "\n# 自動進入 tmux 會話\nif [[ -z \"\$TMUX\" ]]; then\n    tmux attach-session -t sshd || tmux new-session -s sshd\nfi" >> ~/.bashrc
				  source ~/.bashrc
			  	  tmux_run
				  ;;
				2)
				  sed -i '/# 自動進入 tmux 會話/,+4d' ~/.bashrc
				  tmux kill-window -t sshd
				  ;;
				*)
				  break
				  ;;
			  esac
			done
			  ;;

		  22)
			  read -e -p "請輸入你所建立或進入的工作區名稱，如1​​001 kj001 work1:" SESSION_NAME
			  tmux_run
			  send_stats "自訂工作區"
			  ;;


		  23)
			  read -e -p "請輸入你要後台執行的指令，如:curl -fsSL https://get.docker.com | sh:" tmuxd
			  tmux_run_d
			  send_stats "注入指令到後台工作區"
			  ;;

		  24)
			  read -e -p "請輸入要刪除的工作區名稱:" gongzuoqu_name
			  tmux kill-window -t $gongzuoqu_name
			  send_stats "刪除工作區"
			  ;;

		  0)
			  kejilion
			  ;;
		  *)
			  echo "無效的輸入!"
			  ;;
	  esac
	  break_end

	done


}










# 智慧切換鏡像來源函數
switch_mirror() {
	# 可選參數，預設為 false
	local upgrade_software=${1:-false}
	local clean_cache=${2:-false}

	# 取得用戶國家
	local country
	country=$(curl -s ipinfo.io/country)

	echo "檢測到國家：$country"

	if [ "$country" = "CN" ]; then
		echo "使用國內鏡像來源..."
		bash <(curl -sSL https://linuxmirrors.cn/main.sh) \
		  --source mirrors.huaweicloud.com \
		  --protocol https \
		  --use-intranet-source false \
		  --backup true \
		  --upgrade-software "$upgrade_software" \
		  --clean-cache "$clean_cache" \
		  --ignore-backup-tips \
		  --install-epel false \
		  --pure-mode
	else
		echo "使用海外鏡像來源..."
		if [ -f /etc/os-release ] && grep -qi "oracle" /etc/os-release; then
			bash <(curl -sSL https://linuxmirrors.cn/main.sh) \
			  --source mirrors.xtom.com \
			  --protocol https \
			  --use-intranet-source false \
			  --backup true \
			  --upgrade-software "$upgrade_software" \
			  --clean-cache "$clean_cache" \
			  --ignore-backup-tips \
			  --install-epel false \
			  --pure-mode
		else
			bash <(curl -sSL https://linuxmirrors.cn/main.sh) \
				--use-official-source true \
				--protocol https \
				--use-intranet-source false \
				--backup true \
				--upgrade-software "$upgrade_software" \
				--clean-cache "$clean_cache" \
				--ignore-backup-tips \
				--install-epel false \
				--pure-mode
		fi
	fi
}


fail2ban_panel() {
		  root_use
		  send_stats "ssh防禦"
		  while true; do

				check_f2b_status
				echo -e "SSH防禦程序$check_f2b_status"
				echo "fail2ban是一個SSH防止暴力破解工具"
				echo "官網介紹:${gh_proxy}github.com/fail2ban/fail2ban"
				echo "------------------------"
				echo "1. 安裝防禦程序"
				echo "------------------------"
				echo "2. 查看SSH攔截記錄"
				echo "3. 日誌即時監控"
				echo "------------------------"
				echo "4. 基礎參數配置（封禁時間/時間視窗/重試次數）"
				echo "5. 編輯設定檔（nano）"
				echo "------------------------"
				echo "9. 卸載防禦程序"
				echo "------------------------"
				echo "0. 返回上一級選單"
				echo "------------------------"
				read -e -p "請輸入你的選擇:" sub_choice
				case $sub_choice in
					1)
						f2b_install_sshd
						cd ~
						f2b_status
						break_end
						;;
					2)
						echo "------------------------"
						f2b_sshd
						echo "------------------------"
						break_end
						;;
					3)
						tail -f /var/log/fail2ban.log
						break
						;;
					4)
						send_stats "SSH防禦基礎參數配置"
						f2b_basic_config
						break_end
						;;
					5)
						send_stats "SSH防禦編輯設定檔"
						f2b_edit_config
						break_end
						;;
					9)
						remove fail2ban
						rm -rf /etc/fail2ban
						echo "Fail2Ban防禦程序已卸載"
						break
						;;
					*)
						break
						;;
				esac
		  done

}





net_menu() {

	send_stats "網路卡管理工具"
	show_nics() {
		echo "================ 目前網卡資訊 =================="
		printf "%-18s %-12s %-20s %-26s\n" "網路卡名" "狀態" "IP位址" "MAC位址"
		echo "------------------------------------------------"
		for nic in $(ls /sys/class/net); do
			state=$(cat /sys/class/net/$nic/operstate 2>/dev/null)
			ipaddr=$(ip -4 addr show $nic | awk '/inet /{print $2}' | head -n1)
			mac=$(cat /sys/class/net/$nic/address 2>/dev/null)
			printf "%-15s %-10s %-18s %-20s\n" "$nic" "$state" "${ipaddr:-无}" "$mac"
		done
		echo "================================================"
	}

	while true; do
		clear
		show_nics
		echo
		echo "=========== 網路卡管理選單 ==========="
		echo "1. 啟用網卡"
		echo "2. 停用網路卡"
		echo "3. 查看網卡詳細信息"
		echo "4. 刷新網卡資訊"
		echo "0. 返回上一級選單"
		echo "===================================="
		read -erp "請選擇操作:" choice

		case $choice in
			1)
				send_stats "啟用網卡"
				read -erp "請輸入要啟用的網路卡名稱:" nic
				if ip link show "$nic" &>/dev/null; then
					ip link set "$nic" up && echo "✔ 網路卡$nic已啟用"
				else
					echo "✘ 網路卡不存在"
				fi
				read -erp "按回車繼續..."
				;;
			2)
				send_stats "停用網路卡"
				read -erp "請輸入要停用的網路卡名稱:" nic
				if ip link show "$nic" &>/dev/null; then
					ip link set "$nic" down && echo "✔ 網路卡$nic已停用"
				else
					echo "✘ 網路卡不存在"
				fi
				read -erp "按回車繼續..."
				;;
			3)
				send_stats "查看網卡詳情"
				read -erp "請輸入要查看的網路卡名稱:" nic
				if ip link show "$nic" &>/dev/null; then
					echo "========== $nic詳細資訊 =========="
					ip addr show "$nic"
					ethtool "$nic" 2>/dev/null | head -n 10
				else
					echo "✘ 網路卡不存在"
				fi
				read -erp "按回車繼續..."
				;;
			4)
				send_stats "刷新網卡資訊"
				continue
				;;
			*)
				break
				;;
		esac
	done
}



log_menu() {
	send_stats "系統日誌管理工具"

	show_log_overview() {
		echo "============= 系統日誌概覽 ============="
		echo "主機名稱: $(hostname)"
		echo "系統時間: $(date)"
		echo
		echo "[ /var/log 目錄佔用 ]"
		du -sh /var/log 2>/dev/null
		echo
		echo "[ journal 日誌佔用 ]"
		journalctl --disk-usage 2>/dev/null
		echo "========================================"
	}

	while true; do
		clear
		show_log_overview
		echo
		echo "=========== 系統日誌管理選單 ==========="
		echo "1. 查看最近系統日誌（journal）"
		echo "2. 查看指定服務日誌"
		echo "3. 查看登入/安全日誌"
		echo "4. 即時追蹤日誌"
		echo "5. 清理舊 journal 日誌"
		echo "0. 返回上一級選單"
		echo "======================================="
		read -erp "請選擇操作:" choice

		case $choice in
			1)
				send_stats "查看最近日誌"
				read -erp "查看最近多少行日誌？ [預設 100]:" lines
				lines=${lines:-100}
				journalctl -n "$lines" --no-pager
				read -erp "按回車繼續..."
				;;
			2)
				send_stats "查看指定服務日誌"
				read -erp "請輸入服務名稱（如 sshd、nginx）:" svc
				if systemctl list-unit-files | grep -q "^$svc"; then
					journalctl -u "$svc" -n 100 --no-pager
				else
					echo "✘ 服務不存在或無日誌"
				fi
				read -erp "按回車繼續..."
				;;
			3)
				send_stats "查看登入/安全日誌"
				echo "====== 最近登入日誌 ======"
				last -n 10
				echo
				echo "====== 認證日誌 ======"
				if [ -f /var/log/secure ]; then
					tail -n 20 /var/log/secure
				elif [ -f /var/log/auth.log ]; then
					tail -n 20 /var/log/auth.log
				else
					echo "未找到安全日誌文件"
				fi
				read -erp "按回車繼續..."
				;;
			4)
				send_stats "即時追蹤日誌"
				echo "1) 系統日誌"
				echo "2) 指定服務日誌"
				read -erp "選擇追蹤類型:" t
				if [ "$t" = "1" ]; then
					journalctl -f
				elif [ "$t" = "2" ]; then
					read -erp "輸入服務名稱:" svc
					journalctl -u "$svc" -f
				else
					echo "無效選擇"
				fi
				;;
			5)
				send_stats "清理舊 journal 日誌"
				echo "⚠️ 清理 journal 日誌（安全方式）"
				echo "1) 保留最近 7 天"
				echo "2) 保留最近 3 天"
				echo "3) 限制日誌最大 500M"
				read -erp "請選擇清理方式:" c
				case $c in
					1) journalctl --vacuum-time=7d ;;
					2) journalctl --vacuum-time=3d ;;
					3) journalctl --vacuum-size=500M ;;
					*) echo "無效選項" ;;
				esac
				echo "✔ journal 日誌清理完成"
				sleep 2
				;;
			*)
				break
				;;
		esac
	done
}



env_menu() {

	BASHRC="$HOME/.bashrc"
	PROFILE="$HOME/.profile"

	send_stats "系統變數管理工具"

	show_env_vars() {
		clear
		send_stats "目前已生效環境變數"
		echo "========== 目前已生效環境變數（節選） =========="
		printf "%-20s %s\n" "變數名" "值"
		echo "-----------------------------------------------"
		for v in USER HOME SHELL LANG PWD; do
			printf "%-20s %s\n" "$v" "${!v}"
		done

		echo
		echo "PATH:"
		echo "$PATH" | tr ':' '\n' | nl -ba

		echo
		echo "========== 設定檔中定義的變數（解析） =========="

		parse_file_vars() {
			local file="$1"
			[ -f "$file" ] || return

			echo
			echo ">>> 來源文件：$file"
			echo "-----------------------------------------------"

			# 提取 export VAR=xxx 或 VAR=xxx
			grep -Ev '^\s*#|^\s*$' "$file" \
			| grep -E '^(export[[:space:]]+)?[A-Za-z_][A-Za-z0-9_]*=' \
			| while read -r line; do
				var=$(echo "$line" | sed -E 's/^(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*).*/\2/')
				val=$(echo "$line" | sed -E 's/^[^=]+=//')
				printf "%-20s %s\n" "$var" "$val"
			done
		}

		parse_file_vars "$HOME/.bashrc"
		parse_file_vars "$HOME/.profile"

		echo
		echo "==============================================="
		read -erp "按回車繼續..."
	}


	view_file() {
		local file="$1"
		send_stats "查看變數文件$file"
		clear
		if [ -f "$file" ]; then
			echo "========== 查看文件：$file =========="
			cat -n "$file"
			echo "===================================="
		else
			echo "文件不存在：$file"
		fi
		read -erp "按回車繼續..."
	}

	edit_file() {
		local file="$1"
		send_stats "編輯變數文件$file"
		install nano
		nano "$file"
	}

	source_files() {
		echo "正在重新載入環境變數..."
		send_stats "正在重新載入環境變數"
		source "$BASHRC"
		source "$PROFILE"
		echo "✔ 環境變數已重新載入"
		read -erp "按回車繼續..."
	}

	while true; do
		clear
		echo "=========== 系統環境變數管理 =========="
		echo "目前使用者：$USER"
		echo "--------------------------------------"
		echo "1. 查看目前常用環境變數"
		echo "2. 查看 ~/.bashrc"
		echo "3. 查看 ~/.profile"
		echo "4. 編輯 ~/.bashrc"
		echo "5. 編輯 ~/.profile"
		echo "6. 重新載入環境變數（source）"
		echo "--------------------------------------"
		echo "0. 返回上一級選單"
		echo "--------------------------------------"
		read -erp "請選擇操作:" choice

		case "$choice" in
			1)
				show_env_vars
				;;
			2)
				view_file "$BASHRC"
				;;
			3)
				view_file "$PROFILE"
				;;
			4)
				edit_file "$BASHRC"
				;;
			5)
				edit_file "$PROFILE"
				;;
			6)
				source_files
				;;
			0)
				break
				;;
			*)
				echo "無效選項"
				sleep 1
				;;
		esac
	done
}


create_user_with_sshkey() {
	local new_username="$1"
	local is_sudo="${2:-false}"
	local sshkey_vl

	if [[ -z "$new_username" ]]; then
		echo "用法：create_user_with_sshkey <使用者名稱>"
		return 1
	fi

	# 創建用戶
	useradd -m -s /bin/bash "$new_username" || return 1

	echo "導入公鑰範例："
	echo "  - URL：      ${gh_https_url}github.com/torvalds.keys"
	echo "- 直接貼上： ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."
	read -e -p "請導入${new_username}的公鑰:" sshkey_vl

	case "$sshkey_vl" in
		http://*|https://*)
			send_stats "從 URL 匯入 SSH 公鑰"
			fetch_remote_ssh_keys "$sshkey_vl" "/home/$new_username"
			;;
		ssh-rsa*|ssh-ed25519*|ssh-ecdsa*)
			send_stats "公鑰直接導入"
			import_sshkey "$sshkey_vl" "/home/$new_username"
			;;
		*)
			echo "錯誤：未知參數 '$sshkey_vl'"
			return 1
			;;
	esac


	# 修正權限
	chown -R "$new_username:$new_username" "/home/$new_username/.ssh"

	install sudo

	# sudo 免密
	if [[ "$is_sudo" == "true" ]]; then
		cat >"/etc/sudoers.d/$new_username" <<EOF
$new_username ALL=(ALL) NOPASSWD:ALL
EOF
		chmod 440 "/etc/sudoers.d/$new_username"
	fi

	sed -i '/^\s*#\?\s*UsePAM\s\+/d' /etc/ssh/sshd_config
	echo 'UsePAM yes' >> /etc/ssh/sshd_config
	passwd -l "$new_username" &>/dev/null
	restart_ssh

	echo "使用者$new_username創建完成"
}















linux_Settings() {

	while true; do
	  clear
	  # send_stats "系統工具"
	  echo -e "系統工具"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}1.   ${gl_bai}設定腳本啟動快捷鍵${gl_kjlan}2.   ${gl_bai}修改登入密碼"
	  echo -e "${gl_kjlan}3.   ${gl_bai}使用者密碼登入模式${gl_kjlan}4.   ${gl_bai}安裝Python指定版本"
	  echo -e "${gl_kjlan}5.   ${gl_bai}開放所有連接埠${gl_kjlan}6.   ${gl_bai}修改SSH連接埠"
	  echo -e "${gl_kjlan}7.   ${gl_bai}優化DNS位址${gl_kjlan}8.   ${gl_bai}一鍵重裝系統${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}9.   ${gl_bai}停用ROOT帳戶建立新帳戶${gl_kjlan}10.  ${gl_bai}切換優先ipv4/ipv6"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}11.  ${gl_bai}查看連接埠佔用狀態${gl_kjlan}12.  ${gl_bai}修改虛擬記憶體大小"
	  echo -e "${gl_kjlan}13.  ${gl_bai}使用者管理${gl_kjlan}14.  ${gl_bai}使用者/密碼產生器"
	  echo -e "${gl_kjlan}15.  ${gl_bai}系統時區調整${gl_kjlan}16.  ${gl_bai}設定BBR3加速"
	  echo -e "${gl_kjlan}17.  ${gl_bai}防火牆高階管理器${gl_kjlan}18.  ${gl_bai}修改主機名"
	  echo -e "${gl_kjlan}19.  ${gl_bai}切換系統更新來源${gl_kjlan}20.  ${gl_bai}定時任務管理"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}21.  ${gl_bai}本機host解析${gl_kjlan}22.  ${gl_bai}SSH防禦程序"
	  echo -e "${gl_kjlan}23.  ${gl_bai}限流自動關機${gl_kjlan}24.  ${gl_bai}使用者密鑰登入模式"
	  echo -e "${gl_kjlan}25.  ${gl_bai}TG-bot系統監控預警${gl_kjlan}26.  ${gl_bai}修復OpenSSH高風險漏洞"
	  echo -e "${gl_kjlan}27.  ${gl_bai}紅帽系Linux核心升級${gl_kjlan}28.  ${gl_bai}Linux系統核心參數優化${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}29.  ${gl_bai}病毒掃描工具${gl_huang}★${gl_bai}                     ${gl_kjlan}30.  ${gl_bai}文件管理器"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}31.  ${gl_bai}切換系統語言${gl_kjlan}32.  ${gl_bai}命令列美化工具${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}33.  ${gl_bai}設定係統回收站${gl_kjlan}34.  ${gl_bai}系統備份與復原"
	  echo -e "${gl_kjlan}35.  ${gl_bai}ssh遠端連線工具${gl_kjlan}36.  ${gl_bai}硬碟分割區管理工具"
	  echo -e "${gl_kjlan}37.  ${gl_bai}命令列歷史記錄${gl_kjlan}38.  ${gl_bai}rsync遠端同步工具"
	  echo -e "${gl_kjlan}39.  ${gl_bai}命令收藏夾${gl_huang}★${gl_bai}                       ${gl_kjlan}40.  ${gl_bai}網路卡管理工具"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}41.  ${gl_bai}系統日誌管理工具${gl_huang}★${gl_bai}                 ${gl_kjlan}42.  ${gl_bai}系統變數管理工具"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}61.  ${gl_bai}留言板${gl_kjlan}66.  ${gl_bai}一條龍系統調優${gl_huang}★${gl_bai}"
	  echo -e "${gl_kjlan}99.  ${gl_bai}重啟伺服器${gl_kjlan}100. ${gl_bai}隱私與安全"
	  echo -e "${gl_kjlan}101. ${gl_bai}k指令進階用法${gl_huang}★${gl_bai}                    ${gl_kjlan}102. ${gl_bai}解除安裝科技lion腳本"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}0.   ${gl_bai}返回主選單"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "請輸入你的選擇:" sub_choice

	  case $sub_choice in
		  1)
			  while true; do
				  clear
				  read -e -p "請輸入你的快速按鍵（輸入0退出）:" kuaijiejian
				  if [ "$kuaijiejian" == "0" ]; then
					   break_end
					   linux_Settings
				  fi
				  find /usr/local/bin/ -type l -exec bash -c 'test "$(readlink -f {})" = "/usr/local/bin/k" && rm -f {}' \;
				  if [ "$kuaijiejian" != "k" ]; then
					  ln -sf /usr/local/bin/k /usr/local/bin/$kuaijiejian
				  fi
				  ln -sf /usr/local/bin/k /usr/bin/$kuaijiejian > /dev/null 2>&1
				  echo "快速鍵已設定"
				  send_stats "腳本快捷鍵已設定"
				  break_end
				  linux_Settings
			  done
			  ;;

		  2)
			  clear
			  send_stats "設定你的登入密碼"
			  echo "設定你的登入密碼"
			  passwd
			  ;;
		  3)
			  clear
			  add_sshpasswd
			  ;;

		  4)
			root_use
			send_stats "py版本管理"
			echo "python版本管理"
			echo "影片介紹: https://www.bilibili.com/video/BV1Pm42157cK?t=0.1"
			echo "---------------------------------------"
			echo "此功能可無縫安裝python官方支援的任何版本！"
			local VERSION=$(python3 -V 2>&1 | awk '{print $2}')
			echo -e "目前python版本號:${gl_huang}$VERSION${gl_bai}"
			echo "------------"
			echo "推薦版本: 3.12 3.11 3.10 3.9 3.8 2.7"
			echo "查詢更多版本: https://www.python.org/downloads/"
			echo "------------"
			read -e -p "輸入你要安裝的python版本號碼（輸入0退出）:" py_new_v


			if [[ "$py_new_v" == "0" ]]; then
				send_stats "腳本PY管理"
				break_end
				linux_Settings
			fi


			if ! grep -q 'export PYENV_ROOT="\$HOME/.pyenv"' ~/.bashrc; then
				if command -v yum &>/dev/null; then
					yum update -y && yum install git -y
					yum groupinstall "Development Tools" -y
					yum install openssl-devel bzip2-devel libffi-devel ncurses-devel zlib-devel readline-devel sqlite-devel xz-devel findutils -y

					curl -O https://www.openssl.org/source/openssl-1.1.1u.tar.gz
					tar -xzf openssl-1.1.1u.tar.gz
					cd openssl-1.1.1u
					./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl shared zlib
					make
					make install
					echo "/usr/local/openssl/lib" > /etc/ld.so.conf.d/openssl-1.1.1u.conf
					ldconfig -v
					cd ..

					export LDFLAGS="-L/usr/local/openssl/lib"
					export CPPFLAGS="-I/usr/local/openssl/include"
					export PKG_CONFIG_PATH="/usr/local/openssl/lib/pkgconfig"

				elif command -v apt &>/dev/null; then
					apt update -y && apt install git -y
					apt install build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev libgdbm-dev libnss3-dev libedit-dev -y
				elif command -v apk &>/dev/null; then
					apk update && apk add git
					apk add --no-cache bash gcc musl-dev libffi-dev openssl-dev bzip2-dev zlib-dev readline-dev sqlite-dev libc6-compat linux-headers make xz-dev build-base  ncurses-dev
				else
					echo "未知的套件管理器!"
					return
				fi

				curl https://pyenv.run | bash
				cat << EOF >> ~/.bashrc

export PYENV_ROOT="\$HOME/.pyenv"
if [[ -d "\$PYENV_ROOT/bin" ]]; then
  export PATH="\$PYENV_ROOT/bin:\$PATH"
fi
eval "\$(pyenv init --path)"
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"

EOF

			fi

			sleep 1
			source ~/.bashrc
			sleep 1
			pyenv install $py_new_v
			pyenv global $py_new_v

			rm -rf /tmp/python-build.*
			rm -rf $(pyenv root)/cache/*

			local VERSION=$(python -V 2>&1 | awk '{print $2}')
			echo -e "目前python版本號:${gl_huang}$VERSION${gl_bai}"
			send_stats "腳本PY版本切換"

			  ;;

		  5)
			  root_use
			  send_stats "開放埠"
			  iptables_open
			  remove iptables-persistent ufw firewalld iptables-services > /dev/null 2>&1
			  echo "連接埠已全部開放"

			  ;;
		  6)
			root_use
			send_stats "修改SSH端口"

			while true; do
				clear
				sed -i 's/^\s*#\?\s*Port/Port/' /etc/ssh/sshd_config

				# 讀取目前的 SSH 連接埠號
				local current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')

				# 列印目前的 SSH 連接埠號碼
				echo -e "目前的 SSH 連接埠號碼是:${gl_huang}$current_port ${gl_bai}"

				echo "------------------------"
				echo "連接埠號碼範圍1到65535之間的數字。 （輸入0退出）"

				# 提示使用者輸入新的 SSH 連接埠號碼
				read -e -p "請輸入新的 SSH 連接埠號碼:" new_port

				# 判斷連接埠號碼是否在有效範圍內
				if [[ $new_port =~ ^[0-9]+$ ]]; then  # 检查输入是否为数字
					if [[ $new_port -ge 1 && $new_port -le 65535 ]]; then
						send_stats "SSH連接埠已修改"
						new_ssh_port $new_port
					elif [[ $new_port -eq 0 ]]; then
						send_stats "退出SSH連接埠修改"
						break
					else
						echo "連接埠號碼無效，請輸入1到65535之間的數字。"
						send_stats "輸入無效SSH端口"
						break_end
					fi
				else
					echo "輸入無效，請輸入數字。"
					send_stats "輸入無效SSH端口"
					break_end
				fi
			done


			  ;;


		  7)
			set_dns_ui
			  ;;

		  8)

			dd_xitong
			  ;;
		  9)
			root_use
			send_stats "新用戶禁用root"
			read -e -p "請輸入新使用者名稱（輸入0退出）:" new_username
			if [ "$new_username" == "0" ]; then
				break_end
				linux_Settings
			fi

			create_user_with_sshkey $new_username true

			ssh-keygen -l -f /home/$new_username/.ssh/authorized_keys &>/dev/null && {
				passwd -l root &>/dev/null
				sed -i 's/^[[:space:]]*#\?[[:space:]]*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
			}

			;;


		  10)
			root_use
			send_stats "設定v4/v6優先級"
			while true; do
				clear
				echo "設定v4/v6優先級"
				echo "------------------------"


				if grep -Eq '^\s*precedence\s+::ffff:0:0/96\s+100\s*$' /etc/gai.conf 2>/dev/null; then
					echo -e "目前網路優先權設定:${gl_huang}IPv4${gl_bai}優先"
				else
					echo -e "目前網路優先權設定:${gl_huang}IPv6${gl_bai}優先"
				fi

				echo ""
				echo "------------------------"
				echo "1. IPv4 優先 2. IPv6 優先權 3. IPv6 修復工具"
				echo "------------------------"
				echo "0. 返回上一級選單"
				echo "------------------------"
				read -e -p "選擇優先的網路:" choice

				case $choice in
					1)
						prefer_ipv4
						;;
					2)
						rm -f /etc/gai.conf
						echo "已切換為 IPv6 優先"
						send_stats "已切換為 IPv6 優先"
						;;

					3)
						clear
						bash <(curl -L -s jhb.ovh/jb/v6.sh)
						echo "此功能由jhb大神提供，感謝他！"
						send_stats "ipv6修復"
						;;

					*)
						break
						;;

				esac
			done
			;;

		  11)
			clear
			ss -tulnape
			;;

		  12)
			root_use
			send_stats "設定虛擬記憶體"
			while true; do
				clear
				echo "設定虛擬記憶體"
				local swap_used=$(free -m | awk 'NR==3{print $3}')
				local swap_total=$(free -m | awk 'NR==3{print $2}')
				local swap_info=$(free -m | awk 'NR==3{used=$3; total=$2; if (total == 0) {percentage=0} else {percentage=used*100/total}; printf "%dM/%dM (%d%%)", used, total, percentage}')

				echo -e "當前虛擬記憶體:${gl_huang}$swap_info${gl_bai}"
				echo "------------------------"
				echo "1. 分配1024M 2. 分配2048M 3. 分配4096M 4. 自訂大小"
				echo "------------------------"
				echo "0. 返回上一級選單"
				echo "------------------------"
				read -e -p "請輸入你的選擇:" choice

				case "$choice" in
				  1)
					send_stats "已設定1G虛擬內存"
					add_swap 1024

					;;
				  2)
					send_stats "已設定2G虛擬內存"
					add_swap 2048

					;;
				  3)
					send_stats "已設定4G虛擬內存"
					add_swap 4096

					;;

				  4)
					read -e -p "請輸入虛擬記憶體大小（單位M）:" new_swap
					add_swap "$new_swap"
					send_stats "已設定自訂虛擬內存"
					;;

				  *)
					break
					;;
				esac
			done
			;;

		  13)
			  while true; do
				root_use
				send_stats "使用者管理"
				echo "使用者列表"
				echo "----------------------------------------------------------------------------"
				printf "%-24s %-34s %-20s %-10s\n" "使用者名稱" "使用者權限" "使用者群組" "sudo權限"
				while IFS=: read -r username _ userid groupid _ _ homedir shell; do
					local groups=$(groups "$username" | cut -d : -f 2)
					local sudo_status
					if sudo -n -lU "$username" 2>/dev/null | grep -q "(ALL) \(NOPASSWD: \)\?ALL"; then
						sudo_status="Yes"
					else
						sudo_status="No"
					fi
					printf "%-20s %-30s %-20s %-10s\n" "$username" "$homedir" "$groups" "$sudo_status"
				done < /etc/passwd


				  echo ""
				  echo "帳戶操作"
				  echo "------------------------"
				  echo "1. 建立普通用戶 2. 建立進階用戶"
				  echo "------------------------"
				  echo "3. 賦予最高權限 4. 取消最高權限"
				  echo "------------------------"
				  echo "5. 刪除帳號"
				  echo "------------------------"
				  echo "0. 返回上一級選單"
				  echo "------------------------"
				  read -e -p "請輸入你的選擇:" sub_choice

				  case $sub_choice in
					  1)
					   # 提示使用者輸入新使用者名稱
					   read -e -p "請輸入新用戶名:" new_username
					   create_user_with_sshkey $new_username false

						  ;;

					  2)
					   # 提示使用者輸入新使用者名稱
					   read -e -p "請輸入新用戶名:" new_username
					   create_user_with_sshkey $new_username true

						  ;;
					  3)
					   read -e -p "請輸入使用者名稱:" username
					   install sudo
					   cat >"/etc/sudoers.d/$username" <<EOF
$username ALL=(ALL) NOPASSWD:ALL
EOF
					  chmod 440 "/etc/sudoers.d/$username"

						  ;;
					  4)
					   read -e -p "請輸入使用者名稱:" username
				  	   if [[ -f "/etc/sudoers.d/$username" ]]; then
						   grep -lR "^$username" /etc/sudoers.d/ 2>/dev/null | xargs rm -f
					   fi
					   sed -i "/^$username\s*ALL=(ALL)/d" /etc/sudoers
						  ;;
					  5)
					   read -e -p "請輸入要刪除的使用者名稱:" username
					   userdel -r "$username"
						  ;;

					  *)
						  break  # 跳出循环，退出菜单
						  ;;
				  esac

			  done
			  ;;

		  14)
			clear
			send_stats "使用者資訊產生器"
			echo "隨機使用者名稱"
			echo "------------------------"
			for i in {1..5}; do
				username="user$(< /dev/urandom tr -dc _a-z0-9 | head -c6)"
				echo "隨機使用者名稱$i: $username"
			done

			echo ""
			echo "隨機姓名"
			echo "------------------------"
			local first_names=("John" "Jane" "Michael" "Emily" "David" "Sophia" "William" "Olivia" "James" "Emma" "Ava" "Liam" "Mia" "Noah" "Isabella")
			local last_names=("Smith" "Johnson" "Brown" "Davis" "Wilson" "Miller" "Jones" "Garcia" "Martinez" "Williams" "Lee" "Gonzalez" "Rodriguez" "Hernandez")

			# 產生5個隨機用戶姓名
			for i in {1..5}; do
				local first_name_index=$((RANDOM % ${#first_names[@]}))
				local last_name_index=$((RANDOM % ${#last_names[@]}))
				local user_name="${first_names[$first_name_index]} ${last_names[$last_name_index]}"
				echo "隨機用戶姓名$i: $user_name"
			done

			echo ""
			echo "隨機UUID"
			echo "------------------------"
			for i in {1..5}; do
				uuid=$(cat /proc/sys/kernel/random/uuid)
				echo "隨機UUID$i: $uuid"
			done

			echo ""
			echo "16位隨機密碼"
			echo "------------------------"
			for i in {1..5}; do
				local password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16)
				echo "隨機密碼$i: $password"
			done

			echo ""
			echo "32位隨機密碼"
			echo "------------------------"
			for i in {1..5}; do
				local password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32)
				echo "隨機密碼$i: $password"
			done
			echo ""

			  ;;

		  15)
			root_use
			send_stats "換時區"
			while true; do
				clear
				echo "系統時間資訊"

				# 取得目前系統時區
				local timezone=$(current_timezone)

				# 取得目前系統時間
				local current_time=$(date +"%Y-%m-%d %H:%M:%S")

				# 顯示時區和時間
				echo "目前系統時區：$timezone"
				echo "目前系統時間：$current_time"

				echo ""
				echo "時區切換"
				echo "------------------------"
				echo "亞洲"
				echo "1. 中國上海時間 2. 中國香港時間"
				echo "3. 日本東京時間 4. 韓國首爾時間"
				echo "5. 新加坡時間 6. 印度加爾各答時間"
				echo "7. 阿聯酋杜拜時間 8. 澳洲雪梨時間"
				echo "9. 泰國曼谷時間"
				echo "------------------------"
				echo "歐洲"
				echo "11. 英國倫敦時間 12. 法國巴黎時間"
				echo "13. 德國柏林時間 14. 俄羅斯莫斯科時間"
				echo "15. 荷蘭尤特賴赫特時間 16. 西班牙馬德里時間"
				echo "------------------------"
				echo "美洲"
				echo "21. 美國西部時間 22. 美國東部時間"
				echo "23. 加拿大時間 24. 墨西哥時間"
				echo "25. 巴西時間 26. 阿根廷時間"
				echo "------------------------"
				echo "31. UTC全球標準時間"
				echo "------------------------"
				echo "0. 返回上一級選單"
				echo "------------------------"
				read -e -p "請輸入你的選擇:" sub_choice


				case $sub_choice in
					1) set_timedate Asia/Shanghai ;;
					2) set_timedate Asia/Hong_Kong ;;
					3) set_timedate Asia/Tokyo ;;
					4) set_timedate Asia/Seoul ;;
					5) set_timedate Asia/Singapore ;;
					6) set_timedate Asia/Kolkata ;;
					7) set_timedate Asia/Dubai ;;
					8) set_timedate Australia/Sydney ;;
					9) set_timedate Asia/Bangkok ;;
					11) set_timedate Europe/London ;;
					12) set_timedate Europe/Paris ;;
					13) set_timedate Europe/Berlin ;;
					14) set_timedate Europe/Moscow ;;
					15) set_timedate Europe/Amsterdam ;;
					16) set_timedate Europe/Madrid ;;
					21) set_timedate America/Los_Angeles ;;
					22) set_timedate America/New_York ;;
					23) set_timedate America/Vancouver ;;
					24) set_timedate America/Mexico_City ;;
					25) set_timedate America/Sao_Paulo ;;
					26) set_timedate America/Argentina/Buenos_Aires ;;
					31) set_timedate UTC ;;
					*) break ;;
				esac
			done
			  ;;

		  16)

			bbrv3
			  ;;

		  17)
			  iptables_panel

			  ;;

		  18)
		  root_use
		  send_stats "修改主機名"

		  while true; do
			  clear
			  local current_hostname=$(uname -n)
			  echo -e "目前主機名稱:${gl_huang}$current_hostname${gl_bai}"
			  echo "------------------------"
			  read -e -p "請輸入新的主機名稱（輸入0退出）:" new_hostname
			  if [ -n "$new_hostname" ] && [ "$new_hostname" != "0" ]; then
				  if [ -f /etc/alpine-release ]; then
					  # Alpine
					  echo "$new_hostname" > /etc/hostname
					  hostname "$new_hostname"
				  else
					  # 其他系統，如 Debian, Ubuntu, CentOS 等
					  hostnamectl set-hostname "$new_hostname"
					  sed -i "s/$current_hostname/$new_hostname/g" /etc/hostname
					  systemctl restart systemd-hostnamed
				  fi

				  if grep -q "127.0.0.1" /etc/hosts; then
					  sed -i "s/127.0.0.1 .*/127.0.0.1       $new_hostname localhost localhost.localdomain/g" /etc/hosts
				  else
					  echo "127.0.0.1       $new_hostname localhost localhost.localdomain" >> /etc/hosts
				  fi

				  if grep -q "^::1" /etc/hosts; then
					  sed -i "s/^::1 .*/::1             $new_hostname localhost localhost.localdomain ipv6-localhost ipv6-loopback/g" /etc/hosts
				  else
					  echo "::1             $new_hostname localhost localhost.localdomain ipv6-localhost ipv6-loopback" >> /etc/hosts
				  fi

				  echo "主機名稱已更改為:$new_hostname"
				  send_stats "主機名稱已更改"
				  sleep 1
			  else
				  echo "已退出，未更改主機名稱。"
				  break
			  fi
		  done
			  ;;

		  19)
		  root_use
		  send_stats "換系統更新來源"
		  clear
		  echo "選擇更新來源區域"
		  echo "接入LinuxMirrors切換系統更新來源"
		  echo "------------------------"
		  echo "1. 中國大陸【預設】 2. 中國大陸【教育網】 3. 海外地區 4. 智慧切換更新源"
		  echo "------------------------"
		  echo "0. 返回上一級選單"
		  echo "------------------------"
		  read -e -p "輸入你的選擇:" choice

		  case $choice in
			  1)
				  send_stats "中國大陸預設來源"
				  bash <(curl -sSL https://linuxmirrors.cn/main.sh)
				  ;;
			  2)
				  send_stats "中國大陸教育源"
				  bash <(curl -sSL https://linuxmirrors.cn/main.sh) --edu
				  ;;
			  3)
				  send_stats "海外源"
				  bash <(curl -sSL https://linuxmirrors.cn/main.sh) --abroad
				  ;;
			  4)
				  send_stats "智慧切換更新來源"
				  switch_mirror false false
				  ;;

			  *)
				  echo "已取消"
				  ;;

		  esac

			  ;;

		  20)
		  send_stats "定時任務管理"
			  while true; do
				  clear
				  check_crontab_installed
				  clear
				  echo "定時任務列表"
				  crontab -l
				  echo ""
				  echo "操作"
				  echo "------------------------"
				  echo "1. 新增定時任務 2. 刪除定時任務 3. 編輯定時任務"
				  echo "------------------------"
				  echo "0. 返回上一級選單"
				  echo "------------------------"
				  read -e -p "請輸入你的選擇:" sub_choice

				  case $sub_choice in
					  1)
						  read -e -p "請輸入新任務的執行指令:" newquest
						  echo "------------------------"
						  echo "1. 每月任務 2. 每週任務"
						  echo "3. 每天任務 4. 每小時任務"
						  echo "------------------------"
						  read -e -p "請輸入你的選擇:" dingshi

						  case $dingshi in
							  1)
								  read -e -p "選擇每月的幾號執行任務？ (1-30):" day
								  (crontab -l ; echo "0 0 $day * * $newquest") | crontab - > /dev/null 2>&1
								  ;;
							  2)
								  read -e -p "選擇週幾執行任務？ (0-6，0代表星期日):" weekday
								  (crontab -l ; echo "0 0 * * $weekday $newquest") | crontab - > /dev/null 2>&1
								  ;;
							  3)
								  read -e -p "選擇每天幾點執行任務？ （小時，0-23）:" hour
								  (crontab -l ; echo "0 $hour * * * $newquest") | crontab - > /dev/null 2>&1
								  ;;
							  4)
								  read -e -p "輸入每小時的第幾分鐘執行任務？ （分鐘，0-60）:" minute
								  (crontab -l ; echo "$minute * * * * $newquest") | crontab - > /dev/null 2>&1
								  ;;
							  *)
								  break  # 跳出
								  ;;
						  esac
						  send_stats "新增定時任務"
						  ;;
					  2)
						  read -e -p "請輸入需要刪除任務的關鍵字:" kquest
						  crontab -l | grep -v "$kquest" | crontab -
						  send_stats "刪除定時任務"
						  ;;
					  3)
						  crontab -e
						  send_stats "編輯定時任務"
						  ;;
					  *)
						  break  # 跳出循环，退出菜单
						  ;;
				  esac
			  done

			  ;;

		  21)
			  root_use
			  send_stats "本地host解析"
			  while true; do
				  clear
				  echo "本機host解析列表"
				  echo "如果你在這裡添加解析匹配，將不再使用動態解析了"
				  cat /etc/hosts
				  echo ""
				  echo "操作"
				  echo "------------------------"
				  echo "1. 新增新的解析 2. 刪除解析位址"
				  echo "------------------------"
				  echo "0. 返回上一級選單"
				  echo "------------------------"
				  read -e -p "請輸入你的選擇:" host_dns

				  case $host_dns in
					  1)
						  read -e -p "請輸入新的解析記錄 格式: 110.25.5.33 kejilion.pro :" addhost
						  echo "$addhost" >> /etc/hosts
						  send_stats "本機host解析新增"

						  ;;
					  2)
						  read -e -p "請輸入需要刪除的解析內容關鍵字:" delhost
						  sed -i "/$delhost/d" /etc/hosts
						  send_stats "本機host解析刪除"
						  ;;
					  *)
						  break  # 跳出循环，退出菜单
						  ;;
				  esac
			  done
			  ;;

		  22)
			fail2ban_panel
			  ;;


		  23)
			root_use
			send_stats "限流關機功能"
			while true; do
				clear
				echo "限流關機功能"
				echo "影片介紹: https://www.bilibili.com/video/BV1mC411j7Qd?t=0.1"
				echo "------------------------------------------------"
				echo "目前流量使用情況，重啟伺服器流量計算會清除！"
				output_status
				echo -e "${gl_kjlan}總接收:${gl_bai}$rx"
				echo -e "${gl_kjlan}總發送:${gl_bai}$tx"

				# 檢查是否存在 Limiting_Shut_down.sh 文件
				if [ -f ~/Limiting_Shut_down.sh ]; then
					# 取得 threshold_gb 的值
					local rx_threshold_gb=$(grep -oP 'rx_threshold_gb=\K\d+' ~/Limiting_Shut_down.sh)
					local tx_threshold_gb=$(grep -oP 'tx_threshold_gb=\K\d+' ~/Limiting_Shut_down.sh)
					echo -e "${gl_lv}目前設定的進站限流閾值為:${gl_huang}${rx_threshold_gb}${gl_lv}G${gl_bai}"
					echo -e "${gl_lv}目前設定的出站限流閾值為:${gl_huang}${tx_threshold_gb}${gl_lv}GB${gl_bai}"
				else
					echo -e "${gl_hui}目前未啟用限流關機功能${gl_bai}"
				fi

				echo
				echo "------------------------------------------------"
				echo "系統每分鐘會偵測實際流量是否到達閾值，到達後會自動關閉伺服器！"
				echo "------------------------"
				echo "1. 開啟限流關機功能 2. 停用限流關機功能"
				echo "------------------------"
				echo "0. 返回上一級選單"
				echo "------------------------"
				read -e -p "請輸入你的選擇:" Limiting

				case "$Limiting" in
				  1)
					# 輸入新的虛擬記憶體大小
					echo "若實際伺服器就100G流量，可設定閾值為95G，提前關機，以免出現流量誤差或溢位。"
					read -e -p "請輸入進站流量閾值（單位為G，預設100G）:" rx_threshold_gb
					rx_threshold_gb=${rx_threshold_gb:-100}
					read -e -p "請輸入出站流量閾值（單位為G，預設100G）:" tx_threshold_gb
					tx_threshold_gb=${tx_threshold_gb:-100}
					read -e -p "請輸入流量重置日期（預設每月1日重設）:" cz_day
					cz_day=${cz_day:-1}

					cd ~
					curl -Ss -o ~/Limiting_Shut_down.sh ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/Limiting_Shut_down1.sh
					chmod +x ~/Limiting_Shut_down.sh
					sed -i "s/110/$rx_threshold_gb/g" ~/Limiting_Shut_down.sh
					sed -i "s/120/$tx_threshold_gb/g" ~/Limiting_Shut_down.sh
					check_crontab_installed
					crontab -l | grep -v '~/Limiting_Shut_down.sh' | crontab -
					(crontab -l ; echo "* * * * * ~/Limiting_Shut_down.sh") | crontab - > /dev/null 2>&1
					crontab -l | grep -v 'reboot' | crontab -
					(crontab -l ; echo "0 1 $cz_day * * reboot") | crontab - > /dev/null 2>&1
					echo "限流關機已設定"
					send_stats "限流關機已設定"
					;;
				  2)
					check_crontab_installed
					crontab -l | grep -v '~/Limiting_Shut_down.sh' | crontab -
					crontab -l | grep -v 'reboot' | crontab -
					rm ~/Limiting_Shut_down.sh
					echo "已關閉限流關機功能"
					;;
				  *)
					break
					;;
				esac
			done
			  ;;


		  24)
			sshkey_panel
			  ;;

		  25)
			  root_use
			  send_stats "電報預警"
			  echo "TG-bot監控預警功能"
			  echo "影片介紹: https://youtu.be/vLL-eb3Z_TY"
			  echo "------------------------------------------------"
			  echo "您需要設定tg機器人API和接收預警的用戶ID，即可實現本機CPU，內存，硬碟，流量，SSH登入的即時監控預警"
			  echo "到達閾值後會向用戶發送預警訊息"
			  echo -e "${gl_hui}-關於流量，重啟伺服器將重新計算-${gl_bai}"
			  read -e -p "確定繼續嗎？ (Y/N):" choice

			  case "$choice" in
				[Yy])
				  send_stats "電報預警啟用"
				  cd ~
				  install nano tmux bc jq
				  check_crontab_installed
				  if [ -f ~/TG-check-notify.sh ]; then
					  chmod +x ~/TG-check-notify.sh
					  nano ~/TG-check-notify.sh
				  else
					  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/TG-check-notify.sh
					  chmod +x ~/TG-check-notify.sh
					  nano ~/TG-check-notify.sh
				  fi
				  tmux kill-session -t TG-check-notify > /dev/null 2>&1
				  tmux new -d -s TG-check-notify "~/TG-check-notify.sh"
				  crontab -l | grep -v '~/TG-check-notify.sh' | crontab - > /dev/null 2>&1
				  (crontab -l ; echo "@reboot tmux new -d -s TG-check-notify '~/TG-check-notify.sh'") | crontab - > /dev/null 2>&1

				  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/TG-SSH-check-notify.sh > /dev/null 2>&1
				  sed -i "3i$(grep '^TELEGRAM_BOT_TOKEN=' ~/TG-check-notify.sh)" TG-SSH-check-notify.sh > /dev/null 2>&1
				  sed -i "4i$(grep '^CHAT_ID=' ~/TG-check-notify.sh)" TG-SSH-check-notify.sh
				  chmod +x ~/TG-SSH-check-notify.sh

				  # 加入 ~/.profile 檔案中
				  if ! grep -q 'bash ~/TG-SSH-check-notify.sh' ~/.profile > /dev/null 2>&1; then
					  echo 'bash ~/TG-SSH-check-notify.sh' >> ~/.profile
					  if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
						 echo 'source ~/.profile' >> ~/.bashrc
					  fi
				  fi

				  source ~/.profile

				  clear
				  echo "TG-bot預警系統已啟動"
				  echo -e "${gl_hui}你也可以將root目錄中的TG-check-notify.sh預警檔案放到其他機器上直接使用！${gl_bai}"
				  ;;
				[Nn])
				  echo "已取消"
				  ;;
				*)
				  echo "無效的選擇，請輸入 Y 或 N。"
				  ;;
			  esac
			  ;;

		  26)
			  root_use
			  send_stats "修復SSH高風險漏洞"
			  cd ~
			  curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/upgrade_openssh9.8p1.sh
			  chmod +x ~/upgrade_openssh9.8p1.sh
			  ~/upgrade_openssh9.8p1.sh
			  rm -f ~/upgrade_openssh9.8p1.sh
			  ;;

		  27)
			  elrepo
			  ;;
		  28)
			  Kernel_optimize
			  ;;

		  29)
			  clamav
			  ;;

		  30)
			  linux_file
			  ;;

		  31)
			  linux_language
			  ;;

		  32)
			  shell_bianse
			  ;;
		  33)
			  linux_trash
			  ;;
		  34)
			  linux_backup
			  ;;
		  35)
			  ssh_manager
			  ;;
		  36)
			  disk_manager
			  ;;
		  37)
			  clear
			  send_stats "命令列歷史記錄"
			  get_history_file() {
				  for file in "$HOME"/.bash_history "$HOME"/.ash_history "$HOME"/.zsh_history "$HOME"/.local/share/fish/fish_history; do
					  [ -f "$file" ] && { echo "$file"; return; }
				  done
				  return 1
			  }

			  history_file=$(get_history_file) && cat -n "$history_file"
			  ;;

		  38)
			  rsync_manager
			  ;;


		  39)
			  clear
			  linux_fav
			  ;;

		  40)
			  clear
			  net_menu
			  ;;

		  41)
			  clear
			  log_menu
			  ;;

		  42)
			  clear
			  env_menu
			  ;;


		  61)
			clear
			send_stats "留言板"
			echo "造訪科技lion官方留言板，您對腳本有任何想法歡迎留言交流！"
			echo "https://board.kejilion.pro"
			echo "公共密碼: kejilion.sh"
			  ;;

		  66)

			  root_use
			  send_stats "一條龍調優"
			  echo "一條龍系統調優"
			  echo "------------------------------------------------"
			  echo "將對以下內容進行操作與優化"
			  echo "1. 最佳化系統更新來源，更新系統到最新"
			  echo "2. 清理系統垃圾文件"
			  echo -e "3. 設定虛擬內存${gl_huang}1G${gl_bai}"
			  echo -e "4. 設定SSH埠號為${gl_huang}5522${gl_bai}"
			  echo -e "5. 啟動fail2ban防禦SSH暴力破解"
			  echo -e "6. 開放所有端口"
			  echo -e "7. 開啟${gl_huang}BBR${gl_bai}加速"
			  echo -e "8. 設定時區到${gl_huang}上海${gl_bai}"
			  echo -e "9. 自動優化DNS位址${gl_huang}海外: 1.1.1.1 8.8.8.8 國內: 223.5.5.5${gl_bai}"
		  	  echo -e "10. 設定網路為${gl_huang}ipv4優先${gl_bai}"
			  echo -e "11. 安裝基礎工具${gl_huang}docker wget sudo tar unzip socat btop nano vim${gl_bai}"
			  echo -e "12. Linux系統核心參數優化${gl_huang}自動根據網路環境調優${gl_bai}"
			  echo "------------------------------------------------"
			  read -e -p "確定一鍵保養嗎？ (Y/N):" choice

			  case "$choice" in
				[Yy])
				  clear
				  send_stats "一條龍調優啟動"
				  echo "------------------------------------------------"
				  switch_mirror false false
				  linux_update
				  echo -e "[${gl_lv}OK${gl_bai}] 1/12. 更新系統到最新"

				  echo "------------------------------------------------"
				  linux_clean
				  echo -e "[${gl_lv}OK${gl_bai}] 2/12. 清理系統垃圾文件"

				  echo "------------------------------------------------"
				  add_swap 1024
				  echo -e "[${gl_lv}OK${gl_bai}] 3/12. 設定虛擬內存${gl_huang}1G${gl_bai}"

				  echo "------------------------------------------------"
				  new_ssh_port 5522
				  echo -e "[${gl_lv}OK${gl_bai}] 4/12. 設定SSH埠號為${gl_huang}5522${gl_bai}"
				  echo "------------------------------------------------"
				  f2b_install_sshd
				  cd ~
				  f2b_status
				  echo -e "[${gl_lv}OK${gl_bai}] 5/12. 啟動fail2ban防禦SSH暴力破解"

				  echo "------------------------------------------------"
				  echo -e "[${gl_lv}OK${gl_bai}] 6/12. 開放所有端口"

				  echo "------------------------------------------------"
				  bbr_on
				  echo -e "[${gl_lv}OK${gl_bai}] 7/12. 開啟${gl_huang}BBR${gl_bai}加速"

				  echo "------------------------------------------------"
				  set_timedate Asia/Shanghai
				  echo -e "[${gl_lv}OK${gl_bai}] 8/12. 設定時區到${gl_huang}上海${gl_bai}"

				  echo "------------------------------------------------"
				  auto_optimize_dns
				  echo -e "[${gl_lv}OK${gl_bai}] 9/12. 自動最佳化DNS位址${gl_huang}${gl_bai}"
				  echo "------------------------------------------------"
				  prefer_ipv4
				  echo -e "[${gl_lv}OK${gl_bai}] 10/12. 設定網路為${gl_huang}ipv4優先${gl_bai}}"

				  echo "------------------------------------------------"
				  install_docker
				  install wget sudo tar unzip socat btop nano vim
				  echo -e "[${gl_lv}OK${gl_bai}] 11/12. 安裝基礎工具${gl_huang}docker wget sudo tar unzip socat btop nano vim${gl_bai}"
				  echo "------------------------------------------------"

				  curl -sS ${gh_proxy}raw.githubusercontent.com/kejilion/sh/refs/heads/main/network-optimize.sh | bash
				  echo -e "[${gl_lv}OK${gl_bai}] 12/12. Linux系統核心參數最佳化"
				  echo -e "${gl_lv}一條龍系統調優已完成${gl_bai}"

				  ;;
				[Nn])
				  echo "已取消"
				  ;;
				*)
				  echo "無效的選擇，請輸入 Y 或 N。"
				  ;;
			  esac

			  ;;

		  99)
			  clear
			  send_stats "重啟系統"
			  server_reboot
			  ;;
		  100)

			root_use
			while true; do
			  clear
			  if grep -q '^ENABLE_STATS="true"' /usr/local/bin/k > /dev/null 2>&1; then
			  	local status_message="${gl_lv}正在採集數據${gl_bai}"
			  elif grep -q '^ENABLE_STATS="false"' /usr/local/bin/k > /dev/null 2>&1; then
			  	local status_message="${gl_hui}採集已關閉${gl_bai}"
			  else
			  	local status_message="無法確定的狀態"
			  fi

			  echo "隱私與安全"
			  echo "腳本將收集使用者使用功能的數據，優化腳本體驗，製作更多好玩好用的功能"
			  echo "將收集腳本版本號，使用的時間，系統版本，CPU架構，機器所屬國家和使用的功能的名稱，"
			  echo "------------------------------------------------"
			  echo -e "目前狀態:$status_message"
			  echo "--------------------"
			  echo "1. 開啟採集"
			  echo "2. 關閉採集"
			  echo "--------------------"
			  echo "0. 返回上一級選單"
			  echo "--------------------"
			  read -e -p "請輸入你的選擇:" sub_choice
			  case $sub_choice in
				  1)
					  cd ~
					  sed -i 's/^ENABLE_STATS="false"/ENABLE_STATS="true"/' /usr/local/bin/k
					  sed -i 's/^ENABLE_STATS="false"/ENABLE_STATS="true"/' ~/kejilion.sh
					  echo "已開啟擷取"
					  send_stats "隱私與安全已開啟擷取"
					  ;;
				  2)
					  cd ~
					  sed -i 's/^ENABLE_STATS="true"/ENABLE_STATS="false"/' /usr/local/bin/k
					  sed -i 's/^ENABLE_STATS="true"/ENABLE_STATS="false"/' ~/kejilion.sh
					  echo "已關閉採集"
					  send_stats "隱私與安全已關閉採集"
					  ;;
				  *)
					  break
					  ;;
			  esac
			done
			  ;;

		  101)
			  clear
			  k_info
			  ;;

		  102)
			  clear
			  send_stats "解除安裝科技lion腳本"
			  echo "解除安裝科技lion腳本"
			  echo "------------------------------------------------"
			  echo "將徹底卸載kejilion腳本，不影響你其他功能"
			  read -e -p "確定繼續嗎？ (Y/N):" choice

			  case "$choice" in
				[Yy])
				  clear
				  (crontab -l | grep -v "kejilion.sh") | crontab -
				  rm -f /usr/local/bin/k
				  rm ~/kejilion.sh
				  echo "腳本已卸載，再見！"
				  break_end
				  clear
				  exit
				  ;;
				[Nn])
				  echo "已取消"
				  ;;
				*)
				  echo "無效的選擇，請輸入 Y 或 N。"
				  ;;
			  esac
			  ;;

		  0)
			  kejilion

			  ;;
		  *)
			  echo "無效的輸入!"
			  ;;
	  esac
	  break_end

	done



}






linux_file() {
	root_use
	send_stats "文件管理器"
	while true; do
		clear
		echo "文件管理器"
		echo "------------------------"
		echo "目前路徑"
		pwd
		echo "------------------------"
		ls --color=auto -x
		echo "------------------------"
		echo "1. 進入目錄 2. 建立目錄 3. 修改目錄權限 4. 重新命名目錄"
		echo "5. 刪除目錄 6. 返回上一層選單目錄"
		echo "------------------------"
		echo "11. 建立文件 12. 編輯文件 13. 修改文件權限 14. 重新命名文件"
		echo "15. 刪除文件"
		echo "------------------------"
		echo "21. 壓縮檔案目錄 22. 解壓縮檔案目錄 23. 行動檔案目錄 24. 複製檔案目錄"
		echo "25. 傳文件至其他伺服器"
		echo "------------------------"
		echo "0. 返回上一級選單"
		echo "------------------------"
		read -e -p "請輸入你的選擇:" Limiting

		case "$Limiting" in
			1)  # 进入目录
				read -e -p "請輸入目錄名:" dirname
				cd "$dirname" 2>/dev/null || echo "無法進入目錄"
				send_stats "進入目錄"
				;;
			2)  # 创建目录
				read -e -p "請輸入要建立的目錄名稱:" dirname
				mkdir -p "$dirname" && echo "目錄已建立" || echo "創建失敗"
				send_stats "建立目錄"
				;;
			3)  # 修改目录权限
				read -e -p "請輸入目錄名:" dirname
				read -e -p "請輸入權限 (如 755):" perm
				chmod "$perm" "$dirname" && echo "權限已修改" || echo "修改失敗"
				send_stats "修改目錄權限"
				;;
			4)  # 重命名目录
				read -e -p "請輸入目前目錄名稱:" current_name
				read -e -p "請輸入新目錄名稱:" new_name
				mv "$current_name" "$new_name" && echo "目錄已重新命名" || echo "重新命名失敗"
				send_stats "重新命名目錄"
				;;
			5)  # 删除目录
				read -e -p "請輸入要刪除的目錄名稱:" dirname
				rm -rf "$dirname" && echo "目錄已刪除" || echo "刪除失敗"
				send_stats "刪除目錄"
				;;
			6)  # 返回上一级选单目录
				cd ..
				send_stats "返回上一層選單目錄"
				;;
			11) # 创建文件
				read -e -p "請輸入要建立的檔案名稱:" filename
				touch "$filename" && echo "文件已建立" || echo "創建失敗"
				send_stats "建立文件"
				;;
			12) # 编辑文件
				read -e -p "請輸入要編輯的檔名:" filename
				install nano
				nano "$filename"
				send_stats "編輯文件"
				;;
			13) # 修改文件权限
				read -e -p "請輸入檔名:" filename
				read -e -p "請輸入權限 (如 755):" perm
				chmod "$perm" "$filename" && echo "權限已修改" || echo "修改失敗"
				send_stats "修改檔案權限"
				;;
			14) # 重命名文件
				read -e -p "請輸入目前檔名:" current_name
				read -e -p "請輸入新檔名:" new_name
				mv "$current_name" "$new_name" && echo "文件已重新命名" || echo "重新命名失敗"
				send_stats "重新命名文件"
				;;
			15) # 删除文件
				read -e -p "請輸入要刪除的檔名:" filename
				rm -f "$filename" && echo "文件已刪除" || echo "刪除失敗"
				send_stats "刪除文件"
				;;
			21) # 压缩文件/目录
				read -e -p "請輸入要壓縮的檔案/目錄名稱:" name
				install tar
				tar -czvf "$name.tar.gz" "$name" && echo "已壓縮為$name.tar.gz" || echo "壓縮失敗"
				send_stats "壓縮檔案/目錄"
				;;
			22) # 解压文件/目录
				read -e -p "請輸入要解壓縮的檔名 (.tar.gz):" filename
				install tar
				tar -xzvf "$filename" && echo "已解壓縮$filename" || echo "解壓縮失敗"
				send_stats "解壓縮檔案/目錄"
				;;

			23) # 移动文件或目录
				read -e -p "請輸入要移動的檔案或目錄路徑:" src_path
				if [ ! -e "$src_path" ]; then
					echo "錯誤: 檔案或目錄不存在。"
					send_stats "移動檔案或目錄失敗: 檔案或目錄不存在"
					continue
				fi

				read -e -p "請輸入目標路徑 (包括新檔案名稱或目錄名稱):" dest_path
				if [ -z "$dest_path" ]; then
					echo "錯誤: 請輸入目標路徑。"
					send_stats "移動檔案或目錄失敗: 目標路徑未指定"
					continue
				fi

				mv "$src_path" "$dest_path" && echo "檔案或目錄已移動到$dest_path" || echo "移動檔案或目錄失敗"
				send_stats "移動檔案或目錄"
				;;


		   24) # 复制文件目录
				read -e -p "請輸入要複製的檔案或目錄路徑:" src_path
				if [ ! -e "$src_path" ]; then
					echo "錯誤: 檔案或目錄不存在。"
					send_stats "複製檔案或目錄失敗: 檔案或目錄不存在"
					continue
				fi

				read -e -p "請輸入目標路徑 (包括新檔案名稱或目錄名稱):" dest_path
				if [ -z "$dest_path" ]; then
					echo "錯誤: 請輸入目標路徑。"
					send_stats "複製檔案或目錄失敗: 目標路徑未指定"
					continue
				fi

				# 使用 -r 選項以遞歸方式複製目錄
				cp -r "$src_path" "$dest_path" && echo "檔案或目錄已複製到$dest_path" || echo "複製檔案或目錄失敗"
				send_stats "複製檔案或目錄"
				;;


			 25) # 传送文件至远端服务器
				read -e -p "請輸入要傳送的檔案路徑:" file_to_transfer
				if [ ! -f "$file_to_transfer" ]; then
					echo "錯誤: 文件不存在。"
					send_stats "傳送文件失敗: 文件不存在"
					continue
				fi

				kj_ssh_read_host_user_port "請輸入遠端伺服器IP:" "請輸入遠端伺服器使用者名稱 (預設root):" "請輸入登入連接埠 (預設22):" "root" "22"
				local remote_ip="$KJ_SSH_HOST"
				local remote_user="$KJ_SSH_USER"
				local remote_port="$KJ_SSH_PORT"

				kj_ssh_read_password "請輸入遠端伺服器密碼:"
				local remote_password="$KJ_SSH_PASSWORD"

				# 清除已知主機的舊條目
				ssh-keygen -f "/root/.ssh/known_hosts" -R "$remote_ip"
				sleep 2  # 等待时间

				# 使用scp傳輸文件
				scp -P "$remote_port" -o StrictHostKeyChecking=no "$file_to_transfer" "$remote_user@$remote_ip:/home/" <<EOF
$remote_password
EOF

				if [ $? -eq 0 ]; then
					echo "檔案已傳送至遠端伺服器home目錄。"
					send_stats "文件傳送成功"
				else
					echo "文件傳送失敗。"
					send_stats "文件傳送失敗"
				fi

				break_end
				;;



			0)  # 返回上一级选单
				send_stats "返回上一層選單選單"
				break
				;;
			*)  # 处理无效输入
				echo "無效的選擇，請重新輸入"
				send_stats "無效選擇"
				;;
		esac
	done
}






cluster_python3() {
	install python3 python3-paramiko
	cd ~/cluster/
	curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/python-for-vps/main/cluster/$py_task
	python3 ~/cluster/$py_task
}


run_commands_on_servers() {

	install sshpass

	local SERVERS_FILE="$HOME/cluster/servers.py"
	local SERVERS=$(grep -oP '{"name": "\K[^"]+|"hostname": "\K[^"]+|"port": \K[^,]+|"username": "\K[^"]+|"password": "\K[^"]+' "$SERVERS_FILE")

	# 將提取的資訊轉換為數組
	IFS=$'\n' read -r -d '' -a SERVER_ARRAY <<< "$SERVERS"

	# 遍歷伺服器並執行命令
	for ((i=0; i<${#SERVER_ARRAY[@]}; i+=5)); do
		local name=${SERVER_ARRAY[i]}
		local hostname=${SERVER_ARRAY[i+1]}
		local port=${SERVER_ARRAY[i+2]}
		local username=${SERVER_ARRAY[i+3]}
		local password=${SERVER_ARRAY[i+4]}
		echo
		echo -e "${gl_huang}連接到$name ($hostname)...${gl_bai}"
		# sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$username@$hostname" -p "$port" "$1"
		sshpass -p "$password" ssh -t -o StrictHostKeyChecking=no "$username@$hostname" -p "$port" "$1"
	done
	echo
	break_end

}


linux_cluster() {
mkdir cluster
if [ ! -f ~/cluster/servers.py ]; then
	cat > ~/cluster/servers.py << EOF
servers = [

]
EOF
fi

while true; do
	  clear
	  send_stats "集群控制中心"
	  echo "伺服器叢集控制"
	  cat ~/cluster/servers.py
	  echo
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  echo -e "${gl_kjlan}伺服器清單管理${gl_bai}"
	  echo -e "${gl_kjlan}1.  ${gl_bai}新增伺服器${gl_kjlan}2.  ${gl_bai}刪除伺服器${gl_kjlan}3.  ${gl_bai}編輯伺服器"
	  echo -e "${gl_kjlan}4.  ${gl_bai}備份叢集${gl_kjlan}5.  ${gl_bai}還原叢集"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  echo -e "${gl_kjlan}批次執行任務${gl_bai}"
	  echo -e "${gl_kjlan}11. ${gl_bai}安裝科技lion腳本${gl_kjlan}12. ${gl_bai}更新系統${gl_kjlan}13. ${gl_bai}清理系統"
	  echo -e "${gl_kjlan}14. ${gl_bai}安裝docker${gl_kjlan}15. ${gl_bai}安裝BBR3${gl_kjlan}16. ${gl_bai}設定1G虛擬內存"
	  echo -e "${gl_kjlan}17. ${gl_bai}設定時區到上海${gl_kjlan}18. ${gl_bai}開放所有連接埠${gl_kjlan}51. ${gl_bai}自訂指令"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  echo -e "${gl_kjlan}0.  ${gl_bai}返回主選單"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "請輸入你的選擇:" sub_choice

	  case $sub_choice in
		  1)
			  send_stats "新增叢集伺服器"
			  read -e -p "伺服器名稱:" server_name
			  read -e -p "伺服器IP:" server_ip
			  read -e -p "伺服器連接埠（22）:" server_port
			  local server_port=${server_port:-22}
			  read -e -p "伺服器使用者名稱（root）:" server_username
			  local server_username=${server_username:-root}
			  read -e -p "伺服器用戶密碼:" server_password

			  sed -i "/servers = \[/a\    {\"name\": \"$server_name\", \"hostname\": \"$server_ip\", \"port\": $server_port, \"username\": \"$server_username\", \"password\": \"$server_password\", \"remote_path\": \"/home/\"}," ~/cluster/servers.py

			  ;;
		  2)
			  send_stats "刪除叢集伺服器"
			  read -e -p "請輸入需要刪除的關鍵字:" rmserver
			  sed -i "/$rmserver/d" ~/cluster/servers.py
			  ;;
		  3)
			  send_stats "編輯叢集伺服器"
			  install nano
			  nano ~/cluster/servers.py
			  ;;

		  4)
			  clear
			  send_stats "備份叢集"
			  echo -e "請將${gl_huang}/root/cluster/servers.py${gl_bai}檔案下載，完成備份！"
			  break_end
			  ;;

		  5)
			  clear
			  send_stats "還原叢集"
			  echo "請上傳您的servers.py，按任意鍵開始上傳！"
			  echo -e "請上傳您的${gl_huang}servers.py${gl_bai}文件到${gl_huang}/root/cluster/${gl_bai}完成還原！"
			  break_end
			  ;;

		  11)
			  local py_task="install_kejilion.py"
			  cluster_python3
			  ;;
		  12)
			  run_commands_on_servers "k update"
			  ;;
		  13)
			  run_commands_on_servers "k clean"
			  ;;
		  14)
			  run_commands_on_servers "k docker install"
			  ;;
		  15)
			  run_commands_on_servers "k bbr3"
			  ;;
		  16)
			  run_commands_on_servers "k swap 1024"
			  ;;
		  17)
			  run_commands_on_servers "k time Asia/Shanghai"
			  ;;
		  18)
			  run_commands_on_servers "k iptables_open"
			  ;;

		  51)
			  send_stats "自訂執行命令"
			  read -e -p "請輸入批次執行的命令:" mingling
			  run_commands_on_servers "${mingling}"
			  ;;

		  *)
			  kejilion
			  ;;
	  esac
done

}




kejilion_Affiliates() {

clear
send_stats "廣告專欄"
echo "廣告專欄"
echo "------------------------"
echo "將為用戶提供更簡單優雅的推廣與購買體驗！"
echo ""
echo -e "伺服器優惠"
echo "------------------------"
echo -e "${gl_lan}萊卡雲 香港CN2 GIA 韓國雙ISP 美國CN2 GIA 優惠活動${gl_bai}"
echo -e "${gl_bai}網址: https://www.lcayun.com/aff/ZEXUQBIM${gl_bai}"
echo "------------------------"
echo -e "${gl_lan}RackNerd 10.99刀每年 美國 1核心 1G記憶體 20G硬碟 1T流量每月${gl_bai}"
echo -e "${gl_bai}網址: https://my.racknerd.com/aff.php?aff=5501&pid=879${gl_bai}"
echo "------------------------"
echo -e "${gl_zi}Hostinger 52.7刀每年 美國 1核心 4G記憶體 50G硬碟 4T流量每月${gl_bai}"
echo -e "${gl_bai}網址: https://cart.hostinger.com/pay/d83c51e9-0c28-47a6-8414-b8ab010ef94f?_ga=GA1.3.942352702.1711283207${gl_bai}"
echo "------------------------"
echo -e "${gl_huang}搬運工 49刀每季 美國CN2GIA 日本軟銀 2核心 1G內存 20G硬碟 1T流量每月${gl_bai}"
echo -e "${gl_bai}網址: https://bandwagonhost.com/aff.php?aff=69004&pid=87${gl_bai}"
echo "------------------------"
echo -e "${gl_lan}DMIT 28刀每季 美國CN2GIA 1核心 2G記憶體 20G硬碟 800G流量每月${gl_bai}"
echo -e "${gl_bai}網址: https://www.dmit.io/aff.php?aff=4966&pid=100${gl_bai}"
echo "------------------------"
echo -e "${gl_zi}V.PS 6.9刀每月 東京軟銀 2核心 1G內存 20G硬碟 1T流量每月${gl_bai}"
echo -e "${gl_bai}網址: https://vps.hosting/cart/tokyo-cloud-kvm-vps/?id=148&?affid=1355&?affid=1355${gl_bai}"
echo "------------------------"
echo -e "${gl_kjlan}VPS更多熱門優惠${gl_bai}"
echo -e "${gl_bai}網址: https://kejilion.pro/topvps/${gl_bai}"
echo "------------------------"
echo ""
echo -e "網域優惠"
echo "------------------------"
echo -e "${gl_lan}GNAME 8.8刀首年COM域名 6.68刀首年CC域名${gl_bai}"
echo -e "${gl_bai}網址: https://www.gname.com/register?tt=86836&ttcode=KEJILION86836&ttbj=sh${gl_bai}"
echo "------------------------"
echo ""
echo -e "科技lion週邊"
echo "------------------------"
echo -e "${gl_kjlan}B站:${gl_bai}https://b23.tv/2mqnQyh              ${gl_kjlan}油管:${gl_bai}https://www.youtube.com/@kejilion${gl_bai}"
echo -e "${gl_kjlan}官網:${gl_bai}https://kejilion.pro/              ${gl_kjlan}導航:${gl_bai}https://dh.kejilion.pro/${gl_bai}"
echo -e "${gl_kjlan}部落格:${gl_bai}https://blog.kejilion.pro/         ${gl_kjlan}軟體中心:${gl_bai}https://app.kejilion.pro/${gl_bai}"
echo "------------------------"
echo -e "${gl_kjlan}腳本官網:${gl_bai}https://kejilion.sh            ${gl_kjlan}GitHub地址:${gl_bai}${gh_https_url}github.com/kejilion/sh${gl_bai}"
echo "------------------------"
echo ""
}




games_server_tools() {

	while true; do
	  clear
	  echo -e "遊戲開服腳本合集"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}1. ${gl_bai}幻獸帕魯開服腳本"
	  echo -e "${gl_kjlan}2. ${gl_bai}我的世界開服腳本"
	  echo -e "${gl_kjlan}------------------------"
	  echo -e "${gl_kjlan}0. ${gl_bai}返回主選單"
	  echo -e "${gl_kjlan}------------------------${gl_bai}"
	  read -e -p "請輸入你的選擇:" sub_choice

	  case $sub_choice in

		  1) send_stats "幻獸帕魯開服腳本" ; cd ~
			 curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/palworld.sh ; chmod +x palworld.sh ; ./palworld.sh
			 exit
			 ;;
		  2) send_stats "我的世界開服腳本" ; cd ~
			 curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/mc.sh ; chmod +x mc.sh ; ./mc.sh
			 exit
			 ;;

		  0)
			kejilion
			;;

		  *)
			echo "無效的輸入!"
			;;
	  esac
	  break_end

	done


}





















kejilion_update() {

send_stats "腳本更新"
cd ~
while true; do
	clear
	echo "更新日誌"
	echo "------------------------"
	echo "全部日誌:${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/kejilion_sh_log.txt"
	echo "------------------------"

	curl -s ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/kejilion_sh_log.txt | tail -n 30
	local sh_v_new=$(curl -s ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/kejilion.sh | grep -o 'sh_v="[0-9.]*"' | cut -d '"' -f 2)

	if [ "$sh_v" = "$sh_v_new" ]; then
		echo -e "${gl_lv}你已經是最新版本！${gl_huang}v$sh_v${gl_bai}"
		send_stats "腳本已經最新了，無需更新"
	else
		echo "發現新版本！"
		echo -e "目前版本 v$sh_v最新版本${gl_huang}v$sh_v_new${gl_bai}"
	fi


	local cron_job="kejilion.sh"
	local existing_cron=$(crontab -l 2>/dev/null | grep -F "$cron_job")

	if [ -n "$existing_cron" ]; then
		echo "------------------------"
		echo -e "${gl_lv}自動更新已開啟，每天凌晨2點腳本會自動更新！${gl_bai}"
	fi

	echo "------------------------"
	echo "1. 現在更新 2. 開啟自動更新 3. 關閉自動更新"
	echo "------------------------"
	echo "0. 返回主選單"
	echo "------------------------"
	read -e -p "請輸入你的選擇:" choice
	case "$choice" in
		1)
			clear
			local country=$(curl -s ipinfo.io/country)
			if [ "$country" = "CN" ]; then
				curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/cn/kejilion.sh && chmod +x kejilion.sh
			else
				curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/kejilion.sh && chmod +x kejilion.sh
			fi
			canshu_v6
			CheckFirstRun_true
			yinsiyuanquan2
			cp -f ~/kejilion.sh /usr/local/bin/k > /dev/null 2>&1
			echo -e "${gl_lv}腳本已更新至最新版本！${gl_huang}v$sh_v_new${gl_bai}"
			send_stats "腳本已經最新$sh_v_new"
			break_end
			~/kejilion.sh
			exit
			;;
		2)
			clear
			local country=$(curl -s ipinfo.io/country)
			local ipv6_address=$(curl -s --max-time 1 ipv6.ip.sb)
			if [ "$country" = "CN" ]; then
				SH_Update_task="curl -sS -O https://gh.kejilion.pro/raw.githubusercontent.com/kejilion/sh/main/kejilion.sh && chmod +x kejilion.sh && sed -i 's/canshu=\"default\"/canshu=\"CN\"/g' ./kejilion.sh"
			elif [ -n "$ipv6_address" ]; then
				SH_Update_task="curl -sS -O https://gh.kejilion.pro/raw.githubusercontent.com/kejilion/sh/main/kejilion.sh && chmod +x kejilion.sh && sed -i 's/canshu=\"default\"/canshu=\"V6\"/g' ./kejilion.sh"
			else
				SH_Update_task="curl -sS -O https://raw.githubusercontent.com/kejilion/sh/main/kejilion.sh && chmod +x kejilion.sh"
			fi
			check_crontab_installed
			(crontab -l | grep -v "kejilion.sh") | crontab -
			# (crontab -l 2>/dev/null; echo "0 2 * * * bash -c \"$SH_Update_task\"") | crontab -
			(crontab -l 2>/dev/null; echo "$(shuf -i 0-59 -n 1) 2 * * * bash -c \"$SH_Update_task\"") | crontab -
			echo -e "${gl_lv}自動更新已開啟，每天凌晨2點腳本會自動更新！${gl_bai}"
			send_stats "開啟腳本自動更新"
			break_end
			;;
		3)
			clear
			(crontab -l | grep -v "kejilion.sh") | crontab -
			echo -e "${gl_lv}自動更新已關閉${gl_bai}"
			send_stats "關閉腳本自動更新"
			break_end
			;;
		*)
			kejilion_sh
			;;
	esac
done

}





kejilion_sh() {
while true; do
clear
echo -e "${gl_kjlan}"
echo "╦╔═╔═╗ ╦╦╦  ╦╔═╗╔╗╔ ╔═╗╦ ╦"
echo "╠╩╗║╣  ║║║  ║║ ║║║║ ╚═╗╠═╣"
echo "╩ ╩╚═╝╚╝╩╩═╝╩╚═╝╝╚╝o╚═╝╩ ╩"
echo -e "科技lion腳本工具箱 v$sh_v"
echo -e "命令列輸入${gl_huang}k${gl_kjlan}可快速啟動腳本${gl_bai}"
echo -e "${gl_kjlan}------------------------${gl_bai}"
echo -e "${gl_kjlan}1.   ${gl_bai}系統資訊查詢"
echo -e "${gl_kjlan}2.   ${gl_bai}系統更新"
echo -e "${gl_kjlan}3.   ${gl_bai}系統清理"
echo -e "${gl_kjlan}4.   ${gl_bai}基礎工具"
echo -e "${gl_kjlan}5.   ${gl_bai}BBR管理"
echo -e "${gl_kjlan}6.   ${gl_bai}Docker管理"
echo -e "${gl_kjlan}7.   ${gl_bai}WARP管理"
echo -e "${gl_kjlan}8.   ${gl_bai}測試腳本合集"
echo -e "${gl_kjlan}9.   ${gl_bai}甲骨文雲腳本合集"
echo -e "${gl_huang}10.  ${gl_bai}LDNMP建站"
echo -e "${gl_kjlan}11.  ${gl_bai}應用市場"
echo -e "${gl_kjlan}12.  ${gl_bai}後台工作區"
echo -e "${gl_kjlan}13.  ${gl_bai}系統工具"
echo -e "${gl_kjlan}14.  ${gl_bai}伺服器叢集控制"
echo -e "${gl_kjlan}15.  ${gl_bai}廣告專欄"
echo -e "${gl_kjlan}16.  ${gl_bai}遊戲開服腳本合集"
echo -e "${gl_kjlan}------------------------${gl_bai}"
echo -e "${gl_kjlan}00.  ${gl_bai}腳本更新"
echo -e "${gl_kjlan}------------------------${gl_bai}"
echo -e "${gl_kjlan}0.   ${gl_bai}退出腳本"
echo -e "${gl_kjlan}------------------------${gl_bai}"
read -e -p "請輸入你的選擇:" choice

case $choice in
  1) linux_info ;;
  2) clear ; send_stats "系統更新" ; linux_update ;;
  3) clear ; send_stats "系統清理" ; linux_clean ;;
  4) linux_tools ;;
  5) linux_bbr ;;
  6) linux_docker ;;
  7) clear ; send_stats "warp管理" ; install wget
	wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh ; bash menu.sh [option] [lisence/url/token]
	;;
  8) linux_test ;;
  9) linux_Oracle ;;
  10) linux_ldnmp ;;
  11) linux_panel ;;
  12) linux_work ;;
  13) linux_Settings ;;
  14) linux_cluster ;;
  15) kejilion_Affiliates ;;
  16) games_server_tools ;;
  00) kejilion_update ;;
  0) clear ; exit ;;
  *) echo "無效的輸入!" ;;
esac
	break_end
done
}


k_info() {
send_stats "k指令參考用例"
echo "-------------------"
echo "影片介紹: https://www.bilibili.com/video/BV1ib421E7it?t=0.1"
echo "以下是k命令參考用例："
echo "啟動腳本 k"
echo "安裝軟體包 k install nano wget | k add nano wget | k 安裝 nano wget"
echo "卸載軟體包 k remove nano wget | k del nano wget | k uninstall nano wget | k 卸載 nano wget"
echo "更新系統 k update | k 更新"
echo "清理系統垃圾 k clean | k 清理"
echo "重裝系統面板 k dd | k 重裝"
echo "bbr3控制面板 k bbr3 | k bbrv3"
echo "核心調優面板 k nhyh | k 核心最佳化"
echo "設定虛擬記憶體 k swap 2048"
echo "設定虛擬時區 k time Asia/Shanghai | k 時區 Asia/Shanghai"
echo "系統回收站 k trash | k hsz | k 回收站"
echo "系統備份功能 k backup | k bf | k 備份"
echo "ssh遠端連線工具 k ssh | k 遠端連線"
echo "rsync遠端同步工具 k rsync | k 遠端同步"
echo "硬碟管理工具 k disk | k 硬碟管理"
echo "內網穿透（服務端） k frps"
echo "內網穿透（客戶端） k frpc"
echo "軟體啟動 k start sshd | k 啟動 sshd"
echo "軟體停止 k stop sshd | k 停止 sshd"
echo "軟體重啟 k restart sshd | k 重啟 sshd"
echo "軟體狀態檢視 k status sshd | k 狀態 sshd"
echo "軟體開機啟動 k enable docker | k autostart docke | k 開機啟動 docker"
echo "網域憑證申請 k ssl"
echo "網域名稱憑證到期查詢 k ssl ps"
echo "docker管理平面 k docker"
echo "docker環境安裝 k docker install |k docker 安裝"
echo "docker容器管理 k docker ps |k docker 容器"
echo "docker映像管理 k docker img |k docker 映像"
echo "LDNMP站台管理 k web"
echo "LDNMP快取清理 k web cache"
echo "安裝WordPress k wp |k wordpress |k wp xxx.com"
echo "安裝反向代理 k fd |k rp |k 反代 |k fd xxx.com"
echo "安裝負載平衡 k loadbalance |k 負載平衡"
echo "安裝L4負載平衡 k stream |k L4負載平衡"
echo "防火牆面板 k fhq |k 防火牆"
echo "開放埠 k dkdk 8080 |k 開啟連接埠 8080"
echo "關閉連接埠 k gbdk 7800 |k 關閉連接埠 7800"
echo "放行IP k fxip 127.0.0.0/8 |k 放行IP 127.0.0.0/8"
echo "阻止IP k zzip 177.5.25.36 |k 阻止IP 177.5.25.36"
echo "命令收藏 k fav | k 指令收藏夾"
echo "應用市場管理 k app"
echo "應用編號快捷管理 k app 26 | k app 1panel | k app npm"
echo "fail2ban管理 k fail2ban | k f2b"
echo "顯示系統資訊 k info"
echo "ROOT金鑰管理 k sshkey"
echo "SSH公鑰導入(URL) k sshkey <url>"
echo "SSH公鑰導入(GitHub) k sshkey github <user>"

}



if [ "$#" -eq 0 ]; then
	# 如果沒有參數，運行互動式邏輯
	kejilion_sh
else
	# 如果有參數，執行對應函數
	case $1 in
		install|add|安装)
			shift
			send_stats "安裝軟體"
			install "$@"
			;;
		remove|del|uninstall|卸载)
			shift
			send_stats "解除安裝軟體"
			remove "$@"
			;;
		update|更新)
			linux_update
			;;
		clean|清理)
			linux_clean
			;;
		dd|重装)
			dd_xitong
			;;
		bbr3|bbrv3)
			bbrv3
			;;
		nhyh|内核优化)
			Kernel_optimize
			;;
		trash|hsz|回收站)
			linux_trash
			;;
		backup|bf|备份)
			linux_backup
			;;
		ssh|远程连接)
			ssh_manager
			;;

		rsync|远程同步)
			rsync_manager
			;;

		rsync_run)
			shift
			send_stats "定時rsync同步"
			run_task "$@"
			;;

		disk|硬盘管理)
			disk_manager
			;;

		wp|wordpress)
			shift
			ldnmp_wp "$@"

			;;
		fd|rp|反代)
			shift
			ldnmp_Proxy "$@"
	  		find_container_by_host_port "$port"
	  		if [ -z "$docker_name" ]; then
	  		  close_port "$port"
			  echo "已阻止IP+連接埠存取該服務"
	  		else
			  ip_address
			  close_port "$port"
	  		  block_container_port "$docker_name" "$ipv4_address"
	  		fi
			;;

		loadbalance|负载均衡)
			ldnmp_Proxy_backend
			;;


		stream|L4负载均衡)
			ldnmp_Proxy_backend_stream
			;;

		swap)
			shift
			send_stats "快速設定虛擬記憶體"
			add_swap "$@"
			;;

		time|时区)
			shift
			send_stats "快速設定時區"
			set_timedate "$@"
			;;


		iptables_open)
			iptables_open
			;;

		frps)
			frps_panel
			;;

		frpc)
			frpc_panel
			;;


		打开端口|dkdk)
			shift
			open_port "$@"
			;;

		关闭端口|gbdk)
			shift
			close_port "$@"
			;;

		放行IP|fxip)
			shift
			allow_ip "$@"
			;;

		阻止IP|zzip)
			shift
			block_ip "$@"
			;;

		防火墙|fhq)
			iptables_panel
			;;

		命令收藏夹|fav)
			linux_fav
			;;

		status|状态)
			shift
			send_stats "軟體狀態檢視"
			status "$@"
			;;
		start|启动)
			shift
			send_stats "軟體啟動"
			start "$@"
			;;
		stop|停止)
			shift
			send_stats "軟體暫停"
			stop "$@"
			;;
		restart|重启)
			shift
			send_stats "軟體重啟"
			restart "$@"
			;;

		enable|autostart|开机启动)
			shift
			send_stats "軟體開機自啟"
			enable "$@"
			;;

		ssl)
			shift
			if [ "$1" = "ps" ]; then
				send_stats "查看證書狀態"
				ssl_ps
			elif [ -z "$1" ]; then
				add_ssl
				send_stats "快速申請證書"
			elif [ -n "$1" ]; then
				add_ssl "$1"
				send_stats "快速申請證書"
			else
				k_info
			fi
			;;

		docker)
			shift
			case $1 in
				install|安装)
					send_stats "快速安裝docker"
					install_docker
					;;
				ps|容器)
					send_stats "快速容器管理"
					docker_ps
					;;
				img|镜像)
					send_stats "快速鏡像管理"
					docker_image
					;;
				*)
					linux_docker
					;;
			esac
			;;

		web)
		   shift
			if [ "$1" = "cache" ]; then
				web_cache
			elif [ "$1" = "sec" ]; then
				web_security
			elif [ "$1" = "opt" ]; then
				web_optimization
			elif [ -z "$1" ]; then
				ldnmp_web_status
			else
				k_info
			fi
			;;


		app)
			shift
			send_stats "應用$@"
			linux_panel "$@"
			;;

		claw|oc|OpenClaw)
			moltbot_menu
			;;

		info)
			linux_info
			;;

		fail2ban|f2b)
			fail2ban_panel
			;;


		sshkey)

			shift
			case "$1" in
				"" )
					# sshkey → 互動選單
					send_stats "SSHKey 互動選單"
					sshkey_panel
					;;
				github )
					shift
					send_stats "從 GitHub 導入 SSH 公鑰"
					fetch_github_ssh_keys "$1"
					;;
				http://*|https://* )
					send_stats "從 URL 匯入 SSH 公鑰"
					fetch_remote_ssh_keys "$1"
					;;
				ssh-rsa*|ssh-ed25519*|ssh-ecdsa* )
					send_stats "公鑰直接導入"
					import_sshkey "$1"
					;;
				* )
					echo "錯誤：未知參數 '$1'"
					echo "用法："
					echo "k sshkey 進入互動選單"
					echo "k sshkey \"<pubkey>\" 直接導入 SSH 公鑰"
					echo "k sshkey <url> 從 URL 匯入 SSH 公鑰"
					echo "k sshkey github <user> 從 GitHub 匯入 SSH 公鑰"
					;;
			esac

			;;
		*)
			k_info
			;;
	esac
fi
