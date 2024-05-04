//
//  MainPageModel.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 16/10/23.
//

import Foundation
import SwiftUI
import CoreLocation

class AppLogic {
    
    static public var instance = AppLogic()
    
    private init() {}
    
    var locationDataManager = LocationDataManager()
    
    // Получить массив координат углов изображения карты
    func getCornersArr() -> [CornerOnMapValues] {
        [DataSource.instance.corners[.NW]!,
         DataSource.instance.corners[.NE]!,
         DataSource.instance.corners[.SW]!,
         DataSource.instance.corners[.SE]!]
    }
    
    // Проверка поставлены ли все углы изображения карты
    func areCornersSet() -> Bool {
        for corner in getCornersArr() {
            if !corner.isSet {
                return false
            }
        }
        return true
    }
    
    // Установлен ли конкретный угол изображения карты
    func isLocked(of cornerType: CornerType) -> Bool {
        getCoordinates(of: cornerType) != nil
    }
    
    // Удаление координат конкретного угла и метки изображения карты
    func deleteCoordinatesAndPointOnMap(at cornerType: CornerType) {
        DataSource.instance.corners[cornerType]?.deleteCoordinatesAndPointOnMap()
    }
    
    // Установка координат изображения карты
    func setCoordinates(to cornerType: CornerType, coordinates: GeoCoordinates) {
        DataSource.instance.corners[cornerType]?.setCoordinates(coordinates: coordinates)
    }
    
    // Получить координаты и метку конкретного угла изображения карты
    func getCornerOnMapValues(of cornerType: CornerType) -> CornerOnMapValues? {
        DataSource.instance.corners[cornerType]
    }
    
    // Получить координаты конкретного угла изображения карты
    func getCoordinates(of cornerType: CornerType) -> GeoCoordinates? {
        DataSource.instance.corners[cornerType]?.coordinates
    }
    
    // Получить метку конкретного угла изображения карты
    func getPointOnMap(of cornerType: CornerType) -> CGPoint? {
        DataSource.instance.corners[cornerType]?.pointOnMap
    }
    
    // Установить метку конкретного угла изображения карты
    func setPointOnMap(to cornerType: CornerType, point: CGPoint) {
        DataSource.instance.corners[cornerType]?.setPointOnMap(point: point)
    }
}
