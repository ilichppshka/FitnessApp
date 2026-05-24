import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? .greatestFiniteMagnitude
        return totalSize(for: computeRows(subviews: subviews, maxWidth: maxWidth))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let allRows = computeRows(subviews: subviews, maxWidth: bounds.width)
        var y = bounds.minY
        for row in allRows {
            var x = bounds.minX
            let rowHeight = row.map(\.size.height).max() ?? 0
            for item in row {
                item.subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(item.size))
                x += item.size.width + spacing
            }
            y += rowHeight + lineSpacing
        }
    }

    private struct Item {
        let subview: LayoutSubview
        let size: CGSize
    }

    private func computeRows(subviews: Subviews, maxWidth: CGFloat) -> [[Item]] {
        var rows: [[Item]] = []
        var currentRow: [Item] = []
        var rowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let needed = currentRow.isEmpty ? size.width : rowWidth + spacing + size.width
            if needed > maxWidth && !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow = []
                rowWidth = size.width
            } else {
                rowWidth = needed
            }
            currentRow.append(Item(subview: subview, size: size))
        }

        if !currentRow.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }

    private func totalSize(for rows: [[Item]]) -> CGSize {
        let rowWidths = rows.map { row in
            row.reduce(0) { $0 + $1.size.width } + CGFloat(max(row.count - 1, 0)) * spacing
        }
        let width = rowWidths.max() ?? 0
        let height = rows.reduce(0) { $0 + ($1.map(\.size.height).max() ?? 0) }
            + CGFloat(max(rows.count - 1, 0)) * lineSpacing
        return CGSize(width: width, height: height)
    }
}

#if DEBUG
#Preview("Flow Layout") {
    FlowLayout(spacing: Spacing.sm, lineSpacing: Spacing.sm) {
        ForEach(["Chest", "Back", "Shoulders", "Biceps", "Triceps", "Quads", "Hamstrings", "Glutes"], id: \.self) { name in
            Chip(title: name, style: .outline)
        }
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
#endif
