//
//  CategoriesListView.swift
//  MyBudget
//
//  Created by Konstantin Bolgar-Danchenko on 08.02.2023.
//

import SwiftUI

struct CategoriesListView: View {
    
    @Binding var selectedCategories: Set<TransactionCategory>
    
    @State private var name = ""
    @State private var color = Color.red
//    @State var selectedCategories = Set<TransactionCategory>()
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.timestamp, ascending: false)],
        animation: .default)
    private var categories : FetchedResults<TransactionCategory>
    
    var body: some View {
        Form {
            Section {
                ForEach(categories) { category in
                    Button {
                        if !selectedCategories.contains(category) {
                            selectedCategories.insert(category)
                        } else {
                            selectedCategories.remove(category)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            if let data = category.colorData,
                               let uiColor = UIColor.color(data: data) {
                                let color = Color(uiColor)
                                Spacer()
                                    .frame(width: 30, height: 10)
                                    .background(color)
                            }
                            Text(category.name ?? "")
                                .foregroundColor(Color(.label))
                            Spacer()
                            if selectedCategories.contains(category) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }

                }
                .onDelete { indexSet in
                    indexSet.forEach { i in
                        let categoryToDelete = categories[i]
                        selectedCategories.remove(categoryToDelete)
                        viewContext.delete(categoryToDelete)
                    }
                    try? viewContext.save()
                }
            } header: {
                Text("Select a category")
            }
            
            Section {
                TextField("Name", text: $name)
                ColorPicker("Color", selection: $color)
                
                Button {
                    handleAction()
                } label: {
                    HStack {
                        Spacer()
                        Text("Create")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(5)
                }
                .buttonStyle(.plain)

                
            } header: {
                Text("Create a category")
            }

        }
    }
    
    private func handleAction() {
        let context = PersistenceController.shared.container.viewContext
        
        let category = TransactionCategory(context: context)
        category.name = self.name
        category.colorData = UIColor(color).encode()
        category.timestamp = Date()
        
        do {
            try context.save()
            self.name = ""
        } catch {
            print("Failed to save category: \(error)")
        }
    }
}

struct CategoriesListView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesListView(selectedCategories: .constant(.init()))
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
