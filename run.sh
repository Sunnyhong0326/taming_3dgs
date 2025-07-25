#!/bin/bash -ex

show_help() {
  echo -e "\nUsage: $0 [OPTIONS] <commands>\n"
  echo "Options:"
  echo "  --download-src    The source file or folder to download"
  echo "  --download-dest   The destination file or folder to download to"
  echo "  --upload-src      The source file or folder to upload"
  echo "  --upload-dest     The destination file or folder to upload to"
  echo -e "\nThis script downloads the necessary files, executes the specified commands, and then uploads the output files.\n"
}

resolve_path() {
  local path="$1"
  if [[ "$path" != "omniverse://"* && ! "$path" == /* ]]; then
    path="$(pwd)/$path"
  fi
  echo "$path"
}

# Ref: https://stackoverflow.com/a/14203146
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    --download-src)
      DOWNLOAD_SRC=$(resolve_path "$2")
      shift # past argument
      shift # past value
      ;;
    --download-dest)
      DOWNLOAD_DEST=$(resolve_path "$2")
      shift # past argument
      shift # past value
      ;;
    --upload-src)
      UPLOAD_SRC=$(resolve_path "$2")
      shift # past argument
      shift # past value
      ;;
    --upload-dest)
      UPLOAD_DEST=$(resolve_path "$2")
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [ "$#" -lt 1 ]; then
  echo "Error: Incorrect number of arguments. Expected more than 1, got $#."
  show_help
  exit 1
fi

echo "Setting ulimit to hard limit for open files and stack size..."
echo "Current ulimit:"
ulimit -a
echo "Current hard ulimit:"
ulimit -Ha
ulimit -n $(ulimit -Hn)
ulimit -s $(ulimit -Hs)
echo "Current ulimit:"
ulimit -a

echo "Proactively set Google DNS to prevent potential internet connectivity issues..."
# Idempotently add Google DNS to /etc/resolv.conf
RESOLV_CONF="/etc/resolv.conf"
for ns in "8.8.8.8" "8.8.4.4"; do
  if ! grep -q "^nameserver $ns$" "$RESOLV_CONF"; then
    echo "DNS $ns not found in $RESOLV_CONF, adding..."
    echo "nameserver $ns" >> "$RESOLV_CONF"
  fi
done

if [ -n "$DOWNLOAD_SRC" ] || [ -n "$DOWNLOAD_DEST" ]; then
  if [ -e "$DOWNLOAD_DEST" ]; then
    if [ -d "$DOWNLOAD_DEST" ]; then
      echo "Directory exists at '$DOWNLOAD_DEST', deleting contents..."
      rm -rf "$DOWNLOAD_DEST"/{*,.*} || true
    else
      echo "File exists at '$DOWNLOAD_DEST', deleting..."
      rm -f "$DOWNLOAD_DEST"
    fi
  fi
  echo "Copying files from '$DOWNLOAD_SRC' to '$DOWNLOAD_DEST'..."
  ( cd /omnicli && ./omnicli copy "$DOWNLOAD_SRC" "$DOWNLOAD_DEST" )
fi

echo "Will run commands: '$@'"
while [[ $# -gt 0 ]]; do
  echo "Running command: '$1'"
  $1
  shift
done

if [ -n "$UPLOAD_SRC" ] || [ -n "$UPLOAD_DEST" ]; then
  echo "Copying files from '$UPLOAD_SRC' to '$UPLOAD_DEST'..."
  ( cd /omnicli && ./omnicli copy "$UPLOAD_SRC" "$UPLOAD_DEST" )
fi