import Foundation
import SwiftUI

extension String {
    var isNotEmpty: Bool {
        !isEmpty
    }
    
    func matches(searchText: String) -> Bool {
        lowercased().contains(searchText.lowercased())
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}