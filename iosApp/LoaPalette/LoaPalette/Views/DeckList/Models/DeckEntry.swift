
import Foundation

struct DeckEntry: Codable, Identifiable, Hashable {
    let id: String
    let card: LorcanaCard
    var count: Int

    init(card: LorcanaCard, count: Int = 1) {
        self.id = card.id
        self.card = card
        self.count = count
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: DeckEntry, rhs: DeckEntry) -> Bool {
        lhs.id == rhs.id
    }
}
