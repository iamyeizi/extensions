import Foundation
import CoreAudio
import Network

func getOutputDevices() -> [String] {
    var deviceNames: [String] = []
    print("Getting local output devices...")

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

    print("Local output devices found: \(deviceNames)")
    return deviceNames
}

func discoverAirPlayDevices() {
    print("Starting to discover AirPlay devices...")
    let browser = NWBrowser(for: .bonjour(type: "_airplay._tcp", domain: nil), using: .tcp)
    
    browser.stateUpdateHandler = { newState in
        switch newState {
        case .failed(let error):
            print("Failed to browse: \(error)")
        case .ready:
            print("Browser ready")
        case .waiting(let error):
            print("Browser waiting: \(error)")
        case .cancelled:
            print("Browser cancelled")
        default:
            print("Browser state: \(newState)")
        }
    }
    
    browser.browseResultsChangedHandler = { (results: Set<NWBrowser.Result>, changes: Set<NWBrowser.Result.Change>) in
        for result in results {
            if case let NWEndpoint.service(name, _, _, _) = result.endpoint {
                print("Discovered AirPlay device: \(name)")
            }
        }
    }
    
    browser.start(queue: .main)
    // Run the main loop for a short time to ensure discovery
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 10))
}

let localDevices = getOutputDevices()
print("Local Output Devices: \(localDevices)")

discoverAirPlayDevices()