#!/bin/bash
# Rohan Verma

SCRIPT_VERSION="v1.3.2"
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
    i=$(((i + 1) % 4))
    sleep $delay
  done
  wait $pid
  printf "\r[✓] %s\n" "$msg"
  tput cnorm 2>/dev/null  # Show cursor
}

check_for_update_and_apply() {
  echo "[✓] Checking for updates..."

  latest_version=$($JQ -r '.tag_name' < <(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest"))

  if [[ "$latest_version" != "$SCRIPT_VERSION" && "$latest_version" != "null" ]]; then
    echo "📢 Update available: $latest_version (current: $SCRIPT_VERSION)"

    download_url=$($JQ -r ".assets[] | select(.name == \"$SCRIPT_NAME\") | .browser_download_url" < <(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest"))

    if [[ -z "$download_url" ]]; then
      echo "❌ Could not find $SCRIPT_NAME in latest release assets."
      return
    fi

    echo "⬇️ Downloading new version..."
    curl -sL "$download_url" -o "$0.tmp"

    if [[ -s "$0.tmp" ]]; then
      mv "$0.tmp" "$0"
      chmod +x "$0"
      echo "[✓] Updated to $latest_version. Please re-run the script."
      exit 0
    else
      echo "❌ Download failed or empty file."
      rm -f "$0.tmp"
    fi
  else
    echo "[✓] Already latest version! ($SCRIPT_VERSION)"
  fi
}

for bin in ./bin/jq ./bin/speedtest; do
  if [[ -f "$bin" ]]; then
    chmod +x "$bin"
    xattr -d com.apple.quarantine "$bin" 2>/dev/null
  fi

done

if ! command -v jq >/dev/null 2>&1; then
  chmod +x ./bin/jq 2>/dev/null
  JQ="./bin/jq"
else
  JQ="jq"
fi

if ! command -v speedtest >/dev/null 2>&1; then
  chmod +x ./bin/speedtest 2>/dev/null
  SPEEDTEST="./bin/speedtest"
else
  SPEEDTEST="speedtest"
fi

echo "----------------------------------------------------------------------"
check_for_update_and_apply
echo "----------------------------------------------------------------------"

tmpfile=$(mktemp)
($SPEEDTEST --accept-license --accept-gdpr --server-id=17336 --format=json > "$tmpfile") & spinner "Running Speed Test..."
output=$(<"$tmpfile")
rm "$tmpfile"

idle_latency=$(echo "$output" | grep -o '"latency":[^,]*' | head -n1 | cut -d':' -f2)
download_bps=$(echo "$output" | $JQ '.download.bandwidth')
upload_bps=$(echo "$output" | $JQ '.upload.bandwidth')

download_bps=${download_bps:-0}
upload_bps=${upload_bps:-0}

download_mbps=$(awk -v val="$download_bps" 'BEGIN {printf "%.2f", val * 8 / 1000000}')
upload_mbps=$(awk -v val="$upload_bps" 'BEGIN {printf "%.2f", val * 8 / 1000000}')

FILES_KEYS=("testcomplete.txt" "testcomplete.mp4" "testcomplete.jpg")

get_filename() {
  case "$1" in
    "testcomplete.txt") echo "Test File.txt" ;;
    "testcomplete.mp4") echo "Test Video.mp4" ;;
    "testcomplete.jpg") echo "Test Image.jpg" ;;
    *) echo "Unknown" ;;
  esac
}

get_url() {
  case "$1" in
    "testcomplete.txt") echo "https://www.dropbox.com/scl/fi/t6a1l5c5zjrcw805mix9p/test_file.txt?rlkey=shj0igtd3uaworvv9916hdd9t&st=9ez0jx7p&dl=1" ;;
    "testcomplete.mp4") echo "https://www.dropbox.com/scl/fi/972tbbv44pu5x91315k2t/Test-Video.mp4?rlkey=n67p5y7ekr5rw3a66axdmdvq3&st=effafs0l&dl=1" ;;
    "testcomplete.jpg") echo "https://www.dropbox.com/scl/fi/w4igfx3xct6ufc925pui2/Test-Image.jpg?rlkey=bltxi67c3fmnbp710ravcr96v&st=j7xpeo72&dl=1" ;;
    *) echo "" ;;
  esac
}

for LOCAL_NAME in "${FILES_KEYS[@]}"; do
  ACCESS_TOKEN="<YOUR_DROPBOX_TOKEN>"
  DROPBOX_NAME="$(get_filename "$LOCAL_NAME")"
  DOWNLOAD_URL="$(get_url "$LOCAL_NAME")"
  RANDOM_ID=$(uuidgen | cut -c1-8)
  UNIQUE_DROPBOX_NAME="${DROPBOX_NAME%.*}_$RANDOM_ID.${DROPBOX_NAME##*.}"

  start=$(date +%s.%N)
  {
    curl -s -L -o "$LOCAL_NAME" "$DOWNLOAD_URL"
  } & spinner "Downloading $DROPBOX_NAME..."
  wait
  end=$(date +%s.%N)
  download=$(awk -v start="$start" -v end="$end" 'BEGIN {printf "%.2f", end - start}')

  start=$(date +%s.%N)
  {
    curl -s -X POST https://content.dropboxapi.com/2/files/upload \
      --header "Authorization: Bearer $ACCESS_TOKEN" \
      --header "Dropbox-API-Arg: {\"path\": \"/$UNIQUE_DROPBOX_NAME\", \"mode\": \"overwrite\", \"autorename\": false}" \
      --header "Content-Type: application/octet-stream" \
      --data-binary @"$LOCAL_NAME" > /dev/null
  } & spinner "Uploading $DROPBOX_NAME..."
  wait
  end=$(date +%s.%N)
  upload=$(awk -v start="$start" -v end="$end" 'BEGIN {printf "%.2f", end - start}')

  {
    curl -s -X POST https://api.dropboxapi.com/2/files/delete_v2 \
      --header "Authorization: Bearer $ACCESS_TOKEN" \
      --header "Content-Type: application/json" \
      --data "{\"path\": \"/$UNIQUE_DROPBOX_NAME\"}" > /dev/null
  } & spinner "Deleting $DROPBOX_NAME from Dropbox..."
  wait
  rm -f "$LOCAL_NAME"

  if [[ "$DROPBOX_NAME" == "Test File.txt" ]]; then
    txt_download="$download"
    txt_upload="$upload"
  elif [[ "$DROPBOX_NAME" == "Test Video.mp4" ]]; then
    vid_download="$download"
    vid_upload="$upload"
  elif [[ "$DROPBOX_NAME" == "Test Image.jpg" ]]; then
    img_download="$download"
    img_upload="$upload"
  fi

done

echo "----------------------------------------------------------------------"
echo "📥 Text File Download:  $txt_download seconds"
echo "📤 Text File Upload:    $txt_upload seconds"
echo "----------------------------------------------------------------------"
echo "📥 Video File Download: $vid_download seconds"
echo "📤 Video File Upload:   $vid_upload seconds"
echo "----------------------------------------------------------------------"
echo "📥 Image File Download: $img_download seconds"
echo "📤 Image File Upload:   $img_upload seconds"
echo "----------------------------------------------------------------------"
echo "🗿 Latency/Ping:        $idle_latency ms"
echo "📥 Download Speed:      $download_mbps Mbps"
echo "📤 Upload Speed:        $upload_mbps Mbps"
echo "----------------------------------------------------------------------"
read -p "> Enter your current ASD Room Number/Location on Campus: " location
read -p "> Any notes? Leave blank if nothing: " notes
read -p "> Distance to router in meters (estimated): " distance
echo "----------------------------------------------------------------------"

wifi_name=$(system_profiler SPAirPortDataType 2>/dev/null | awk '/Current Network Information:/ {getline; gsub(":", "", $1); print $1; exit}')
laptop_owner=$(scutil --get ComputerName)

if [[ "$wifi_name" == "ASD" ]]; then
        {
          curl -s -X POST https://docs.google.com/forms/d/e/1FAIpQLSdJqVtrNwXMySfBWkkWBK13TH9qMH_hhS0VqcmivjTj9k64ZQ/formResponse \
            -d "entry.366340186=$laptop_owner" \
            -d "entry.163968548=$wifi_name" \
            -d "entry.1417593520=$location" \
            -d "entry.1988809452=$distance" \
            -d "entry.920602030=$download_mbps" \
            -d "entry.1199007316=$upload_mbps" \
            -d "entry.1831664958=$idle_latency" \
            -d "entry.332463093=$txt_download" \
            -d "entry.261161766=$txt_upload" \
            -d "entry.1579796133=$img_download" \
            -d "entry.911938217=$img_upload" \
            -d "entry.489745409=$vid_download" \
            -d "entry.1329736496=$vid_upload" \
            -d "entry.1500120204=$notes" > /dev/null
        } & spinner "Submitting results to Spreadsheet..."
echo "----------------------------------------------------------------------"
elif [[ "$wifi_name" != "ASD" ]]; then
        exit
fi
