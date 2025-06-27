
import Foundation
import UIKit
import MapKit




// протокол для передачи выбранных данных обратно
protocol MapSelectionDelegate: AnyObject {
    func didSelectLocation(coordinate: CLLocationCoordinate2D, address: String?)
}


class MapSelectionViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    weak var delegate: MapSelectionDelegate?
    let locationManager = CLLocationManager()  // исправлено имя переменной
    var mapView: MKMapView!
    var annotation: MKPointAnnotation?
    var selectedAddress: String?
    var selectedCoordinate: CLLocationCoordinate2D?
    //  кнопка Done
    
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
//        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupMapView()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorization()  // исправлено имя функции
        
        
        setupDoneButton()
    }
    
    
    func setupMapView() {
        mapView = MKMapView(frame: view.bounds)
        mapView.autoresizingMask = [ .flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true // вкл отображение текущего местоположения
        mapView.userTrackingMode = .follow // следит за пользователем
        
        
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
        
        // Создаем новую аннотацию
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = coordinate
        newAnnotation.title = "Загрузка адреса..."
        mapView.addAnnotation(newAnnotation)
        annotation = newAnnotation
        
        // Обратное геокодирование
        let geocoder = CLGeocoder()
        let locationForGeocode = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(locationForGeocode) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let placemark = placemarks?.first, error == nil {
                // Форматируем адрес
                let street = placemark.thoroughfare ?? ""
                let number = placemark.subThoroughfare ?? ""
                let city = placemark.locality ?? ""
                
                var streetPart = ""
                if !street.isEmpty {
                    streetPart = number.isEmpty ? street : "\(street), \(number)"
                }
                
                var addressParts = [String]()
                if !streetPart.isEmpty {
                    addressParts.append(streetPart)
                }
                if !city.isEmpty {
                    addressParts.append(city)
                }
                
                let formattedAddress = addressParts.joined(separator: ", ")
                
                // Обновляем аннотацию
                newAnnotation.title = formattedAddress
                self.mapView.selectAnnotation(newAnnotation, animated: true)
                
                // Сохраняем для передачи
                self.selectedAddress = formattedAddress
                self.selectedCoordinate = coordinate
                
            } else {
                newAnnotation.title = "Адрес не найден"
                self.mapView.selectAnnotation(newAnnotation, animated: true)
                self.selectedAddress = nil
                self.selectedCoordinate = nil
            }
        }
        
        // Центрируем карту
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Не кастомизируем стандартное отображение для текущей локации пользователя
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "Pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true  // включаем отображение callout
            annotationView?.animatesDrop = true    // анимация падения пина
            annotationView?.pinTintColor = .red
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    
    
    
    
    func setupDoneButton() {
        view.addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: 255),
            doneButton.heightAnchor.constraint(equalToConstant: 99)
            
        ])
        
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
    }
    
    
    @objc func doneButtonTapped() {
        if let coordinate = selectedCoordinate {
            // Если адрес уже есть, используем его, иначе делаем обратное геокодирование
            if let address = selectedAddress {
                delegate?.didSelectLocation(coordinate: coordinate, address: address)
                dismiss(animated: true)
            } else {
            
            // Обратное геокодирование с помощью CLGeocoder
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
                geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
                    guard let self = self else { return }
                    
                    var addressString: String? = nil
                    
                    if let placemark = placemarks?.first, error == nil {
                        let street = placemark.thoroughfare ?? ""
                        let number = placemark.subThoroughfare ?? ""
                        let city = placemark.locality ?? ""
                        var parts = [String]()
                        
                        if !street.isEmpty {
                            let streetWithNumber = number.isEmpty ? street : "\(street) \(number)"
                            
                            parts.append(streetWithNumber)
                        }
                        
                        if !city.isEmpty {
                            parts.append(city)
                        }
                        
                        addressString = parts.joined(separator: ", ")
                    }
                    
                    self.delegate?.didSelectLocation(coordinate: coordinate, address: addressString)
                    self.dismiss(animated: true)
                }
            }
        } else {
            // Если маркер не выбран, закрываем экран без передачи координат
            dismiss(animated: true)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("Получена локация: \(location.coordinate.latitude), \(location.coordinate.longitude)")
           
            let coordinate = location.coordinate
            let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 800,
                longitudinalMeters: 800
                )
            
            mapView.setRegion(region, animated: true)
//            locationManager.stopUpdatingLocation()
            
            
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
