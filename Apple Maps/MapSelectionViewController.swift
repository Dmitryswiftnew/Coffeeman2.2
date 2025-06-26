
import Foundation
import UIKit
import CoreLocation
import MapKit


// проблема с картой не решена

// протокол для передачи выбранных данных обратно
protocol MapSelectionDelegate: AnyObject {
    func didSelectLocation(coordinate: CLLocationCoordinate2D, address: String?)
}


class MapSelectionViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    weak var delegate: MapSelectionDelegate?
    let locationManager = CLLocationManager()  // исправлено имя переменной
    var mapView: MKMapView!
    var annotation: MKPointAnnotation?
    
    //  кнопка Done
    
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorization()  // исправлено имя функции
        
        setupMapView()
        setupDoneButton()
    }
    
    
    func setupMapView() {
        mapView = MKMapView(frame: view.bounds)
        mapView.autoresizingMask = [ .flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true // вкл отображение текущего местоположения
        
        mapView.layer.borderColor = UIColor.red.cgColor  // Красная граница
        mapView.layer.borderWidth = 3                    // Толщина границы 3 пункта
        
        // настройка жеста для добавления маркера
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        view.addSubview(mapView)
    }
    
    
    @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Удаляем предыдущую аннотацию
        
        if let existingAnnotation = annotation {
            mapView.removeAnnotation(existingAnnotation)
        }
        
        // Создаем новыйю аннотацию
        
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = coordinate
        mapView.addAnnotation(newAnnotation)
        annotation = newAnnotation
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
    }
    
    
    func setupDoneButton() {
        view.addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: 120),
            doneButton.heightAnchor.constraint(equalToConstant: 44)
            
        ])
        
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
    }
    
    
    @objc func doneButtonTapped() {
        guard let annotation = annotation else { return }
        let coordinate = annotation.coordinate
        
        // Обратное геокодирование с помощью CLGeocoder
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            var addressString: String? = nil
            
            if let error = error {
                print("Geocoder error: \(error.localizedDescription)")
            } else if let placemark = placemarks?.first {
                // Форматируем адрес
                addressString = [
                    placemark.thoroughfare,
                    placemark.subThoroughfare,
                    placemark.locality,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")
            }
            
            self.delegate?.didSelectLocation(coordinate: coordinate, address: addressString)
            self.dismiss(animated: true)
        }
    }

    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("Получена локация: \(location.coordinate.latitude), \(location.coordinate.longitude)")
           
            let coordinate = location.coordinate
            let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
                )
            
            mapView.setRegion(region, animated: true)
            locationManager.stopUpdatingLocation()
            
            
        }
    }
    
    
  
    
    
    // MARK: - CLLocationManagerDelegate и разрешения
    
    func checkLocationAuthorization() {
        if #available(iOS 14.0, *) {
            let status = locationManager.authorizationStatus
            handleAuthorizationStatus(status)
        } else {
            let status = CLLocationManager.authorizationStatus()
            print("Authorization status: \(status.rawValue)")
            handleAuthorizationStatus(status)
        }
    }
    
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        print("Handling authorization status: \(status.rawValue)")
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
    
    // Для iOS 14+
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
