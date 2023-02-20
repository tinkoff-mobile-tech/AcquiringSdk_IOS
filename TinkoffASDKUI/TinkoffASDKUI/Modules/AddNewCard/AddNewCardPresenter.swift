//
//  AddNewCardPresenter.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 20.12.2022.
//

import Foundation
import enum TinkoffASDKCore.APIError

protocol IAddNewCardPresenter: AnyObject {

    func viewDidLoad()
    func viewDidAppear()
    func cardFieldViewAddCardTapped()
    func viewUserClosedTheScreen()

    func cardFieldViewPresenter() -> ICardFieldViewOutput
}

// MARK: - Presenter

final class AddNewCardPresenter {

    weak var view: IAddNewCardView?

    private lazy var cardFieldPresenter = CardFieldPresenter(output: self)

    private weak var output: IAddNewCardOutput?
    private let cardsController: ICardsController

    private var didAddCard = false
    private var didReceivedError = false

    init(cardsController: ICardsController, output: IAddNewCardOutput?) {
        self.cardsController = cardsController
        self.output = output
    }
}

extension AddNewCardPresenter: IAddNewCardPresenter {

    func cardFieldViewAddCardTapped() {
        guard cardFieldPresenter.validateWholeForm().isValid else { return }

        let cardOptions = CardOptions(
            pan: cardFieldPresenter.cardNumber,
            validThru: cardFieldPresenter.expiration,
            cvc: cardFieldPresenter.cvc
        )

        addCard(options: cardOptions)
    }

    func viewDidLoad() {
        view?.reloadCollection(sections: [.cardField])
        view?.disableAddButton()
    }

    func viewDidAppear() {
        view?.activateCardField()
    }

    func viewUserClosedTheScreen() {
        // проверка что мы не сами закрываем экран после успешного добавления карты
        guard !didAddCard, !didReceivedError else { return }
        output?.addingNewCardCompleted(result: .cancelled)
    }

    func cardFieldViewPresenter() -> ICardFieldViewOutput {
        cardFieldPresenter
    }
}

extension AddNewCardPresenter: ICardFieldOutput {
    func cardFieldValidationResultDidChange(result: CardFieldValidationResult) {
        result.isValid ? view?.enableAddButton() : view?.disableAddButton()
    }
}

// MARK: - Private

extension AddNewCardPresenter {

    private func addCard(options: CardOptions) {
        view?.showLoadingState()

        cardsController.addCard(options: options) { [weak self] result in
            guard let self = self else { return }

            self.view?.hideLoadingState()

            switch result {
            case let .succeded(paymentCard):
                self.view?.closeScreen()
                self.didAddCard = true
                self.output?.addingNewCardCompleted(result: .succeded(paymentCard))
            case let .failed(error):
                self.didReceivedError = true
                self.handleAddCard(error: error)
            case .cancelled:
                self.view?.closeScreen()
            }
        }
    }

    private func handleAddCard(error: Error) {
        let alreadyHasSuchCardErrorCode = 510

        if (error as NSError).code == alreadyHasSuchCardErrorCode {
            view?.showOkNativeAlert(data: .alreadyHasSuchCardError)
            output?.addingNewCardCompleted(result: .failed(error))
        } else {
            view?.showOkNativeAlert(data: .genericError)
            output?.addingNewCardCompleted(result: .failed(error))
        }
    }
}

private extension OkAlertData {

    static var alreadyHasSuchCardError: Self {
        OkAlertData(
            title: Loc.CommonAlert.AddCard.title,
            buttonTitle: Loc.CommonAlert.button
        )
    }

    static var genericError: Self {
        OkAlertData(
            title: Loc.CommonAlert.SomeProblem.title,
            message: Loc.CommonAlert.SomeProblem.description,
            buttonTitle: Loc.CommonAlert.button
        )
    }
}
