//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify
import AWSPluginsCore

public struct AppSyncGraphQLRequestOptions {

    /// authorization type
    public let authType: AWSAuthorizationType?

    public init(authType: AWSAuthorizationType? = nil) {
        self.authType = authType
    }
}

public extension GraphQLRequest.Options {
    static func withAuthType(_ authType: AWSAuthorizationType) -> GraphQLRequest.Options {
        .init(pluginOptions: AppSyncGraphQLRequestOptions(authType: authType))
    }
}
