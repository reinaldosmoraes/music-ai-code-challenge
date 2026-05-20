//
//  String+Extensions.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, bundle: .main, comment: "")
    }

    func localized(_ arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
}
