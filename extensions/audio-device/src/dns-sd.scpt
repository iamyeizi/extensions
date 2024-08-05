set devices to {}

-- Get AirPlay devices using dns-sd
set airplayServices to paragraphs of (do shell script "dns-sd -B _raop._tcp")

-- Parse the output to extract device names
repeat with service in airplayServices
    set deviceName to text 3 thru -1 of service
    set end of devices to deviceName
end repeat

-- Your existing code to get current output devices
tell application "System Preferences"
    reveal pane id "com.apple.preference.sound"
end tell

tell application "System Events"
    tell application process "System Preferences"
        repeat until exists tab group 1 of window "Sound"
        end repeat
        tell tab group 1 of window "Sound"
            click radio button "Output"
            tell table 1 of scroll area 1
                set selected_row to (first UI element whose selected is true)
                set currentOutput to value of text field 1 of selected_row as text
                
                repeat with r in rows
                    try
                        set deviceName to value of text field 1 of r as text
                        set deviceType to value of text field 2 of r as text
                        set end of devices to {deviceName, deviceType}
                    end try
                end repeat
            end tell
        end tell
    end tell
end tell

if application "System Preferences" is running then
    tell application "System Preferences" to quit
end if

return {devices, "currentOutput", currentOutput}
