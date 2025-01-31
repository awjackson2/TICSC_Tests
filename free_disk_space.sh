#!/usr/bin/env bash

echo "=============================================================================="
echo "Freeing up disk space on CI system"
echo "=============================================================================="

# Capture and Display Environment Variables Before Cleanup
echo "=============================================================================="
echo "Environment Variables BEFORE Cleanup:"
echo "=============================================================================="
env | sort | tee /tmp/env_before_cleanup.txt
echo "Stored environment variables before cleanup in /tmp/env_before_cleanup.txt"
echo "------------------------------------------------------------------------------"

# List and Log 100 Largest Packages Before Cleanup
echo "Listing 100 largest installed packages:"
dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 100 | tee /tmp/largest_packages_before.txt
df -h | tee /tmp/disk_usage_before.txt
echo "------------------------------------------------------------------------------"

# Removing Large Packages
echo "Removing large packages..."
sudo apt-get remove -y '^ghc-8.*'
sudo apt-get remove -y '^dotnet-.*'
sudo apt-get remove -y '^llvm-.*'
sudo apt-get remove -y 'php.*'
sudo apt-get remove -y azure-cli google-cloud-sdk hhvm google-chrome-stable firefox powershell mono-devel
sudo apt-get autoremove -y
sudo apt-get clean
echo "------------------------------------------------------------------------------"

# Log Changes to Disk Usage
df -h | tee /tmp/disk_usage_after.txt
echo "Logged disk usage changes to /tmp/disk_usage_after.txt"
echo "------------------------------------------------------------------------------"

# Removing Large Directories
echo "Removing large directories..."
rm -rf /usr/share/dotnet/
rm -rf /opt/hostedtoolcache
echo "------------------------------------------------------------------------------"

# Capture and Display Environment Variables After Cleanup
echo "=============================================================================="
echo "Environment Variables AFTER Cleanup:"
echo "=============================================================================="
env | sort | tee /tmp/env_after_cleanup.txt
echo "Stored environment variables after cleanup in /tmp/env_after_cleanup.txt"
echo "------------------------------------------------------------------------------"

# Compare and Highlight Differences in Environment Variables
echo "=============================================================================="
echo "Comparing Environment Variables (BEFORE vs. AFTER Cleanup)"
echo "=============================================================================="
diff /tmp/env_before_cleanup.txt /tmp/env_after_cleanup.txt || echo "No differences detected."

echo "=============================================================================="
echo "Cleanup complete! Review logs:"
echo "  - Environment BEFORE: /tmp/env_before_cleanup.txt"
echo "  - Environment AFTER:  /tmp/env_after_cleanup.txt"
echo "  - Disk Usage BEFORE:  /tmp/disk_usage_before.txt"
echo "  - Disk Usage AFTER:   /tmp/disk_usage_after.txt"
echo "  - Largest Packages BEFORE: /tmp/largest_packages_before.txt"
echo "=============================================================================="
