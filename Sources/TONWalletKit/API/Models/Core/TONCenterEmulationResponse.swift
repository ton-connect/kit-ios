//  TONCenterEmulationResponse.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 13.10.2025.
//

import Foundation

public struct TONCenterEmulationResponse: Codable {
    public let mcBlockSeqno: Int?
    public let trace: TONEmulationTraceNode?
    public let transactions: [String: TONCenterTransaction]?
    public let actions: [TONEmulationAction]?
    public let codeCells: [String: String]?
    public let dataCells: [String: String]?
    public let addressBook: [String: TONEmulationAddressBookEntry]?
    public let metadata: [String: TONEmulationAddressMetadata]?
    public let randSeed: String?
    public let isIncomplete: Bool?

    enum CodingKeys: String, CodingKey {
        case mcBlockSeqno = "mc_block_seqno"
        case trace
        case transactions
        case actions
        case codeCells = "code_cells"
        case dataCells = "data_cells"
        case addressBook = "address_book"
        case metadata
        case randSeed = "rand_seed"
        case isIncomplete = "is_incomplete"
    }
}

public struct TONEmulationTraceNode: Codable {
    public let txHash: String?
    public let inMsgHash: String?
    public let children: [TONEmulationTraceNode]?

    enum CodingKeys: String, CodingKey {
        case txHash = "tx_hash"
        case inMsgHash = "in_msg_hash"
        case children
    }
}

public struct TONCenterTransaction: Codable {
    public let account: String?
    public let hash: String?
    public let lt: String?
    public let now: Int?
    public let mcBlockSeqno: Int?
    public let traceExternalHash: String?
    public let prevTransHash: String?
    public let prevTransLt: String?
    public let origStatus: String?
    public let endStatus: String?
    public let totalFees: String?
    public let totalFeesExtraCurrencies: [String: String]?
    public let description: TONEmulationTransactionDescription?
    public let blockRef: TONEmulationBlockRef?
    public let inMsg: TONEmulationMessage?
    public let outMsgs: [TONEmulationMessage]?
    public let accountStateBefore: TONEmulationAccountState?
    public let accountStateAfter: TONEmulationAccountState?
    public let emulated: Bool?
    public let traceId: String?

    enum CodingKeys: String, CodingKey {
        case account
        case hash
        case lt
        case now
        case mcBlockSeqno = "mc_block_seqno"
        case traceExternalHash = "trace_external_hash"
        case prevTransHash = "prev_trans_hash"
        case prevTransLt = "prev_trans_lt"
        case origStatus = "orig_status"
        case endStatus = "end_status"
        case totalFees = "total_fees"
        case totalFeesExtraCurrencies = "total_fees_extra_currencies"
        case description
        case blockRef = "block_ref"
        case inMsg = "in_msg"
        case outMsgs = "out_msgs"
        case accountStateBefore = "account_state_before"
        case accountStateAfter = "account_state_after"
        case emulated
        case traceId = "trace_id"
    }
}

public struct TONEmulationBlockRef: Codable {
    public let workchain: Int?
    public let shard: String?
    public let seqno: Int?
}

public struct TONEmulationTransactionDescription: Codable {
    public let type: String
    public let aborted: Bool
    public let destroyed: Bool
    public let creditFirst: Bool
    public let isTock: Bool
    public let installed: Bool
    public let storagePh: TONEmulationStoragePh
    public let creditPh: TONEmulationCreditPh
    public let computePh: TONEmulationComputePh
    public let action: TONEmulationActionDescription

    enum CodingKeys: String, CodingKey {
        case type
        case aborted
        case destroyed
        case creditFirst = "credit_first"
        case isTock = "is_tock"
        case installed
        case storagePh = "storage_ph"
        case creditPh = "credit_ph"
        case computePh = "compute_ph"
        case action
    }
}

public struct TONEmulationStoragePh: Codable {
    public let storageFeesCollected: String?
    public let statusChange: String?

    enum CodingKeys: String, CodingKey {
        case storageFeesCollected = "storage_fees_collected"
        case statusChange = "status_change"
    }
}

public struct TONEmulationCreditPh: Codable {
    public let credit: String?
}

public struct TONEmulationComputePh: Codable {
    public let skipped: Bool?
    public let success: Bool?
    public let msgStateUsed: Bool?
    public let accountActivated: Bool?
    public let gasFees: String?
    public let gasUsed: String?
    public let gasLimit: String?
    public let gasCredit: String?
    public let mode: Int?
    public let exitCode: Int?
    public let vmSteps: Int?
    public let vmInitStateHash: String?
    public let vmFinalStateHash: String?

    enum CodingKeys: String, CodingKey {
        case skipped
        case success
        case msgStateUsed = "msg_state_used"
        case accountActivated = "account_activated"
        case gasFees = "gas_fees"
        case gasUsed = "gas_used"
        case gasLimit = "gas_limit"
        case gasCredit = "gas_credit"
        case mode
        case exitCode = "exit_code"
        case vmSteps = "vm_steps"
        case vmInitStateHash = "vm_init_state_hash"
        case vmFinalStateHash = "vm_final_state_hash"
    }
}

public struct TONEmulationActionDescription: Codable {
    public let success: Bool?
    public let valid: Bool?
    public let noFunds: Bool?
    public let statusChange: String?
    public let totalFwdFees: String?
    public let totalActionFees: String?
    public let resultCode: Int?
    public let totActions: Int?
    public let specActions: Int?
    public let skippedActions: Int?
    public let msgsCreated: Int?
    public let actionListHash: String?
    public let totMsgSize: TONEmulationMsgSize?

    enum CodingKeys: String, CodingKey {
        case success
        case valid
        case noFunds = "no_funds"
        case statusChange = "status_change"
        case totalFwdFees = "total_fwd_fees"
        case totalActionFees = "total_action_fees"
        case resultCode = "result_code"
        case totActions = "tot_actions"
        case specActions = "spec_actions"
        case skippedActions = "skipped_actions"
        case msgsCreated = "msgs_created"
        case actionListHash = "action_list_hash"
        case totMsgSize = "tot_msg_size"
    }
}

public struct TONEmulationMsgSize: Codable {
    public let cells: String?
    public let bits: String?
}

public struct TONEmulationMessage: Codable {
    public let hash: String?
    public let source: String?
    public let destination: String
    public let value: String?
    public let valueExtraCurrencies: [String: String]?
    public let fwdFee: String?
    public let ihrFee: String?
    public let createdLt: String?
    public let createdAt: String?
    public let opcode: String?
    public let ihrDisabled: Bool?
    public let bounce: Bool?
    public let bounced: Bool?
    public let importFee: String?
    public let messageContent: TONEmulationMessageContent?
    public let initState: String?
    public let hashNorm: String?

    enum CodingKeys: String, CodingKey {
        case hash
        case source
        case destination
        case value
        case valueExtraCurrencies = "value_extra_currencies"
        case fwdFee = "fwd_fee"
        case ihrFee = "ihr_fee"
        case createdLt = "created_lt"
        case createdAt = "created_at"
        case opcode
        case ihrDisabled = "ihr_disabled"
        case bounce
        case bounced
        case importFee = "import_fee"
        case messageContent = "message_content"
        case initState = "init_state"
        case hashNorm = "hash_norm"
    }
}

public struct TONEmulationMessageContent: Codable {
    public let hash: String?
    public let body: String?
    public let decoded: String?
}

public struct TONEmulationAccountState: Codable {
    public let hash: String?
    public let balance: String?
    public let extraCurrencies: [String: String]?
    public let accountStatus: String?
    public let frozenHash: String?
    public let dataHash: String?
    public let codeHash: String?

    enum CodingKeys: String, CodingKey {
        case hash
        case balance
        case extraCurrencies = "extra_currencies"
        case accountStatus = "account_status"
        case frozenHash = "frozen_hash"
        case dataHash = "data_hash"
        case codeHash = "code_hash"
    }
}

public struct TONEmulationAction: Codable {
    public let traceId: String?
    public let actionId: String?
    public let startLt: String?
    public let endLt: String?
    public let startUtime: Int?
    public let endUtime: Int?
    public let traceEndLt: String?
    public let traceEndUtime: Int?
    public let traceMcSeqnoEnd: Int?
    public let transactions: [String]?
    public let success: Bool?
    public let type: String?
    public let traceExternalHash: String?
    public let accounts: [String]?
    public let details: TONEmulationActionDetails?

    enum CodingKeys: String, CodingKey {
        case traceId = "trace_id"
        case actionId = "action_id"
        case startLt = "start_lt"
        case endLt = "end_lt"
        case startUtime = "start_utime"
        case endUtime = "end_utime"
        case traceEndLt = "trace_end_lt"
        case traceEndUtime = "trace_end_utime"
        case traceMcSeqnoEnd = "trace_mc_seqno_end"
        case transactions
        case success
        case type
        case traceExternalHash = "trace_external_hash"
        case accounts
        case details
    }
}

public enum TONEmulationActionDetails: Codable {
    case jettonSwap(TONEmulationJettonSwapDetails)
    case callContract(TONEmulationCallContractDetails)
    case unknown([String: String])

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let _ = try? container.decode(String.self, forKey: .dex) {
            let value = try TONEmulationJettonSwapDetails(from: decoder)
            self = .jettonSwap(value)
            return
        }
        if let _ = try? container.decode(String.self, forKey: .opcode) {
            let value = try TONEmulationCallContractDetails(from: decoder)
            self = .callContract(value)
            return
        }
        let value = try [String: String](from: decoder)
        self = .unknown(value)
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .jettonSwap(let value):
            try value.encode(to: encoder)
        case .callContract(let value):
            try value.encode(to: encoder)
        case .unknown(let value):
            try value.encode(to: encoder)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case dex
        case opcode
    }
}

public struct TONEmulationJettonSwapDetails: Codable {
    public let dex: String?
    public let sender: String?
    public let assetIn: String?
    public let assetOut: String?
    public let dexIncomingTransfer: TONEmulationJettonTransfer?
    public let dexOutgoingTransfer: TONEmulationJettonTransfer?
    public let peerSwaps: [String]?

    enum CodingKeys: String, CodingKey {
        case dex
        case sender
        case assetIn = "asset_in"
        case assetOut = "asset_out"
        case dexIncomingTransfer = "dex_incoming_transfer"
        case dexOutgoingTransfer = "dex_outgoing_transfer"
        case peerSwaps = "peer_swaps"
    }
}

public struct TONEmulationJettonTransfer: Codable {
    public let asset: String?
    public let source: String?
    public let destination: String?
    public let sourceJettonWallet: String?
    public let destinationJettonWallet: String?
    public let amount: String?

    enum CodingKeys: String, CodingKey {
        case asset
        case source
        case destination
        case sourceJettonWallet = "source_jetton_wallet"
        case destinationJettonWallet = "destination_jetton_wallet"
        case amount
    }
}

public struct TONEmulationCallContractDetails: Codable {
    public let opcode: String?
    public let source: String?
    public let destination: String?
    public let value: String?
    public let extraCurrencies: [String: String]?

    enum CodingKeys: String, CodingKey {
        case opcode
        case source
        case destination
        case value
        case extraCurrencies = "extra_currencies"
    }
}

public struct TONEmulationAddressBookEntry: Codable {
    public let userFriendly: String?
    public let domain: String?

    enum CodingKeys: String, CodingKey {
        case userFriendly = "user_friendly"
        case domain
    }
}

public struct TONEmulationAddressMetadata: Codable {
    public let isIndexed: Bool?
    public let tokenInfo: [TONEmulationTokenInfo]?

    enum CodingKeys: String, CodingKey {
        case isIndexed = "is_indexed"
        case tokenInfo = "token_info"
    }
}

public struct TONEmulationTokenInfo: Codable {
    public let valid: Bool?
    public let type: String?
    public let extra: TONEmulationTokenInfoExtra?
}

public struct TONEmulationTokenInfoExtra: Codable {
    public let balance: String?
    public let jetton: String?
    public let owner: String?
    public let name: String?
    public let symbol: String?
    public let description: String?
    public let image: String?
    public let decimals: String?
    public let uri: String?
    public let websites: [String]?
}
