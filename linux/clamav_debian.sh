sudo apt update && sudo apt install clamav clamav-daemon -y

sudo freshclam
sudo systemctl enable --now clamav-freshclam

echo "to scan, run sudo clamscan -i -r /"
echo "append -d <path> for extra rules"

echo

echo "multi-scan with clamdscan --multiscan --fdpass -i /home/$USER"
echo "-i only shows infected paths"