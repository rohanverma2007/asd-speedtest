#!/bin/bash

# Rohan was here

SCRIPT_VERSION="v1.0.0"
GITHUB_REPO="rohanverma2007/asd-speedtest"
SCRIPT_NAME="speedtest.sh"

spinner() {
  local pid=$!
  local msg=$1
  local spinstr='|/-\\'
  local delay=0.1
  local i=0

  tput civis 2>/dev/null  # Hide cursor
  while kill -0 $pid 2>/dev/null; do
    printf "\r[%c] %s" "${spinstr:$i:1}" "$msg"
    i=$(( (i + 1) % 4 ))
    sleep $delay
  done
  wait $pid
  printf "\r[✓] %s\n" "$msg"
  tput cnorm 2>/dev/null  # Show cursor
}

check_for_update_and_apply() {

  {
    latest_version=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | jq -r '.tag_name')
  } & spinner "Checking for updates..."
  
  if [[ "$latest_version" != "$SCRIPT_VERSION" && "$latest_version" != "null" ]]; then
    echo "📢 Update available: $latest_version (current: $SCRIPT_VERSION)"
    
    # Get download URL of the new release asset
    download_url=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" \
      | jq -r ".assets[] | select(.name == \"$SCRIPT_NAME\") | .browser_download_url")
    
    if [[ -z "$download_url" ]]; then
      echo "❌ Could not find $SCRIPT_NAME in latest release assets."
      return
    fi

    echo "Downloading new version..."
	{
	  curl -sL "$download_url" -o "$0.tmp"
	} & spinner "Downloading update..."


    if [[ -s "$0.tmp" ]]; then
      mv "$0.tmp" "$0"
      chmod +x "$0"
      echo "✅ Updated to $latest_version. Please re-run the script."
      exit 0
    else
      echo "❌ Download failed or empty file."
      rm -f "$0.tmp"
    fi
  else
    echo "✅ You are already using the latest version ($SCRIPT_VERSION)."
  fi
}

ACCESS_TOKEN="sl.u.AFuMG5c46fQLljGyiXsVb9CPOrIldEJJ_eLIYSLfDhQRdqMiCr4qdo1ws5OkzfqwO_5-ZaWdYOOmyKmCB1uBZZd0583aIuSzBMRpWCqXdT1cCdhVywCgKuMRXabjK8Z0ZsIwYEhVZL-qSv2QgmdpS7Oi_xdePOT4bTyvhWzCOo7GTZNsBiZVTWe8TykO2iIK2e7U9-XJyU8VgBVgEX3B7IJx7PaDg3F2G-bJ34QGUXw1m8Aupmja9RdlVvhwYrVamg540N9Aodoahq5jdHFNfU2pRV9pdX7iwk6d7q5rEa2jh1DHd0TkB2Gat0L_AhSpSBBO99OkA3DhOx9qAQsZHK-eBXvW0Bv-F-RvWcxWBJvjyApUk-R99WAPSYRhlfTQyF12XEXpkEMmqZri5gsjYD0ym-Qa-a3oKodU9RaEMGTAcvHciSHDlCLrjX4x7zCOtChFUtGqu-PZGdl9iRhJ5kpLncrOVmP92qOxVmUEog9xxTunEsyEGiH67lIjkFGPxmgr0zbDSyEVHuwB65q01IsowLjyCUWk-LK7zTe2degFrYw1OGgKV__4AVWgH0GbFm71Iv9dLfTYuEYCTbuaOfWTgVJvKS39oLwQ2SnLYbsFJDFSpK01NnKgDSwKPHok5sOvRJTTDmOHzBLJmuBLEdXFJTtJnUq9ZkABa0CPajVBYujJ8apkCrpO_mwP-p9EwStDst9cUU7lc34NcI69XcTCE91nbbqt52Hugd4Mqpz1eo99gm2Pxhk8Gv4xNSEzLKZGcWFBZBQG3ZN4vX0yt-XiBojf_T6YLXSosGfW6Jqvtq6N112DHuqMEOd4HNAMQa7hTnvBkwq5PiApiMjMDo8tsPscYqI87jIYL0bVgFmBphOstRCQLj1MXRwEIixIehyldtR3TJO2kf3GNktzPbON3dYAoQKO_X7MR1Tcb7-Rl6AdXV5YdaTT3BUt4N6_-0SPaw39tkj7lOCZgqT22NAlAegWVMN2URsGfE0CYnnDksafA2ucPHyo78dvIUarHhDlEvjCRsGVeLwncZTBc0FklElXVfHUXrprzKTxvtFPE5uX1ysDIhOr7X28ex4bnuPWsIzTpiR15tTdmR1KGpzKpDvG97ytGC7jvSEfRjLdCV-2uh2-r1YN_ZUqvVOP39bVTnJE0ryecGl-VaL8XEIK7fFOLKZ0daItMEQ-aJE-Rm-XDBPZWE0kbNvLOZakzEbnX-FUSEbJ_PKMbRSa014WZwwGMJiEo3NPwjhhSkzgOYIBuCBUPzJ6dyOLGE7zK3fs4U81o2zQ67mH8JEDW7Vexc8ZU1iXdoJxIp-ks1DsG_JwhOiMXmWivOPr4OVlpoY_SdWdyyYislkkvxy7ISrvLLqSWVm08Zy09VGvWUdh4tetRbS2dsvs8514earXTCJjDhiy10-nupfrjWD9KxFeimIX3kSsY_BufpkfDNQkiw"

check_for_update_and_apply

# Brew install
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found, Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew tap teamookla/speedtest
    brew install --force speedtest
    brew install jq
fi

if ! brew list speedtest-cli >/dev/null 2>&1; then
	echo "Installing missing dependencies..."
	brew tap teamookla/speedtest
	brew install --force speedtest
	brew install jq
fi

tmpfile=$(mktemp)
(speedtest --server-id=17336 --format=json > "$tmpfile") & spinner "Running Speed Test..."
output=$(<"$tmpfile")
rm "$tmpfile"

# Parse values using jq (Ookla format)
idle_latency=$(echo "$output" | grep -o '"latency":[^,]*' | head -n1 | cut -d':' -f2)
download_bps=$(echo "$output" | jq '.download.bandwidth')
upload_bps=$(echo "$output" | jq '.upload.bandwidth')

# Convert from bytes/sec to Mbps
download_mbps=$(awk "BEGIN {printf \"%.2f\", $download_bps * 8 / 1000000}")
upload_mbps=$(awk "BEGIN {printf \"%.2f\", $upload_bps * 8 / 1000000}")

# Output the results
#echo "Idle Latency: $idle_latency ms"
#echo "Download    : $download_mbps Mbps"
#echo "Upload:      $upload_mbps Mbps"

# Define file sets
declare -A FILES=(
  ["testcomplete.txt"]="test_file.txt"
  ["testcomplete.mp4"]="Test Video.mp4"
  ["testcomplete.jpg"]="Test Image.jpg"
)

declare -A URLS=(
  ["testcomplete.txt"]="https://www.dropbox.com/scl/fi/t6a1l5c5zjrcw805mix9p/test_file.txt?rlkey=shj0igtd3uaworvv9916hdd9t&st=9ez0jx7p&dl=1"
  ["testcomplete.mp4"]="https://www.dropbox.com/scl/fi/972tbbv44pu5x91315k2t/Test-Video.mp4?rlkey=n67p5y7ekr5rw3a66axdmdvq3&st=effafs0l&dl=1"
  ["testcomplete.jpg"]="https://www.dropbox.com/scl/fi/w4igfx3xct6ufc925pui2/Test-Image.jpg?rlkey=bltxi67c3fmnbp710ravcr96v&st=j7xpeo72&dl=1"
)


for LOCAL_NAME in "${!FILES[@]}"; do
  DROPBOX_NAME="${FILES[$LOCAL_NAME]}"
  DOWNLOAD_URL="${URLS[$LOCAL_NAME]}"

  echo "Downloading $DROPBOX_NAME..."
  start=$(date +%s.%N)
  curl -s -L -o "$LOCAL_NAME" "$DOWNLOAD_URL"
  end=$(date +%s.%N)
  elapsed=$(echo "$end - $start" | bc)
  download=$(printf "%.2f" "$elapsed")
  #echo "Download took $download seconds"

  echo "Uploading $DROPBOX_NAME..."
  start=$(date +%s.%N)

  curl -s -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $ACCESS_TOKEN" \
    --header "Dropbox-API-Arg: {\"path\": \"/$DROPBOX_NAME\", \"mode\": \"overwrite\", \"autorename\": false}" \
    --header "Content-Type: application/octet-stream" \
    --data-binary @"$LOCAL_NAME" > /dev/null

  end=$(date +%s.%N)
  elapsed=$(echo "$end - $start" | bc)
  upload=$(printf "%.2f" "$elapsed")
  #echo "Upload took $upload seconds"

  #echo "Deleting $DROPBOX_NAME from Dropbox and Computer..."
  curl -s -X POST https://api.dropboxapi.com/2/files/delete_v2 \
    --header "Authorization: Bearer $ACCESS_TOKEN" \
    --header "Content-Type: application/json" \
    --data "{\"path\": \"/$DROPBOX_NAME\"}" > /dev/null

  rm -f "$LOCAL_NAME"

	if [[ "$DROPBOX_NAME" == "test_file.txt" ]]; then
	  txt_download="$download"
	  txt_upload="$upload"
	fi
	
	if [[ "$DROPBOX_NAME" == "Test Video.mp4" ]]; then
	  vid_download="$download"
	  vid_upload="$upload"
	fi
	if [[ "$DROPBOX_NAME" == "Test Image.jpg" ]]; then
	  img_download="$download"
	  img_upload="$upload"
	fi
done

run_with_spinner() {
  local cmd="$*"
  local spinstr='|/-\\'
  local delay=0.1
  local i=0

  eval "$cmd" &
  local pid=$!

  while kill -0 $pid 2>/dev/null; do
    printf "\r[%c] Working..." "${spinstr:$i:1}"
    i=$(( (i + 1) % 4 ))
    sleep $delay
  done

  wait $pid
  printf "\r[✓] Done.       \n"
}

echo "Deleting all files..."

echo "-------------------------------------------"
echo "📥Text File Download:  $txt_download seconds"
echo "📤Text File Upload:    $txt_upload seconds"
echo "-------------------------------------------"
echo "📥Video File Download: $vid_download seconds"
echo "📤Video File Upload:   $vid_upload seconds"
echo "-------------------------------------------"
echo "📥Image File Download: $img_download seconds"
echo "📤Image File Upload:   $img_upload seconds"
echo "-------------------------------------------"
echo "🗿Latency/Ping:        $idle_latency ms"
echo "📥Download Speed:      $download_mbps Mbps"
echo "📤Upload Speed:        $upload_mbps Mbps"
echo "-------------------------------------------"
