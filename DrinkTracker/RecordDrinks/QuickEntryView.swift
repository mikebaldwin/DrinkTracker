//
//  QuickEntryView.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/16/24.
//

import SwiftUI

struct QuickEntryView: View {
    @State private var drinkCount = 0.0
    @State private var quickEntryValue = ""
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
                
                Button {
                    showDrinkEntryAlert = true
                } label: {
                    Text("\(Formatter.formatDecimal(drinkCount))")
                        .font(.largeTitle)
                        .frame(width: 75)
                        .foregroundStyle(Color.black)
                }
                .buttonStyle(PlainButtonStyle())
                
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
                // pass drink back to superview
                drinkCount = 0
            }
            Button("Cancel", role: .cancel) { drinkCount = 0 }
        }
        .alert("Enter standard drinks", isPresented: $showDrinkEntryAlert) {
            TextField("", text: $quickEntryValue)
                .keyboardType(.decimalPad)
            
            Button("Cancel", role: .cancel) {
                showDrinkEntryAlert = false
                quickEntryValue = ""
            }
            Button("Done") {
                if let value = Double(quickEntryValue) {
                    drinkCount = value
                }
                showDrinkEntryAlert = false
                showRecordDrinksConfirmation = true
                quickEntryValue = ""
            }
        }

    }
}

#Preview {
    QuickEntryView()
}
