import App
import Vapor
import TelegramBotSDK
import FCL_SDK
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

print("@@@@@@@")
print(URLRequest.self)
print("@@@@@@@")

var env = try Environment.detect()
try loadCustomEnv(env)
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
guard let token: String = Environment.get("TelegramBotToken") else {
    fatalError("contractEnv not found")
}
app.bot.initialize(token: token)
try configureTelegramBot(app)

try configureFCL()
try configure(app)

try app.run()
