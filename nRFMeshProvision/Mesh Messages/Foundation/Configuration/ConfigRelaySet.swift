/*
* Copyright (c) 2019, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation

public struct ConfigRelaySet: AcknowledgedConfigMessage {
    public static let opCode: UInt32 = 0x8027
    public static let responseType: StaticMeshMessage.Type = ConfigRelayStatus.self
    
    public var parameters: Data? {
        return Data([state.rawValue]) + ((count & 0x07) | steps << 3)
    }
    
    /// The new Relay state for the Node.
    public let state: NodeFeatureState
    /// Number of retransmissions on advertising bearer for each Network PDU
    /// relayed by the Node. Possible values are 0...7, which correspond to
    /// 1-8 transmissions in total.
    public let count: UInt8
    /// Number of 10-millisecond steps between retransmissions, decremented by 1.
    /// Possible values are 0...31, which corresponds to 10-320 milliseconds
    /// intervals.
    public let steps: UInt8
    /// The interval between retransmissions, in seconds.
    public var interval: TimeInterval {
        return TimeInterval(steps + 1) / 100
    }
    
    /// Disables the Relay on the Node.
    public init() {
        self.state = .notEnabled
        self.count = 0
        self.steps = 0
    }
    
    /// Enables and sets the Relay settings on the Node.
    ///
    /// - parameter count: Number of retransmissions on advertising bearer
    ///                    for each Network PDU relayed by the Node. Possible
    ///                    values are 0...7, which correspond to 1-8 transmissions
    ///                    in total.
    /// - parameter steps: Number of 10-millisecond steps between retransmissions,
    ///                    decremented by 1. Possible values are 0...31, which
    ///                    corresponds to 10-320 milliseconds intervals.
    public init(count: UInt8, steps: UInt8) {
        self.state = .enabled
        self.count = min(7, count)
        self.steps = min(31, steps)
    }
    
    /// Enables and sets the Relay settings on the Node.
    ///
    /// - parameter relayRetransmit: The Relay Retranmission settings.
    /// - since: 4.0.0 
    public init(_ relayRetransmit: Node.RelayRetransmit) {
        self.state = .enabled
        self.count = relayRetransmit.count - 1
        self.steps = relayRetransmit.steps
    }
    
    public init?(parameters: Data) {
        guard parameters.count == 2 else {
            return nil
        }
        guard let state = NodeFeatureState(rawValue: parameters[0]) else {
            return nil
        }
        self.state = state
        self.count = parameters[1] & 0x07
        self.steps = parameters[1] >> 3
    }
    
}
