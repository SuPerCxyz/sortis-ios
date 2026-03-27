//
//  Rule.swift
//  Sortis
//
//  规则数据模型
//

import Foundation

// 规则
struct Rule: Identifiable, Decodable {
    let id: Int
    let name: String
    let description: String?
    let categoryId: Int
    let category: CategoryInfo?
    let conditions: [RuleCondition]
    let priority: Int
    let isEnabled: Bool
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, priority
        case categoryId = "category_id"
        case category, conditions
        case isEnabled = "is_enabled"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        categoryId = try container.decode(Int.self, forKey: .categoryId)
        category = try container.decodeIfPresent(CategoryInfo.self, forKey: .category)
        priority = try container.decodeIfPresent(Int.self, forKey: .priority) ?? 0
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)

        // Handle conditions - could be array or object with conditions inside
        if let condArray = try? container.decode([RuleCondition].self, forKey: .conditions) {
            conditions = condArray
        } else if let condObj = try? container.decode(RuleConditionsWrapper.self, forKey: .conditions) {
            conditions = condObj.conditions
        } else {
            conditions = []
        }
    }

    // Convenience initializer for creating new rules
    init(id: Int, name: String, categoryId: Int, conditions: [RuleCondition], isEnabled: Bool, createdAt: String, updatedAt: String?) {
        self.id = id
        self.name = name
        self.description = nil
        self.categoryId = categoryId
        self.category = nil
        self.conditions = conditions
        self.priority = 0
        self.isEnabled = isEnabled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// Category info for rules
struct CategoryInfo: Decodable {
    let id: Int
    let name: String
}

// 规则条件包装
struct RuleConditionsWrapper: Decodable {
    let operator: String?
    let conditions: [RuleCondition]
}

// 规则条件
struct RuleCondition: Identifiable, Decodable {
    var id: Int { _id ?? 0 }
    private let _id: Int?
    let field: String
    let `operator`: String
    let value: AnyEncodable

    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case field
        case `operator`
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decodeIfPresent(Int.self, forKey: ._id)
        field = try container.decode(String.self, forKey: .field)
        `operator` = try container.decode(String.self, forKey: .operator)

        // Try to decode value as string first, then as any
        if let stringValue = try? container.decode(String.self, forKey: .value) {
            value = AnyEncodable(stringValue)
        } else {
            value = try container.decode(AnyEncodable.self, forKey: .value)
        }
    }

    init(id: Int? = nil, field: String, operator: String, value: AnyEncodable) {
        self._id = id
        self.field = field
        self.`operator` = `operator`
        self.value = value
    }
}

// 规则列表响应
struct RuleListResponse: Decodable {
    let total: Int
    let rules: [Rule]
}

// 创建/更新规则请求
struct RuleRequest: Encodable {
    let name: String
    let description: String?
    let categoryId: Int
    let priority: Int
    let conditions: [String: AnyEncodable]
    let isEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case name, description, priority, conditions
        case categoryId = "category_id"
        case isEnabled = "is_enabled"
    }
}

// 用于 Any 类型的 Encodable 包装
struct AnyEncodable: Encodable, Decodable {
    let value: Any

    private let encodeFunc: (Encoder) throws -> Void

    init(_ value: Any) {
        self.value = value
        if let encodable = value as? Encodable {
            self.encodeFunc = { encoder in
                var container = encoder.singleValueContainer()
                try container.encode(encodable)
            }
        } else if let dict = value as? [String: Any] {
            self.encodeFunc = { encoder in
                var container = encoder.container(keyedBy: AnyCodingKey.self)
                for (key, val) in dict {
                    try container.encode(AnyEncodable(val), forKey: AnyCodingKey(stringValue: key)!)
                }
            }
        } else if let array = value as? [Any] {
            self.encodeFunc = { encoder in
                var container = encoder.unkeyedContainer()
                for val in array {
                    try container.encode(AnyEncodable(val))
                }
            }
        } else {
            self.encodeFunc = { _ in }
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let stringValue = try? container.decode(String.self) {
            value = stringValue
            encodeFunc = { encoder in
                var container = encoder.singleValueContainer()
                try container.encode(stringValue)
            }
        } else if let intValue = try? container.decode(Int.self) {
            value = intValue
            encodeFunc = { encoder in
                var container = encoder.singleValueContainer()
                try container.encode(intValue)
            }
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
            encodeFunc = { encoder in
                var container = encoder.singleValueContainer()
                try container.encode(boolValue)
            }
        } else if let dictValue = try? container.decode([String: AnyEncodable].self) {
            value = dictValue.mapValues { $0.value }
            encodeFunc = { encoder in
                var container = encoder.container(keyedBy: AnyCodingKey.self)
                for (key, val) in dictValue {
                    try container.encode(val, forKey: AnyCodingKey(stringValue: key)!)
                }
            }
        } else if let arrayValue = try? container.decode([AnyEncodable].self) {
            value = arrayValue.map { $0.value }
            encodeFunc = { encoder in
                var container = encoder.unkeyedContainer()
                for val in arrayValue {
                    try container.encode(val)
                }
            }
        } else {
            value = ""
            encodeFunc = { _ in }
        }
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}

struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}