#Start-Process "wusa.exe" -ArgumentList "/uninstall /kb:5002623 /quiet /norestart" -Wait
Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*KB5002623*" } | ForEach-Object { $_.Uninstall() }
