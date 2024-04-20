//
//  MainPageModel.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 16/10/23.
//

import Foundation
import SwiftUI
import CoreLocation

class PointOnMapValues {
    fileprivate(set) var coordinates: GeoCoordinates?
    fileprivate(set) var pointOnMap: CGPoint?
    
    init() {}
    
    init(coordinates: GeoCoordinates) {
        self.coordinates = coordinates
    }
    
    init(coordinates: GeoCoordinates, point: CGPoint) {
        self.coordinates = coordinates
        self.pointOnMap = point
    }
    
    static func == (lhs: PointOnMapValues, rhs: PointOnMapValues) -> Bool {
        lhs.coordinates == rhs.coordinates && lhs.pointOnMap == rhs.pointOnMap
    }
    
    var isSet: Bool {
        coordinates != nil && pointOnMap != nil
    }
}

class CornerOnMapValues: PointOnMapValues, Identifiable {
    var id: String { cornerType.rawValue }
    var cornerType: CornerType
    
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
    
    static func == (lhs: CornerOnMapValues, rhs: CornerOnMapValues) -> Bool {
        lhs.cornerType == rhs.cornerType && (lhs as PointOnMapValues) == (rhs as PointOnMapValues)
    }
}

struct MyAppLogic {
    
    var locationDataManager = LocationDataManager()
    
    var lastSavedCoord: CLLocationCoordinate2D?
    
    var correctionMyCoordinates: GeoCoordinates?
    var correctionRealCoordinates: GeoCoordinates?
    
    var mapCorrection = GeoCoordinates()
    
    private(set) var corners: [CornerType: CornerOnMapValues] =
    [.NW: CornerOnMapValues(cornerType: .NW),
     .NE: CornerOnMapValues(cornerType: .NE),
     .SW: CornerOnMapValues(cornerType: .SW),
     .SE: CornerOnMapValues(cornerType: .SE)
    ]
    
    mutating func deleteCoordinatesAndPointOnMap(at cornerType: CornerType) {
        corners[cornerType]?.coordinates = nil
        corners[cornerType]?.pointOnMap = nil
    }
    
    mutating func setCoordinates(to cornerType: CornerType, coordinates: GeoCoordinates) {
        corners[cornerType]?.coordinates = coordinates
    }
    
    func getCornerOnMapValues(of cornerType: CornerType) -> CornerOnMapValues? {
        corners[cornerType]
    }
    
    
    func getCoordinates(of cornerType: CornerType) -> GeoCoordinates? {
        corners[cornerType]?.coordinates
    }
    
    func getPointOnMap(of cornerType: CornerType) -> CGPoint? {
        corners[cornerType]?.pointOnMap
    }
    
    mutating func setPointOnMap(to cornerType: CornerType, point: CGPoint) {
        corners[cornerType]?.pointOnMap = point
    }
    
    func getIsOn(of cornerType: CornerType) -> Bool {
        corners[cornerType]!.isSet
    }
    
    func getCorrectionMyCoordinates() -> GeoCoordinates? {
        correctionMyCoordinates
    }
    
    func getCorrectionRealCoordinates() -> GeoCoordinates? {
        correctionRealCoordinates
    }
}
