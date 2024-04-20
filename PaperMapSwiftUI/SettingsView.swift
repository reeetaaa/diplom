//
//  SettingsView.swift
//  PaperMapSwiftUI
//
//  Created by Маргарита Бабухадия on 18.04.2024.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedPrecision = 0
    @State private var selectedFormat = 1
    private var precisions = [0, 1, 2, 3]
    private var coord = GeoCoordinate(coordType: .degDecimals(2), coordInDeg: 12.3456789)
    private var types: [GeoCoordinate.GeoCoordinateType] {
        let prec = precisions[selectedPrecision]
        return [.degDecimals(prec), .minDecimals(prec), .secDecimals(prec)]
    }
    private var formats: [String] {
        types.map { t in
            GeoCoordinate(coordType: t, coordInDeg: coord.coordInDeg).getString(isLatitude: true)
        }
    }
    
    var body: some View {
        VStack{
            Text("Например: \nДля координаты \(coord.coordInDeg)")
                .font(.title3)
                .multilineTextAlignment(.center)
                
            HStack{
                Spacer(minLength: 50)
                Text("Формат")
                Picker("", selection: $selectedFormat){
                    ForEach(Array(formats.enumerated()), id: \.offset){ i, e in
                        Text(e).tag(i)
                    }
                } .pickerStyle(.wheel)
                Spacer(minLength: 50)
            }
            HStack{
                Spacer(minLength: 50)
                Text("Десятичная часть")
                Picker("", selection: $selectedPrecision){
                    ForEach(Array(precisions.enumerated()), id: \.offset){ i, e in
                        Text(String(e)).tag(i)
                    }
                } .pickerStyle(.wheel)
                Spacer(minLength: 50)
            }
        }
        .onAppear {
            switch DataSource.instance.coordinateType {
                case .degDecimals(let p):
                    selectedPrecision = precisions.firstIndex(of: p) ?? 0
                case .minDecimals(let p):
                    selectedPrecision = precisions.firstIndex(of: p) ?? 0
                case .secDecimals(let p):
                    selectedPrecision = precisions.firstIndex(of: p) ?? 0
            }
            selectedFormat = types.firstIndex(of: DataSource.instance.coordinateType) ?? 0
        }
        .onChange(of: selectedFormat){
            save()
        }
        .onChange(of: selectedPrecision){
            save()
        }
    }
    
    func save() {
        DataSource.instance.coordinateType = types[selectedFormat]
    }
}

#Preview {
    SettingsView()
}
