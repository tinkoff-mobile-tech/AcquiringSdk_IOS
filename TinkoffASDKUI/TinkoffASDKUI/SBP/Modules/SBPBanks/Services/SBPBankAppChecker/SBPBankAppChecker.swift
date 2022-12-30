//
//  SBPBankAppChecker.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.12.2022.
//

import TinkoffASDKCore

private extension String {
    static let bankSchemesKey = "LSApplicationQueriesSchemes"
}

final class SBPBankAppChecker: ISBPBankAppChecker {

    // Dependencies
    private let application: IUIApplication

    // MARK: - Initialization

    public init(application: IUIApplication) {
        self.application = application
    }

    // MARK: - ISBPBankAppChecker

    /// Принимает список банков из которых происходит выборка по следующей логике:
    /// Смотрит в Info.plist мерча и осталяет только те банки которые указанны в этом Info.plist (это те банки которые мерч считает наиболее предпочтительными для совершения оплаты)
    /// Далее из желаемого мерчом списка удалются все те, которые не установленны на устройстве пользователя
    /// И после всех манипуляций возвращает список оставшихся банков
    /// - Parameter allBanks: Список банков из которых будет производится выборка
    /// - Returns: Список банков подходящие под условия
    func bankAppsPreferredByMerchant(from allBanks: [SBPBank]) -> [SBPBank] {
        if let bankSchemesArray = Bundle.main.infoDictionary?[.bankSchemesKey] as? [String] {
            var preferredBanks = allBanks.filter { bank in bankSchemesArray.contains(where: { $0 == bank.schema }) }
            preferredBanks = preferredBanks.filter { isBankAppInstalled($0) }
            return preferredBanks
        } else {
            return []
        }
    }

    func openBankApp(_ bank: SBPBank, completion: @escaping SBPBankAppCheckerOpenBankAppCompletion) {
        guard let url = URL(string: "\(bank.schema)://") else { return }
        application.open(url, options: [:], completionHandler: completion)
    }
}

// MARK: - Private

extension SBPBankAppChecker {
    private func isBankAppInstalled(_ bank: SBPBank) -> Bool {
        guard let url = URL(string: "\(bank.schema)://") else { return false }
        return application.canOpenURL(url)
    }
}