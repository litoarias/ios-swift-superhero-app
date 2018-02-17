//
//  CharactersUseCase.swift
//  SuperheroApp
//
//  Created by Balazs Varga on 2018. 02. 12..
//  Copyright © 2018. W.UP. All rights reserved.
//

struct GetCharactersRequest: UseCaseRequest {
    var page: Page

    init(page: Page) {
        self.page = page
    }
}

struct GetCharactersResponse: UseCaseResponse {
    var characters: [Character]
}

class GetCharactersUseCase: UseCase<GetCharactersRequest, GetCharactersResponse> {

    private let charactersDataSource: CharactersDataSource

    init(charactersDataSource: CharactersDataSource) {
        self.charactersDataSource = charactersDataSource
    }

    override func executeUseCase(request: GetCharactersRequest) throws {
        self.charactersDataSource.loadCharacters(page: request.page, onSuccess: { (characters: [Character]) in
            let response = GetCharactersResponse(characters: characters)
            if let onSuccess = self.onSuccess {
                onSuccess(response)
            }
        }, onError: {
            if let onError = self.onError {
                onError()
            }
        })
    }
}
