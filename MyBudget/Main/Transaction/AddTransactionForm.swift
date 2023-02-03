//
//  AddTransactionForm.swift
//  MyBudget
//
//  Created by Konstantin Bolgar-Danchenko on 03.02.2023.
//

import SwiftUI
import PhotosUI

struct AddTransactionForm: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var amount = ""
    @State private var date = Date()
    
    @State private var shouldPresentPhotoPicker = false
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var photoData: Data? = nil
    
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
                    PhotosPicker(selection: $selectedPhoto,
                                 matching: .images,
                                 preferredItemEncoding: .automatic,
                                 photoLibrary: .shared()) {
                        Text("Select Photo")
                    }
                                 .onChange(of: selectedPhoto) { newValue in
                                     Task {
                                         if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                             photoData = data
                                         }
                                     }
                                 }
                    if let photoData,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
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
