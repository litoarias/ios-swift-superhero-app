//
//  CharactersPresenter.swift
//  SuperheroApp
//
//  Created by Balazs Varga on 2018. 02. 12..
//  Copyright © 2018. W.UP. All rights reserved.
//

private let defaultLimit = 100

class CharactersPreseneter: CharactersMvpPresenter {

    private let useCaseHandler: UseCaseHandler
    private var getCharactersUseCase: GetCharactersUseCase
    private weak var view: CharactersMvpView?
    private var currentPage: Page = Page(limit: defaultLimit, offset: 0)
    private var objects: [Character] = [Character]()

    init(useCaseHandler: UseCaseHandler, getCharactersUseCase: GetCharactersUseCase) {
        self.useCaseHandler = useCaseHandler
        self.getCharactersUseCase = getCharactersUseCase
    }

    func takeView(view: CharactersMvpView) {
        self.view = view
        self.loadCharacters()
    }

    func characters() -> [Character] {
        return self.objects
    }

    func charactersCount() -> Int {
        return self.objects.count
    }

    func loadCharacters() {

        self.view?.showLoadingIndicator()

        let request = GetCharactersRequest(page: self.currentPage)

        self.useCaseHandler.executeUseCase(useCase: self.getCharactersUseCase,
                                           request: request,
                                           onSuccess: { (response: GetCharactersResponse) in
            self.view?.hideLoadingIndicator()

            if response.characters.isEmpty {
                self.view?.showNoCharacters()
            } else {
                self.objects.append(contentsOf: response.characters)
                self.view?.refreshCharacters()
            }
        }, onError: {
            self.view?.hideLoadingIndicator()
            // TODO hardcoded message
            self.view?.showLoadingCharactersError(message: "Something wrong!")
        })
    }

    func loadMoreCharacters() {
        self.view?.showMoreLoadingIndicator()

        self.currentPage.offset += defaultLimit
        let request = GetCharactersRequest(page: self.currentPage)

        self.useCaseHandler.executeUseCase(useCase: self.getCharactersUseCase,
                                           request: request,
                                           onSuccess: { (response: GetCharactersResponse) in
            self.view?.hideMoreLoadingIndicator()

            if response.characters.isEmpty {
                self.view?.showNoCharacters()
            } else {
                self.objects.append(contentsOf: response.characters)
                self.view?.refreshCharacters()
            }
        }, onError: {
            // TODO remove hardcoded message
            self.view?.hideMoreLoadingIndicator()
            self.view?.showLoadingCharactersError(message: "Something wrong!")
        })
    }
}
