//
//  MainPadDeviceView.swift
//  MyBudget
//
//  Created by Konstantin Bolgar-Danchenko on 12.02.2023.
//

import SwiftUI

struct MainPadDeviceView: View {
    
    @State var shouldShowAddCardForm = false
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    private var cards: FetchedResults<Card>
    
    @State var selectedCard: Card?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(cards) { card in
                            CreditCardView(card: card)
                                .frame(width: 350)
                                .onTapGesture {
                                    withAnimation {
                                        self.selectedCard = card
                                    }
                                }
                                .scaleEffect(self.selectedCard == card ? 1.1 : 1)
                        }
                    }
                    .frame(height: 250)
                    .padding(.horizontal)
                    .onAppear {
                        self.selectedCard = cards.first
                    }
                }
                
                if let card = selectedCard {
                    TransactionsGrid(card: card)
                }
            }
            .navigationTitle("Money Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addCardButton
                }
            }
            .sheet(isPresented: $shouldShowAddCardForm) {
                AddCardForm(card: nil, didAddCard: nil)
            }
        }
    }
    
    private var addCardButton: some View {
        Button {
            shouldShowAddCardForm.toggle()
        } label: {
            Text("+ Card")
        }

    }
}

struct TransactionsGrid: View {
    
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
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var fetchRequest: FetchRequest<CardTransaction>
    
    @State var shouldShowAddTransactionform = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Transactions")
                Spacer()
                Button {
                    shouldShowAddTransactionform.toggle()
                } label: {
                    Text("+ Transaction")
                }
            }
            .sheet(isPresented: $shouldShowAddTransactionform) {
                AddTransactionForm(card: card)
            }
            
            let columns: [GridItem] = [
                .init(.fixed(100), spacing: 16, alignment: .leading),
                .init(.fixed(200), spacing: 16, alignment: .leading),
                .init(.adaptive(minimum: 300, maximum: 800), spacing: 16, alignment: .leading),
                .init(.flexible(minimum: 100, maximum: 450), spacing: 16, alignment: .trailing),
            ]
            
            LazyVGrid(columns: columns) {
                HStack {
                    Text("Date")
                    Image(systemName: "arrow.up.arrow.down")
                }
                
                Text("Photo / Receipt")
                
                HStack {
                    Text("Name")
                    Image(systemName: "arrow.up.arrow.down")
                }
                
                HStack {
                    Text("Amount")
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
            .font(.system(size: 24, weight: .semibold))
            .foregroundColor(Color(.darkGray))
            
            LazyVStack(spacing: 0) {
                ForEach(fetchRequest.wrappedValue) { transaction in
                    VStack(spacing: 0) {
                        Divider()
                        if let index = fetchRequest.wrappedValue.firstIndex(of: transaction) {
                            LazyVGrid(columns: columns) {
                                if let date = transaction.timestamp {
                                    Text(dateFormatter.string(from: date))
                                }
                                
                                if let data = transaction.photoData,
                                   let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .frame(width: 80, height: 80, alignment: .leading)
                                        .cornerRadius(8)
                                } else {
                                    Text("No photo available")
                                }
                                
                                Text(transaction.name ?? "")
                                
                                Text(String(format: "%.2f", transaction.amount))
                            }
                            .padding(.vertical)
                            .background(index % 2 == 0 ? Color(.systemBackground) : Color(.init(white: 0, alpha: 0.03)))
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

struct MainPadDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        MainPadDeviceView()
            .previewDevice(PreviewDevice(rawValue: "iPad Air (5th generation)"))
            .environment(\.horizontalSizeClass, .regular)
            .previewInterfaceOrientation(.portrait)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

