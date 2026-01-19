sudo apt update
sudo apt install ufw -y

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw --force enable

sudo ufw status verbose

echo "Adjust allowed services/ports with: sudo ufw allow <service|port>"
