import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocation?
    @Published var permissionStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        permissionStatus = locationManager.authorizationStatus
        askForPermission()
    }
    
    func askForPermission() {
        if permissionStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if permissionStatus == .authorizedWhenInUse || permissionStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            print("Location permission not granted.")
        }
    }
    
    // This runs when the permission changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        permissionStatus = manager.authorizationStatus
        
        if permissionStatus == .authorizedWhenInUse || permissionStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        } else {
            manager.stopUpdatingLocation()
            userLocation = nil
        }
    }
    
    // Gets called when location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.first {
            userLocation = newLocation
            // stop updating after getting one location to save battery
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
}
