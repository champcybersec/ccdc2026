## TL;DR of Linux Scripts

### Antivirus
- `clamav_debian.sh` - Install ClamAV on Debian
- `clamav_rpm.sh` - Install ClamAV on RPM-based systems (enables EPEL if needed)

### SSH & Authentication
- `check_user_ssh_keys.sh` — lists users whose `.ssh` folders contain key material.

### Systemd & Services
- `compare_service_boot.sh` — compares expected vs actual boot targets from `systemctl list-unit-files`.
- `list_user_services.sh` — lists user/getty services from systemd with toggles for extra filters.

### User Management
- `lock_user.sh` — locks and expires any home-directory users not listed in the safe allowlist.
- `remove_user.sh` — interactive helper for deleting non-protected user accounts.

### Monitoring & Forensics
- `list_edited_files.sh` — finds recently modified files with optional path filters and time ranges.
- `lsof_checks.sh` — backgrounds a recurring `lsof -i` capture into `~/lsof_check.txt`.
- `w_check.sh` — installs the bundled cron specification to capture `w -i` snapshots.
- `w_check_cron.sh` — cron schedule that appends `w -i` output to `~/w_checks.txt` every minute.

### Firewall
- `ufw_setup_debian.sh` — installs and enables UFW with deny-in/allow-out defaults on Debian.
- `ufw_setup_rpm.sh` — installs and enables UFW on RPM systems (enables EPEL) with deny-in/allow-out defaults.

### Cron Utilities
- `Daniel_Rosenfield/list_all_cronjobs.sh` — enumerates cronjobs for all users plus system cron folders.
- `Daniel_Rosenfield/list_and_del_all_cronjobs.sh` — lists cronjobs and optionally deletes selected entries.
