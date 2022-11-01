import Foundation
import FCL_SDK
import Cadence
import Vapor

public func configureFCL() throws {
    guard let gomokuAddress = Environment.get("WEB_FLOW_ADDRESS_GOMOKU_ADMIN") else {
        fatalError("WEB_FLOW_ADDRESS_GOMOKU_ADMIN not found in .env* file")
    }
    guard let fungibleTokenAddress = Environment.get("WEB_FLOW_ADDRESS_FUNGIBLE_TOKEN") else {
        fatalError("WEB_FLOW_ADDRESS_FUNGIBLE_TOKEN not found in .env* file")
    }
    guard let flowTokenAddress = Environment.get("WEB_FLOW_ADDRESS_FLOW_TOKEN") else {
        fatalError("WEB_FLOW_ADDRESS_FLOW_TOKEN not found in .env* file")
    }

    fcl.config
        .put(.network(.testnet))
        .put(.logging(true))
        .put(.replace(
            placeHolder: "0xFUNGIBLE_TOKEN_ADDRESS",
            with: Address(hexString: "0x\(fungibleTokenAddress)")
        ))
        .put(.replace(
            placeHolder: "0xFLOW_TOKEN_ADDRESS",
            with: Address(hexString: "0x\(flowTokenAddress)")
        ))
        .put(.replace(
            placeHolder: "0xMATCH_CONTRACT_ADDRESS",
            with: Address(hexString: "0x\(gomokuAddress)")
        ))
        .put(.replace(
            placeHolder: "0xGOMOKU_TYPE_ADDRESS",
            with: Address(hexString: "0x\(gomokuAddress)")
        ))
        .put(.replace(
            placeHolder: "0xGOMOKU_IDENTITY_ADDRESS",
            with: Address(hexString: "0x\(gomokuAddress)")
        ))
        .put(.replace(
            placeHolder: "0xGOMOKU_RESULT_ADDRESS",
            with: Address(hexString: "0x\(gomokuAddress)")
        ))
        .put(.replace(
            placeHolder: "0xGOMOKU_ADDRESS",
            with: Address(hexString: "0x\(gomokuAddress)")
        ))
}
