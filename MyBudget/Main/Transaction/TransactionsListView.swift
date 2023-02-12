//
//  TransactionsListView.swift
//  MyBudget
//
//  Created by Konstantin Bolgar-Danchenko on 06.02.2023.
//

import SwiftUI

struct TransactionsListView: View {
    
    let card: Card
    
    init(card: Card) {
        self.card = card
        
        fetchRequest = FetchRequest<CardTransaction>(
            entity: CardTransaction.entity(),
            sortDescriptors: [
                .init(key: "timestamp", ascending: false)
            ],
            predicate: .init(format: "card == %@", self.card)
        )
    }
    
    @State private var shouldPresentAddTransactionForm = false
    @State private var shouldPresentFilterSheet = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var fetchRequest: FetchRequest<CardTransaction>
    
    var body: some View {
        VStack {
            if fetchRequest.wrappedValue.isEmpty {
                Text("Get starting by adding your first transaction")
                
                addTransactionButton
            } else {
                HStack {
                    Spacer()
                    addTransactionButton
                    filterButton
                        .sheet(isPresented: $shouldPresentFilterSheet) {
                            FilterSheet(selectedCategories: selectedCategories) { categories in
                                self.selectedCategories = categories
                            }
                        }
                }
                .padding(.horizontal)
                
                ForEach(filterTransactions(selectedCategories: selectedCategories)) { transaction in
                    CardTransactionView(transaction: transaction)
                }
            }
        }
        .fullScreenCover(isPresented: $shouldPresentAddTransactionForm) {
            AddTransactionForm(card: self.card)
        }
    }
    
    @State var selectedCategories = Set<TransactionCategory>()
    
    private func filterTransactions(selectedCategories: Set<TransactionCategory>) -> [CardTransaction] {
        if selectedCategories.isEmpty {
            return Array(fetchRequest.wrappedValue)
        }
        
        return fetchRequest.wrappedValue.filter { transaction in
            var shouldKeep = false
            
            if let categories = transaction.categories as? Set<TransactionCategory> {
                categories.forEach({ category in
                    if selectedCategories.contains(category) {
                        shouldKeep = true
                    }
                })
            }
            return shouldKeep
        }
    }
    
    private var filterButton: some View {
        Button {
            shouldPresentFilterSheet.toggle()
        } label: {
            HStack {
                Image(systemName: "line.horizontal.3.decrease.circle")
                Text("Filter")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(Color(.systemBackground))
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(.label))
            .cornerRadius(5)
        }
    }
    
    private var addTransactionButton: some View {
        Button {
            shouldPresentAddTransactionForm.toggle()
        } label: {
            Text("+ Transaction")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(.systemBackground))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(.label))
                .cornerRadius(5)
        }
    }
}

struct FilterSheet: View {
    
    @State var selectedCategories: Set<TransactionCategory>
    let didSaveFilters: (Set<TransactionCategory>) -> ()
    
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.timestamp, ascending: false)],
        animation: .default)
    private var categories : FetchedResults<TransactionCategory>
    
    var body: some View {
        NavigationView {
            Form {
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
            }
            .navigationTitle("Select Filters")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
            }
        }
    }
    
    private var saveButton: some View {
        Button {
            didSaveFilters(selectedCategories)
            dismiss()
        } label: {
            Text("Save")
        }

    }
}

struct CardTransactionView: View {
    
    let transaction: CardTransaction
    
    @State var shouldShowActionSheet = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    func handleDelete() {
        withAnimation {
            do {
                let context = PersistenceController.shared.container.viewContext
                context.delete(transaction)
                try context.save()
            } catch {
                print("Failed to delete transaction: \(error)")
            }
        }
    }
    
    var body: some View {
        
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(transaction.name ?? "")
                        .font(.headline)
                    
                    if let date = transaction.timestamp,
                       let dateString = dateFormatter.string(from: date) {
                        Text(dateString)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Button {
                        shouldShowActionSheet.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 24))
                    }
                    .padding(EdgeInsets(top: 6, leading: 8, bottom: 4, trailing: 0))
                    .confirmationDialog(self.transaction.name ?? "", isPresented: $shouldShowActionSheet, titleVisibility: Visibility.visible) {
                        Button("Cancel", role: .cancel) {
                            shouldShowActionSheet.toggle()
                        }

                        Button("Delete Transaction", role: .destructive) {
                            handleDelete()
                        }
                    }
                    
                    Text(String(format: "$%.2f", transaction.amount))
                }
            }
            
            if let categories = transaction.categories as? Set<TransactionCategory> {
                let sortedCategories = Array(categories).sorted(by: { $0.timestamp ?? Date() > $1.timestamp ?? Date() })
                HStack {
                    ForEach(sortedCategories) { category in
                        HStack {
                            if let data = category.colorData,
                               let uiColor = UIColor.color(data: data) {
                                let color = Color(uiColor: uiColor)
                                Text(category.name ?? "")
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 8)
                                    .background(color)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                            }
                        }
                    }
                    Spacer()
                }
            }
            
            if let photoData = transaction.photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            }
        }
        .foregroundColor(Color(.label))
        .padding()
        .background(Color.white)
        .cornerRadius(5)
        .shadow(radius: 5)
        .padding()
    }
}

struct TransactionsListView_Previews: PreviewProvider {
    
    static let firstCard: Card? = {
        let context = PersistenceController.shared.container.viewContext
        let request = Card.fetchRequest()
        request.sortDescriptors = [.init(key: "timestamp", ascending: true)]
        return try? context.fetch(request).first
    }()
    
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        ScrollView {
            if let card = firstCard {
                TransactionsListView(card: card)
            }
        }
        .environment(\.managedObjectContext, context)
    }
}
