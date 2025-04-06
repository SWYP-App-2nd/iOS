import Foundation
import Combine

struct CheckInPerson: Identifiable, Hashable {
    let id: UUID
    let name: String
    var frequency: CheckInFrequency?
}

enum CheckInFrequency: String, CaseIterable, Identifiable {
    case none = "주기 선택"
    case daily = "매일"
    case weekly = "매주"
    case biweekly = "2주"
    case monthly = "매달"
    case semiAnnually = "6개월"
    
    var id: String { rawValue }
}

class ContactFrequencySettingsViewModel: ObservableObject {
    @Published var people: [CheckInPerson] = []
    @Published var isUnified: Bool = false
    @Published var unifiedFrequency: CheckInFrequency? = nil
    
    var canComplete: Bool {
        if isUnified {
            // unifiedFrequency가 nil이 아니고 .none이 아닐때 true
            return unifiedFrequency != nil && unifiedFrequency != CheckInFrequency.none
        } else {
            // 각각의 사람 frequency가 nil 아니고 .none 아닐떄
            return people.allSatisfy {
                $0.frequency != nil && $0.frequency != CheckInFrequency.none
            }
        }
    }
    
    func toggleUnifiedFrequency(_ enabled: Bool) {
        isUnified = enabled
    }
    
    func updateFrequency(for person: CheckInPerson, to frequency: CheckInFrequency) {
        guard let index = people.firstIndex(of: person) else { return }
        people[index].frequency = frequency
    }
    
    func applyUnifiedFrequency(_ frequency: CheckInFrequency) {
        unifiedFrequency = frequency
        if isUnified {
            people = people.map {
                CheckInPerson(id: $0.id, name: $0.name, frequency: frequency)
            }
        }
    }
}
