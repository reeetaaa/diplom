//
//  GeoCoordinate.swift
//  PaperMap
//
//  Created by Margarita Babukhadia on 18/09/23.
//  Copyright © 2023 Margarita Babukhadia. All rights reserved.
//

import Foundation
import CoreLocation

// Хранение одной координаты
struct GeoCoordinate: Equatable {
    
    // Типы координаты
    enum GeoCoordinateType: Equatable {
        //3.1234° (погрешность ~11m); 3.12345° (погрешность ~1.1m)
        case degDecimals(Int) // Сколько знаков после запятой для градусов
        
        //3°22.11' (погрешность ~19m); 3°22.111' (погрешность ~1.9m)
        case minDecimals(Int) // Сколько знаков после запятой для минут
        
        //3°22'11" (погрешность ~30m); 3°22'11.1" (погрешность ~3m)
        case secDecimals(Int) // Сколько знаков после запятой для секунд
        
        // Функция для сравнения типов координаты (равно)
        static func == (lhs: GeoCoordinateType, rhs: GeoCoordinateType) -> Bool {
            switch (lhs, rhs) {
                case (let .degDecimals(a1), let .degDecimals(a2)):
                    return a1 == a2
                case (let .minDecimals(a1), let .minDecimals(a2)):
                    return a1 == a2
                case (let .secDecimals(a1), let .secDecimals(a2)):
                    return a1 == a2
                default:
                    return false
            }
        }
        
        // Функция для сравнения типов координаты (не равно)
        static func != (lhs: GeoCoordinateType, rhs: GeoCoordinateType) -> Bool {
            !(lhs == rhs)
        }
    }
    
    private static var sZero: GeoCoordinate? // Нулевая координата
    
    public static var zero: GeoCoordinate { // Проверка введена координата или нет
        if sZero == nil {
            sZero = GeoCoordinate(coordType: DataSource.instance.coordinateType)
        }
        return sZero!
    }
    
    public var isZero: Bool { // Введена координата или нет
        self.coordInDeg == 0
    }
    
    public var geoCoordType: GeoCoordinateType // Тип координаты
    
    // Хранение координаты в градусах в чистом виде
    // Если это северная широта, то значение положительное, если южное, то отрицательное
    // Если это восточная долгота, то значение положительное, если западная, то отрицательное
    public var coordInDeg: Double = 0.0
    
    public var coordInRad: Double { // Координата в радианах
        get {
            coordInDeg * Double.pi / 180
        }
        set {
            coordInDeg = newValue * 180 / Double.pi
        }
    }
    
    // Положительная координата или отрицательная (северная широта или южная)
    public var isNorthOrEast: Bool {
        get {
            return coordInDeg >= 0
        }
        set(value) {
            coordInDeg = value ? absCoordinate : -absCoordinate
        }
    }
    
    // Абсолютная координата с округлением без знака
    public var absCoordinate: Double {
        get {
            Self.roundByMyType(number: abs(coordInDeg),
                               geoCoordType: self.geoCoordType)
        }
        set(value) {
            coordInDeg = isNorthOrEast ? value : -value
        }
    }
    
    public init(coordType: GeoCoordinateType) {
        geoCoordType = coordType
    }
    
    public init(coordType: GeoCoordinateType, coordInDeg: Double) {
        self.geoCoordType = coordType
        self.coordInDeg = coordInDeg
    }
    
    // Округление координаты с учетом погрешности
    private static func roundByMyType(number: Double,
                                      geoCoordType: GeoCoordinateType) -> Double {
        let roundStep = roundStep(of: geoCoordType)
        return roundBy(number: number, by: roundStep)
    }
    
    // Расчет погрешности
    private static func roundStep(of geoCoordType: GeoCoordinateType) -> Double {
        switch geoCoordType {
            case .degDecimals(let precision):
            return 1.0 / pow(10, precision.doubleValue)
            case .minDecimals(let precision):
                return 1.0 / pow(10, precision.doubleValue) / 60
            case .secDecimals(let precision):
                return 1.0 / pow(10, precision.doubleValue) / 60 / 60
        }
    }
    
    // Округление с нужным шагом
    private static func roundBy(number: Double, by roundStep: Double) -> Double {
        Double(round(number / roundStep)) * roundStep
    }
    
    // Получение целых градусов
    public var deg: Int {
        get {
            return Int(absCoordinate)
        }
        set(value) {
            let newAbs = absCoordinate - Int(absCoordinate).doubleValue + value.doubleValue
            coordInDeg = newAbs * (isNorthOrEast ? 1 : -1)
        }
    }
    
    // Получение целых минут
    public var min: Int {
        get {
            let minsTotal = (absCoordinate - deg.doubleValue) * 60 + 0.00000000001 // 0.00000000001 для избавления от 9 в периоде
            return Int(minsTotal)
        }
        set(value) {
            let newAbs = absCoordinate - min.doubleValue / 60 + value.doubleValue / 60
            coordInDeg = newAbs * (isNorthOrEast ? 1 : -1)
        }
    }
    
    // Получение целых секунд
    public var seconds: Int {
        get {
            if case .secDecimals(let dec) = geoCoordType, dec > 0 { // Если секунды с десятыми, то
                return Int(decimalsOfMinutes * 60 + 0.00000000001) // брать целые значения с избавлением от периода
            } else {
                return Int(round(decimalsOfMinutes * 60)) // Иначе просто округлить
            }
        }
        set(value) {
            let newAbs = absCoordinate - seconds.doubleValue / 60 / 60 + value.doubleValue / 60 / 60
            coordInDeg = newAbs * (isNorthOrEast ? 1 : -1)
        }
    }
    
    /**
     Установка одной десятичной цифры в нужной позиции в зависимости от типа координаты
     Например:
         Для 41.3333 .degDecimals (at: 1, value: 9) будет 41.9333
         Для 41°43.33' .minDecimals (at: 1, value: 9) будет 41°33.93'
         Для 41°43'44.33" .minDecimals (at: 1, value: 9) будет 41°43'44.93"
     */
    public mutating func setDecimal(at index: Int, value: Int) {
        guard index > 0 else {
            print("Ошибка: setDecimal index должен быть больше 0")
            return
        }
        switch geoCoordType {
            case .degDecimals(let dec):
                guard index <= dec else {
                    print("Ошибка: setDecimal index больше чем количество десятых")
                    return
                }
                decimalsOfDegrees = Self.changeDecimal(in: decimalsOfDegrees,
                                                       at: index,
                                                       value: value,
                                                       geoCoordType: self.geoCoordType)
            case .minDecimals(let dec):
                guard index <= dec else {
                    print("Ошибка: setDecimal index больше чем количество десятых")
                    return
                }
                decimalsOfMinutes = Self.changeDecimal(in: decimalsOfMinutes,
                                                       at: index,
                                                       value: value, geoCoordType: self.geoCoordType)
            case .secDecimals(let dec):
                guard index <= dec else {
                    print("Ошибка: setDecimal index больше чем количество десятых")
                    return
                }
                decimalsOfSeconds = Self.changeDecimal(in: decimalsOfSeconds,
                                                       at: index,
                                                       value: value,
                                                       geoCoordType: self.geoCoordType)
        }
    }
    
    /**
     Получает значение меньше 1 (десятичная часть числа, например: 0.33333) и меняет число в определенной позиции
     (in: 0.33333, at: 2, value: 9) вернет 0.39333
     */
    private static func changeDecimal(in decimals: Double, 
                                      at index: Int,
                                      value: Int,
                                      geoCoordType: GeoCoordinateType) -> Double {
        
        guard decimals >= 0 && decimals < 1 else {
            print("Ошибка: changeDecimal изменяемое значение должно быть в диапазоне [0;1): \(decimals)")
            return decimals
        }
        
        guard value >= 0 && value <= 9 else {
            print("Ошибка: changeDecimal целое число изменяемое в значении должно быть в диапазоне [0;9]: \(value)")
            return decimals
        }
        
        // decimals = 0.56789, index = 2, value = 3
        let multiplier = pow(10, index).doubleValue // = 100
        let decimalsRounded = Self.roundByMyType(number: decimals,
                                                 geoCoordType: geoCoordType)
        let numberSearching = decimalsRounded * multiplier // 56.789
        let foundNumber = Int(numberSearching) - Int(numberSearching / 10) * 10 // 56 - 50 = 6
        let foundRealNumber = foundNumber.doubleValue / multiplier // 0.06
        let numberToReplace = value.doubleValue / multiplier // 0.03
        let result = decimalsRounded - foundRealNumber + numberToReplace // 0.53789000000000004
        let err = 100000000000.0
        return Int(result * err).doubleValue / err // 0.53789
    }
    
    // Получение десятичной части для градусов
    public var decimalsOfDegrees: Double {
        get {
            let result = absCoordinate - Int(absCoordinate).doubleValue
            if case .degDecimals(let dec) = geoCoordType {
                let multiplier = pow(10, dec).doubleValue
                return round(result * multiplier) / multiplier
            }
            return result
        }
        set(value) {
            absCoordinate = Int(absCoordinate).doubleValue + value
        }
    }
    
    // Найти число в десятичной части градусов по позиции
    public func getDecimalsOfDegreesDigit(at index: Int) -> Int {
        getDecimal(of: decimalsOfDegrees, at: index)
    }
    
    // Установка определенного числа по позиции в десятичной части для градусов
    public mutating func setDecimalsOfDegreesDigit(at index: Int, newDigit: Int) {
        decimalsOfDegrees = changeDecimal(of: decimalsOfDegrees, at: index, to: newDigit)
    }
    
    // Получение десятичной части для минут
    public var decimalsOfMinutes: Double {
        get {
            let result = absCoordinate * 60 - deg.doubleValue * 60 - min.doubleValue
            if case .minDecimals(let dec) = geoCoordType {
                let multiplier = pow(10, dec).doubleValue
                return round(result * multiplier) / multiplier
            }
            return result
        }
        set(value) {
            absCoordinate = absCoordinate - decimalsOfMinutes / 60 + value / 60
        }
    }
    
    // Найти число в десятичной части минут по позиции
    public func getDecimalsOfMinutesDigit(at index: Int) -> Int {
        getDecimal(of: decimalsOfMinutes, at: index)
    }
    
    // Установка определенного числа по позиции в десятичной части для минут
    public mutating func setDecimalsOfMinutesDigit(at index: Int, newDigit: Int) {
        decimalsOfMinutes = changeDecimal(of: decimalsOfMinutes, at: index, to: newDigit)
    }
    
    // Получение десятичной части для секунд
    public var decimalsOfSeconds: Double {
        get { // 41°22'11.6"
            let result = absCoordinate * 60 * 60 - deg.doubleValue * 60 * 60 - min.doubleValue * 60 - seconds.doubleValue
            if case .secDecimals(let dec) = geoCoordType {
                let multiplier = pow(10, dec).doubleValue
                return round(result * multiplier) / multiplier
            }
            return result
        }
        set(value) {
            absCoordinate = absCoordinate - decimalsOfSeconds / 60 / 60 + value / 60 / 60
        }
    }
    
    // Найти число в десятичной части секунд по позиции
    public func getDecimalsOfSecondsDigit(at index: Int) -> Int {
        getDecimal(of: decimalsOfSeconds, at: index)
    }
    
    // Установка определенного числа по позиции в десятичной части для секунд
    public mutating func setDecimalsOfSecondsDigit(at index: Int, newDigit: Int) {
        decimalsOfSeconds = changeDecimal(of: decimalsOfSeconds, at: index, to: newDigit)
    }
    
    // Найти число в определенной позиции в десятичной части числа
    private func getDecimal(of value: Double, at index: Int) -> Int {
        Int(value * pow(10, index + 1).doubleValue) % 10
    }
    
    // Поменять число в определенной позиции в десятичной части числа
    private func changeDecimal(of value: Double, at index: Int, to newDigit: Int) -> Double {
        let powerOf10 = pow(10, index + 1).doubleValue
        let poweredValue = value * powerOf10
        let oldDigit = Int(poweredValue) % 10
        let res = (poweredValue + (-oldDigit + newDigit).doubleValue) / powerOf10
        return res
    }
    
    // Вывод координат в зависимости от выбранного типа координат
    func getString(isLatitude: Bool) -> String {
        let absCoord = absCoordinate
        if absCoord == 0 {
            return "-"
        }
        
        var result = ""
        
        let digits = isLatitude ? 2 : 3; // Для широты 2 числа для градусов, для долготы - 3
        
        switch geoCoordType {
            case .degDecimals(let precision):
                result = String(format: "%0\(digits+precision).\(precision)f°", absCoord)
            case .minDecimals(let precision):
                let x = precision == 0 ? 2 : 3
                result = String(format: "%0\(digits)d°%0\(x+precision).\(precision)f'", deg, min.doubleValue + decimalsOfMinutes)
            case .secDecimals(let precision):
                result = String(format: "%0\(digits)d°%02d'", deg, min)
                   + (precision == 0
                        ? String(format: "%02d\"", seconds)
                        : String(format: "%0\(3+precision).\(precision)f\"", seconds.doubleValue + decimalsOfSeconds))
        }
        
        result += isLatitude ? (isNorthOrEast ? "С": "Ю") : (isNorthOrEast ? "В": "З")
        
        return result
    }
    
    // Сложение двух координат
    public static func + (lhs: GeoCoordinate, rhs: GeoCoordinate) -> GeoCoordinate {
        GeoCoordinate(coordType: lhs.geoCoordType, coordInDeg: lhs.coordInDeg + rhs.coordInDeg)
    }

}

// Хранение координат
struct GeoCoordinates: Equatable {
    
    private static var sZero: GeoCoordinates?
    public static var zero: GeoCoordinates {
        if sZero == nil {
            sZero = GeoCoordinates()
        }
        return sZero! 
    }
    public var isZero: Bool {
        self.lat.isZero && self.long.isZero
    }
    
    private var settingNow: Bool = false
    
    public var lat: GeoCoordinate { // Широта (latitude)
        didSet {
            if !settingNow {
                settingNow = true
                long.geoCoordType = lat.geoCoordType
                settingNow = false
            }
        }
    }
    public var long: GeoCoordinate { // Долгота (longitude)
        didSet {
            if !settingNow {
                settingNow = true
                lat.geoCoordType = long.geoCoordType
                settingNow = false
            }
        }
    }
    
    public init() {
        self.init(coordType: .minDecimals(3))
    }
    
    public init(coordType: GeoCoordinate.GeoCoordinateType) {
        lat = GeoCoordinate(coordType: coordType)
        long = GeoCoordinate(coordType: coordType)
        geoCoordType = coordType
    }
    
    public init(lat: GeoCoordinate, long: GeoCoordinate) {
        self.lat = lat
        self.long = long
        geoCoordType = lat.geoCoordType
    }
    
    public init(coordType: GeoCoordinate.GeoCoordinateType, lat: Double, long: Double) {
        self.lat = GeoCoordinate(coordType: coordType, coordInDeg: lat)
        self.long = GeoCoordinate(coordType: coordType, coordInDeg: long)
        geoCoordType = coordType
    }
    
    public init(from coord: CLLocationCoordinate2D, coordType: GeoCoordinate.GeoCoordinateType) {
        self.lat = GeoCoordinate(coordType: coordType, coordInDeg: coord.latitude)
        self.long = GeoCoordinate(coordType: coordType, coordInDeg: coord.longitude)
        geoCoordType = coordType
    }
    
    public init(from coord2D: CLLocationCoordinate2D) {
        geoCoordType = .minDecimals(3)
        self.lat = GeoCoordinate(coordType: geoCoordType, coordInDeg: coord2D.latitude)
        self.long = GeoCoordinate(coordType: geoCoordType, coordInDeg: coord2D.longitude)
    }
    
    // Переключение типа координат и у широты, и у долготы
    public var geoCoordType: GeoCoordinate.GeoCoordinateType {
        didSet {
            lat.geoCoordType = geoCoordType
            long.geoCoordType = geoCoordType
        }
    }
    
    // Получить широту в текстовом формате
    private func getLatStr() -> String {
        return lat.getString(isLatitude: true)
    }
    
    // Получить долготу в текстовом формате
    private func getLongStr() -> String {
        return long.getString(isLatitude: false)
    }
    
    // Получить координаты в текстовом формате
    func getCoordinatesString(separator: String = "\n") -> String {
        return getLatStr() +
                separator +
                getLongStr()
    }
    
    // Сложение координат
    static func + (lhs: GeoCoordinates, rhs: GeoCoordinates) -> GeoCoordinates {
        let latInDeg = lhs.lat.coordInDeg + rhs.lat.coordInDeg
        var longInDeg = lhs.long.coordInDeg + rhs.long.coordInDeg
        
        if longInDeg > 180 {
            longInDeg -= 360
        } else if longInDeg < -180 {
            longInDeg += 360
        }
        
        return GeoCoordinates(coordType: lhs.geoCoordType, lat: latInDeg, long: longInDeg)
    }
    
    // Вычитание координат
    static func - (lhs: GeoCoordinates, rhs: GeoCoordinates) -> GeoCoordinates {
        let latInDeg = lhs.lat.coordInDeg - rhs.lat.coordInDeg
        
        var longInDeg = lhs.long.coordInDeg - rhs.long.coordInDeg
        if longInDeg > 180 {
            longInDeg -= 360
        } else if longInDeg < -180 {
            longInDeg += 360
        }
        
        return GeoCoordinates(coordType: lhs.geoCoordType, lat: latInDeg, long: longInDeg)
    }
    
    // Деление координат на заданное число
    static func / (coord: GeoCoordinates, divider: CGFloat) -> GeoCoordinates {
        GeoCoordinates(coordType: coord.geoCoordType, lat: coord.lat.coordInDeg / divider, long: coord.long.coordInDeg / divider)
    }
    
    // Вычиследние среднего значения с помощью собственного оператора (~~)
    static func ~~ (lC: GeoCoordinates, rC: GeoCoordinates) -> GeoCoordinates {
        lC + (rC - lC) / 2
    }
    
    // Сравнивание координат
    static func == (lhs: GeoCoordinates, rhs: GeoCoordinates) -> Bool {
        lhs.lat == rhs.lat && lhs.long == rhs.long
    }
}

// Расширение для вычисления внутренних координат
extension CLLocationCoordinate2D {
    // Вывод координат в виде строки
    func getCoordinatesString(coordType: GeoCoordinate.GeoCoordinateType, separator: String = "\n") -> String {
        let geoCoord = GeoCoordinates(coordType: coordType, lat: self.latitude, long: self.longitude)
        return geoCoord.getCoordinatesString(separator: separator)
    }
}
