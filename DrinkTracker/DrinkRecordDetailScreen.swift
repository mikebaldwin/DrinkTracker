//
//  DrinkRecordDetailScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 5/8/24.
//

import SwiftUI

struct DrinkRecordDetailScreen: View {
    var completion: ((DrinkRecord, Date) -> Void)?
    
    var drinkRecord: DrinkRecord
    @State var date: Date
    
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startDate = Date.distantPast
        let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        return startDate...endDate
    }()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Standard Drinks")
                        Spacer()
                        Text(Formatter.formatDecimal(drinkRecord.standardDrinks))
                    }
                    HStack {
                        DatePicker(
                            "Date",
                            selection: $date,
                            in: dateRange,
                            displayedComponents: [
                                .date,
                                .hourAndMinute
                            ]
                        )
                        .onChange(of: date) {
                            if Calendar.current.isDate(drinkRecord.timestamp, inSameDayAs: date) {
                                drinkRecord.timestamp = date
                            } else if let completion {
                                completion(drinkRecord, date)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(drinkRecord.name ?? "Untitled Drink")
    }
    
    private let dateFormatter = DateFormatter()
    
    init(drinkRecord: DrinkRecord, completion: ((DrinkRecord, Date) -> Void)?) {
        self.drinkRecord = drinkRecord
        self.completion = completion
        date = drinkRecord.timestamp
    }
    
    private func formatDate(_ date: Date) -> String {
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: date)
    }
    
}

//#Preview {
//    DrinkRecordDetailScreen(
//        drinkRecord: DrinkRecord(
//            standardDrinks: 1.63,
//            name: nil
//        )
//    )
//}
