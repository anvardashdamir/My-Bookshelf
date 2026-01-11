//
//  String+Validation.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 28.12.25.
//

import Foundation

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isValidEmail: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(startIndex..., in: self)
        let match = detector?.firstMatch(in: self, options: [], range: range)
        return match?.url?.scheme == "mailto" && match?.range == range
    }
}
