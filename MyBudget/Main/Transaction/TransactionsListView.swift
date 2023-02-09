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
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var fetchRequest: FetchRequest<CardTransaction>
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \CardTransaction.timestamp, ascending: false)],
//        animation: .default)
//    private var transactions: FetchedResults<CardTransaction>
    
    var body: some View {
        VStack {
            Text("Get starting by adding your first transaction")
            
            Button {
                shouldPresentAddTransactionForm.toggle()
            } label: {
                Text("+ Transaction")
                    .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
                    .background(Color(.label))
                    .foregroundColor(Color(.systemBackground))
                    .font(.headline)
                    .cornerRadius(5)
            }
            .fullScreenCover(isPresented: $shouldPresentAddTransactionForm) {
                AddTransactionForm(card: self.card)
            }
            
            ForEach(fetchRequest.wrappedValue) { transaction in
                CardTransactionView(transaction: transaction)
            } 
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
