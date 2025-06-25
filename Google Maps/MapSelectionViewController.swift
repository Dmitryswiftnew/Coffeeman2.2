
import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation


// протокол для передачи выбранных данных обратно
protocol MapSelectionDelegate: AnyObject {
    func didSelectLocation(coordinate: CLLocationCoordinate2D, address: String?)
}


class MapSelectionViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    weak var delegate: MapSelectionDelegate?
    let locationManager = CLLocationManager()  // исправлено имя переменной
    var mapView: GMSMapView!
    var marker: GMSMarker?
    
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
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 1)
        
        mapView = GMSMapView(options: options)
        mapView.frame = view.bounds
        
        mapView.layer.borderColor = UIColor.red.cgColor  // Красная граница
        mapView.layer.borderWidth = 3                    // Толщина границы 3 пункта
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        
        view.addSubview(mapView)
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
        guard let mapView = mapView else { return }
        
        // получаем координаты центра карты
        
        let centerCoordinate = mapView.camera.target
        
        // обратное геокодирование
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(centerCoordinate) { [weak self] response , error in
            guard let self = self else { return }
            
            if let error = error {
                print("Geocoder error: \(error.localizedDescription)")  // проверка на ошибку
            }
            
            
            var adressString: String? = nil
            
            if let address = response?.firstResult(), error == nil {
                // формируем строку адреса из компонентов
                
                let lines = address.lines ?? []
                adressString = lines.joined(separator: ", ")
            }
               // Передаем координаты и адрес обратно через делегат
            
            self.delegate?.didSelectLocation(coordinate: centerCoordinate, address: adressString)
            
            // // Закрываем модальный экран
            self.dismiss(animated: true)
            
            
        }
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("Получена локация: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            guard mapView != nil else {
                print("Ошибка: mapView не инициализирован")
                return
            }
            let camera = GMSCameraPosition(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15)
            mapView.animate(to: camera)
            print("Анимация камеры запущена")
            locationManager.stopUpdatingLocation()
        }
    }
    
    
    // MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // удаляем предыдущий маркер
        marker?.map = nil
        // создаем новый маркер в точке касания
        
        
        // новый маркер в точке касания
        marker = GMSMarker(position: coordinate)
        marker?.map = mapView
        
        // Центрируем камеру на выбранной точке
        mapView.animate(toLocation: coordinate)
        
        
        marker?.isDraggable = true
        
        
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
