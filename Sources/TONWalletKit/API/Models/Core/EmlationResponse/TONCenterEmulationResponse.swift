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
    public let codeCells: [String: String]? // base64-encoded cells by code hash
    public let dataCells: [String: String]? // base64-encoded cells by code hash
    public let addressBook: [String: TONEmulationAddressBookEntry]?
    public let metadata: [String: TONEmulationAddressMetadata]?
    public let randSeed: String?
    public let isIncomplete: Bool?
    
    public init(
        mcBlockSeqno: Int?,
        trace: TONEmulationTraceNode?,
        transactions: [String : TONCenterTransaction]?,
        actions: [TONEmulationAction]?,
        codeCells: [String: String]?,
        dataCells: [String: String]?,
        addressBook: [String: TONEmulationAddressBookEntry]?,
        metadata: [String: TONEmulationAddressMetadata]?,
        randSeed: String?,
        isIncomplete: Bool?
    ) {
        self.mcBlockSeqno = mcBlockSeqno
        self.trace = trace
        self.transactions = transactions
        self.actions = actions
        self.codeCells = codeCells
        self.dataCells = dataCells
        self.addressBook = addressBook
        self.metadata = metadata
        self.randSeed = randSeed
        self.isIncomplete = isIncomplete
    }
    
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

    public init(
        txHash: String?,
        inMsgHash: String?,
        children: [TONEmulationTraceNode]?
    ) {
        self.txHash = txHash
        self.inMsgHash = inMsgHash
        self.children = children
    }
    
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
    public let origStatus: TONEmulationAccountStatus?
    public let endStatus: TONEmulationAccountStatus?
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

    public init(
        account: String?,
        hash: String?,
        lt: String?,
        now: Int?,
        mcBlockSeqno: Int?,
        traceExternalHash: String?,
        prevTransHash: String?,
        prevTransLt: String?,
        origStatus: TONEmulationAccountStatus?,
        endStatus: TONEmulationAccountStatus?,
        totalFees: String?,
        totalFeesExtraCurrencies: [String : String]?,
        description: TONEmulationTransactionDescription?,
        blockRef: TONEmulationBlockRef?,
        inMsg: TONEmulationMessage?,
        outMsgs: [TONEmulationMessage]?,
        accountStateBefore: TONEmulationAccountState?,
        accountStateAfter: TONEmulationAccountState?,
        emulated: Bool?,
        traceId: String?
    ) {
        self.account = account
        self.hash = hash
        self.lt = lt
        self.now = now
        self.mcBlockSeqno = mcBlockSeqno
        self.traceExternalHash = traceExternalHash
        self.prevTransHash = prevTransHash
        self.prevTransLt = prevTransLt
        self.origStatus = origStatus
        self.endStatus = endStatus
        self.totalFees = totalFees
        self.totalFeesExtraCurrencies = totalFeesExtraCurrencies
        self.description = description
        self.blockRef = blockRef
        self.inMsg = inMsg
        self.outMsgs = outMsgs
        self.accountStateBefore = accountStateBefore
        self.accountStateAfter = accountStateAfter
        self.emulated = emulated
        self.traceId = traceId
    }
    
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

public enum TONEmulationAccountStatus: Codable {
    case active
    case frozen
    case uninit
    case unknown(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        switch value.lowercased() {
        case "active":
            self = .active
        case "frozen":
            self = .frozen
        case "uninit":
            self = .uninit
        default:
            self = .unknown(value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .active:
            try container.encode("active")
        case .frozen:
            try container.encode("frozen")
        case .uninit:
            try container.encode("uninit")
        case .unknown(let value):
            try container.encode(value)
        }
    }
}

public enum TONEmulationStatusChange: Codable {
    case unchanged
    case unknown(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        switch value.lowercased() {
        case "unchanged":
            self = .unchanged
        default:
            self = .unknown(value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .unchanged:
            try container.encode("unchanged")
        case .unknown(let value):
            try container.encode(value)
        }
    }
}

public struct TONEmulationBlockRef: Codable {
    public let workchain: Int?
    public let shard: String?
    public let seqno: Int?
    
    public init(workchain: Int?, shard: String?, seqno: Int?) {
        self.workchain = workchain
        self.shard = shard
        self.seqno = seqno
    }
}

public struct TONEmulationTransactionDescription: Codable {
    public let type: String
    public let aborted: Bool
    public let destroyed: Bool
    public let creditFirst: Bool
    public let isTock: Bool
    public let installed: Bool
    public let storagePh: TONEmulationStoragePh?
    public let creditPh: TONEmulationCreditPh?
    public let computePh: TONEmulationComputePh?
    public let action: TONEmulationActionDescription?

    public init(
        type: String,
        aborted: Bool,
        destroyed: Bool,
        creditFirst: Bool,
        isTock: Bool,
        installed: Bool,
        storagePh: TONEmulationStoragePh?,
        creditPh: TONEmulationCreditPh?,
        computePh: TONEmulationComputePh?,
        action: TONEmulationActionDescription?
    ) {
        self.type = type
        self.aborted = aborted
        self.destroyed = destroyed
        self.creditFirst = creditFirst
        self.isTock = isTock
        self.installed = installed
        self.storagePh = storagePh
        self.creditPh = creditPh
        self.computePh = computePh
        self.action = action
    }
    
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
    public let statusChange: TONEmulationStatusChange?

    public init(
        storageFeesCollected: String?,
        statusChange: TONEmulationStatusChange?
    ) {
        self.storageFeesCollected = storageFeesCollected
        self.statusChange = statusChange
    }
    
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

    public init(
        skipped: Bool?,
        success: Bool?,
        msgStateUsed: Bool?,
        accountActivated: Bool?,
        gasFees: String?,
        gasUsed: String?,
        gasLimit: String?,
        gasCredit: String?,
        mode: Int?,
        exitCode: Int?,
        vmSteps: Int?,
        vmInitStateHash: String?,
        vmFinalStateHash: String?
    ) {
        self.skipped = skipped
        self.success = success
        self.msgStateUsed = msgStateUsed
        self.accountActivated = accountActivated
        self.gasFees = gasFees
        self.gasUsed = gasUsed
        self.gasLimit = gasLimit
        self.gasCredit = gasCredit
        self.mode = mode
        self.exitCode = exitCode
        self.vmSteps = vmSteps
        self.vmInitStateHash = vmInitStateHash
        self.vmFinalStateHash = vmFinalStateHash
    }
    
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
    public let statusChange: TONEmulationStatusChange // base64-encoded cells by code hash?
    public let totalFwdFees: String?
    public let totalActionFees: String?
    public let resultCode: Int?
    public let totActions: Int?
    public let specActions: Int?
    public let skippedActions: Int?
    public let msgsCreated: Int?
    public let actionListHash: String?
    public let totMsgSize: TONEmulationMsgSize?

    public init(
        success: Bool?,
        valid: Bool?,
        noFunds: Bool?,
        statusChange: TONEmulationStatusChange,
        totalFwdFees: String?,
        totalActionFees: String?,
        resultCode: Int?,
        totActions: Int?,
        specActions: Int?,
        skippedActions: Int?,
        msgsCreated: Int?,
        actionListHash: String?,
        totMsgSize: TONEmulationMsgSize?
    ) {
        self.success = success
        self.valid = valid
        self.noFunds = noFunds
        self.statusChange = statusChange
        self.totalFwdFees = totalFwdFees
        self.totalActionFees = totalActionFees
        self.resultCode = resultCode
        self.totActions = totActions
        self.specActions = specActions
        self.skippedActions = skippedActions
        self.msgsCreated = msgsCreated
        self.actionListHash = actionListHash
        self.totMsgSize = totMsgSize
    }
    
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
    
    public init(
        cells: String?,
        bits: String?
    ) {
        self.cells = cells
        self.bits = bits
    }
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

    public init(
        hash: String?,
        source: String?,
        destination: String,
        value: String?,
        valueExtraCurrencies: [String : String]?,
        fwdFee: String?,
        ihrFee: String?,
        createdLt: String?,
        createdAt: String?,
        opcode: String?,
        ihrDisabled: Bool?,
        bounce: Bool?,
        bounced: Bool?,
        importFee: String?,
        messageContent: TONEmulationMessageContent?,
        initState: String?,
        hashNorm: String?
    ) {
        self.hash = hash
        self.source = source
        self.destination = destination
        self.value = value
        self.valueExtraCurrencies = valueExtraCurrencies
        self.fwdFee = fwdFee
        self.ihrFee = ihrFee
        self.createdLt = createdLt
        self.createdAt = createdAt
        self.opcode = opcode
        self.ihrDisabled = ihrDisabled
        self.bounce = bounce
        self.bounced = bounced
        self.importFee = importFee
        self.messageContent = messageContent
        self.initState = initState
        self.hashNorm = hashNorm
    }
    
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
    public let body: String? // base64-encoded body
    public let decoded: AnyCodable?
    
    public init(
        hash: String?,
        body: String?,
        decoded: AnyCodable?
    ) {
        self.hash = hash
        self.body = body
        self.decoded = decoded
    }
}

public struct TONEmulationAccountState: Codable {
    public let hash: String?
    public let balance: String?
    public let extraCurrencies: [String: String]?
    public let accountStatus: TONEmulationAccountStatus?
    public let frozenHash: String?
    public let dataHash: String?
    public let codeHash: String?

    public init(
        hash: String?,
        balance: String?,
        extraCurrencies: [String : String]?,
        accountStatus: TONEmulationAccountStatus?,
        frozenHash: String?,
        dataHash: String?,
        codeHash: String?
    ) {
        self.hash = hash
        self.balance = balance
        self.extraCurrencies = extraCurrencies
        self.accountStatus = accountStatus
        self.frozenHash = frozenHash
        self.dataHash = dataHash
        self.codeHash = codeHash
    }
    
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
    public let type: TONEmulationActionType?
    public let traceExternalHash: String?
    public let accounts: [String]?
    public let details: TONEmulationActionDetails?

    public init(
        traceId: String?,
        actionId: String?,
        startLt: String?,
        endLt: String?,
        startUtime: Int?,
        endUtime: Int?,
        traceEndLt: String?,
        traceEndUtime: Int?,
        traceMcSeqnoEnd: Int?,
        transactions: [String]?,
        success: Bool?,
        type: TONEmulationActionType?,
        traceExternalHash: String?,
        accounts: [String]?,
        details: TONEmulationActionDetails?
    ) {
        self.traceId = traceId
        self.actionId = actionId
        self.startLt = startLt
        self.endLt = endLt
        self.startUtime = startUtime
        self.endUtime = endUtime
        self.traceEndLt = traceEndLt
        self.traceEndUtime = traceEndUtime
        self.traceMcSeqnoEnd = traceMcSeqnoEnd
        self.transactions = transactions
        self.success = success
        self.type = type
        self.traceExternalHash = traceExternalHash
        self.accounts = accounts
        self.details = details
    }
    
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

public enum TONEmulationActionType: Codable {
    case jettonSwap
    case callContract
    case unknown(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        switch value.lowercased() {
        case "jetton_swap":
            self = .jettonSwap
        case "call_contract":
            self = .callContract
        default:
            self = .unknown(value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .jettonSwap:
            try container.encode("jetton_swap")
        case .callContract:
            try container.encode("call_contract")
        case .unknown(let value):
            try container.encode(value)
        }
    }
}

public enum TONEmulationActionDetails: Codable {
    case jettonSwap(TONEmulationJettonSwapDetails)
    case callContract(TONEmulationCallContractDetails)
    case unknown([String: AnyCodable])

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
        let value = try [String: AnyCodable](from: decoder)
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

    public init(
        dex: String?,
        sender: String?,
        assetIn: String?,
        assetOut: String?,
        dexIncomingTransfer: TONEmulationJettonTransfer?,
        dexOutgoingTransfer: TONEmulationJettonTransfer?,
        peerSwaps: [String]?
    ) {
        self.dex = dex
        self.sender = sender
        self.assetIn = assetIn
        self.assetOut = assetOut
        self.dexIncomingTransfer = dexIncomingTransfer
        self.dexOutgoingTransfer = dexOutgoingTransfer
        self.peerSwaps = peerSwaps
    }
    
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

    public init(
        asset: String?,
        source: String?,
        destination: String?,
        sourceJettonWallet: String?,
        destinationJettonWallet: String?,
        amount: String?
    ) {
        self.asset = asset
        self.source = source
        self.destination = destination
        self.sourceJettonWallet = sourceJettonWallet
        self.destinationJettonWallet = destinationJettonWallet
        self.amount = amount
    }
    
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

    public init(
        opcode: String?,
        source: String?,
        destination: String?,
        value: String?,
        extraCurrencies: [String : String]?
    ) {
        self.opcode = opcode
        self.source = source
        self.destination = destination
        self.value = value
        self.extraCurrencies = extraCurrencies
    }
    
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

    public init(
        userFriendly: String?,
        domain: String?
    ) {
        self.userFriendly = userFriendly
        self.domain = domain
    }
    
    enum CodingKeys: String, CodingKey {
        case userFriendly = "user_friendly"
        case domain
    }
}

public struct TONEmulationAddressMetadata: Codable {
    public let isIndexed: Bool?
    public let tokenInfo: [TONEmulationTokenInfo]?

    public init(
        isIndexed: Bool?,
        tokenInfo: [TONEmulationTokenInfo]?
    ) {
        self.isIndexed = isIndexed
        self.tokenInfo = tokenInfo
    }
    
    enum CodingKeys: String, CodingKey {
        case isIndexed = "is_indexed"
        case tokenInfo = "token_info"
    }
}

public enum TONEmulationTokenInfo: Codable {
    case wallets(TONEmulationTokenInfoWallets)
    case masters(TONEmulationTokenInfoMasters)
    case unknown(TONEmulationTokenInfoBase)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "jetton_wallets":
            let wallets = try TONEmulationTokenInfoWallets(from: decoder)
            self = .wallets(wallets)
        case "jetton_masters":
            let masters = try TONEmulationTokenInfoMasters(from: decoder)
            self = .masters(masters)
        default:
            let base = try TONEmulationTokenInfoBase(from: decoder)
            self = .unknown(base)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .wallets(let wallets):
            try wallets.encode(to: encoder)
        case .masters(let masters):
            try masters.encode(to: encoder)
        case .unknown(let base):
            try base.encode(to: encoder)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
}

public struct TONEmulationTokenInfoBase: Codable {
    public let valid: Bool
    public let type: String
    public let additionalProperties: [String: AnyCodable]?
    
    public init(
        valid: Bool,
        type: String,
        additionalProperties: [String: AnyCodable]? = nil
    ) {
        self.valid = valid
        self.type = type
        self.additionalProperties = additionalProperties
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        valid = try container.decode(Bool.self, forKey: .valid)
        type = try container.decode(String.self, forKey: .type)
        
        // Decode additional unknown properties
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var additional: [String: AnyCodable] = [:]
        
        let knownKeys = Set(CodingKeys.allCases.map { $0.stringValue })
        
        for key in dynamicContainer.allKeys {
            if !knownKeys.contains(key.stringValue) {
                if let value = try? dynamicContainer.decode(AnyCodable.self, forKey: key) {
                    additional[key.stringValue] = value
                }
            }
        }
        
        additionalProperties = additional.isEmpty ? nil : additional
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(valid, forKey: .valid)
        try container.encode(type, forKey: .type)
        
        // Encode additional properties
        if let additionalProperties = additionalProperties {
            var dynamicContainer = encoder.container(keyedBy: DynamicCodingKeys.self)
            for (key, value) in additionalProperties {
                let codingKey = DynamicCodingKeys(stringValue: key)!
                try dynamicContainer.encode(value, forKey: codingKey)
            }
        }
    }
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case valid, type
    }
}

public struct TONEmulationTokenInfoMasters: Codable {
    public let type: String = "jetton_masters"
    public let valid: Bool
    public let name: String
    public let symbol: String
    public let description: String
    public let image: String?
    public let extra: Extra
    
    public init(
        valid: Bool,
        name: String,
        symbol: String,
        description: String,
        image: String? = nil,
        extra: Extra
    ) {
        self.valid = valid
        self.name = name
        self.symbol = symbol
        self.description = description
        self.image = image
        self.extra = extra
    }
    
    public struct Extra: Codable {
        public let imageBig: String?
        public let imageMedium: String?
        public let imageSmall: String?
        public let imageData: String? // base64 encoded image data
        public let social: [String]?
        public let uri: String?
        public let websites: [String]?
        public let additionalProperties: [String: AnyCodable]?
        
        public init(
            imageBig: String? = nil,
            imageMedium: String? = nil,
            imageSmall: String? = nil,
            imageData: String? = nil,
            social: [String]? = nil,
            uri: String? = nil,
            websites: [String]? = nil,
            additionalProperties: [String: AnyCodable]? = nil
        ) {
            self.imageBig = imageBig
            self.imageMedium = imageMedium
            self.imageSmall = imageSmall
            self.imageData = imageData
            self.social = social
            self.uri = uri
            self.websites = websites
            self.additionalProperties = additionalProperties
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            imageBig = try container.decodeIfPresent(String.self, forKey: .imageBig)
            imageMedium = try container.decodeIfPresent(String.self, forKey: .imageMedium)
            imageSmall = try container.decodeIfPresent(String.self, forKey: .imageSmall)
            imageData = try container.decodeIfPresent(String.self, forKey: .imageData)
            social = try container.decodeIfPresent([String].self, forKey: .social)
            uri = try container.decodeIfPresent(String.self, forKey: .uri)
            websites = try container.decodeIfPresent([String].self, forKey: .websites)
            
            // Decode additional unknown properties
            let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
            var additional: [String: AnyCodable] = [:]
            
            let knownKeys = Set(CodingKeys.allCases.map { $0.stringValue })
            
            for key in dynamicContainer.allKeys {
                if !knownKeys.contains(key.stringValue) {
                    if let value = try? dynamicContainer.decode(AnyCodable.self, forKey: key) {
                        additional[key.stringValue] = value
                    }
                }
            }
            
            additionalProperties = additional.isEmpty ? nil : additional
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(imageBig, forKey: .imageBig)
            try container.encodeIfPresent(imageMedium, forKey: .imageMedium)
            try container.encodeIfPresent(imageSmall, forKey: .imageSmall)
            try container.encodeIfPresent(imageData, forKey: .imageData)
            try container.encodeIfPresent(social, forKey: .social)
            try container.encodeIfPresent(uri, forKey: .uri)
            try container.encodeIfPresent(websites, forKey: .websites)
            
            // Encode additional properties
            if let additionalProperties = additionalProperties {
                var dynamicContainer = encoder.container(keyedBy: DynamicCodingKeys.self)
                
                for (key, value) in additionalProperties {
                    guard let codingKey = DynamicCodingKeys(stringValue: key) else {
                        continue
                    }
                    try dynamicContainer.encode(value, forKey: codingKey)
                }
            }
        }
        
        private enum CodingKeys: String, CodingKey, CaseIterable {
            case imageBig = "_image_big"
            case imageMedium = "_image_medium"
            case imageSmall = "_image_small"
            case decimals
            case imageData = "image_data"
            case social
            case uri
            case websites
        }
    }
}

public struct TONEmulationTokenInfoWallets: Codable {
    public let type: String = "jetton_wallets"
    public let valid: Bool
    public let extra: Extra
    
    public init(
        valid: Bool,
        extra: Extra
    ) {
        self.valid = valid
        self.extra = extra
    }
    
    public struct Extra: Codable {
        public let balance: String
        public let jetton: String
        public let owner: String
        
        public init(balance: String, jetton: String, owner: String) {
            self.balance = balance
            self.jetton = jetton
            self.owner = owner
        }
    }
}
