import Fluent
import Vapor
import Leaf
import FCL_SDK
import Queues
import Cadence
import TelegramBotSDK
import Redis

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.leaf.render("index", [
            "title": "Hi!",
            "body": "Hello Vapor!",
        ])
    }

    app.get("hello", ":name") { req -> String in
        let name = req.parameters.get("name")!
        return "Hello, \(name)!"
    }

    app.post("respond") { req -> String in
        let update = try req.content.decode(
            Update.self,
            using: JSONDecoder.custom(keys: .convertFromSnakeCase)
        )

        guard let userTelegramId = update.message?.from?.id else {
            throw Error.identityInvalid
        }

        guard let text = update.message?.text else {
            throw Error.messageNotFound
        }

        let connetRouteKey = "🔗 connect wallet"
        let disconnetRouteKey = "🚶‍♂️ disconnect"
        if text == "/start" {
            let button1 = KeyboardButton(text: connetRouteKey)
            let button2 = KeyboardButton(text: disconnetRouteKey)
            let markup = ReplyKeyboardMarkup(
                keyboard: [
                    [button1, button2],
                ],
                resizeKeyboard: true,
                oneTimeKeyboard: false,
                selective: false
            )
            req.application.telegramBot.sendMessageSync(
                chatId: .chat(userTelegramId),
                text: "Welcome to use Gomoku notify bot!",
                replyMarkup: ReplyMarkup.replyKeyboardMarkup(markup)
            )
        } else if text == connetRouteKey {
            let link = "http://127.0.0.1:3000/?telegramId=\(userTelegramId)"
            _ = req.application.telegramBot
                .sendMessageSync(
                    chatId: .chat(userTelegramId),
                    text: "Using link to connect:\n[\(link)](\(link))",
                    parseMode: .markdown
                )
        } else if text == disconnetRouteKey {
            User.query(on: app.db)
                .filter(\.$telegramChatId == userTelegramId)
                .first()
                .flatMap {
                    $0?.delete(on: req.db) ?? req.eventLoop.makeFailedFuture(Error.identityInvalid)
                }
                .whenComplete { result in
                    switch result {
                    case .success:
                        req.application.telegramBot.sendMessageSync(
                            chatId: .chat(userTelegramId),
                            text: "Disconnected"
                        )
                    case let .failure(failure):
                        req.application.telegramBot.sendMessageSync(
                            chatId: .chat(userTelegramId),
                            text: failure.localizedDescription
                        )
                    }
                }
        } else {
            req.application.telegramBot.sendMessageSync(
                chatId: .chat(userTelegramId),
                text: "Commend not found."
            )
        }

        return "True"
    }

    /* request body must have values below.
        userAddress: String
        telegramId: String
        accountProofAppName: String
        accountProof: AccountProof
     */
    app.post("user", "enableNotification") { req async throws -> Vapor.Response in
        let verifiableUser = try req.content.decode(VerifiableUser.self)
        let valid = try await AppUtilities.verifyAccountProof(
            appIdentifier: verifiableUser.accountProofAppName,
            accountProofData: verifiableUser.accountProof,
            fclCryptoContract: Address(hexString: Constent.bloctoSignatureVerifyAddress)
        )

        guard valid else {
            return Response(
                status: HTTPStatus.unauthorized,
                body: "Account proof is invalid."
            )
        }
        let userRawAddress: String = verifiableUser.userAddress.hexStringWithPrefix
        guard let telegramChatId = Int64(verifiableUser.telegramId) else {
            return Response(
                status: HTTPStatus.badRequest,
                body: .init(string: Error.telegramIdNotFound.errorDescription ?? "")
            )
        }

        let storedUser: User
        let existUser = try await User.find(userRawAddress, on: req.db)
        if let existUser = existUser {
            storedUser = existUser
        } else {
            // user not found
            let user = User(id: userRawAddress, telegramChatId: telegramChatId)
            try await user.save(on: req.db)
            storedUser = user
        }

        let userAddress = Address(hexString: userRawAddress)
        if storedUser.enableNotification == false {
            try await req.queue.dispatch(
                TelegramBotJob.self,
                .init(telegramChatId: telegramChatId, userAddress: userAddress)
            )
            storedUser.enableNotification = true
            try await storedUser.update(on: req.db)
        }

        return Response(
            status: HTTPResponseStatus.ok,
            body: .empty
        )
    }
}
