//
//
//  CardListAssembly.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import TinkoffASDKCore
import UIKit

final class CardListAssembly: ICardListAssembly {
    // MARK: Dependencies

    private let cardsControllerAssembly: ICardsControllerAssembly
    private let addNewCardAssembly: IAddNewCardAssembly

    // MARK: Init

    init(
        cardsControllerAssembly: ICardsControllerAssembly,
        addNewCardAssembly: IAddNewCardAssembly
    ) {
        self.cardsControllerAssembly = cardsControllerAssembly
        self.addNewCardAssembly = addNewCardAssembly
    }

    // MARK: ICardListAssembly

    func cardsPresentingNavigationController(customerKey: String) -> UINavigationController {
        let view = createModule(customerKey: customerKey, configuration: .cardList())
        return UINavigationController.withASDKBar(rootViewController: view)
    }

    func cardSelectionNavigationController(
        customerKey: String,
        cards: [PaymentCard],
        selectedCard: PaymentCard,
        paymentFlow: PaymentFlow
    ) -> UINavigationController {
        let view = createModule(
            customerKey: customerKey,
            configuration: .choosePaymentCardList(selectedCardId: selectedCard.cardId),
            cards: cards
        )

        return UINavigationController.withASDKBar(rootViewController: view)
    }

    // MARK: Helpers

    private func createModule(
        customerKey: String,
        configuration: CardListScreenConfiguration,
        cards: [PaymentCard] = []
    ) -> UIViewController {
        let router = CardListRouter(addNewCardAssembly: addNewCardAssembly)

        let presenter = CardListPresenter(
            screenConfiguration: configuration,
            cardsController: cardsControllerAssembly.cardsController(customerKey: customerKey),
            router: router,
            imageResolver: PaymentSystemImageResolver(),
            bankResolver: BankResolver(),
            paymentSystemResolver: PaymentSystemResolver(),
            cards: cards
        )

        let view = CardListViewController(
            configuration: configuration,
            presenter: presenter
        )

        router.transitionHandler = view
        presenter.view = view

        return view
    }
}

// MARK: - CardListScreenConfiguration + Styles

private extension CardListScreenConfiguration {
    static func cardList() -> Self {
        Self(
            listItemsAreSelectable: false,
            navigationTitle: Loc.Acquiring.CardList.screenTitle,
            addNewCardCellTitle: Loc.Acquiring.CardList.addCard,
            selectedCardId: nil
        )
    }

    static func choosePaymentCardList(selectedCardId: String) -> Self {
        // заменить строки на ключи после добавления на странице локализации в спеке
        Self(
            listItemsAreSelectable: true,
            navigationTitle: Loc.CardList.Screen.Title.paymentByCard,
            addNewCardCellTitle: Loc.CardList.Button.anotherCard,
            selectedCardId: selectedCardId
        )
    }
}