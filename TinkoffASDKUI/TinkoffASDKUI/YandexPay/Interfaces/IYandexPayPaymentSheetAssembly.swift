//
//  IYandexPayPaymentSheetAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import UIKit

protocol IYandexPayPaymentSheetAssembly {
    func yandexPayActivity(
        paymentFlow: PaymentFlow,
        base64Token: String,
        output: IYandexPayPaymentSheetOutput
    ) -> UIViewController
}
