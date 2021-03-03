//
//
//  Confirmation3DSDataACS.swift
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

public struct Confirmation3DSDataACS: Codable {
    var acsUrl: String
    var acsTransId: String
    var tdsServerTransId: String

    enum CodingKeys: String, CodingKey {
        case acsUrl = "ACSUrl"
        case acsTransId = "AcsTransId"
        case tdsServerTransId = "TdsServerTransId"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        acsUrl = try container.decode(String.self, forKey: .acsUrl)
        acsTransId = try container.decode(String.self, forKey: .acsTransId)
        tdsServerTransId = try container.decode(String.self, forKey: .tdsServerTransId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(acsUrl, forKey: .acsUrl)
        try container.encode(acsTransId, forKey: .acsTransId)
        try container.encode(tdsServerTransId, forKey: .tdsServerTransId)
    }
}
