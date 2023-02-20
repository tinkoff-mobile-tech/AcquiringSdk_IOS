//
//  AddNewCardResult.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 20.02.2023.
//

import Foundation
import TinkoffASDKCore

public enum AddNewCardResult {
    case succeded(PaymentCard)
    case failed(Error)
    case cancelled
}
