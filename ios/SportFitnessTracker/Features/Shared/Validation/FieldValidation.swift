import Foundation

enum ValidationError: LocalizedError, Equatable {
    case requiredField(String)
    case nonNegative(String)
    case greaterThanZero(String)
    case duplicateValue(String)
    case invalidNumber(String)
    case invalidChoice(String)

    var errorDescription: String? {
        switch self {
        case let .requiredField(field):
            return "\(field) is required."
        case let .nonNegative(field):
            return "\(field) must be zero or greater."
        case let .greaterThanZero(field):
            return "\(field) must be greater than zero."
        case let .duplicateValue(field):
            return "\(field) must be unique."
        case let .invalidNumber(field):
            return "\(field) must be a valid number."
        case let .invalidChoice(field):
            return "\(field) has an invalid selection."
        }
    }
}

enum FieldValidation {
    static func requireText(_ value: String, field: String) throws {
        if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError.requiredField(field)
        }
    }

    static func requireNonNegative(_ value: Double, field: String) throws {
        if value < 0 {
            throw ValidationError.nonNegative(field)
        }
    }

    static func requireGreaterThanZero(_ value: Double, field: String) throws {
        if value <= 0 {
            throw ValidationError.greaterThanZero(field)
        }
    }

    static func parseDouble(_ value: String, field: String) throws -> Double {
        guard let parsed = Double(value.replacingOccurrences(of: ",", with: ".")) else {
            throw ValidationError.invalidNumber(field)
        }

        return parsed
    }

    static func ensureUnique(_ value: String, in values: [String], field: String) throws {
        if values.contains(where: { $0.caseInsensitiveCompare(value) == .orderedSame }) {
            throw ValidationError.duplicateValue(field)
        }
    }
}