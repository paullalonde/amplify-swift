//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

// swiftlint:disable all
import Amplify
import Foundation

public struct Post14: Model {
  public let postId: String
  public let sk: Temporal.Date
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?

  public init(
    postId: String,
    sk: Temporal.Date
  ) {
    self.init(
      postId: postId,
      sk: sk,
      createdAt: nil,
      updatedAt: nil
    )
  }
  init(
    postId: String,
    sk: Temporal.Date,
    createdAt: Temporal.DateTime? = nil,
    updatedAt: Temporal.DateTime? = nil
  ) {
      self.postId = postId
      self.sk = sk
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}
