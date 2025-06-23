//
//  QuickEntryViewWatch.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/16/24.
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
                        drinkCount -= 0.5
                    }
                } label: {
                    Image(systemName: "minus.circle")
                        .font(.largeTitle)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Decrease drink count")
                .accessibilityHint("Decreases drink count by 0.5")
                .disabled(drinkCount <= 0)
                
                Button {
                    showDrinkEntryAlert = true
                } label: {
                    Text("\(Formatter.formatDecimal(drinkCount))")
                        .font(.largeTitle)
                        .frame(width: 75)
                        .foregroundStyle(Color.black)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Current drink count")
                .accessibilityValue("\(Formatter.formatDecimal(drinkCount)) drinks")
                .accessibilityHint("Tap to enter exact amount, or use plus and minus buttons")
                
                Button {
                    drinkCount += 0.5
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.largeTitle)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Increase drink count")
                .accessibilityHint("Increases drink count by 0.5")
                
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
                .disabled(drinkCount < 0.1)
                .accessibilityLabel("Record drinks")
                .accessibilityHint("Records \(Formatter.formatDecimal(drinkCount)) drinks to today's total")
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
            .accessibilityLabel("Confirm recording")
            .accessibilityHint("Adds \(Formatter.formatDecimal(drinkCount)) drinks to today's total")
            
            Button("Cancel", role: .cancel) { drinkCount = 0 }
            .accessibilityLabel("Cancel recording")
            .accessibilityHint("Cancels recording and resets counter to zero")
        }
        .alert("Enter standard drinks", isPresented: $showDrinkEntryAlert) {
            TextField("Number of drinks", text: $manualEntryValue)
                .keyboardType(.decimalPad)
                .accessibilityLabel("Number of drinks")
                .accessibilityHint("Enter the exact number of standard drinks")
            
            Button("Cancel", role: .cancel) {
                showDrinkEntryAlert = false
                manualEntryValue = ""
            }
            .accessibilityLabel("Cancel entry")
            .accessibilityHint("Cancels manual entry and returns to counter")
            
            Button("Done") {
                if let value = Double(manualEntryValue) {
                    drinkCount = value
                }
                showRecordDrinksConfirmation = true
                manualEntryValue = ""
            }
            .accessibilityLabel("Set drink count")
            .accessibilityHint("Sets the drink count to the entered value")
        }
    }
}

#Preview {
    QuickEntryView()
}
