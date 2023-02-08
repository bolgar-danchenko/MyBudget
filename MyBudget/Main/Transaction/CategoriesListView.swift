//
//  CategoriesListView.swift
//  MyBudget
//
//  Created by Konstantin Bolgar-Danchenko on 08.02.2023.
//

import SwiftUI

struct CategoriesListView: View {
    
    @State private var name = ""
    @State private var color = Color.red
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.timestamp, ascending: false)],
        animation: .default)
    private var categories : FetchedResults<TransactionCategory>
    
    var body: some View {
        Form {
            Section {
                ForEach(categories) { category in
                    HStack(spacing: 12) {
                        if let data = category.colorData,
                           let uiColor = UIColor.color(data: data) {
                            let color = Color(uiColor)
                            Spacer()
                                .frame(width: 30, height: 10)
                                .background(color)
                        }
                        Text(category.name ?? "")
                        Spacer()
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { i in
                        viewContext.delete(categories[i])
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
        CategoriesListView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
