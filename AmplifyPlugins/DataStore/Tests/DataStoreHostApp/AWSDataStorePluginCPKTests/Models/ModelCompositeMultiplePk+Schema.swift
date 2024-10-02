//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

// swiftlint:disable all
import Amplify
import Foundation

public extension ModelCompositeMultiplePk {
  // MARK: - CodingKeys
   enum CodingKeys: String, ModelKey {
    case id
    case location
    case name
    case lastName
    case createdAt
    case updatedAt
  }

  static let keys = CodingKeys.self
  //  MARK: - ModelSchema

  static let schema = defineSchema { model in
    let modelCompositeMultiplePk = ModelCompositeMultiplePk.keys

    model.pluralName = "ModelCompositeMultiplePks"

    model.attributes(
      .index(fields: ["id", "location", "name"], name: nil),
      .primaryKey(fields: [modelCompositeMultiplePk.id, modelCompositeMultiplePk.location, modelCompositeMultiplePk.name])
    )

    model.fields(
      .field(modelCompositeMultiplePk.id, is: .required, ofType: .string),
      .field(modelCompositeMultiplePk.location, is: .required, ofType: .string),
      .field(modelCompositeMultiplePk.name, is: .required, ofType: .string),
      .field(modelCompositeMultiplePk.lastName, is: .optional, ofType: .string),
      .field(modelCompositeMultiplePk.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(modelCompositeMultiplePk.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension ModelCompositeMultiplePk: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Custom
  public typealias IdentifierProtocol = ModelIdentifier<Self, ModelIdentifierFormat.Custom>
}

public extension ModelCompositeMultiplePk.IdentifierProtocol {
  static func identifier(
    id: String,
    location: String,
    name: String
  ) -> Self {
    .make(fields: [(name: "id", value: id), (name: "location", value: location), (name: "name", value: name)])
  }
}
