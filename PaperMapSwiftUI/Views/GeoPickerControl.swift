//
//  GeoPickerControl.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 10/10/23.
//

import SwiftUI

// Окно выставления координат
struct GeoPickerControl: View {
    
    var geoType: GeoType // Тип координаты
    @Binding var coordinate: GeoCoordinate // Переданная координата
    
    @State private var selectedDeg: Int = 0 // Выставленные градусы
    @State private var selectedMin: Int = 0 // Выставленные минуты
    @State private var selectedSec: Int = 0 // Выставленные секунды
    @State private var selectedDecimals: [Int] = Array(repeating: 0, count: 7) // Десятичная часть последней части координат
    
    @State private var geoLetter: GeoLetter = GeoLetter(multiplier: 1, letter: "С") // Отображение частей света
    
    // Структура для контроля частей света
    private struct GeoLetter: Hashable {
        var multiplier: Int
        var letter: String
    }
    
    private let latLetters = [GeoLetter(multiplier: 1, letter: "С"), // Положительный - север
                              GeoLetter(multiplier: -1, letter: "Ю")] // Отрицательный - юг
    private let longLetters = [GeoLetter(multiplier: 1, letter: "В"), // Положительный - восток
                               GeoLetter(multiplier: -1, letter: "З")] // Отрицательный - запад
    
    var body: some View {
        HStack {
            let maxDeg = geoType == .latitude ? 90 : 180 // Максимальное количество градусов
            let frameWidthFor2 = 80.0
            let frameWidthFor1 = 50.0
            let padding = -10.0
            
            // Колесо выбора для градусов
            Picker("", selection: $selectedDeg) {
                ForEach((0..<maxDeg).reversed(), id: \.self) { t in
                    Text(String(format: "%0\(geoType == .latitude ? 2 : 3)d", t))
                }
            }
            .pickerStyle(.wheel)
            .frame(width: frameWidthFor2)
            .padding(padding)
            .onChange(of: selectedDeg) { // https://www.hackingwithswift.com/books/ios-swiftui/responding-to-state-changes-using-onchange
                coordinate.deg = selectedDeg
            }
            .onAppear {
                selectedDeg = coordinate.deg
            }
            
            
            switch coordinate.geoCoordType {
                case .degDecimals(let dec):
                    if dec > 0 {
                        // Если надо показывать градусы с десятичной частью
                        Text(".").font(.title).padding(-5)
                        ForEach(0..<dec, id:\.self) { i in
                            Picker("", selection: $selectedDecimals[i]) {
                                ForEach((0..<10).reversed(), id: \.self) { t in
                                    Text(String(format: "%01d", t))
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: frameWidthFor1)
                            .padding(padding)
                            .onChange(of: selectedDecimals[i]) {
                                coordinate.setDecimalsOfDegreesDigit(at: i, newDigit: selectedDecimals[i])
                            }
                            .onAppear {
                                selectedDecimals[i] = coordinate.getDecimalsOfDegreesDigit(at: i)
                            }
                        }
                    }
                    Text("°").font(.title)
                case .minDecimals(let dec):
                    // Колесо выбора для минут
                    Text("°").font(.title)
                    
                    Picker("", selection: $selectedMin) {
                        ForEach((0..<60).reversed(), id: \.self) { t in
                            Text(String(format: "%02d", t))
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: frameWidthFor2)
                    .padding(padding)
                    .onChange(of: selectedMin) {
                        coordinate.min = selectedMin
                    }
                    .onAppear {
                        selectedMin = coordinate.min
                    }
                    
                    
                    if dec > 0 {
                        // Если надо показывать минуты с десятичной частью
                        Text(".").font(.title).padding(-5)
                        ForEach(0..<dec, id:\.self) { i in
                            Picker("", selection: $selectedDecimals[i]) {
                                ForEach((0..<10).reversed(), id: \.self) { t in
                                    Text(String(format: "%01d", t))
                                }
                            }
                           .pickerStyle(.wheel)
                           .frame(width: frameWidthFor1)
                           .padding(padding)
                           .onChange(of: selectedDecimals[i]) {
                               coordinate.setDecimalsOfMinutesDigit(at: i, newDigit: selectedDecimals[i])
                           }
                           .onAppear {
                               selectedDecimals[i] = coordinate.getDecimalsOfMinutesDigit(at: i)
                           }
                        }
                    }
                    Text("\'").font(.title)
            case .secDecimals(let dec):
                // Колесо выбора для минут
                Text("°").font(.title)
                
                Picker("", selection: $selectedMin) {
                    ForEach((0..<60).reversed(), id: \.self) { t in
                        Text(String(format: "%02d", t))
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: frameWidthFor2)
                .padding(padding)
                .onChange(of: selectedMin) {
                    coordinate.min = selectedMin
                }
                .onAppear {
                    selectedMin = coordinate.min
                }
                
                Text("\'").font(.title)
                
                // Колесо выбора для секунд
                Picker("", selection: $selectedSec) {
                    ForEach((0..<60).reversed(), id: \.self) { t in
                        Text(String(format: "%02d", t))
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: frameWidthFor2)
                .padding(padding)
                .onChange(of: selectedSec) {
                    coordinate.seconds = selectedSec
                }
                .onAppear {
                    selectedSec = coordinate.seconds
                }
                
                if dec > 0 {
                    // Если надо показывать секунды с десятичной частью
                    Text(".").font(.title).padding(-5)
                    ForEach(0..<dec, id:\.self) { i in
                        Picker("", selection: $selectedDecimals[i]) {
                            ForEach((0..<10).reversed(), id: \.self) { t in
                                Text(String(format: "%01d", t))
                            }
                        }
                       .pickerStyle(.wheel)
                       .frame(width: frameWidthFor1)
                       .padding(padding)
                       .onChange(of: selectedDecimals[i]) {
                           coordinate.setDecimalsOfSecondsDigit(at: i, newDigit: selectedDecimals[i])
                       }
                       .onAppear {
                           selectedDecimals[i] = coordinate.getDecimalsOfSecondsDigit(at: i)
                       }
                    }
                }
                Text("\"").font(.title)
            }
        
            // Колесо выбора для частей света
            Picker("", selection: $geoLetter) {
                ForEach(geoType == .latitude ? latLetters : longLetters, id: \.self) { l in
                    Text(l.letter)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: frameWidthFor1)
            .padding(padding)
            .onChange(of: geoLetter) {
                coordinate.isNorthOrEast = geoLetter.multiplier == 1
            }
            .onAppear {
                geoLetter = (geoType == .latitude ? latLetters : longLetters)[coordinate.isNorthOrEast ? 0 : 1]
            }
        }
        .onChange(of: coordinate) { // Когда координата поменалась
            withAnimation { // Установка координат с анимацией
                selectedDeg = coordinate.deg
                selectedMin = coordinate.min
                selectedSec = coordinate.seconds
                geoLetter = (geoType == .latitude ? latLetters : longLetters)[coordinate.isNorthOrEast ? 0 : 1]
                switch coordinate.geoCoordType {
                    case .degDecimals(let dec):
                        for i in 0..<dec {
                            selectedDecimals[i] = coordinate.getDecimalsOfDegreesDigit(at: i)
                        }
                    case .minDecimals(let dec):
                        for i in 0..<dec {
                            selectedDecimals[i] = coordinate.getDecimalsOfMinutesDigit(at: i)
                        }
                    case .secDecimals(let dec):
                        for i in 0..<dec {
                            selectedDecimals[i] = coordinate.getDecimalsOfSecondsDigit(at: i)
                        }
                 }
            }
        }
    }
}

struct GeoLetter: Hashable {
    var multiplier: Int
    var letter: String
}
