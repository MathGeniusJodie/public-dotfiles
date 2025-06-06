#!/bin/bash
archive_path="obsidian_vault_$(date +%Y%m%d_%H%M%S).zip"
cd RemoteVault || exit 1
git add --all && git commit -m "backup $(date +%Y%m%d_%H%M%S)"
cd ..
#zip -r "$archive_path" "RemoteVault"
tar -cf "$archive_path" "RemoteVault"
rclone copy "$archive_path" "Proton:obsidian_backup"
rm "$archive_path"