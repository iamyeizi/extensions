import Foundation
import CoreAudio

func getOutputDevices() -> [String] {
    var deviceNames: [String] = []

    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDevices,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain // Updated for macOS 12.0 and later
    )
    
    var dataSize: UInt32 = 0
    let status = AudioObjectGetPropertyDataSize(
        AudioObjectID(kAudioObjectSystemObject),
        &propertyAddress,
        0,
        nil,
        &dataSize
    )

    if status != noErr {
        print("Error getting data size: \(status)")
        return []
    }

    let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
    var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
    
    let status2 = AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &propertyAddress,
        0,
        nil,
        &dataSize,
        &deviceIDs
    )

    if status2 != noErr {
        print("Error getting device IDs: \(status2)")
        return []
    }

    for deviceID in deviceIDs {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain // Updated for macOS 12.0 and later
        )
        
        var deviceName: Unmanaged<CFString>?
        var dataSize = UInt32(MemoryLayout<CFString?>.size)
        let status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceName
        )
        
        if status == noErr, let deviceName = deviceName?.takeRetainedValue() {
            deviceNames.append(deviceName as String)
        } else {
            print("Error getting device name for device ID \(deviceID): \(status)")
        }
    }

    return deviceNames
}

let devices = getOutputDevices()
print("Output Devices: \(devices)")