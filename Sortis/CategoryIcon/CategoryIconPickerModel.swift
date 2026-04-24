//
//  CategoryIconPickerModel.swift
//  Sortis
//

struct CategoryIconPickerModel {
    static let options = categoryIconPresetOptions

    static func label(for icon: String?) -> String {
        getCategoryIconLabel(icon)
    }

    static func canonicalValue(for icon: String?) -> String {
        getCategoryIconPickerValue(icon) ?? ""
    }
}
