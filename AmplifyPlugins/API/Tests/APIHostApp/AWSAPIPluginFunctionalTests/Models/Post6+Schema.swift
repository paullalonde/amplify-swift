//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

// swiftlint:disable all
import Amplify
import Foundation

public extension Post6 {
  // MARK: - CodingKeys
   enum CodingKeys: String, ModelKey {
    case id
    case title
    case blog
    case comments
    case createdAt
    case updatedAt
  }

  static let keys = CodingKeys.self
  //  MARK: - ModelSchema

  static let schema = defineSchema { model in
    let post6 = Post6.keys

    model.pluralName = "Post6s"

    model.attributes(
      .index(fields: ["blogID"], name: "byBlog")
    )

    model.fields(
      .id(),
      .field(post6.title, is: .required, ofType: .string),
      .belongsTo(post6.blog, is: .optional, ofType: Blog6.self, targetName: "blogID"),
      .hasMany(post6.comments, is: .optional, ofType: Comment6.self, associatedWith: Comment6.keys.post),
      .field(post6.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(post6.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}
