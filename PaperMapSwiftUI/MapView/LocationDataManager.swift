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
    private var locationManager = CLLocationManager() // Управление услугами геопозиционирования
    
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
            
        case .restricted:  // Услуги определения местоположения ограничены
            authorizationStatus = .restricted
            break
            
        case .denied:  // Услуги определения местоположения не разрешены
            authorizationStatus = .denied
            break
            
        case .notDetermined:   // Услуги определения местоположения не определены
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
