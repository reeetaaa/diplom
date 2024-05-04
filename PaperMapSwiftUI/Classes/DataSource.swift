//
//  DataSource.swift
//  PaperMap
//
//  Created by Margarita Babukhadia on 25/09/23.
//  Copyright © 2023 Margarita Babukhadia. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation

// Класс для хранения данных (Singleton)
class DataSource {
    
    private(set) static var instance = DataSource()
    
    private init() {}
    
    var mapImage: Image? // Изображение карты
    
    var coordinateType = GeoCoordinate.GeoCoordinateType.minDecimals(1) // Тип координат
    
    private(set) var corners: [CornerType: CornerOnMapValues] =  // Координаты углов изображения карты
        [.NW: CornerOnMapValues(cornerType: .NW),
         .NE: CornerOnMapValues(cornerType: .NE),
         .SW: CornerOnMapValues(cornerType: .SW),
         .SE: CornerOnMapValues(cornerType: .SE)
        ]
    
    var mapCorrection = GeoCoordinates() // Коррекция карты по широте и долготе
    
    var lastSavedCoord: CLLocationCoordinate2D?  // Координаты местоположения пользователя
}
