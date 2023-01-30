//
//  AddCardForm.swift
//  MyBudget
//
//  Created by Konstantin Bolgar-Danchenko on 30.01.2023.
//

import SwiftUI

struct AddCardForm: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var cardNumber = ""
    @State private var limit = ""
    @State private var cardType = "Visa"
    
    @State private var month = 1
    @State private var year = Calendar.current.component(.year, from: Date())
    
    @State private var color = Color.blue
    
    let currentYear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                    
                    TextField("Credit Card Number", text: $cardNumber)
                        .keyboardType(.numberPad)
                    
                    TextField("Credit Limit", text: $limit)
                        .keyboardType(.numberPad)
                    
                    Picker("Type", selection: $cardType) {
                        ForEach(["Visa", "MasterCard", "Discovery", "Citibank"], id: \.self) { cardType in
                            Text(String(cardType)).tag(String(cardType))
                        }
                    }
                } header: {
                    Text("Card Info")
                }
                
                Section {
                    Picker("Month", selection: $month) {
                        ForEach(1...12, id: \.self) { num in
                            Text(String(num)).tag(String(num))
                        }
                    }
                    
                    Picker("Year", selection: $year) {
                        ForEach(currentYear..<currentYear + 20, id: \.self) { num in
                            Text(String(num)).tag(String(num))
                        }
                    }
                } header: {
                    Text("Expiration")
                }
                
                Section {
                    ColorPicker("Color", selection: $color)
                } header: {
                    Text("Color")
                }
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
