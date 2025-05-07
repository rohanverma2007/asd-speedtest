#!/bin/bash
# Rohan Verma

SCRIPT_VERSION="v1.1.9"
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
  echo "🔍 Checking for updates..."

  latest_version=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | jq -r '.tag_name')
  
  if [[ "$latest_version" != "$SCRIPT_VERSION" && "$latest_version" != "null" ]]; then
    echo "📢 Update available: $latest_version (current: $SCRIPT_VERSION)"
    
    # Get download URL of the new release asset
    download_url=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" \
      | jq -r ".assets[] | select(.name == \"$SCRIPT_NAME\") | .browser_download_url")
    
    if [[ -z "$download_url" ]]; then
      echo "❌ Could not find $SCRIPT_NAME in latest release assets."
      return
    fi

    echo "⬇️ Downloading new version..."
    curl -sL "$download_url" -o "$0.tmp"

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
    echo "✅ Already latest version! ($SCRIPT_VERSION)"
  fi
}
echo "-------------------------------------------"
check_for_update_and_apply
echo "-------------------------------------------"

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

declare -A FILES=(
  ["testcomplete.txt"]="Test File.txt"
  ["testcomplete.mp4"]="Test Video.mp4"
  ["testcomplete.jpg"]="Test Image.jpg"
)

declare -A URLS=(
  ["testcomplete.txt"]="https://www.dropbox.com/scl/fi/t6a1l5c5zjrcw805mix9p/test_file.txt?rlkey=shj0igtd3uaworvv9916hdd9t&st=9ez0jx7p&dl=1"
  ["testcomplete.mp4"]="https://www.dropbox.com/scl/fi/972tbbv44pu5x91315k2t/Test-Video.mp4?rlkey=n67p5y7ekr5rw3a66axdmdvq3&st=effafs0l&dl=1"
  ["testcomplete.jpg"]="https://www.dropbox.com/scl/fi/w4igfx3xct6ufc925pui2/Test-Image.jpg?rlkey=bltxi67c3fmnbp710ravcr96v&st=j7xpeo72&dl=1"
)


for LOCAL_NAME in "${!FILES[@]}"; do
  ACCESS_TOKEN="sl.u.AFukczMxnAFibTJeNCgG4tUWAoLSEgW2FzPtBBintHXAM-zYRD3Cb9VZG8BxRT027bzHSt1RgWC03dgpFaCm10CiAgihUnK6EfTiJwLMvv4O-Z4SyE90P7kMql_J2bCekIKOHuKqukvfgCXSvHd6V6tSlZbu3DXoELlmztMnNC691Vi-6OZlcIkW_4Oc0vAznkLEHSJSUB5K_cYDNj-k-YmT-6lNKAuZjBZPECemPUZJXo00vAlomywLycOKcHK1PdePHltt34Hk_Dt6QHCo--s_-oyGACNM0vIMJrOdU8eSvjJNOO4Xa_k9MT9LaZqk4DoP8WLMV8uQjlllAiBc8VKGkhRTt0RKIoKwSFogPZZYdJ6QJEJeUZNCIQYev8YuM_cLT1terb5EHTHWA__BeLXv_xxVYudiJS60lDZWCkE5a8cI9dyFBXr9xTaz7_3DZ3oaNOtd1fDomqUXOr-VBgeCe-9V6HUC_sWgZkP1pPmvX4_RvXa8fnVMUuXAgclnUrhi9wj8pzmmclrzxaJYSIn1tnIMg5JYU9_6UzUoSyJqUOEXNSo8VJ-7R32Oe3yopYCDMxS7dwxtyEltJFyqYXK407Fx5qEZWhHqdYVSmP0s0vgZwt1JMCWXaHtNmaaiV1MmSx3oweDMWxIR2Ax368oVmb9HTQXoIvSYIw86aMn3vFXykq2YjoMheiOqs10iKWnNa5ZqRTCzH77vNxhMZNMXWZCzEv07yXSVutAZkfv9_u2frntuRAom4_OJUg0yqlIUbhfPBJj73lujFYsR31_dsBN5-TucRDvlitS5oYrMTb_i-0NdsuD5-UYbNhixM4_1dHXSdb4dn1kVl3KglchQsFI6Dc6JAcgJi9phUpqhlE3IlRP5hKoFy9lSruoF3peiFKlIUxveL-ktlKffg31YWFOnQ9joUqcsNeUKt11lgUsWqPafbYpCUfx6dKx_TTBLSRgEfSYF3M71WdvnlMGHGPm430vQUdAjwD3mNjIkwGtN12evc3zj8Cgsk-pK9dfbYf8R0NeBelXMLG9n5cq-ECLDgS3VkqRCGiHt7_YqKBqHKQj9ZCji8GHRmEHJfXGRavj7WaUGbS8giZhO9tfMC_-Kcy4yST55TfjVKifbC6RjkLOkraDNbPdc6eNImx5TYkvO2MtcT3tzYKzU8h13HZyGKNlXg4UQ1UU2YIpUoZXJJa4A6XBtp5SI_Pi7MnUqA0qvAnviJ7McKyF342Uds9c0WG_LX3VhUOm65Pwy6yC7Y2734wsEEIXZwmoIxhgnBDU0rPA8u-pEY_agVXZOsqLv9DXB2VLd6Z6xJFDV0AtIuZeXGQvXnwFjO0ObDYarsmdqyFa-6YcRWX2hioZIvFFQgrDPxOAcHp7udR9nSDBNxY1LOVqJoz1voa4dGFOCdovE_wp1ah7uTOQqdVrcEg4tKbIHov_B9ABX85vhUw"
  DROPBOX_NAME="${FILES[$LOCAL_NAME]}"
  DOWNLOAD_URL="${URLS[$LOCAL_NAME]}"
  RANDOM_ID=$(uuidgen | cut -c1-8)
  UNIQUE_DROPBOX_NAME="${DROPBOX_NAME%.*}_$RANDOM_ID.${DROPBOX_NAME##*.}"

  start=$(date +%s.%N)
  {
    curl -s -L -o "$LOCAL_NAME" "$DOWNLOAD_URL"
  } & spinner "Downloading $DROPBOX_NAME..."
  end=$(date +%s.%N)
  elapsed=$(echo "$end - $start" | bc)
  download=$(printf "%.2f" "$elapsed")
  start=$(date +%s.%N)

  {
    curl -s -X POST https://content.dropboxapi.com/2/files/upload \
      --header "Authorization: Bearer $ACCESS_TOKEN" \
      --header "Dropbox-API-Arg: {\"path\": \"/$UNIQUE_DROPBOX_NAME\", \"mode\": \"overwrite\", \"autorename\": false}" \
      --header "Content-Type: application/octet-stream" \
      --data-binary @"$LOCAL_NAME" > /dev/null
  } & spinner "Uploading $DROPBOX_NAME..."

  end=$(date +%s.%N)
  elapsed=$(echo "$end - $start" | bc)
  upload=$(printf "%.2f" "$elapsed")

  {
    curl -s -X POST https://api.dropboxapi.com/2/files/delete_v2 \
      --header "Authorization: Bearer $ACCESS_TOKEN" \
      --header "Content-Type: application/json" \
      --data "{\"path\": \"/$UNIQUE_DROPBOX_NAME\"}" > /dev/null
  } & spinner "Deleting $DROPBOX_NAME from Dropbox..."

  rm -f "$LOCAL_NAME"

	if [[ "$DROPBOX_NAME" == "Test File.txt" ]]; then
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