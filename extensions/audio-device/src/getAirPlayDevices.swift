import Foundation
import CoreAudio
import Network

func discoverAirPlayDevices(excludeLocalDeviceName localDeviceName: String, completion: @escaping ([String]) -> Void) {
    var airPlayDevices: [String] = []
    let browser = NWBrowser(for: .bonjour(type: "_airplay._tcp", domain: nil), using: .tcp)
    
    browser.browseResultsChangedHandler = { (results: Set<NWBrowser.Result>, changes: Set<NWBrowser.Result.Change>) in
        for result in results {
            if case let NWEndpoint.service(name, _, _, _) = result.endpoint {
                if name != localDeviceName && !name.lowercased().contains("macbook") {
                    airPlayDevices.append(name)
                }
            }
        }
        completion(airPlayDevices)
    }
    
    browser.start(queue: .main)
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 10))
}

let localDeviceName = Host.current().localizedName ?? ""

discoverAirPlayDevices(excludeLocalDeviceName: localDeviceName) { airPlayDevices in
    print("\(airPlayDevices)")
}