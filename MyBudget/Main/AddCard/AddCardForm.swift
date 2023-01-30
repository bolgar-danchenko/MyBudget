//
//  AddCardForm.swift
//  MyBudget
//
//  Created by Konstantin Bolgar-Danchenko on 30.01.2023.
//

import SwiftUI

struct AddCardForm: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text("Add card form")
            }
            .navigationTitle("Add Credit Card")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

struct AddCardForm_Previews: PreviewProvider {
    static var previews: some View {
        AddCardForm()
    }
}
