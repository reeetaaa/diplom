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
    
    @State private var latitude: GeoCoordinate = GeoCoordinate(coordType: DataSource.instance.coordinateType)
    @State private var longitude: GeoCoordinate = GeoCoordinate(coordType: DataSource.instance.coordinateType)
    
    @State private var mapImage: Image = Image(systemName: "map")
    
    @State private var isPinLocked: [CornerType: Bool]? = [.NW: false, .NE: false, .SW: false, .SE: false]
    @State private var cornerPointsOnImage: [CornerType: CGPoint]? = [.NW: .zero, .NE: .zero, .SW: .zero, .SE: .zero] // Координаты углов изображения карты в системе XY
    
    @State private var centerPoint: CGPoint = .zero
    @State private var explicitlyScrollToThisPoint: CGPoint = .zero
    
    var body: some View {
        VStack {
            ScrollableMapForSettingPoints(mapImage: $mapImage,
                                          mode: $mode,
                                          isPinLocked: $isPinLocked,
                                          cornerPointsOnImage: $cornerPointsOnImage,
                                          centerPoint: $centerPoint,
                                          explicitlyScrollToThisPoint: $explicitlyScrollToThisPoint)
            
            if case .showingButtons = mode {
                // Кнопки для выбора угла
                Text("Нажмите на кнопку, чтобы установить угол")
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(MyAppViewModel.instance.getCornersArr(), id: \.id) { cs in
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
            // ПРОДОЛЖИТЬ
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
                                MyAppViewModel.instance.setCoordinates(to: cornerType, coordinates: coordinates)
                                MyAppViewModel.instance.setPointOnMap(of: cornerType, point: cornerPointsOnImage?[cornerType] ?? CGPoint.zero)
                                
                                isPinLocked?[cornerType] = MyAppViewModel.instance.isLocked(of: cornerType)
                            }
                            .buttonStyle(.bordered)
                            Button("Отменить") {
                                mode = .showingButtons(cornerType)
                                isPinLocked?[cornerType] = MyAppViewModel.instance.isLocked(of: cornerType)
                            }.buttonStyle(.bordered)
                        }
                        .onAppear() {
                            if let coordinates = MyAppViewModel.instance.getCoordinates(of: cornerType) {
                                latitude = coordinates.lat
                                longitude = coordinates.long
                            }
                        }
                    }
                    
                    GeoPickerControl(geoType: .latitude, coordinate: $latitude)
                        .padding(-10)
                        .onAppear {
                            if let coordinates = MyAppViewModel.instance.getCoordinates(of: cornerType) {
                                latitude = coordinates.lat
                            }
                        }
                    
                    GeoPickerControl(geoType: .longitude, coordinate: $longitude)
                        .padding(-10)
                        .onAppear {
                            if let coordinates = MyAppViewModel.instance.getCoordinates(of: cornerType) {
                                longitude = coordinates.long
                            }
                        }
                }
            } else if case .viewingCornerCoordinates(let cornerType) = mode {
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
                            let coordinates = MyAppViewModel.instance.getCoordinates(of: cornerType)
                            
                            if let coordinates = coordinates {
                                Text(coordinates.lat.getString(isLatitude: true))
                                Text(coordinates.long.getString(isLatitude: false))
                            }
                        }
                        Spacer()
                        Button("Удалить точку") {
                            MyAppViewModel.instance.deleteCoordinatesAndPointOnMap(at: cornerType)
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
                isPinLocked?[cT] = MyAppViewModel.instance.isLocked(of: cT)
                if let pointOnMap = MyAppViewModel.instance.getPointOnMap(of: cT) {
                    cornerPointsOnImage?[cT] = pointOnMap
                }
            }
        }
    }
    
    private func getTitle(of cornerSetting: CornerOnMapValues) -> String {
        if let coordStr = MyAppViewModel.instance.getCoordinates(of: cornerSetting.cornerType)?.getCoordinatesString() {
            return coordStr
        }
        return cornerSetting.cornerType.rawValue + "\n" + "угол"
    }
    
    private func suggestedPointValues(for cornerType: CornerType) -> PointOnMapValues? {
        var result: PointOnMapValues? = nil
        let latFrom = cornerType.anotherCornerWIthSameLatName
        let longFrom = cornerType.anotherCornerWithSameLongName
        if let valuesToGetLat = MyAppViewModel.instance.getCornerOnMapValues(of: latFrom),
           let valuesToGetLong = MyAppViewModel.instance.getCornerOnMapValues(of: longFrom) {
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
