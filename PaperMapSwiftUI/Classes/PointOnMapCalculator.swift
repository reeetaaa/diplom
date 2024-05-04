//
//  DeltaCounter.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 17/11/23.
//

import Foundation
import MapKit

// Калькулятор расчетов на линии
struct PointOnTheLineCalculator {
    
    private struct LockedPoint {
        private(set) var geoPos: GeoCoordinates // Координаты позиции точки на карте (широта, долгота)
        private(set) var point: CGPoint // Координаты x, y на изображении карты
    }
    
    private var point1: LockedPoint
    private var point2: LockedPoint
    
    private var geoPosToCount: GeoCoordinates = .zero
    private var pointToGet: CGPoint = .zero
    
    init?(pointSetting1: PointOnMapValues?, pointSetting2: PointOnMapValues?) {
        guard let pointSetting1 = pointSetting1, let pointSetting2 = pointSetting2 else {
            return nil
        }
        guard pointSetting1.coordinates != nil, pointSetting2.coordinates != nil,
              pointSetting1.pointOnMap != nil, pointSetting2.pointOnMap != nil else {
            return nil
        }
        
        self.point1 = LockedPoint(geoPos: pointSetting1.coordinates!, point: pointSetting1.pointOnMap!)
        self.point2 = LockedPoint(geoPos: pointSetting2.coordinates!, point: pointSetting2.pointOnMap!)
    }
    
    // Рассчитанная точка
    private var pointCalculated: PointOnMapValues {
        PointOnMapValues(coordinates: geoPosToCount, point: pointToGet)
    }
    
    // Рассчитать точку с координатами и x, y по переданной широте на линии point1, point2
    public mutating func countPointFromLat(lat: GeoCoordinate) -> PointOnMapValues {
        geoPosToCount.lat = lat
        
        let k = (geoPosToCount.lat.coordInRad - point1.geoPos.lat.coordInRad) / (point2.geoPos.lat.coordInRad - point1.geoPos.lat.coordInRad)
        
        pointToGet.x = point1.point.x + (point2.point.x - point1.point.x) * k
        pointToGet.y = point1.point.y + (point2.point.y - point1.point.y) * k
        
        geoPosToCount.long.coordInRad = point1.geoPos.long.coordInRad + (point2.geoPos.long.coordInRad - point1.geoPos.long.coordInRad) * k
        return pointCalculated
    }
    
    // Рассчитать точку с координатами и x, y по переданной долготе на линии point1, point2
    public mutating func countPointFromLong(long: GeoCoordinate) -> PointOnMapValues {
        geoPosToCount.long = long
        
        let k = (tan(geoPosToCount.long.coordInRad) - tan(point1.geoPos.long.coordInRad)) / (tan(point2.geoPos.long.coordInRad) - tan(point1.geoPos.long.coordInRad))
        
        pointToGet.x = point1.point.x + (point2.point.x - point1.point.x) * k
        pointToGet.y = point1.point.y + (point2.point.y - point1.point.y) * k
        
        geoPosToCount.lat.coordInDeg = point1.geoPos.lat.coordInDeg + (point2.geoPos.lat.coordInDeg - point1.geoPos.lat.coordInDeg) * k
        return pointCalculated
    }
}

// Калькулятор расчетов на карте
class PointOnMapCalculator {
    
    fileprivate var corners: [CornerType: CornerOnMapValues]
    
    init(corners: [CornerType: CornerOnMapValues]) {
        self.corners = corners
    }
    
    // По координатам углов изображения карты и переданной позиции широты и долготы найти x, y
    func getPointFrom(geoPos: GeoCoordinates) -> PointOnMapValues? {
        if geoPos.isZero {
            return nil
        }
        
        // Получение калькулятора по нижней линии карты
        guard var deltaCounterOfLowerEdge = PointOnTheLineCalculator(pointSetting1: corners[.SW], pointSetting2: corners[.SE]) else {
            return nil
        }
        
        // По заданной долготе найти точку на нижней линии карты
        let pointOnLowerEdge = deltaCounterOfLowerEdge.countPointFromLong(long: geoPos.long)
        
        // Получение калькулятора по верхней линии карты
        guard var deltaCounterOfUpperEdge = PointOnTheLineCalculator(pointSetting1: corners[.NW], pointSetting2: corners[.NE]) else {
            return nil
        }
        
        // По заданной долготе найти точку на верхней линии карты
        let pointOnUpperEdge = deltaCounterOfUpperEdge.countPointFromLong(long: geoPos.long)
        
        // Получение калькулятора, который соединяет найденные линии
        guard var deltaCounterOfFinalPoint = PointOnTheLineCalculator(pointSetting1: pointOnLowerEdge, pointSetting2: pointOnUpperEdge) else {
            return nil
        }
        
        // Получение точки на этой линии
        let point = deltaCounterOfFinalPoint.countPointFromLat(lat: geoPos.lat)
        
        return point
    }
    
    // По координатам углов изображения карты и переданной точки на карте найти координаты
    func getCoordinatesFrom(point: CGPoint) -> GeoCoordinates? {
        if point == .zero {
            return nil
        }
        
        guard var deltaCounterOfLowerEdge = PointOnTheLineCalculator(pointSetting1: corners[.SW], pointSetting2: corners[.SE]),
              var deltaCounterOfUpperEdge = PointOnTheLineCalculator(pointSetting1: corners[.NW], pointSetting2: corners[.NE]),
              var deltaCounterOfLeftEdge = PointOnTheLineCalculator(pointSetting1: corners[.SW], pointSetting2: corners[.NW]),
              var deltaCounterOfRightEdge = PointOnTheLineCalculator(pointSetting1: corners[.SE], pointSetting2: corners[.NE]) else {
            return nil
        }
        
        guard var upperLeftCoord1 = corners[.NW]?.coordinates,
              var upperRightCoord1 = corners[.NE]?.coordinates,
              var lowerLeftCoord1 = corners[.SW]?.coordinates,
              var lowerRightCoord1 = corners[.SE]?.coordinates,
              var upperLeftCoord2 = corners[.NW]?.coordinates,
              var upperRightCoord2 = corners[.NE]?.coordinates,
              var lowerLeftCoord2 = corners[.SW]?.coordinates,
              var lowerRightCoord2 = corners[.SE]?.coordinates else {
            return nil
        }
        
        // Нахождение долготы точки
        var foundLong: GeoCoordinate? = nil
        // 1 градус = 60 морских миль, 1 морская миля = 1852 метра
        let findingError = 0.00001 // погрешность в градусов (примерно 1.1м)
        while true {
            // Середины двух точек (сверху и снизу)
            let lowerCurrentPoint = lowerLeftCoord1 ~~ lowerRightCoord1
            let upperCurrentPoint = upperLeftCoord1 ~~ upperRightCoord1
            
            // Прямая по двум точкам, которые являются серединами двух точек (сверху и снизу)
            let currPointValuesInLowerEdge: PointOnMapValues = deltaCounterOfLowerEdge.countPointFromLong(long: lowerCurrentPoint.long)
            let currPointValuesInUpperEdge: PointOnMapValues = deltaCounterOfUpperEdge.countPointFromLong(long: upperCurrentPoint.long)
            
            // Указатель на то, с какой стороны находится точка относительно прямой
            let pointSide = point.getPointSideToTheLineHorisintaly(startOfLine: currPointValuesInLowerEdge.pointOnMap!,
                                                                   endOfLine: currPointValuesInUpperEdge.pointOnMap!)
            
            if (pointSide == .toTheRight) { // Наша линия находится с правой стороны
                lowerRightCoord1 = currPointValuesInLowerEdge.coordinates!
                upperRightCoord1 = currPointValuesInUpperEdge.coordinates!
            } else if (pointSide == .toTheLeft) {
                lowerLeftCoord1 = currPointValuesInLowerEdge.coordinates!
                upperLeftCoord1 = currPointValuesInUpperEdge.coordinates!
            }
            
            if pointSide == .onTheLine || abs(lowerRightCoord1.long.coordInDeg - lowerLeftCoord1.long.coordInDeg) < findingError {
                // Точка найдена
                foundLong = currPointValuesInLowerEdge.coordinates!.long
                break
            }
        }
        
        // Нахождение широты точки
        var foundLat: GeoCoordinate? = nil
        while true {
            let leftCurrentPoint = lowerLeftCoord2 ~~ upperLeftCoord2
            let rightCurrentPoint = lowerRightCoord2 ~~ upperRightCoord2
            
            let currPointValuesInLeftEdge: PointOnMapValues = deltaCounterOfLeftEdge.countPointFromLat(lat: leftCurrentPoint.lat)
            let currPointValuesInRightEdge: PointOnMapValues = deltaCounterOfRightEdge.countPointFromLat(lat: rightCurrentPoint.lat)
            
            let pointSide = point.getPointSideToTheLineVerticaly(startOfLine: currPointValuesInLeftEdge.pointOnMap!,
                                                                 endOfLine: currPointValuesInRightEdge.pointOnMap!)
            
            if (pointSide == .above) { // Наша линия находится с правой стороны
                lowerLeftCoord2 = currPointValuesInLeftEdge.coordinates!
                lowerRightCoord2 = currPointValuesInRightEdge.coordinates!
            } else if (pointSide == .below) {
                upperLeftCoord2 = currPointValuesInLeftEdge.coordinates!
                upperRightCoord2 = currPointValuesInRightEdge.coordinates!
            }
            
            if pointSide == .onTheLine || abs(lowerLeftCoord2.lat.coordInDeg - upperLeftCoord2.lat.coordInDeg) < findingError {
                // Точка найдена
                foundLat = currPointValuesInLeftEdge.coordinates!.lat
                break
            }
        }
        
        guard let foundLat = foundLat,
              let foundLong = foundLong else {
            return nil
        }
        return GeoCoordinates(lat: foundLat, long: foundLong)
    }
}

// Определение масштаба для встроенной карты
class MapSpanCalculator: PointOnMapCalculator {
    
    func getSpanFrom(deltaX: CGFloat, deltaY: CGFloat) -> MKCoordinateSpan? {
        if let leftLower = corners[CornerType.SW],
           let leftLowerPoint = leftLower.pointOnMap,
           let leftLowerCoord = leftLower.coordinates {
            let newPoint = CGPoint(x: leftLowerPoint.x + deltaX,
                                   y: leftLowerPoint.y - deltaY)
            
            if let newCoord = getCoordinatesFrom(point: newPoint) {
                return MKCoordinateSpan(latitudeDelta: abs(leftLowerCoord.lat.coordInDeg - newCoord.lat.coordInDeg),
                                        longitudeDelta: abs(leftLowerCoord.long.coordInDeg - newCoord.long.coordInDeg))
            }
        }
        return nil
    }
    
}
