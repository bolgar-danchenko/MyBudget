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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(cards) { card in
                            CreditCardView(card: card)
                                .frame(width: 400)
                        }
                    }
                }
                TransactionsGrid()
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
    var body: some View {
        VStack {
            HStack {
                Text("Transactions")
                Spacer()
                Button {
                    
                } label: {
                    Text("+ Transaction")
                }
            }
            
            let columns: [GridItem] = [
                .init(.fixed(100), spacing: 16, alignment: .leading),
                .init(.fixed(200), spacing: 16, alignment: .leading),
                .init(.adaptive(minimum: 300, maximum: 800), spacing: 16),
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
                    Spacer()
                }
                
                HStack {
                    Text("Amount")
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
            .foregroundColor(Color(.darkGray))
        }
        .font(.system(size: 24, weight: .semibold))
        .padding()
    }
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

