//
//  AddTransactionForm.swift
//  MyBudget
//
//  Created by Konstantin Bolgar-Danchenko on 03.02.2023.
//

import SwiftUI

struct AddTransactionForm: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var amount = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Amount", text: $amount)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    NavigationLink {
                        Text("New category page")
                    } label: {
                        Text("Many to many")
                    }

                } header: {
                    Text("Information")
                }
                
                Section {
                    Button("Select Photo") {
                        
                    }
                } header: {
                    Text("Photo/Receipt")
                }
            }
            .navigationTitle("Add Transaction")
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
    
    private var saveButton: some View {
        Button {
            
        } label: {
            Text("Save")
        }
    }
    
    private var cancelButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Cancel")
        }

    }
}

struct AddTransactionForm_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionForm()
    }
}
