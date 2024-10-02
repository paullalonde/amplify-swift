//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

// swiftlint:disable all
import Amplify
import Foundation

public struct Post8V2: Model {
    public let id: String
    public var name: String
    public var randomId: String?
    var _blog: LazyReference<Blog8V2>
    public var blog: Blog8V2?   {
        get async throws {
            try await _blog.get()
        }
    }
    public var comments: List<Comment8V2>?
    public var createdAt: Temporal.DateTime?
    public var updatedAt: Temporal.DateTime?

    public init(
        id: String = UUID().uuidString,
        name: String,
        randomId: String? = nil,
        blog: Blog8V2? = nil,
        comments: List<Comment8V2>? = []
    ) {
        self.init(
            id: id,
            name: name,
            randomId: randomId,
            blog: blog,
            comments: comments,
            createdAt: nil,
            updatedAt: nil
        )
    }
    init(
        id: String = UUID().uuidString,
        name: String,
        randomId: String? = nil,
        blog: Blog8V2? = nil,
        comments: List<Comment8V2>? = [],
        createdAt: Temporal.DateTime? = nil,
        updatedAt: Temporal.DateTime? = nil
    ) {
        self.id = id
        self.name = name
        self.randomId = randomId
        self._blog = LazyReference(blog)
        self.comments = comments
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    public mutating func setBlog(_ blog: Blog8V2? = nil) {
        _blog = LazyReference(blog)
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .name)
        self.randomId = try? values.decode(String?.self, forKey: .randomId)
        self._blog = try values.decodeIfPresent(LazyReference<Blog8V2>.self, forKey: .blog) ?? LazyReference(identifiers: nil)
        self.comments = try values.decodeIfPresent(List<Comment8V2>?.self, forKey: .comments) ?? .init()
        self.createdAt = try? values.decode(Temporal.DateTime?.self, forKey: .createdAt)
        self.updatedAt = try? values.decode(Temporal.DateTime?.self, forKey: .updatedAt)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(randomId, forKey: .randomId)
        try container.encode(_blog, forKey: .blog)
        try container.encode(comments, forKey: .comments)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}
