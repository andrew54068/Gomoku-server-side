import Vapor
import TelegramBotSDK
import Fluent

public func configureTelegramBot(_ app: Application) throws {

    // config telegram bot
    let bot = app.telegramBot
    bot.setWebhookAsync(url: "\(Constent.ngrokURLString)/respond") { result, error in
        if let error = error {
            print(error)
        } else {
            print(result ?? false)
        }
    }

    print("Ready to accept commands")
}
