//
//  LocationDataManager.swift
//  LocationTrackerExample
//
//  Created by Margarita Babukhadia on 18/11/23.
//
import Foundation
import CoreLocation

// Класс получения координат пользователя от системы
class LocationDataManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus? // Статус разрешения использования геопозиции
    @Published var coord: CLLocationCoordinate2D? // Геопозиция пользователя
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // Запуск отслеживания геопозиции пользователя
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    // Остановка отслеживания геопозиции пользователя
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // Функция запроса пользователю для использования его геопозиции
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:  
            authorizationStatus = .authorizedWhenInUse
            locationManager.requestLocation()
            break
            
        case .restricted:  // Location services currently unavailable.
            // Insert code here of what should happen when Location services are NOT authorized
            authorizationStatus = .restricted
            break
            
        case .denied:  // Location services currently unavailable.
            // Insert code here of what should happen when Location services are NOT authorized
            authorizationStatus = .denied
            break
            
        case .notDetermined:        // Authorization not determined yet.
            authorizationStatus = .notDetermined
            manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }
    
    // Функция для изменения координат пользователя, полученные от системы
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coord = locations.last?.coordinate
    }
    
    // Функция для вывода ошибок
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка: \(error.localizedDescription)")
    }
    
}

// Расширение для сравнивания изменений координат
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
