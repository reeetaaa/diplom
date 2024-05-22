//
//  GeoType.swift
//  PaperMap
//
//  Created by Margarita Babukhadia on 10/10/23.
//  Copyright © 2023 Margarita Babukhadia. All rights reserved.
//

import Foundation

// Коллекция  различных перечислений (enumeration)

//
enum GeoType {
    case latitude
    case longitude
}

enum Semisphare : Int, CustomStringConvertible {
    case N = 1
    case S = -1
    case E = 2
    case W = -2
    
    var sign : Int {
        return self.rawValue / abs(self.rawValue)
    }
    
    var description: String {
        return self == Semisphare.N ? "С" :
            self == Semisphare.S ? "Ю" :
            self == Semisphare.E ? "В" : "З"
    }
}

enum CornerType : String, CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case NW = "↖️"
    case NE = "↗️"
    case SE = "↘️"
    case SW = "↙️"
    
    case center
    
    var opposite: CornerType {
        switch self {
        case .NE:
            return .SW
        case .NW:
            return .SE
        case .SE:
            return .NW
        case .SW:
            return .NE
        case .center:
            return .center
        }
    }
    
    var semisphares: [Semisphare] {
        switch self {
        case .NE:
            return [.N, .E]
        case .NW:
            return [.N, .W]
        case .SE:
            return [.S, .E]
        case .SW:
            return [.S, .W]
        case .center:
            return []
        }
    }
    
    var anotherCornerWIthSameLatName: CornerType {
        switch self {
        case .NW:
            return .NE
        case .NE:
            return .NW
        case .SE:
            return .SW
        case .SW:
            return .SE
        case .center:
            return .center
        }
    }
    
    var anotherCornerWithSameLongName: CornerType {
        switch self {
        case .NW:
            return .SW
        case .NE:
            return .SE
        case .SE:
            return .NE
        case .SW:
            return .NW
        case .center:
            return .center
        }
    }
}

enum SettingPointMode {
    case showingButtons(CornerType?) // CornerType это визуальная прокрутка карты до положения по умолчанию
    case editingCornerCoordinates(CornerType?)
    case viewingCornerCoordinates(CornerType?)
    
    func getCornerType() -> CornerType? {
        let cornerType: CornerType?
        switch self {
        case .showingButtons(let cT):
            cornerType = cT
        case .editingCornerCoordinates(let cT):
            cornerType = cT
        case .viewingCornerCoordinates(let cT):
            cornerType = cT
        }
        return cornerType
    }
}

public enum PointSideFromLine {
    case onTheLine
    case toTheLeft
    case toTheRight
    case above
    case below
}

public enum RectCorner {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
}


