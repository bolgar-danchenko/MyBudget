//
//  AddTransactionForm.swift
//  MyBudget
//
//  Created by Konstantin Bolgar-Danchenko on 03.02.2023.
//

import SwiftUI
import PhotosUI

struct AddTransactionForm: View {
    
    let card: Card
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var amount = ""
    @State private var date = Date()
    
    @State private var shouldPresentPhotoPicker = false
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var photoData: Data? = nil
    
    @State private var selectedCategories = Set<TransactionCategory>()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Amount", text: $amount)
                    DatePicker("Date", selection: $date, displayedComponents: .date)

                } header: {
                    Text("Information")
                }
                
                Section {
                    NavigationLink {
                        CategoriesListView(selectedCategories: $selectedCategories)
                            .navigationTitle("Categories")
                            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    } label: {
                        Text("Select categories")
                    }
                    
                    let sortedCategories = Array(selectedCategories).sorted(by: { $0.timestamp ?? Date() > $1.timestamp ?? Date()})
                    
                    ForEach(sortedCategories) { category in
                        HStack(spacing: 12) {
                            if let data = category.colorData,
                               let uiColor = UIColor.color(data: data) {
                                let color = Color(uiColor)
                                Spacer()
                                    .frame(width: 30, height: 10)
                                    .background(color)
                            }
                            
                            Text(category.name ?? "")
                        }
                    }
                    
                } header: {
                    Text("Categories")
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
                                             let uiImage = UIImage(data: data)?.resized(to: .init(width: 300, height: 300))
                                             let compressedImageData = uiImage?.jpegData(compressionQuality: 0.3)
                                             photoData = compressedImageData
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
            let context = PersistenceController.shared.container.viewContext
            let transaction = CardTransaction(context: context)
            transaction.name = self.name
            transaction.amount = Float(self.amount) ?? 0
            transaction.timestamp = self.date
            transaction.photoData = photoData
            
            transaction.card = self.card
            transaction.categories = self.selectedCategories as NSSet
            
            do {
                try context.save()
                dismiss()
            } catch {
                print("Failed to save transaction: \(error)")
            }
            
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
    
    static let firstCard: Card? = {
        let context = PersistenceController.shared.container.viewContext
        let request = Card.fetchRequest()
        request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
        return try? context.fetch(request).first
    }()
    
    static var previews: some View {
        if let card = firstCard {
            AddTransactionForm(card: card)
        }
    }
}

extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            let hScale = newSize.height / size.height
            let vScale = newSize.width / size.width
            let scale = max(hScale, vScale) // Scale to fill
            let resizeSize = CGSize(width: size.width * scale, height: size.height * scale)
            var middle = CGPoint.zero
            if resizeSize.width > newSize.width {
                middle.x -= (resizeSize.width - newSize.width) / 2.0
            }
            if resizeSize.height > newSize.height {
                middle.y -= (resizeSize.height - newSize.height) / 2.0
            }
            
            draw(in: CGRect(origin: middle, size: resizeSize))
        }
    }
}
