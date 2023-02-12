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
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(cards) { card in
                            CreditCardView(card: card)
                                .frame(width: 400)
                        }
                    }
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

struct MainPadDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        MainPadDeviceView()
            .previewDevice(PreviewDevice(rawValue: "iPad Air (5th generation)"))
            .environment(\.horizontalSizeClass, .regular)
            .previewInterfaceOrientation(.portrait)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

