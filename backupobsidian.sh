#!/bin/bash
archive_path="obsidian_vault_$(date +%Y%m%d_%H%M%S).zip"
zip -r "$archive_path" "RemoteVault"
rclone copy "$archive_path" "Dropbox:obsidian_backup"
rm "$archive_path"