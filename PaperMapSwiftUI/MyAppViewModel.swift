//
//  MainPageViewModel.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 16/10/23.
//

import Foundation
import SwiftUI
import CoreLocation

class MyAppViewModel {
    
    static public var instance = MyAppViewModel()
    
    private var model: MyAppLogic = MyAppLogic()
    
    private init() {}
    
    var lastSavedCoord: CLLocationCoordinate2D? {
        get {
            model.lastSavedCoord
        }
        set {
            model.lastSavedCoord = newValue
        }
    }
    
    // MARK: - Access to the model
    
    
    
    func getCornersArr() -> [CornerOnMapValues] {
        [model.corners[.NW]!, model.corners[.NE]!, model.corners[.SW]!, model.corners[.SE]!]
    }
    
    func getCorners() -> [CornerType: CornerOnMapValues] {
        model.corners
    }
    
    func areCornersSet() -> Bool {
        for corner in getCornersArr() {
            if !corner.isSet {
                return false
            }
        }
        return true
    }
    
    // MARK: - Intents
    
    func selectMapImage(image: Image?) {
        DataSource.instance.mapImage = image
    }
    
    func getCornerOnMapValues(of cornerType: CornerType) -> CornerOnMapValues? {
        model.getCornerOnMapValues(of: cornerType)
    }
    
    func getCoordinates(of cornerType: CornerType) -> GeoCoordinates? {
        model.getCoordinates(of: cornerType)
    }
    
    func isLocked(of cornerType: CornerType) -> Bool {
        model.getCoordinates(of: cornerType) != nil
    }
    
    func setCoordinates(to cornerType: CornerType, coordinates: GeoCoordinates) {
        model.setCoordinates(to: cornerType, coordinates: coordinates)
    }
    
    func deleteCoordinatesAndPointOnMap(at cornerType: CornerType) {
        model.deleteCoordinatesAndPointOnMap(at: cornerType)
    }
    
    func getPointOnMap(of cornerType: CornerType) -> CGPoint? {
        model.getPointOnMap(of: cornerType)
    }
    
    func setPointOnMap(of cornerType: CornerType, point: CGPoint) {
        model.setPointOnMap(to: cornerType, point: point)
    }
    
    func getLocationDataManager() -> LocationDataManager {
        model.locationDataManager
    }
    
    func getCorrectionMyCoordinates() -> GeoCoordinates? {
        model.getCorrectionMyCoordinates()
    }
    
    func getCorrectionRealCoordinates() -> GeoCoordinates? {
        model.getCorrectionRealCoordinates()
    }
    
    func setMapCorrection(_ corr: GeoCoordinates) {
        model.mapCorrection = corr
    }
    
    func getMapCorrection() -> GeoCoordinates {
        return model.mapCorrection
    }
}
