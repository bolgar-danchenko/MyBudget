//
//  DeviceIdiomView.swift
//  MyBudget
//
//  Created by Konstantin Bolgar-Danchenko on 12.02.2023.
//

import SwiftUI

struct DeviceIdiomView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            MainView()
        } else {
            if horizontalSizeClass == .compact {
                Color.blue
            } else {
                MainPadDeviceView()
            }
        }
    }
}

struct DeviceIdiomView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceIdiomView()
        
        DeviceIdiomView()
            .previewDevice(PreviewDevice(rawValue: "iPad Air (5th generation)"))
            .environment(\.horizontalSizeClass, .regular)
            .previewInterfaceOrientation(.landscapeLeft)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        
        DeviceIdiomView()
            .previewDevice(PreviewDevice(rawValue: "iPad Air (5th generation)"))
            .environment(\.horizontalSizeClass, .compact)
    }
}
