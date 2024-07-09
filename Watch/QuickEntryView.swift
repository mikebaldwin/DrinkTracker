//
//  QuickEntryView.swift
//  Watch
//
//  Created by Mike Baldwin on 6/26/24.
//

import SwiftUI

struct QuickEntryView: View {
    var completion: ((DrinkRecord) -> Void)?
    
    @State private var drinkCount = 0.0
    @State private var manualEntryValue = ""
    @State private var showDrinkEntryAlert = false
    @State private var showRecordDrinksConfirmation = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button {
                    if drinkCount > 0 {
                        withAnimation {
                            drinkCount -= 1.0
                        }
                    }
                } label: {
                    Image(systemName: "minus.circle")
                        .font(.largeTitle)
                }
                .buttonStyle(PlainButtonStyle())
                
                Text("\(Formatter.formatDecimal(drinkCount))")
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .frame(width: 75)
                    .foregroundStyle(Color.black)
                    .focusable(true)
                    .digitalCrownRotation(
                        $drinkCount,
                        from: 0,
                        through: 100,
                        by: 0.1,
                        sensitivity: .medium,
                        isContinuous: true,
                        isHapticFeedbackEnabled: true
                    )
                
                Button {
                    withAnimation {
                        drinkCount += 1.0
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.largeTitle)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding([.top, .bottom])
            HStack {
                Spacer()
                Button {
                    showRecordDrinksConfirmation = true
                } label: {
                    Text("Record Drink")
                }
                .disabled(drinkCount < 1)
                Spacer()
            }
        }
        .confirmationDialog(
            "Add \(Formatter.formatDecimal(drinkCount)) drinks to today's record?",
            isPresented: $showRecordDrinksConfirmation,
            titleVisibility: .visible
        ) {
            Button("Record Drink") {
                if let completion {
                    completion(DrinkRecord(standardDrinks: drinkCount))
                }
                drinkCount = 0
            }
            Button("Cancel", role: .cancel) { drinkCount = 0 }
        }
    }
}

#Preview {
    QuickEntryView(completion: { _ in })
}
