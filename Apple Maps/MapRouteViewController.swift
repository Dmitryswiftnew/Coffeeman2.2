

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation




class MapRouteViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        checkLocationAuthorization()
    }

    func checkLocationAuthorization() {
        if #available(iOS 14.0, *) {
            // Используем свойство экземпляра locationManager.authorizationStatus
            let status = locationManager.authorizationStatus

            handleAuthorizationStatus(status)
        } else {
            // Для iOS ниже 14 используем статический метод класса
            let status = CLLocationManager.authorizationStatus()

            handleAuthorizationStatus(status)
        }
    }

    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showLocationDeniedAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }

    // Делегат для отслеживания изменений разрешения
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

    // Для iOS ниже 14
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if #available(iOS 14.0, *) {
            // Не вызывается на iOS 14+, используем locationManagerDidChangeAuthorization
            return
        }
        checkLocationAuthorization()
    }

    func showLocationDeniedAlert() {
        let alert = UIAlertController(title: "Доступ к местоположению запрещён",
                                      message: "Для работы с картой необходимо разрешить доступ к местоположению в настройках.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Открыть настройки", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
}
