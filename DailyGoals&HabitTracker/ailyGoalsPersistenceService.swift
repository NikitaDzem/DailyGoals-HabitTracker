import Foundation

final class ailyGoalsPersistenceService {
    static let ailyGoalsShared = ailyGoalsPersistenceService()

    private let ailyGoalsDefaults: UserDefaults
    private let ailyGoalsPayloadKey = "ailyGoalsAppPayload"
    private let ailyGoalsEncoder = JSONEncoder()
    private let ailyGoalsDecoder = JSONDecoder()

    private init(ailyGoalsDefaults: UserDefaults = .standard) {
        self.ailyGoalsDefaults = ailyGoalsDefaults
        ailyGoalsEncoder.dateEncodingStrategy = .iso8601
        ailyGoalsDecoder.dateDecodingStrategy = .iso8601
    }

    func ailyGoalsLoadPayload() -> ailyGoalsAppPayload {
        guard let ailyGoalsData = ailyGoalsDefaults.data(forKey: ailyGoalsPayloadKey) else {
            return ailyGoalsAppPayload()
        }
        do {
            return try ailyGoalsDecoder.decode(ailyGoalsAppPayload.self, from: ailyGoalsData)
        } catch {
            return ailyGoalsAppPayload()
        }
    }

    func ailyGoalsSavePayload(_ ailyGoalsPayload: ailyGoalsAppPayload) {
        do {
            let ailyGoalsData = try ailyGoalsEncoder.encode(ailyGoalsPayload)
            ailyGoalsDefaults.set(ailyGoalsData, forKey: ailyGoalsPayloadKey)
        } catch {
            return
        }
    }

    func ailyGoalsExportJSON(from ailyGoalsPayload: ailyGoalsAppPayload) -> Data? {
        do {
            let ailyGoalsPretty = JSONEncoder()
            ailyGoalsPretty.outputFormatting = [.prettyPrinted, .sortedKeys]
            ailyGoalsPretty.dateEncodingStrategy = .iso8601
            return try ailyGoalsPretty.encode(ailyGoalsPayload)
        } catch {
            return nil
        }
    }

    func ailyGoalsResetAll() {
        ailyGoalsDefaults.removeObject(forKey: ailyGoalsPayloadKey)
    }
}
