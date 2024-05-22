//
//  ContentView.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 06/10/23.
//
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-make-a-scroll-view-move-to-a-location-using-scrollviewreader
// https://doordash.engineering/2022/07/21/programmatic-scrolling-with-swiftui-scrollview/
// https://developer.apple.com/documentation/swiftui/making-fine-adjustments-to-a-view-s-position
// https://saeedrz.medium.com/detect-scroll-position-in-swiftui-3d6e0d81fc6b
// https://www.hackingwithswift.com/books/ios-swiftui/understanding-frames-and-coordinates-inside-geometryreader
// https://stackoverflow.com/questions/62062839/swiftui-how-to-get-size-height-of-scrollview-content

import SwiftUI

// Окно установки координат углов изображения карты
struct SetCornersView: View {
    
    @State private var mode: SettingPointMode = .showingButtons(.NW) // Режим отображения окна
    
    // Переменные для установки широты и доготы углов изображения карты
    @State private var latitude: GeoCoordinate = GeoCoordinate(coordType: DataSource.instance.coordinateType)
    @State private var longitude: GeoCoordinate = GeoCoordinate(coordType: DataSource.instance.coordinateType)
    
    @State private var mapImage: Image = Image(systemName: "map") // Изображение карты
    
    // Переменная для отслеживания был ли заведен угол изображения карты
    @State private var isPinLocked: [CornerType: Bool]? = [.NW: false, .NE: false, .SW: false, .SE: false]
    
    // Координаты углов изображения карты в системе XY
    @State private var cornerPointsOnImage: [CornerType: CGPoint]? = [.NW: .zero, .NE: .zero, .SW: .zero, .SE: .zero]
    
    @State private var centerPoint: CGPoint = .zero // Центральная точка экрана
    @State private var explicitlyScrollToThisPoint: CGPoint = .zero // Точка на экране, к которой необходимо перенести метку
    
    var body: some View {
        VStack {
            ScrollableMapForSettingPoints(mapImage: $mapImage,
                                          mode: $mode,
                                          isPinLocked: $isPinLocked,
                                          cornerPointsOnImage: $cornerPointsOnImage,
                                          centerPoint: $centerPoint,
                                          explicitlyScrollToThisPoint: $explicitlyScrollToThisPoint)
            
            // В режиме отображения кнопок углов изображения карты
            if case .showingButtons = mode {
                // Кнопки для выбора угла
                Text("Нажмите на кнопку, чтобы установить угол")
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(AppLogic.instance.getCornersArr(), id: \.id) { cs in
                        PushButton(title: getTitle(of: cs), isLocked: cs.isSet)
                        .onTapGesture { d in
                            if cs.isSet {
                                mode = .viewingCornerCoordinates(cs.cornerType)
                            } else {
                                mode = .editingCornerCoordinates(cs.cornerType)
                            }
                        }
                    }
                }
            } 
            // В режиме редактирования угла изображения карты
            else if case .editingCornerCoordinates(let cornerType) = mode {
                if let cornerType = cornerType {
                    VStack {
                        Text("Установите точку на " + cornerType.rawValue + " угол карты и введите координаты:") 
                        HStack {
                            
                            if let sV = suggestedPointValues(for: cornerType),
                               let sC = sV.coordinates {
                                Button("Угадать") { 
                                    latitude = sC.lat
                                    longitude = sC.long
                                    if let sP = sV.pointOnMap {
                                        explicitlyScrollToThisPoint = sP
                                    }
                                }
                            }
                            
                            Spacer()
                            Button("Сохранить") {
                                mode = .viewingCornerCoordinates(cornerType)
                                cornerPointsOnImage?[cornerType] = centerPoint
                                
                                var coordinates = GeoCoordinates(coordType: DataSource.instance.coordinateType)
                                coordinates.lat = $latitude.wrappedValue
                                coordinates.long = $longitude.wrappedValue
                                AppLogic.instance.setCoordinates(to: cornerType, coordinates: coordinates)
                                AppLogic.instance.setPointOnMap(to: cornerType, point: cornerPointsOnImage?[cornerType] ?? CGPoint.zero)
                                
                                isPinLocked?[cornerType] = AppLogic.instance.isLocked(of: cornerType)
                            }
                            .buttonStyle(.bordered)
                            Button("Отменить") {
                                mode = .showingButtons(cornerType)
                                isPinLocked?[cornerType] = AppLogic.instance.isLocked(of: cornerType)
                            }.buttonStyle(.bordered)
                        }
                        .onAppear() {
                            if let coordinates = AppLogic.instance.getCoordinates(of: cornerType) {
                                latitude = coordinates.lat
                                longitude = coordinates.long
                            }
                        }
                    }
                    
                    GeoPickerControl(geoType: .latitude, coordinate: $latitude)
                        .padding(-10)
                        .onAppear {
                            if let coordinates = AppLogic.instance.getCoordinates(of: cornerType) {
                                latitude = coordinates.lat
                            }
                        }
                    
                    GeoPickerControl(geoType: .longitude, coordinate: $longitude)
                        .padding(-10)
                        .onAppear {
                            if let coordinates = AppLogic.instance.getCoordinates(of: cornerType) {
                                longitude = coordinates.long
                            }
                        }
                }
            }
            // В режиме просмотра координат угла изображения карты
            else if case .viewingCornerCoordinates(let cornerType) = mode {
                if let cornerType = cornerType {
                    HStack {
                        Text("Координаты " + cornerType.rawValue + " угла:")
                        Spacer()
                        Button("Изменить") {
                            mode = .editingCornerCoordinates(cornerType)
                            isPinLocked?[cornerType] = false
                            
                        }.buttonStyle(.bordered)
                        Button("Готово") {
                            mode = .showingButtons(cornerType)
                        }.buttonStyle(.bordered)
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            let coordinates = AppLogic.instance.getCoordinates(of: cornerType)
                            
                            if let coordinates = coordinates {
                                Text(coordinates.lat.getString(isLatitude: true))
                                Text(coordinates.long.getString(isLatitude: false))
                            }
                        }
                        Spacer()
                        Button("Удалить точку") {
                            AppLogic.instance.deleteCoordinatesAndPointOnMap(at: cornerType)
                            mode = .showingButtons(cornerType)
                            isPinLocked?[cornerType] = false
                        }.buttonStyle(.bordered)
                    }
                    Spacer()
                }
            }
        }
        .onChange(of: isPinLocked) {
            
        }
        .onChange(of: cornerPointsOnImage) {
            
        }
        .onAppear {
            mapImage = DataSource.instance.mapImage ?? Image(systemName: "map")
            latitude = GeoCoordinate(coordType: DataSource.instance.coordinateType)
            longitude = GeoCoordinate(coordType: DataSource.instance.coordinateType)
            for cT in [CornerType.NW, .NE, .SE, .SW] {
                isPinLocked?[cT] = AppLogic.instance.isLocked(of: cT)
                if let pointOnMap = AppLogic.instance.getPointOnMap(of: cT) {
                    cornerPointsOnImage?[cT] = pointOnMap
                }
            }
        }
    }
    
    private func getTitle(of cornerSetting: CornerOnMapValues) -> String {
        if let coordStr = AppLogic.instance.getCoordinates(of: cornerSetting.cornerType)?.getCoordinatesString() {
            return coordStr
        }
        return cornerSetting.cornerType.rawValue + "\n" + "угол"
    }
    
    private func suggestedPointValues(for cornerType: CornerType) -> PointOnMapValues? {
        var result: PointOnMapValues? = nil
        let latFrom = cornerType.anotherCornerWIthSameLatName
        let longFrom = cornerType.anotherCornerWithSameLongName
        if let valuesToGetLat = AppLogic.instance.getCornerOnMapValues(of: latFrom),
           let valuesToGetLong = AppLogic.instance.getCornerOnMapValues(of: longFrom) {
            if let coordForLat = valuesToGetLat.coordinates, let coordForLong = valuesToGetLong.coordinates {
                var suggestedCoord = GeoCoordinates(lat: coordForLat.lat, long: coordForLong.long)
                if let posXFrom = valuesToGetLong.pointOnMap?.x,
                   let posYFrom = valuesToGetLat.pointOnMap?.y {
                    let suggestedPoint = CGPoint(x: posXFrom, y: posYFrom)
                    result = PointOnMapValues(coordinates: suggestedCoord, point: suggestedPoint)
                } else {
                    result = PointOnMapValues(coordinates: suggestedCoord)
                }
            }
        }
        return result
    }
}

#Preview {
    SetCornersView()
}

struct SetCornersView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            SetCornersView()
        }
    }
}
