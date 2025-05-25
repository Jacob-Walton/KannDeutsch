import SwiftUI

struct EntryRow: View {
    let entry: DictionaryEntry
    let searchText: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Circle()
                .fill(iconColor.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(entry.german.prefix(1)).uppercased())
                        .font(.headline)
                        .foregroundStyle(iconColor)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // German text
                HStack(spacing: 8) {
                    if searchText.isEmpty {
                        Text(entry.displayGerman)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                    } else {
                        HighlightedText(
                            text: entry.displayGerman,
                            highlight: searchText,
                            highlightColor: Theme.accentColor
                        )
                        .font(.callout)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    }
                    
                    if entry.isIdiom {
                        Image(systemName: "quote.bubble.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
                
                // English text
                if searchText.isEmpty {
                    Text(entry.english)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                } else {
                    HighlightedText(
                        text: entry.english,
                        highlight: searchText,
                        highlightColor: Theme.accentColor
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    private var iconColor: Color {
        guard let gender = entry.germanGender else { return .gray }
        switch gender.lowercased() {
        case "m": return .blue
        case "f": return .pink
        case "n": return .green
        case "pl": return .purple
        default: return .gray
        }
    }
}

struct HighlightedText: View {
    let text: String
    let highlight: String
    let highlightColor: Color
    
    var body: some View {
        let highlighted = getHighlightedText()
        Text(highlighted)
    }
    
    private func getHighlightedText() -> AttributedString {
        var attributed = AttributedString(text)
        
        guard !highlight.isEmpty else { return attributed }
        
        let searchText = highlight.lowercased()
        let textLower = text.lowercased()
        
        var currentIndex = textLower.startIndex
        while let range = textLower[currentIndex...].range(of: searchText) {
            let nsRange = NSRange(range, in: text)
            if let attributedRange = Range(nsRange, in: attributed) {
                attributed[attributedRange].backgroundColor = highlightColor.opacity(0.3)
                attributed[attributedRange].foregroundColor = highlightColor
            }
            currentIndex = range.upperBound
        }
        
        return attributed
    }
}