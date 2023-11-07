//
//  File.swift
//
//
//  Created by Saultz, Ian on 10/27/23.
//

import Foundation
import AWSPluginsCore

extension CognitoIdentityProviderAction where
Input == VerifyUserAttributeInput,
Output == VerifyUserAttributeOutputResponse {

    /*
     "VerifyUserAttribute":{
       "name":"VerifyUserAttribute",
       "http":{
         "method":"POST",
         "requestUri":"/"
       },
       "input":{"shape":"VerifyUserAttributeRequest"},
       "output":{"shape":"VerifyUserAttributeResponse"},
       "errors":[
         {"shape":"ResourceNotFoundException"},
         {"shape":"InvalidParameterException"},
         {"shape":"CodeMismatchException"},
         {"shape":"ExpiredCodeException"},
         {"shape":"NotAuthorizedException"},
         {"shape":"TooManyRequestsException"},
         {"shape":"LimitExceededException"},
         {"shape":"PasswordResetRequiredException"},
         {"shape":"UserNotFoundException"},
         {"shape":"UserNotConfirmedException"},
         {"shape":"InternalErrorException"},
         {"shape":"AliasExistsException"},
         {"shape":"ForbiddenException"}
       ],
       "authtype":"none"
     }
   },
     */
    static func verifyUserAttribute(region: String) -> Self {
        .init(
            name: "VerifyUserAttribute",
            method: .post,
            xAmzTarget: "AWSCognitoIdentityProviderService.VerifyUserAttribute",
            requestURI: "/",
            successCode: 200,
            hostPrefix: "",
            mapError: mapError(data:response:)
        )
    }
}