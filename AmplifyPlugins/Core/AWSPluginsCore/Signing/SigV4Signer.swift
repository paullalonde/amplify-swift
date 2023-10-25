//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CryptoKit

/**
 SigV4 Signing Process

        Description of functions used in diagram:
        Lowercase()     Convert the string to lowercase.

        Hex()           Lowercase base 16 encoding.

        SHA256Hash()    Secure Hash Algorithm (SHA) Cryptographic hash function.

        HMAC-SHA256()   Computes HMAC by using the SHA256 algorithm with the
                        signing key procided. This is the final signature.

        Trim()          Remove any leading or trailing whitepsace.

        UriEncode()     URI encode every byte. UriEncode() must enforce the following rules:
                            - URI encode every byte except the unreserved characters:
                              'A'-'Z', 'a'-'z', '0'-'9', '-', '.', '_', and '~'.
                            - The space character is a reserved character and must be
                              encoded as "%20" (and not as "+").
                            - Each URI encoded byte is formed by a '%' and the two-digit
                              hexadecimal value of the byte.
                            - Letters in the hexadecimal value must be uppercase, for example "%1A".
                            - Encode the forward slash character, '/', everywhere except in
                              the object key name. For example, if the object key name is
                              photos/Jan/sample.jpg, the forward slash in the key name is not encoded.

                            ⚠️ Important
                            The standard UriEncode functions provided by your development platform may not
                            work because of differences in implementation and related ambiguity in the
                            underlying RFCs. We recommend that you write your own custom UriEncode function to
                            ensure that your encoding will work.



                                              ┌─────────────────────────────────┐
       1. Canonical Request         ┌─────────│"GET" | "PUT" | "POST" | ...     │
                                    │         └─────────────────────────────────┘
       ┌────────────────────────────┼─────┐
       │HTTP Verb + "\n" +  ◀───────┘     │   ┌─────────────────────────────────┐
       │                              ┌───┼───│UriEncode(<resource>)            │
       │                              │   │   └─────────────────────────────────┘
       │                              │   │
       │Canonical URI + "\n" + ◀──────┘   │   ┌────────────────────────────────────────────────────────────────┐
       │                                  │   │UriEncode(<QueryParamer1>) + "=" + UriEncode(<value>) + "&" +   │
       │                                  │   │UriEncode(<QueryParamer2>) + "=" + UriEncode(<value>) + "&" +   │
       │                                  │┌──│  ...                                                           │
       │Canonical Query String + "\n" +  ◀┼┘  │UriEncode(<QueryParamerN>) + "=" + UriEncode(<value>)           │
       │                                  │   └────────────────────────────────────────────────────────────────┘
       │                                  │
       │                                  │   ┌────────────────────────────────────────────────────────────────┐
       │Canonical Headers + "\n" +  ◀───┐ │   │Lowercase(<HeaderName1>) + ":" + Trim(<value>) + "\n"           │
       │                                │ │   │Lowercase(<HeaderName2>) + ":" + Trim(<value>) + "\n"           │
       │                                └─┼───│  ...                                                           │
       │                                  │   │Lowercase(<HeaderNameN>) + ":" + Trim(<value>) + "\n"           │
       │Signed Headers + "\n" +   ◀────┐  │   └────────────────────────────────────────────────────────────────┘
       │                               │  │   ┌────────────────────────────────────────────────────────────────┐
       │                               │  │   │Lowercase(<HeaderName1>) + ";" +                                │
       │                               │  │   │Lowercase(<HeaderName2>) + ";" +                                │
       │"UNSIGNED-PAYLOAD"             └──┼───│  ...                                                           │
       │                                  │   │Lowercase(<HeaderNameN>)                                        │
       └──────────────────────────────────┘   └────────────────────────────────────────────────────────────────┘
                         │
                         │
    ┌────────────────────┘
    │
    │   2. StringToSign
    │
    │  ┌──────────────────────────────────┐
    │  │"AWS4-HMAC-SHA256" + "\n" +       │   ┌────────────────────────────────────────────────┐
    │  │                            ┌─────┼───│Format ISO8601, e.g. "20130524T000000Z"         │
    │  │                            │     │   └────────────────────────────────────────────────┘
    │  │                            │     │
    │  │TimeStamp + "\n" + ◀────────┘     │   ┌───────────────────────────────────────────────────┐
    │  │                                  │   │"<yyyymmdd>/<AWS Region>/<service>/aws4_request"   │
    │  │                          ┌───────┼───│e.g. "20130524/us-east-1/rekognition/aws4_request" │
    └─▶│                          │       │   └───────────────────────────────────────────────────┘
       │Scope + "\n" + ◀──────────┘       │
       │                                  │
       │                                  │
       │                                  │
       │Hex(SHA256Hash(Canonical Request))│
       │                                  │
       └──────────────────────────────────┘
                         │
                         │
    ┌────────────────────┘
    │    3. Signature
    │┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
    │                                                                                                   │
    ││ ┌──────────────────────────────────────────────────────────────────────────────────────────────┐
    │  │DateKey                 = HMAC-SHA256("AWS4" + "<SecretAccessKey>", "<yyyymmdd>")             │ │
    ││ │                                                                                              │
    │  │DateRegionKey           = HMAC-SHA256(DateKey, "<aws-region>")                                │ │
    ││ │                                                                                              │
    │  │DateRegionServiceKey    = HMAC-SHA256(DateRegionKey, "<aws-service>")                         │ │
    ││ │                                                                                              │
    │  │SigningKey              = HMAC-SHA256(DateRegionServiceKey, "aws4_request")                   │ │
    ││ │                                                                                              │
    │  └──────────┬───────────────────────────────────────────────────────────────────────────────────┘ │
    ││            │
    │             │                                                                                     │
    ││ ┌──────────▼─────────────────────────────────────────────┐
    └─▶│signature = Hex(HMAC-SHA256(SigningKey, StringToSign))  │                                       │
     │ └────────────────────────────────────────────────────────┘
                                                                                                        │
     └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
*/
public struct SigV4Signer {
    let credentials: Credentials
    // e.g. "rekognition"
    let serviceName: String
    // e.g. "us-east-1"
    let region: String

    // Reference type storage that holds the
    // previous signature (if it exists) to use
    // in subsequent signing requests as needed.
    let _storage = PreviousSignatureStorage()
    final class PreviousSignatureStorage {
        var previousSignature: String?
    }

    /// Time Formatter used in
    ///  -  X-Amz-Date header
    ///  - String to Sign: TimeStamp
    let _timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// Date Formatter used in
    ///  - Credential Scope
    ///  - Signing Key
    let _dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    public init(credentials: Credentials, serviceName: String, region: String) {
        self.credentials = credentials
        self.serviceName = serviceName
        self.region = region
    }

    /// Create a SigV4 Signed URL
    /// - Parameters:
    ///   - url: URL to be signed.
    ///   - method: Method
    ///   - body: Optional body to be included in the request (default is `nil`)
    ///   - headers: Headers to be included in the signed url.
    ///   You don't beed to pass in the `host` header - `host:<host>` is added automatically.
    ///   - date: Current date. (default is `Date()`)
    ///   - expires: Expiration time of the presigned url (default is `300` seconds)
    /// - Returns: A SigV4 Signed URLRequest
    public func sign(
        url: URL,
        method: HTTPMethod = .get,
        body: RequestBody? = nil,
        headers: [String: String] = [:],
        date: () -> Date = { .init() },
        expires: Int = 300
    ) -> URLRequest {
        let date = date()
        let timestamp = _timeFormatter.string(from: date)
        let datestamp = _dateFormatter.string(from: date)

        var headersToAdd = [
            "host": "\(url.hostWithPort)",
            "X-Amz-Date": timestamp
        ]
        if let sessionToken = credentials.sessionToken {
            headersToAdd["X-Amz-Security-Token"] = sessionToken
        }
        let headers = headers.merging(
            headersToAdd,
            uniquingKeysWith: { _, new in new }
        )

        let url = url.path.isEmpty
        ? url.appendingPathComponent("/")
        : url

        let hashedPayload = _hashedPayload(body)
        let headersToSign = headers
            .filter { $0.key != "Authorization" }

        let canonicalURI = PercentEncoding.uriWithSlash.encode(url.path)
        let canonicalHeaders = _canonicalHeaders(headersToSign)
        let signedHeaders = _signedHeaders(headersToSign)
        let credentialScope = _credentialScope(
            datestamp: datestamp,
            region: region,
            serviceName: serviceName
        )

        let canonicalQueryString = _canonicalQueryString(
            query: url.query
        )

        let canonicalRequest = _canonicalRequest(
            method: method,
            canonicalURI: canonicalURI,
            canonicalQueryString: canonicalQueryString,
            canonicalHeaders: canonicalHeaders,
            signedHeaders: signedHeaders,
            hashedPayload: hashedPayload
        )

        let stringToSign = _stringToSign(
            canonicalRequest: canonicalRequest,
            credentialScope: credentialScope,
            timestamp: timestamp
        )

        let signingKey = _signingKey(
            region: region,
            secretKey: credentials.secret,
            datestamp: datestamp
        )

        let signature = _hash(data: stringToSign, key: signingKey).hexDigest()
        let authorizationHeader = "AWS4-HMAC-SHA256 Credential=\(credentials.accessKey)/\(credentialScope),SignedHeaders=\(signedHeaders),Signature=\(signature)"
        var request = URLRequest(url: url)
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        request.httpMethod = method.verb
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")

        return request
    }

    // "<datestamp>/<region>/<service-name>/aws4_request"
    func _credentialScope(datestamp: String, region: String, serviceName: String) -> String {
        [datestamp, region, serviceName, "aws4_request"]
            .joined(separator: "/")
    }

    // Keys of the headers to be included in the signature calculation
    // delimited by `;`
    func _signedHeaders(_ headers: [String: String]) -> String {
        headers
            .lazy
            .map(\.key)
            .map { $0.lowercased() }
            .sorted()
            .joined(separator: ";")
    }

    // Canoincal headers portion of the canonical request
    func _canonicalHeaders(_ headers: [String: String]) -> String {
        headers.map { header in
            "\(header.key.lowercased()):\(header.value.trimmingCharacters(in: .whitespaces))"
        }
        .sorted()
        .joined(separator: "\n")
    }

    /**
     -

            """
            HTTP Verb
            Canonical URI
            Canonical Query String
            Canonical Headers

            Signed Headers
            Hashed Payload
            """
     */
    func _canonicalRequest(
        method: HTTPMethod,
        canonicalURI: String,
        canonicalQueryString: String,
        canonicalHeaders: String,
        signedHeaders: String,
        hashedPayload: String
    ) -> Data {
        let canonicalRequest = """
        \(method.verb)
        \(canonicalURI)
        \(canonicalQueryString)
        \(canonicalHeaders)

        \(signedHeaders)
        \(hashedPayload)
        """

        return Data(canonicalRequest.utf8)
    }

    func _canonicalQueryString(
        query: String?
    ) -> String {
        guard let query, !query.isEmpty else { return "" }

        return query.split(separator: "&")
            .map {
                String($0).split(separator: "=")
                    .map(String.init)
                    .map(PercentEncoding.uri.encode)
                    .joined(separator: "=")
            }
            .sorted()
            .joined(separator: "&")
    }

    /// String to Sign portion of the signed url
    ///
    ///     """
    ///     AWS4-HMAC-SHA256
    ///     <timestamp>
    ///     <credential-scope>
    ///     <canonical-request-hash>
    ///     """
    func _stringToSign(
        canonicalRequest: Data,
        credentialScope: String,
        timestamp: String
    ) -> Data {
        let canonicalRequestHash = SHA256.hash(data: canonicalRequest).hexDigest()
        let stringToSign = """
        AWS4-HMAC-SHA256
        \(timestamp)
        \(credentialScope)
        \(canonicalRequestHash)
        """
        return Data(stringToSign.utf8)
    }

    // Tiny helper used extensively here to reduce a few characters
    func _data(_ s: String) -> Data { .init(s.utf8) }

    // HMAC SHA256 Hash of data using a key
    func _hash<D: ContiguousBytes>(
        data: Data,
        key: D
    ) -> HashedAuthenticationCode<SHA256> {
        HMAC<SHA256>.authenticationCode(
            for: data,
            using: SymmetricKey(data: key)
        )
    }

    // Generates the signing key used as the key to sign
    // the `String to Sign`
    func _signingKey(
        region: String,
        secretKey: String,
        datestamp: String
    ) -> Data {
        let secret = Data("AWS4\(credentials.secret)".utf8)
        let dateKey = _hash(
            data: _data(datestamp),
            key: secret
        )
        let dateRegionKey = _hash(data: _data(region), key: dateKey)
        let dateRegionServiceKey = _hash(data: _data(serviceName), key: dateRegionKey)
        let signingKey = _hash(data: _data("aws4_request"), key: dateRegionServiceKey)

        return Data(signingKey)
    }

    // Helper that hashes a payload or returns a hashed empty
    // body if the payload is nil
    func _hashedPayload(_ payload: RequestBody?) -> String {
        guard let payload else { return Self.hashedEmptyBody }
        let hash = payload.hash(payload.input)
        return hash
    }
}