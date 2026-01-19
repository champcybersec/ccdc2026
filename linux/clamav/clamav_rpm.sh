if command -v dnf >/dev/null 2>&1; then
  PKG_MGR="dnf"
elif command -v yum >/dev/null 2>&1; then
  PKG_MGR="yum"
else
  echo "Neither dnf nor yum is available on this system."
  exit 1
fi

if [ "$PKG_MGR" = "dnf" ]; then
  sudo dnf makecache --refresh
  if ! sudo dnf repolist --enabled 2>/dev/null | grep -qi epel; then
    echo "EPEL repository not detected; attempting to enable..."
    if ! sudo dnf install epel-release -y; then
      sudo dnf install dnf-plugins-core -y
      sudo dnf config-manager --set-enabled epel || echo "Enable EPEL manually if packages are missing."
    fi
    echo
  fi
else
  sudo yum makecache
  if ! sudo yum repolist enabled 2>/dev/null | grep -qi epel; then
    echo "EPEL repository not detected; attempting to enable..."
    if ! sudo yum install epel-release -y; then
      if ! command -v yum-config-manager >/dev/null 2>&1; then
        sudo yum install yum-utils -y
      fi
      sudo yum-config-manager --enable epel || echo "Enable EPEL manually if packages are missing."
    fi
    echo
  fi
fi

sudo "$PKG_MGR" install clamav clamav-update -y

sudo freshclam
sudo systemctl enable --now clamav-freshclam

echo "to scan, run sudo clamscan -i -r /"
echo "append -d <path> for extra rules"

echo

echo "multi-scan with clamdscan --multiscan --fdpass -i /home/$USER"
echo "-i only shows infected paths"
