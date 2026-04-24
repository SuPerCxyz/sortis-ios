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
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}
