//
//  PointOnMapValues.swift
//  PaperMapSwiftUI
//
//  Created by Маргарита Бабухадия on 04.05.2024.
//

import Foundation

// Соответствие координат с точкой на экране
class PointOnMapValues {
    private(set) var coordinates: GeoCoordinates? // Геокоординаты точки
    private(set) var pointOnMap: CGPoint? // Координаты точки на экране
    
    init() {}
    
    init(coordinates: GeoCoordinates) {
        self.coordinates = coordinates
    }
    
    init(coordinates: GeoCoordinates, point: CGPoint) {
        self.coordinates = coordinates
        self.pointOnMap = point
    }
    
    // Проверка установлены ли геокоординаты и координаты точки на экране
    var isSet: Bool {
        coordinates != nil && pointOnMap != nil
    }
    
    // Проверка равенства двух точек
    static func == (lhs: PointOnMapValues, rhs: PointOnMapValues) -> Bool {
        lhs.coordinates == rhs.coordinates && lhs.pointOnMap == rhs.pointOnMap
    }
    
    // Удаление геокоординат и координат точки на экране
    func deleteCoordinatesAndPointOnMap() {
        coordinates = nil
        pointOnMap = nil
    }
    
    // Установка геокоординат
    func setCoordinates(coordinates: GeoCoordinates) {
        self.coordinates = coordinates
    }
    
    // Установка координат точки на экране
    func setPointOnMap(point: CGPoint) {
        pointOnMap = point
    }
}
