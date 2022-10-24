import Foundation
import Vapor
import TelegramBotSDK
import Queues
import Fluent
import FluentPostgresDriver
import FCL_SDK
import Cadence
import FlowSDK

public struct TelegramInfo: Codable {
    let telegramChatId: Int64
    let userAddress: Address
}

public struct TelegramBotJob: AsyncJob {
    public typealias Payload = TelegramInfo

    public func dequeue(_ context: Queues.QueueContext, _ payload: TelegramInfo) async throws {
        guard let getMatchedIndicesScript = scriptsFileContent(name: "Matcher-get-matched-by-address.cdc") else {
            return
        }
        let matchedIndicesRawValue = try await fcl.query(
            script: getMatchedIndicesScript,
            arguments: [
                .address(payload.userAddress),
            ]
        )
        let matchedIndices: [UInt32] = try matchedIndicesRawValue.toSwiftValue()

        for index in matchedIndices {
            do {
                guard let getCompositionRefScript = scriptsFileContent(name: "Gomoku-get-composition-ref.cdc") else {
                    continue
                }
                let compositionRawValue = try await fcl.query(
                    script: getCompositionRefScript,
                    arguments: [.uint32(index)]
                )
                let gomokuComposition: GomokuComposition? = try compositionRawValue.toSwiftValue()

                guard let gomokuComposition = gomokuComposition else {
                    continue
                }

                let matched = gomokuComposition.challenger != nil
                let finished = gomokuComposition.roundWinners.count == 2
                let roundStep = RoundStep(
                    round: gomokuComposition.currentRound,
                    stepCount: gomokuComposition.steps[Int(gomokuComposition.currentRound)].count
                )

                let userAddress = payload.userAddress
                let user: User
                var latestRoundStepUpdated = true
                if let existUser = try await User.find(
                    userAddress.hexStringWithPrefix,
                    on: context.application.db
                ) {
                    let compositions = try await existUser.$compositions.get(on: context.application.db)
                    if let existComposition = compositions.first(where: { $0.id == String(gomokuComposition.id) }) {
                        existComposition.matched = matched
                        existComposition.finished = finished
                        if existComposition.latestRoundStep == roundStep {
                            latestRoundStepUpdated = false
                        } else {
                            existComposition.round = roundStep.round
                            existComposition.stepCount = roundStep.stepCount
                        }
                        try await existComposition.update(on: context.application.db)
                    } else {
                        // Composition not found.
                        let composition = Composition(
                            id: "\(gomokuComposition.id)",
                            userAddress: userAddress.hexStringWithPrefix,
                            matched: matched,
                            finished: finished,
                            latestRoundStep: roundStep
                        )
                        try await existUser.$compositions.create(composition, on: context.application.db)
                    }
                    user = existUser
                } else {
                    // User not found.
                    let newUser = User(
                        id: userAddress.hexStringWithPrefix,
                        telegramChatId: payload.telegramChatId
                    )
                    let composition = Composition(
                        id: "\(gomokuComposition.id)",
                        userAddress: userAddress.hexStringWithPrefix,
                        matched: matched,
                        finished: finished,
                        latestRoundStep: roundStep
                    )
                    try await newUser.$compositions.create(composition, on: context.application.db)
                    try await newUser.create(on: context.application.db)
                    user = newUser
                }

                guard user.enableNotification else {
                    continue
                }
                
                guard gomokuComposition.roundWinners.count < 2 else {
                    continue
                }

                if shouldNotify(
                    gomokuComposition: gomokuComposition,
                    userAddress: userAddress
                ) {
                    guard latestRoundStepUpdated else { continue }
                    context.application.telegramBot.sendMessageAsync(
                        chatId: .chat(payload.telegramChatId),
                        text: "now it's your turn at [\(index)](\(Constent.webURLString)\(index))",
                        parseMode: .markdown,
                        disableNotification: false
                    )
                } else {
                    try await context.application
                        .queues
                        .queue
                        .dispatch(
                            TelegramBotJob.self,
                            .init(
                                telegramChatId: payload.telegramChatId,
                                userAddress: payload.userAddress
                            ),
                            maxRetryCount: 3,
                            delayUntil: Date(timeIntervalSinceNow: 1 * 10)
                        )
                }
            } catch {
                context.application.console.error(error.localizedDescription, newLine: true)
                continue
            }
        }
    }

}

func shouldNotify(
    gomokuComposition: GomokuComposition,
    userAddress: Address
) -> Bool {
    let currentRound = Int(gomokuComposition.currentRound)
    let stepsCountMod = gomokuComposition.steps[currentRound].count % 2
    if (currentRound + stepsCountMod) % 2 == 0 {
        // Challenger's move
        return gomokuComposition.challenger == userAddress
    } else {
        // Host's move
        return gomokuComposition.host == userAddress
    }
}
