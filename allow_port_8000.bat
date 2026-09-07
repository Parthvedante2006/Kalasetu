@echo off
echo Adding Windows Firewall rule for Kalasetu backend (port 8000)...
netsh advfirewall firewall add rule name="Kalasetu Backend" dir=in action=allow protocol=TCP localport=8000
echo.
echo Done! You can close this window.
pause
