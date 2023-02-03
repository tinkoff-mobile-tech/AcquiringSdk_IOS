//
//  MainFormPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import Foundation
import TinkoffASDKCore

final class MainFormPresenter {
    // MARK: Dependencies

    weak var view: IMainFormViewController?
    private let router: IMainFormRouter
    private let coreSDK: AcquiringSdk
    private let paymentFlow: PaymentFlow
    private let configuration: MainFormUIConfiguration
    private let stub: MainFormStub

    // MARK: Child Presenters

    private lazy var savedCardPresenter = SavedCardPresenter(output: self)

    // MARK: State

    private var rows: [MainFormRowType] { [.savedCard(savedCardPresenter)] }
    private var loadedCards: [PaymentCard] = []

    // MARK: Init

    init(
        router: IMainFormRouter,
        coreSDK: AcquiringSdk,
        paymentFlow: PaymentFlow,
        configuration: MainFormUIConfiguration,
        stub: MainFormStub
    ) {
        self.router = router
        self.coreSDK = coreSDK
        self.paymentFlow = paymentFlow
        self.configuration = configuration
        self.stub = stub
    }

    // MARK: Helpers

    private func loadCardsIfNeeded() {
        guard let customerKey = paymentFlow.customerOptions?.customerKey else { return }

        coreSDK.getCardList(data: GetCardListData(customerKey: customerKey)) { [weak self] result in
            guard let cards = try? result.get() else { return }
            let activeCards = cards.filter { $0.status == .active }

            guard let selectedCard = activeCards.first else { return }

            DispatchQueue.main.async {
                self?.loadedCards = activeCards
                self?.savedCardPresenter.presentationState = .selected(
                    card: selectedCard,
                    hasAnotherCards: activeCards.count > 1
                )
            }
        }
    }
}

// MARK: - IMainFormPresenter

extension MainFormPresenter: IMainFormPresenter {
    func viewDidLoad() {
        let orderDetails = MainFormOrderDetailsViewModel(
            amountDescription: "К оплате",
            amount: "10 500 ₽",
            orderDescription: "Заказ №123456"
        )

        let paymentControls = MainFormPaymentControlsViewModel(
            buttonType: .primary(title: "Оплатить картой")
        )

        let header = MainFormHeaderViewModel(
            orderDetails: orderDetails,
            paymentControls: paymentControls
        )

        view?.updateHeader(with: header)
//        view?.set(payButtonEnabled: savedCardPresenter.isValid)
        loadCardsIfNeeded()
    }

    func viewWasClosed() {}

    func viewDidTapPayButton() {
        router.openCardPaymentForm(paymentFlow: paymentFlow, cards: loadedCards)
    }

    func numberOfRows() -> Int {
        rows.count
    }

    func row(at indexPath: IndexPath) -> MainFormRowType {
        rows[indexPath.row]
    }
}

// MARK: - ISavedCardPresenterOutput

extension MainFormPresenter: ISavedCardPresenterOutput {
    func savedCardPresenter(
        _ presenter: SavedCardPresenter,
        didRequestReplacementFor paymentCard: PaymentCard
    ) {}

    func savedCardPresenter(
        _ presenter: SavedCardPresenter,
        didUpdateCVC cvc: String,
        isValid: Bool
    ) {
//        view?.set(payButtonEnabled: isValid)
    }
}