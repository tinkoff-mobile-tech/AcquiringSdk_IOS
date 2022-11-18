//
//
//  Submit3DSAuthorizationV2Request.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public struct Submit3DSAuthorizationV2Request: AcquiringRequest {
    public static let path: String = "v2/Submit3DSAuthorizationV2"
    var path: String { Self.path }

    let baseURL: URL
    let httpMethod: HTTPMethod = .post
    let parametersEncoding: ParametersEncoding = .urlEncodedForm
    let parameters: HTTPParameters
    let terminalKeyProvidingStrategy: TerminalKeyProvidingStrategy
    let tokenFormationStrategy: TokenFormationStrategy

    init(data: Submit3DSAuthorizationV2Data, baseURL: URL) {
        if data.paymentId != nil {
            terminalKeyProvidingStrategy = .always
            tokenFormationStrategy = .includeAll(except: Constants.Keys.cres)
        } else {
            terminalKeyProvidingStrategy = .never
            tokenFormationStrategy = .none
        }

        self.baseURL = baseURL
        let dict = Self.formParamsDictionary(from: data)
        parameters = (try? dict.encode2JSONObject(dateEncodingStrategy: .iso8601)) ?? [:]
    }
}

extension Submit3DSAuthorizationV2Request {

    static func formParamsDictionary(from data: Submit3DSAuthorizationV2Data) -> [String: String] {
        if let paymentId = data.paymentId {
            return [Constants.Keys.paymentId: paymentId]
        }

        if let cres = data.cres {
            return [Constants.Keys.cres: cres]
        }

        return [:]
    }
}