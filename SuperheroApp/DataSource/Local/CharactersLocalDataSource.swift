//
//  CharactersLocalDataSource.swift
//  SuperheroApp
//
//  Created by Balazs Varga on 2018. 02. 11..
//  Copyright © 2018. W.UP. All rights reserved.
//

import CoreData

class CharactersLocalDataSource: CharactersDataSource {

    private let persistentContainer: NSPersistentContainer

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    func loadCharacters(page: Page, onSuccess: @escaping ([Character]) -> Void, onError: @escaping () -> Void) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CharacterEntity")
        fetchRequest.fetchLimit = page.limit
        fetchRequest.fetchOffset = page.offset
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            let result = try self.persistentContainer.viewContext.fetch(fetchRequest)

            var characters = [Character]()

            for entity in result {

                if let characterId = entity.value(forKey: "id") as? Int,
                    let name = entity.value(forKey: "name") as? String,
                    let thumbnailUrl = entity.value(forKey: "thumbnailUrl") as? String {
                    let character = Character(characterId: characterId, name: name, thumbnailUrl: thumbnailUrl)
                    characters.append(character)
                }
            }

            onSuccess(characters)
        } catch {
            onError()
        }
    }

    func loadCharacter(characterId: Int, onSuccess: @escaping (Character?) -> Void, onError: @escaping () -> Void) {

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CharacterEntity")
        fetchRequest.predicate = NSPredicate(format: "id = \(characterId)")

        do {
            let result = try self.persistentContainer.viewContext.fetch(fetchRequest)

            if let entity = result.first,
                let characterId = entity.value(forKey: "id") as? Int,
                let name = entity.value(forKey: "name") as? String,
                let thumbnailUrl = entity.value(forKey: "thumbnailUrl") as? String {
                let character = Character(characterId: characterId, name: name, thumbnailUrl: thumbnailUrl)
                onSuccess(character)
            }

        } catch {
            onError()
        }
    }

    func saveCharacters(characters: [Character], onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {

        for character in characters {
            let entity = NSEntityDescription .insertNewObject(forEntityName: "CharacterEntity",
                                                              into: self.persistentContainer.viewContext)
            entity.setValue(character.characterId, forKey: "id")
            entity.setValue(character.name, forKey: "name")
            entity.setValue(character.thumbnailUrl, forKey: "thumbnailUrl")
        }
        do {
            try self.persistentContainer.viewContext.save()
            onSuccess()
        } catch {
            onError()
        }
    }
}
