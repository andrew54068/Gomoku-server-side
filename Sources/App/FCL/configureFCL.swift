import Foundation
import FCL_SDK
import Cadence
import Vapor

public func configureFCL() throws {
    try loadCustomEnv()
    let address = Environment.get("testnet_admin_address")!

    fcl.config
        .put(.network(.testnet))
        .put(.logging(true))
        .put(.replace(
            placeHolder: "0xFUNGIBLE_TOKEN_ADDRESS",
            with: Address(hexString: "0x9a0766d93b6608b7")
        ))
        .put(.replace(
            placeHolder: "0xFLOW_TOKEN_ADDRESS",
            with: Address(hexString: "0x7e60df042a9c0868")
        ))
        .put(.replace(
            placeHolder: "0xMATCH_CONTRACT_ADDRESS",
            with: Address(hexString: "0x\(address)")
        ))
        .put(.replace(
            placeHolder: "0xGOMOKU_TYPE_ADDRESS",
            with: Address(hexString: "0x\(address)")
        ))
        .put(.replace(
            placeHolder: "0xGOMOKU_IDENTITY_ADDRESS",
            with: Address(hexString: "0x\(address)")
        ))
        .put(.replace(
            placeHolder: "0xGOMOKU_RESULT_ADDRESS",
            with: Address(hexString: "0x\(address)")
        ))
        .put(.replace(
            placeHolder: "0xGOMOKU_ADDRESS",
            with: Address(hexString: "0x\(address)")
        ))
}
