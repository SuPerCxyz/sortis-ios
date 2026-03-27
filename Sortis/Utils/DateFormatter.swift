//
//  DateFormatter.swift
//  Sortis
//
//  日期格式化工具
//

import Foundation

extension String {
    // 格式化 ISO 8601 日期时间为显示格式
    func formatDateTime() -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: self) else {
            // 尝试另一种格式
            let alternateFormatter = ISO8601DateFormatter()
            if let altDate = alternateFormatter.date(from: self) {
                return formatDisplayDate(altDate)
            }
            return self
        }

        return formatDisplayDate(date)
    }

    private func formatDisplayDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "昨天 HH:mm"
            return formatter.string(from: date)
        } else if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd HH:mm"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            return formatter.string(from: date)
        }
    }
}