# Script used to configure restricted firewall rules for a Windows Box | Credit to Jregan for sharing
net stop bthserv
# net stop dns
net stop nettcpportsharing
net stop rasman
net stop remoteregistry


net start wuauserv
set-service wuauserv -StartupType Automatic
net start EventLog
set-service EventLog -StartupType Automatic
net start mpssvc
set-service mpssvc -StartupType Automatic
net start WdNisSvc
set-service WdNisSvc -StartupType Automatic
net start WinDefend
set-service WinDefend -StartupType Automatic

netsh advfirewall export "C:\Program Files\Common Files\default.wfw"
Remove-NetFirewallRule -All

# Baseline stuff, use on all machines
New-NetFirewallRule -DisplayName "Internal traffic" -Direction Inbound -RemoteAddress "172.20.240.0" -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Internal traffic" -Direction Inbound -RemoteAddress "172.20.241.0" -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Internal traffic" -Direction Inbound -RemoteAddress "172.20.242.0" -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "HTTP(S) external outbound" -Direction Outbound -RemotePort 80,443 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "DNS Client" -Program "C:\Windows\system32\svchost.exe" -Direction Outbound -RemotePort 53 -Protocol UDP -Action Allow
New-NetFirewallRule -DisplayName "Internal traffic out" -Direction Outbound -RemoteAddress "172.20.240.0" -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Internal traffic out" -Direction Outbound -RemoteAddress "172.20.241.0" -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Internal traffic out" -Direction Outbound -RemoteAddress "172.20.242.0" -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "LDAP-In-TCP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 389 -RemoteAddress "172.20.240.0"
New-NetFirewallRule -DisplayName "LDAP-In-UDP" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 389 -RemoteAddress "172.20.240.0"
New-NetFirewallRule -DisplayName "LDAPS-In-TCP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 636 -RemoteAddress "172.20.240.0"
New-NetFirewallRule -DisplayName "LDAP-GC-In-TCP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3268 -RemoteAddress "172.20.240.0"
New-NetFirewallRule -DisplayName "LDAP-GC-SSL-In-TCP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3269 -RemoteAddress "172.20.240.0"

# Critical services, only uncomment the ones you need
# New-NetFirewallRule -DisplayName "HTTP server" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
# New-NetFirewallRule -DisplayName "HTTPS server" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow
# New-NetFirewallRule -DisplayName "FTP server IN" -Program "C:\Windows\system32\svchost.exe" -Direction Inbound -LocalPort 20,21,1024-65535 -Protocol TCP -Action Allow
# New-NetFirewallRule -DisplayName "FTP server OUT" -Program "C:\Windows\system32\svchost.exe" -Direction Outbound -LocalPort 20 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "DNS server" -Program "C:\Windows\system32\dns.exe" -Direction Inbound -LocalPort 53 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "DNS server" -Program "C:\Windows\system32\dns.exe" -Direction Inbound -LocalPort 53 -Protocol UDP -Action Allow
New-NetFirewallRule -DisplayName "RDP server" -Program "C:\Windows\system32\svchost.exe" -Direction Inbound -LocalPort 3389 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "RDP server" -Program "C:\Windows\system32\svchost.exe" -Direction Inbound -LocalPort 3389 -Protocol UDP -Action Allow
# New-NetFirewallRule -DisplayName "SMB server" -Direction Inbound -LocalPort 445 -Protocol TCP -Action Allow
# New-NetFirewallRule -DisplayName "SSH server" -Direction Inbound -LocalPort 22 -Protocol TCP -Action Allow
# New-NetFirewallRule -DisplayName "SMTP server" -Direction Inbound -LocalPort 23,110,143,465,587,993,995,2525 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "DHCP server" -Direction Inbound -LocalPort 67,68 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "DHCP server" -Direction Inbound -LocalPort 67,68 -Protocol UDP -Action Allow
New-NetFirewallRule -DisplayName "DHCP server" -Direction Outbound -LocalPort 67,68 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "DHCP server" -Direction Outbound -LocalPort 67,68 -Protocol UDP -Action Allow
# New-NetFirewallRule -DisplayName "POP3 scoring" -Direction Inbound -LocalPort 110 -Protocol TCP -Action Allow
# New-NetFirewallRule -DisplayName "POP3 scoring" -Direction Outbound -LocalPort 110 -Protocol TCP -Action Allow
# New-NetFirewallRule -DisplayName "POP3 scoring UDP" -Direction Inbound -LocalPort 110 -Protocol UDP -Action Allow
# New-NetFirewallRule -DisplayName "POP3 scoring UDP" -Direction Outbound -LocalPort 110 -Protocol UDP -Action Allow
