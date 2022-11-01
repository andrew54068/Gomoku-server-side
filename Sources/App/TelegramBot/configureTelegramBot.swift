import Vapor
import TelegramBotSDK
import Fluent

public func configureTelegramBot(_ app: Application) throws {

    guard let webNotificationURLString = Environment.get("WEB_NOTIFICATION_API_URL") else {
        fatalError("WEB_NOTIFICATION_API_URL not found in .env* file")
    }

    // config telegram bot
    let bot = app.telegramBot
    bot.setWebhookAsync(url: webNotificationURLString) { result, error in
        if let error = error {
            print(error)
        } else {
            print(result ?? false)
        }
    }

    print("Ready to accept commands")
}
