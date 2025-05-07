# asd-speedtest
Speedtest Script for ASD Network (or any network!)

## Installation
1. Click on releases on the right
2. Download the **latest** ASD_Speedtest.zip
3. Unzip the file ASD_Speedtest.zip
4. Open Terminal Window
5. Run ```cd Downloads/ASD_Speedtest``` (if it is downloaded in your "Downloads" directory, otherwise cd is used to change directories, so to change directory to download you do cd Download, for documents cd Documents)
6. Simply run the command ```bash speedtest.sh```
7. Head to usage if you want to understand how to gather distance

## Usage
Run the command with:
```
bash speedtest.sh
```
- For finding distance, please use the iPhone Measure app (if not downloaded, download it now!). If you are using Android, download the "Measure Tools: AR Ruler Camera" app and measure with that if your Phone has LiDar capabilities. Otherwise, just __try to eyeball the distance!__
- Enter in the spreadsheet all of the data given as shown in the spreadsheet

## Expected Output
```
-------------------------------------------
🔍 Checking for updates...
✅ You are already using the latest version (v1.1.7).
-------------------------------------------
[✓] Running Speed Test...
[✓] Downloading Test File.txt...
[✓] Uploading Test File.txt...
[✓] Deleting Test File.txt from Dropbox...
[✓] Downloading Test Image.jpg...
[✓] Uploading Test Image.jpg...
[✓] Deleting Test Image.jpg from Dropbox...
[✓] Downloading Test Video.mp4...
[✓] Uploading Test Video.mp4...
[✓] Deleting Test Video.mp4 from Dropbox...
-------------------------------------------
📥Text File Download:  11.51 seconds
📤Text File Upload:    10.33 seconds
-------------------------------------------
📥Video File Download: 19.71 seconds
📤Video File Upload:   19.34 seconds
-------------------------------------------
📥Image File Download: 7.45 seconds
📤Image File Upload:   7.85 seconds
-------------------------------------------
🗿Latency/Ping:        5.966 ms
📥Download Speed:      703.59 Mbps
📤Upload Speed:        318.37 Mbps
-------------------------------------------
```
