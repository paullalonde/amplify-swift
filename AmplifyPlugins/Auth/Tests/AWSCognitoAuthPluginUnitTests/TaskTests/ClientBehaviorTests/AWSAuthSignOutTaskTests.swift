//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

import Amplify
import AWSCognitoIdentityProvider
import XCTest
@testable import AWSCognitoAuthPlugin

// swiftlint:disable type_body_length
// swiftlint:disable file_length
class AWSAuthSignOutTaskTests: BasePluginTest {

    override var initialState: AuthState {
        AuthState.configured(
            AuthenticationState.signedIn(.testData),
            AuthorizationState.sessionEstablished(.testData)
        )
    }

    func testSuccessfullSignOut() async {
        mockIdentityProvider = MockIdentityProvider(
            mockRevokeTokenResponse: { _ in
                return .testData
            }, mockGlobalSignOutResponse: { _ in
                return .testData
            }
        )
        guard let result = await plugin.signOut() as? AWSCognitoSignOutResult,
              case .complete = result else {
            XCTFail("Did not return complete signOut")
            return
        }
    }

    func testGlobalSignOutFailed() async {
        mockIdentityProvider = MockIdentityProvider(
            mockRevokeTokenResponse: { _ in
                return .testData
            }, mockGlobalSignOutResponse: { _ in
                throw AWSCognitoIdentityProvider.InternalErrorException()
            }
        )
        guard let result = await plugin.signOut(options: .init(globalSignOut: true)) as? AWSCognitoSignOutResult,
              case .partial(
                  revokeTokenError: let revokeTokenError,
                  globalSignOutError: let globalSignOutError,
                  hostedUIError: let hostedUIError
              ) = result else {
            XCTFail("Did not return partial signOut")
            return
        }
        XCTAssertTrue(result.signedOutLocally)
        XCTAssertNotNil(revokeTokenError)
        XCTAssertNotNil(globalSignOutError)
        XCTAssertNil(hostedUIError)
    }

    func testRevokeSignOutFailed() async {
        mockIdentityProvider = MockIdentityProvider(
            mockRevokeTokenResponse: { _ in
                throw AWSCognitoIdentityProvider.InternalErrorException()
            }, mockGlobalSignOutResponse: { _ in
                return .testData
            }
        )
        guard let result = await plugin.signOut(options: .init(globalSignOut: true)) as? AWSCognitoSignOutResult,
              case .partial(
                  revokeTokenError: let revokeTokenError,
                  globalSignOutError: let globalSignOutError,
                  hostedUIError: let hostedUIError
              ) = result else {
            XCTFail("Did not return partial signOut")
            return
        }
        XCTAssertNotNil(revokeTokenError)
        XCTAssertNil(globalSignOutError)
        XCTAssertNil(hostedUIError)
    }

    func testInvalidStateForSignOut() async {

        let initialState = AuthState.configured(
            AuthenticationState.federatedToIdentityPool,
            AuthorizationState.sessionEstablished(.testData)
        )

        let authPlugin = configureCustomPluginWith(initialState: initialState)

        guard let result = await authPlugin.signOut() as? AWSCognitoSignOutResult,
              case .failed(let authError) = result,
              case .invalidState = authError else {

            XCTFail("Sign out during federation should not succeed")
            return
        }
        XCTAssertFalse(result.signedOutLocally)

    }

    func testInvalidStateForSignOutWhenSignedInUsingHostedUI() async {

        let initialState = AuthState.configured(
            AuthenticationState.signedIn(.hostedUISignInData),
            AuthorizationState.sessionEstablished(.hostedUITestData)
        )

        let authPlugin = configureCustomPluginWith(initialState: initialState)

        let result = await authPlugin.signOut() as? AWSCognitoSignOutResult

        guard case .failed(let authError) = result else {
            XCTFail("Sign out should have failed.")
            return
        }
        guard case .configuration = authError else {
            XCTFail("Auth error should be service but got: \(authError)")
            return
        }
    }

    func testGuestSignOut() async {

        let initialState = AuthState.configured(
            AuthenticationState.signedOut(.init()),
            AuthorizationState.sessionEstablished(.testDataIdentityPool)
        )

        let authPlugin = configureCustomPluginWith(initialState: initialState)

        guard let result = await authPlugin.signOut() as? AWSCognitoSignOutResult,
              case .complete = result else {

            XCTFail("Sign out during guest should succeed")
            return
        }
        XCTAssertTrue(result.signedOutLocally)

    }
}
