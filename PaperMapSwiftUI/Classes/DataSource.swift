//
//  DataSource.swift
//  PaperMap
//
//  Created by Margarita Babukhadia on 25/09/23.
//  Copyright © 2023 Margarita Babukhadia. All rights reserved.
//

import Foundation
import SwiftUI

// Класс для хранения данных (Singleton)
class DataSource {
    
    private(set) static var instance = DataSource()
    
    private init() {}
    
    var mapImage: Image? // Изображение карты
    
    var coordinateType = GeoCoordinate.GeoCoordinateType.minDecimals(1) // Тип координат
    
}
