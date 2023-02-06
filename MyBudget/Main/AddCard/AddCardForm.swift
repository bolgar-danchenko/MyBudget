//
//  AddCardForm.swift
//  MyBudget
//
//  Created by Konstantin Bolgar-Danchenko on 30.01.2023.
//

import SwiftUI

struct AddCardForm: View {
    
    let card: Card?
    var didAddCard: ((Card) -> ())? = nil
    
    init(card: Card? = nil, didAddCard: ((Card) -> ())? = nil) {
        self.card = card
        self.didAddCard = didAddCard
        
        _name = State(initialValue: self.card?.name ?? "")
        _cardNumber = State(initialValue: self.card?.number ?? "")
        
        if let limit = card?.limit {
            _limit = State(initialValue: String(limit))
        }
        
        _cardType = State(initialValue: self.card?.cardType ?? "")
        _month = State(initialValue: Int(self.card?.expMonth ?? 1))
        _year = State(initialValue: Int(self.card?.expYear ?? Int16(currentYear)))
        
        if let data = self.card?.color,
           let uiColor = UIColor.color(data: data) {
            let cardColor = Color(uiColor: uiColor)
            _color = State(initialValue: cardColor)
        }
    }
    
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
            AddCardFormView()
                .navigationTitle(self.card != nil ? "Edit Credit Card" : "Add Credit Card")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
            }
        }
    }
    
    private var cancelButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Cancel")
        }
    }
    
    private var saveButton: some View {
        Button {
            let viewContext = PersistenceController.shared.container.viewContext
            
            let card = self.card != nil ? self.card! : Card(context: viewContext)
            
            card.name = self.name
            card.number = self.cardNumber
            card.limit = Int32(self.limit) ?? 0
            card.expMonth = Int16(self.month)
            card.expYear = Int16(self.year)
            card.timestamp = Date()
            card.color = UIColor(self.color).encode()
            card.cardType = self.cardType
            
            do {
                try viewContext.save()
                dismiss()
                didAddCard?(card)
            } catch {
                print("Failed to persist new card: \(error)")
            }
            
        } label: {
            Text("Save")
        }
    }
    
    @ViewBuilder
    private func AddCardFormView() -> some View {
        Form {
            Section {
                TextField("Name", text: $name)
                
                TextField("Credit Card Number", text: $cardNumber)
                    .keyboardType(.numberPad)
                
                TextField("Credit Limit", text: $limit)
                    .keyboardType(.numberPad)
                
                Picker("Type", selection: $cardType) {
                    ForEach(["Visa", "MasterCard"], id: \.self) { cardType in
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
    }
}

struct AddCardForm_Previews: PreviewProvider {
    static var previews: some View {
//        AddCardForm()
        let context = PersistenceController.shared.container.viewContext
        MainView()
            .environment(\.managedObjectContext, context)
    }
}

extension UIColor {
    
    class func color(data: Data) -> UIColor? {
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
    }
    
    func encode() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}
