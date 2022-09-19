//
//  CloudStorage+Ext.swift
//  GradingApp
//
//  Created by Tom Rudnick on 19.09.22.
//

import Foundation
import CloudStorage

private let sync = CloudStorageSync.shared
private var dateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy"
    return dateFormatter
}

extension CloudStorage where Value == HalfType {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { if let rawHalf = sync.int(for: key) {
                        return HalfType(rawValue: Int16(rawHalf)) ?? wrappedValue
                    } else {
                        return wrappedValue
                    }
            },
            syncSet: { newValue in sync.set(newValue.rawValue, for: key) })
    }
}



extension CloudStorage where Value == Date {
    public init(wrappedValue: Value, _ key: String) {
        self.init(keyName: key) {
            if let dateString = sync.string(for: key), let date = dateFormatter.date(from: dateString) {
                return date
            } else {
                return wrappedValue
            }
        } syncSet: { newValue in
            sync.set(dateFormatter.string(from: newValue), for: key)
        }
    }
}
