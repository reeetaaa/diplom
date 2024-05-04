//
//  CornerOnMapValues.swift
//  PaperMapSwiftUI
//
//  Created by Маргарита Бабухадия on 04.05.2024.
//

import Foundation

// Соответствие координат с точкой на экране конкретного угла
class CornerOnMapValues: PointOnMapValues, Identifiable {
    var id: String { cornerType.rawValue } // id для определения уникальности угла
    private(set) var cornerType: CornerType // тип угла (СЗ, СВ, ЮЗ, ЮВ)
    
    init(cornerType: CornerType) {
        self.cornerType = cornerType
        super.init()
    }
    
    init(cornerType: CornerType, coordinates: GeoCoordinates) {
        self.cornerType = cornerType
        super.init(coordinates: coordinates)
    }
    
    init(cornerType: CornerType, coordinates: GeoCoordinates, point: CGPoint) {
        self.cornerType = cornerType
        super.init(coordinates: coordinates, point: point)
    }
    
    // Проверка равенства двух точек
    static func == (lhs: CornerOnMapValues, rhs: CornerOnMapValues) -> Bool {
        lhs.cornerType == rhs.cornerType && (lhs as PointOnMapValues) == (rhs as PointOnMapValues)
    }
}
