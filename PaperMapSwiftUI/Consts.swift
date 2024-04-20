//
//  Consts.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 09/10/23.
//

import Foundation
import SwiftUI

class Consts {
    
    class Colors {
        
        class PushedButton {
            static func backColor(_ isOn: Bool) -> Color {
                isOn
                ? Color(hue: 0.529, saturation: 0.444, brightness: 1)
                : Color(white: 0.6)
            }
            
            static func foreColor(_ isOn: Bool) -> Color {
                isOn
                ? Color(hue: 0.58, saturation: 0.963, brightness: 0.635)
                : Color.white
            }
            
            static func borderColor(_ isOn: Bool) -> Color {
                isOn
                ? Color(hue: 0.529, saturation: 0.6, brightness: 1)
                : Color.white
            }
        }
    }
    
}
