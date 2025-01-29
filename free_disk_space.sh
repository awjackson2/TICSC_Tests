#!/usr/bin/env bash

echo "=============================================================================="
echo "Freeing up disk space on CI system"
echo "=============================================================================="

# Capture Environment Variables Before Cleanup
env > /tmp/env_before_cleanup.txt
echo "Stored environment variables before cleanup in /tmp/env_before_cleanup.txt"

# List and Log 100 Largest Packages Before Cleanup
dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 100 > /tmp/largest_packages_before.txt
df -h > /tmp/disk_usage_before.txt

echo "Removing large packages"
sudo apt-get remove -y '^ghc-8.*'
sudo apt-get remove -y '^dotnet-.*'
sudo apt-get remove -y '^llvm-.*'
sudo apt-get remove -y 'php.*'
sudo apt-get remove -y azure-cli google-cloud-sdk hhvm google-chrome-stable firefox powershell mono-devel
sudo apt-get autoremove -y
sudo apt-get clean

# Log Changes to Disk Usage
df -h > /tmp/disk_usage_after.txt
echo "Logged disk usage changes to /tmp/disk_usage_after.txt"

echo "Removing large directories"
rm -rf /usr/share/dotnet/
rm -rf /opt/hostedtoolcache

# Capture Environment Variables After Cleanup
env > /tmp/env_after_cleanup.txt
echo "Stored environment variables after cleanup in /tmp/env_after_cleanup.txt"

echo "=============================================================================="
echo "Cleanup complete! Review /tmp/env_before_cleanup.txt and /tmp/env_after_cleanup.txt"
echo "=============================================================================="
