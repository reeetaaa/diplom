//
//  TestPage.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 20/10/23.
//

import SwiftUI
import Combine

// Файл для тестрировки различных элементов отдельно 
struct LineView: View {
    
    @State var coord = GeoCoordinate(coordType: .secDecimals(1), coordInDeg: 33.3456)
    
    var body: some View {
        VStack {
            GeoPickerControl(geoType: .latitude, coordinate: $coord)
            Text("Coordinate: \(coord.getString(isLatitude: true))")
            Button(action: {
                coord.coordInDeg = -20.35713
            }, label: {Text("Push me")})
            
            PushButton(title: "Пример")
        }
        
    }
}

#Preview {
    LineView()
}


