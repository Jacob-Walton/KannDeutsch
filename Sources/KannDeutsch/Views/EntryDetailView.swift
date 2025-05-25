import SwiftUI

struct EntryDetailView: View {
    let entry: DictionaryEntry
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var expandedSections: Set<String> = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header Card
                HeaderCard(entry: entry)
                    .padding()
                
                // Quick Info Grid
                if entry.hasAdditionalInfo {
                    QuickInfoGrid(entry: entry)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                
                // Sections
                VStack(spacing: 16) {
                    // German Section
                    if !entry.germanAnnotations.isEmpty || !entry.germanVariations.isEmpty {
                        LanguageSection(
                            title: "German Details",
                            icon: "flag",
                            color: .blue,
                            annotations: entry.germanAnnotations,
                            variations: entry.germanVariations,
                            isExpanded: expandedSections.contains("german")
                        ) {
                            toggleSection("german")
                        }
                    }
                    
                    // English Section
                    if !entry.englishAnnotations.isEmpty || !entry.englishVariations.isEmpty {
                        LanguageSection(
                            title: "English Details",
                            icon: "flag.fill",
                            color: .green,
                            annotations: entry.englishAnnotations,
                            variations: entry.englishVariations,
                            isExpanded: expandedSections.contains("english")
                        ) {
                            toggleSection("english")
                        }
                    }
                    
                    // Usage & Context
                    if !entry.tags.isEmpty {
                        UsageSection(
                            entry: entry,
                            isExpanded: expandedSections.contains("usage")
                        ) {
                            toggleSection("usage")
                        }
                    }
                }
                .padding(.horizontal)
                
                // Actions
                ActionsSection(entry: entry)
                    .padding()
                
                Spacer(minLength: 40)
            }
        }
        .navigationTitle("Entry Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if sizeClass == .compact {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func toggleSection(_ section: String) {
        withAnimation(.spring(response: 0.3)) {
            if expandedSections.contains(section) {
                expandedSections.remove(section)
            } else {
                expandedSections.insert(section)
            }
        }
    }
}

// MARK: - Header Card
struct HeaderCard: View {
    let entry: DictionaryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // German
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(entry.german)
                        .font(.system(size: 36, weight: .bold))
                        .textSelection(.enabled)
                    
                    Spacer()
                    
                    if entry.isIdiom {
                        Label("Idiom", systemImage: "quote.bubble.fill")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.secondaryAccent, in: Capsule())
                            .foregroundStyle(.white)
                    }
                }
                
                if let gender = entry.germanGender, !gender.isEmpty {
                    HStack(spacing: 12) {
                        GenderBadge(gender: gender)
                        
                        if !entry.genderArticle.isEmpty {
                            Text("\(entry.genderArticle) \(entry.german)")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // English
            VStack(alignment: .leading, spacing: 8) {
                Label("English", systemImage: "globe")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(entry.english)
                    .font(.title2)
                    .fontWeight(.medium)
                    .textSelection(.enabled)
            }
        }
        .padding(24)
        .background(Theme.backgroundSecondary, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Quick Info Grid
struct QuickInfoGrid: View {
    let entry: DictionaryEntry
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            if let pos = entry.partOfSpeech, !pos.isEmpty {
                InfoCard(
                    icon: "textformat.abc",
                    title: "Part of Speech",
                    value: pos.capitalized
                )
            }
            
            if let usage = entry.usageLevel, !usage.isEmpty {
                InfoCard(
                    icon: "person.2.fill",
                    title: "Usage",
                    value: usage.capitalized
                )
            }
            
            if !entry.germanVariations.isEmpty {
                InfoCard(
                    icon: "arrow.triangle.branch",
                    title: "Variations",
                    value: "\(entry.germanVariations.count) forms"
                )
            }
            
            if !entry.tags.isEmpty {
                InfoCard(
                    icon: "tag.fill",
                    title: "Categories",
                    value: "\(entry.tags.count) tags"
                )
            }
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.accentColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Theme.backgroundTertiary, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Language Section
struct LanguageSection: View {
    let title: String
    let icon: String
    let color: Color
    let annotations: [String]
    let variations: [String]
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onToggle) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                    
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.spring(response: 0.3), value: isExpanded)
                }
                .foregroundStyle(.primary)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    if !annotations.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Annotations", systemImage: "note.text")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            ForEach(annotations, id: \.self) { annotation in
                                HStack(alignment: .top, spacing: 8) {
                                    Circle()
                                        .fill(color.opacity(0.5))
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 6)
                                    
                                    Text(annotation)
                                        .font(.callout)
                                }
                            }
                        }
                    }
                    
                    if !variations.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Variations", systemImage: "arrow.triangle.branch")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            ForEach(variations, id: \.self) { variation in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "arrow.turn.down.right")
                                        .font(.caption)
                                        .foregroundStyle(color.opacity(0.7))
                                        .padding(.top, 2)
                                    
                                    Text(variation)
                                        .font(.callout)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                }
                .padding(.leading, 28)
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(Theme.backgroundTertiary, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Usage Section
struct UsageSection: View {
    let entry: DictionaryEntry
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onToggle) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.orange)
                    
                    Text("Usage & Context")
                        .font(.headline)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.spring(response: 0.3), value: isExpanded)
                }
                .foregroundStyle(.primary)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    if let domain = entry.subjectDomain, !domain.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Subject Domains", systemImage: "books.vertical")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text(domain)
                                .font(.callout)
                        }
                    }
                    
                    if let usage = entry.usageLevel, !usage.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Usage Level", systemImage: "person.2")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text(usage)
                                .font(.callout)
                        }
                    }
                    
                    if !entry.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("All Tags", systemImage: "tag")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(entry.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Theme.accentColor.opacity(0.1), in: Capsule())
                                        .foregroundStyle(Theme.accentColor)
                                }
                            }
                        }
                    }
                }
                .padding(.leading, 28)
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(Theme.backgroundTertiary, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Actions Section
struct ActionsSection: View {
    let entry: DictionaryEntry
    @State private var showingCopied = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ShareLink(item: "\(entry.displayGerman) - \(entry.english)") {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.accentColor, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    UIPasteboard.general.string = "\(entry.displayGerman) - \(entry.english)"
                    showingCopied = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showingCopied = false
                    }
                }) {
                    Label(showingCopied ? "Copied!" : "Copy", systemImage: showingCopied ? "checkmark" : "doc.on.doc")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.backgroundSecondary, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Supporting Views
struct GenderBadge: View {
    let gender: String
    
    var genderInfo: (article: String, color: Color, name: String) {
        switch gender.lowercased() {
        case "m": return ("der", .blue, "Masculine")
        case "f": return ("die", .pink, "Feminine")
        case "n": return ("das", .green, "Neuter")
        case "pl": return ("die", .purple, "Plural")
        default: return (gender, .gray, gender)
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(genderInfo.color)
                .frame(width: 8, height: 8)
            
            Text(genderInfo.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(genderInfo.color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(genderInfo.color.opacity(0.15), in: Capsule())
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var maxHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += maxHeight + spacing
                    maxHeight = 0
                }
                
                frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
                x += size.width + spacing
                maxHeight = max(maxHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: y + maxHeight)
        }
    }
}