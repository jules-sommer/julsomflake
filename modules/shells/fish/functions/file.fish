if test (count $argv) -eq 0
  echo "Usage: file <path>"
  return 1
end

set -l file_path $argv[1]
set -l dir_path (dirname "$file_path")

# Check if we have write permissions in the parent directory
if test -w "$dir_path" || mkdir -p -- "$dir_path" 2>/dev/null
  touch -- "$file_path" 2>/dev/null || begin
      echo "Error: Failed to create file (permission denied?). Trying with sudo..."
      sudo touch -- "$file_path" || return 1
  end
else
  echo "Creating directories and file with sudo..."
  sudo mkdir -p -- "$dir_path" || return 1
  sudo touch -- "$file_path" || return 1
end
