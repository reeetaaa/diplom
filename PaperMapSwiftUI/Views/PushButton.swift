//
//  PushedButton.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 09/10/23.
//

import SwiftUI
import Foundation

// Кнопка с состоянием нажатости
struct PushButton: View {
    var title: String
    @State var isLocked: Bool = true
    
    private let padding = 5.0

    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: 7).stroke(Color.white)
            shape.fill(Consts.Colors.PushedButton.backColor(isLocked))
            shape.stroke(Consts.Colors.PushedButton.borderColor(isLocked))
            
            HStack {
                if isLocked {
                    Image(systemName: "mappin.and.ellipse")
                        .frame(height: 20)
                        .foregroundColor(Consts.Colors.PushedButton.foreColor(isLocked))
                }
                Text(title)
                    .multilineTextAlignment(isLocked ? .trailing : .center)
                    .foregroundStyle(Consts.Colors.PushedButton.foreColor(isLocked))
                    .padding(13 + (isLocked ? padding : 0))
            }
        }
        .padding(isLocked ? 0 : padding)
        .shadow(radius: isLocked ? 0 : padding)
    }
}


