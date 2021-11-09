pragma solidity ^0.4.23;


interface Token {

     
    function totalSupply() external view returns (uint256 supply);

     
     
    function balanceOf(address _owner) external view returns (uint256 balance);

     
     
     
     
    function transfer(address _to, uint256 _value) external returns (bool success);

     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

     
     
     
     
    function approve(address _spender, uint256 _value) external returns (bool success);

     
     
     
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

     
    function decimals() external view returns (uint8 decimals);
}

contract Utils {
    string constant public contract_version = "0.3._";

     
     
     
    function contractExists(address contract_address) public view returns (bool) {
        uint size;

        assembly {
            size := extcodesize(contract_address)
        }

        return size > 0;
    }
}

library ECVerify {

    function ecverify(bytes32 hash, bytes signature)
        internal
        pure
        returns (address signature_address)
    {
        require(signature.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

         
         
         
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))

             
            v := byte(0, mload(add(signature, 96)))
        }

         
        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28);

        signature_address = ecrecover(hash, v, r, s);

         
        require(signature_address != 0x0);

        return signature_address;
    }
}

contract SecretRegistry {

     

    string constant public contract_version = "0.3._";

     
    mapping(bytes32 => uint256) public secrethash_to_block;

     

    event SecretRevealed(bytes32 indexed secrethash, bytes32 secret);

     
     
     
     
    function registerSecret(bytes32 secret) public returns (bool) {
        bytes32 secrethash = keccak256(abi.encodePacked(secret));
        if (secret == 0x0 || secrethash_to_block[secrethash] > 0) {
            return false;
        }
        secrethash_to_block[secrethash] = block.number;
        emit SecretRevealed(secrethash, secret);
        return true;
    }

     
     
     
    function registerSecretBatch(bytes32[] secrets) public returns (bool) {
        bool completeSuccess = true;
        for(uint i = 0; i < secrets.length; i++) {
            if(!registerSecret(secrets[i])) {
                completeSuccess = false;
            }
        }
        return completeSuccess;
    }

    function getSecretRevealBlockHeight(bytes32 secrethash) public view returns (uint256) {
        return secrethash_to_block[secrethash];
    }
}

contract TokenNetwork is Utils {

     

    string constant public contract_version = "0.3._";

     
    Token public token;

     
    SecretRegistry public secret_registry;

     
    uint256 public chain_id;

    uint256 public settlement_timeout_min;
    uint256 public settlement_timeout_max;

    uint256 constant public MAX_SAFE_UINT256 = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    uint256 public deposit_limit;

    uint256 public channel_counter;

     
     
    mapping (bytes32 => Channel) public channels;

     
     
    mapping (bytes32 => uint256) public participants_hash_to_channel_counter;

     
     
     
     
     
     
     
     
    mapping(bytes32 => uint256) locksroot_identifier_to_locked_amount;

    struct Participant {
         
         
         
        uint256 deposit;

         
        uint256 withdrawn_amount;

         
         
         
        bool is_the_closer;

         
         
        bytes32 balance_hash;

         
         
        uint256 nonce;
    }

    struct Channel {
         
         
         
         
         
        uint256 settle_block_number;

         
         
         
        uint8 state;

        mapping(address => Participant) participants;
    }

    struct SettlementData {
        uint256 deposit;
        uint256 withdrawn;
        uint256 transferred;
        uint256 locked;
    }

     

    event ChannelOpened(
        bytes32 indexed channel_identifier,
        address indexed participant1,
        address indexed participant2,
        uint256 settle_timeout
    );

    event ChannelNewDeposit(
        bytes32 indexed channel_identifier,
        address indexed participant,
        uint256 total_deposit
    );

     
    event ChannelWithdraw(
        bytes32 indexed channel_identifier,
        address indexed participant, uint256 total_withdraw
    );

    event ChannelClosed(bytes32 indexed channel_identifier, address indexed closing_participant);

    event ChannelUnlocked(
        address indexed participant,
        address indexed partner,
        bytes32 indexed locksroot,
        uint256 unlocked_amount,
        uint256 returned_tokens
    );

    event NonClosingBalanceProofUpdated(
        bytes32 indexed channel_identifier,
        address indexed closing_participant
    );

    event ChannelSettled(
        bytes32 indexed channel_identifier,
        uint256 participant1_amount,
        uint256 participant2_amount
    );

     

    modifier isOpen(address participant, address partner) {
        bytes32 channel_identifier = getChannelIdentifier(participant, partner);
        require(channels[channel_identifier].state == 1);
        _;
    }

    modifier settleTimeoutValid(uint256 timeout) {
        require(timeout >= settlement_timeout_min && timeout <= settlement_timeout_max);
        _;
    }

     

    constructor(
        address _token_address,
        address _secret_registry,
        uint256 _chain_id,
        uint256 _settlement_timeout_min,
        uint256 _settlement_timeout_max
    )
        public
    {
        require(_token_address != 0x0);
        require(_secret_registry != 0x0);
        require(_chain_id > 0);
        require(_settlement_timeout_min > 0);
        require(_settlement_timeout_max > 0);
        require(_settlement_timeout_max > _settlement_timeout_min);
        require(contractExists(_token_address));
        require(contractExists(_secret_registry));

        token = Token(_token_address);

        secret_registry = SecretRegistry(_secret_registry);
        chain_id = _chain_id;
        settlement_timeout_min = _settlement_timeout_min;
        settlement_timeout_max = _settlement_timeout_max;

         
        require(token.totalSupply() > 0);

         
        bool exists = address(token).call(bytes4(keccak256("decimals()")));
        uint8 decimals = 18;
        if (exists) {
            decimals = token.decimals();
        }

        deposit_limit = 100 * (10 ** uint256(decimals));
    }

     

     
     
     
     
     
     
    function openChannel(address participant1, address participant2, uint256 settle_timeout)
        settleTimeoutValid(settle_timeout)
        public
        returns (bytes32)
    {
        channel_counter += 1;

         
        bytes32 pair_hash = getParticipantsHash(participant1, participant2);

         
        require(participants_hash_to_channel_counter[pair_hash] == 0);

        participants_hash_to_channel_counter[pair_hash] = channel_counter;

         
         
        bytes32 channel_identifier = getChannelIdentifier(participant1, participant2);
        Channel storage channel = channels[channel_identifier];

        require(channel.settle_block_number == 0);
        require(channel.state == 0);

         
        channel.settle_block_number = settle_timeout;
         
        channel.state = 1;

        emit ChannelOpened(channel_identifier, participant1, participant2, settle_timeout);

        return channel_identifier;
    }

     
     
     
     
     
     
    function setTotalDeposit(address participant, uint256 total_deposit, address partner)
        isOpen(participant, partner)
        public
    {
        require(total_deposit > 0);
        require(total_deposit <= deposit_limit);

        bytes32 channel_identifier;
        uint256 added_deposit;
        uint256 channel_deposit;

        channel_identifier = getChannelIdentifier(participant, partner);
        Channel storage channel = channels[channel_identifier];
        Participant storage participant_state = channel.participants[participant];
        Participant storage partner_state = channel.participants[partner];

         
        added_deposit = total_deposit - participant_state.deposit;

         
        participant_state.deposit += added_deposit;

         
        channel_deposit = participant_state.deposit + partner_state.deposit;

        emit ChannelNewDeposit(channel_identifier, participant, participant_state.deposit);

         
        require(token.transferFrom(msg.sender, address(this), added_deposit));

        require(participant_state.deposit >= added_deposit);
        require(channel_deposit >= participant_state.deposit);
        require(channel_deposit >= partner_state.deposit);
    }

     
     
     
     
     
     
     
     
     
    function setTotalWithdraw(
        address participant,
        uint256 total_withdraw,
        address partner,
        bytes participant_signature,
        bytes partner_signature
    )
        external
    {
        require(total_withdraw > 0);

        bytes32 channel_identifier;
        uint256 total_deposit;
        uint256 current_withdraw;

        channel_identifier = getChannelIdentifier(participant, partner);
        Channel storage channel = channels[channel_identifier];

        Participant storage participant_state = channel.participants[participant];
        Participant storage partner_state = channel.participants[partner];

        total_deposit = participant_state.deposit + partner_state.deposit;

         
         
        current_withdraw = total_withdraw - participant_state.withdrawn_amount;

        participant_state.withdrawn_amount += current_withdraw;

         
        require(token.transfer(participant, current_withdraw));

         
        require(channel.state == 1);

        verifyWithdrawSignatures(
            channel_identifier,
            participant,
            partner,
            total_withdraw,
            participant_signature,
            partner_signature
        );

        require(current_withdraw > 0);

         
        require(participant_state.withdrawn_amount >= current_withdraw);
        require(participant_state.withdrawn_amount == total_withdraw);

         
        require(participant_state.withdrawn_amount <= (total_deposit - partner_state.withdrawn_amount));

        require(total_deposit >= participant_state.deposit);
        require(total_deposit >= partner_state.deposit);

         
        assert(participant_state.nonce == 0);
        assert(partner_state.nonce == 0);

        emit ChannelWithdraw(channel_identifier, participant, participant_state.withdrawn_amount);
    }

     
     
     
     
     
     
     
     
    function closeChannel(
        address partner,
        bytes32 balance_hash,
        uint256 nonce,
        bytes32 additional_hash,
        bytes signature
    )
        isOpen(msg.sender, partner)
        public
    {
        address recovered_partner_address;
        bytes32 channel_identifier;

        channel_identifier = getChannelIdentifier(msg.sender, partner);
        Channel storage channel = channels[channel_identifier];

         
        channel.state = 2;
        channel.participants[msg.sender].is_the_closer = true;

         
        channel.settle_block_number += uint256(block.number);

         
         
         
        if (nonce > 0) {
            recovered_partner_address = recoverAddressFromBalanceProof(
                channel_identifier,
                balance_hash,
                nonce,
                additional_hash,
                signature
            );

            updateBalanceProofData(channel, recovered_partner_address, nonce, balance_hash);

             
            require(partner == recovered_partner_address);
        }

        emit ChannelClosed(channel_identifier, msg.sender);
    }

     
     
     
     
     
     
     
     
     
     
    function updateNonClosingBalanceProof(
        address closing_participant,
        address non_closing_participant,
        bytes32 balance_hash,
        uint256 nonce,
        bytes32 additional_hash,
        bytes closing_signature,
        bytes non_closing_signature
    )
        external
    {
        require(balance_hash != 0x0);
        require(nonce > 0);

        bytes32 channel_identifier;
        address recovered_non_closing_participant;
        address recovered_closing_participant;

        channel_identifier = getChannelIdentifier(closing_participant, non_closing_participant);
        Channel storage channel = channels[channel_identifier];

         
         
        recovered_non_closing_participant = recoverAddressFromBalanceProofUpdateMessage(
            channel_identifier,
            balance_hash,
            nonce,
            additional_hash,
            closing_signature,
            non_closing_signature
        );

        recovered_closing_participant = recoverAddressFromBalanceProof(
            channel_identifier,
            balance_hash,
            nonce,
            additional_hash,
            closing_signature
        );

        Participant storage closing_participant_state = channel.participants[closing_participant];

         
        updateBalanceProofData(channel, closing_participant, nonce, balance_hash);

        emit NonClosingBalanceProofUpdated(channel_identifier, closing_participant);

         
        require(channel.state == 2);

         
        require(channel.settle_block_number >= block.number);

         
        require(closing_participant_state.is_the_closer);

        require(closing_participant == recovered_closing_participant);
        require(non_closing_participant == recovered_non_closing_participant);
    }

     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
    function settleChannel(
        address participant1,
        uint256 participant1_transferred_amount,
        uint256 participant1_locked_amount,
        bytes32 participant1_locksroot,
        address participant2,
        uint256 participant2_transferred_amount,
        uint256 participant2_locked_amount,
        bytes32 participant2_locksroot
    )
        public
    {
        bytes32 pair_hash;
        bytes32 channel_identifier;

        pair_hash = getParticipantsHash(participant1, participant2);
        channel_identifier = getChannelIdentifier(participant1, participant2);
        Channel storage channel = channels[channel_identifier];

         
        require(channel.state == 2);

         
        require(channel.settle_block_number < block.number);

        Participant storage participant1_state = channel.participants[participant1];
        Participant storage participant2_state = channel.participants[participant2];

        require(verifyBalanceHashData(
            participant1_state,
            participant1_transferred_amount,
            participant1_locked_amount,
            participant1_locksroot
        ));

        require(verifyBalanceHashData(
            participant2_state,
            participant2_transferred_amount,
            participant2_locked_amount,
            participant2_locksroot
        ));

         
         
         
         
         
         
         
        (
            participant1_transferred_amount,
            participant2_transferred_amount,
            participant1_locked_amount,
            participant2_locked_amount
        ) = getSettleTransferAmounts(
            participant1_state,
            participant1_transferred_amount,
            participant1_locked_amount,
            participant2_state,
            participant2_transferred_amount,
            participant2_locked_amount
        );

         
        delete channel.participants[participant1];
        delete channel.participants[participant2];
        delete channels[channel_identifier];

         
        delete participants_hash_to_channel_counter[pair_hash];


         
        updateUnlockData(
            participant1,
            participant2,
            participant1_locked_amount,
            participant1_locksroot
        );
        updateUnlockData(
            participant2,
            participant1,
            participant2_locked_amount,
            participant2_locksroot
        );

         
        if (participant1_transferred_amount > 0) {
            require(token.transfer(participant1, participant1_transferred_amount));
        }

        if (participant2_transferred_amount > 0) {
            require(token.transfer(participant2, participant2_transferred_amount));
        }

        emit ChannelSettled(
            channel_identifier,
            participant1_transferred_amount,
            participant2_transferred_amount
        );
    }

    function getSettleTransferAmounts(
        Participant storage participant1_state,
        uint256 participant1_transferred_amount,
        uint256 participant1_locked_amount,
        Participant storage participant2_state,
        uint256 participant2_transferred_amount,
        uint256 participant2_locked_amount
    )
        view
        private
        returns (uint256, uint256, uint256, uint256)
    {
         
         
         
         

         
         
         
         
         
         
         
         
         

        uint256 participant1_amount;
        uint256 participant2_amount;
        uint256 total_available_deposit;

        SettlementData memory participant1_settlement;
        SettlementData memory participant2_settlement;

        participant1_settlement.deposit = participant1_state.deposit;
        participant1_settlement.withdrawn = participant1_state.withdrawn_amount;
        participant1_settlement.transferred = participant1_transferred_amount;
        participant1_settlement.locked = participant1_locked_amount;

        participant2_settlement.deposit = participant2_state.deposit;
        participant2_settlement.withdrawn = participant2_state.withdrawn_amount;
        participant2_settlement.transferred = participant2_transferred_amount;
        participant2_settlement.locked = participant2_locked_amount;

        total_available_deposit = getChannelAvailableDeposit(
            participant1_state,
            participant2_state
        );

         
         
         
        participant1_amount = getMaxPossibleReceivableAmount(
            participant1_settlement,
            participant2_settlement
        );

         
        participant1_amount = min(participant1_amount, total_available_deposit);

         
        participant2_amount = total_available_deposit - participant1_amount;

         
        (participant1_amount, participant2_locked_amount) = failsafe_subtract(
            participant1_amount,
            participant2_locked_amount
        );

         
        (participant2_amount, participant1_locked_amount) = failsafe_subtract(
            participant2_amount,
            participant1_locked_amount
        );

         
        assert(participant1_amount <= total_available_deposit);
        assert(participant2_amount <= total_available_deposit);
        assert(total_available_deposit == (
            participant1_amount +
            participant2_amount +
            participant1_locked_amount +
            participant2_locked_amount
        ));

        return (
            participant1_amount,
            participant2_amount,
            participant1_locked_amount,
            participant2_locked_amount
        );
    }

     
     
     
     
     
     
     
     
    function unlock(
        address participant,
        address partner,
        bytes merkle_tree_leaves
    )
        public
    {
        require(merkle_tree_leaves.length > 0);

        bytes32 channel_identifier;
        bytes32 unlock_key;
        bytes32 computed_locksroot;
        uint256 unlocked_amount;
        uint256 locked_amount;
        uint256 returned_tokens;

        channel_identifier = getChannelIdentifier(participant, partner);

         
         
        (computed_locksroot, unlocked_amount) = getMerkleRootAndUnlockedAmount(merkle_tree_leaves);

         
         
         
         
        unlock_key = getLocksrootIdentifier(partner, participant, computed_locksroot);
        locked_amount = locksroot_identifier_to_locked_amount[unlock_key];

         
        require(locked_amount > 0);

         
        unlocked_amount = min(unlocked_amount, locked_amount);

         
        returned_tokens = locked_amount - unlocked_amount;

         
        delete locksroot_identifier_to_locked_amount[unlock_key];

         
        if (unlocked_amount > 0) {
            require(token.transfer(participant, unlocked_amount));
        }

         
        if (returned_tokens > 0) {
            require(token.transfer(partner, returned_tokens));
        }

        emit ChannelUnlocked(participant, partner, computed_locksroot, unlocked_amount, returned_tokens);

         
        require(channels[channel_identifier].state == 0);

        require(computed_locksroot != 0);
        require(locked_amount > 0);
        require(locked_amount >= returned_tokens);
        assert(locked_amount >= unlocked_amount);
    }

    function cooperativeSettle(
        address participant1_address,
        uint256 participant1_balance,
        address participant2_address,
        uint256 participant2_balance,
        bytes participant1_signature,
        bytes participant2_signature
    )
        public
    {
        bytes32 pair_hash;
        bytes32 channel_identifier;
        address participant1;
        address participant2;
        uint256 total_available_deposit;

        pair_hash = getParticipantsHash(participant1_address, participant2_address);
        channel_identifier = getChannelIdentifier(participant1_address, participant2_address);
        Channel storage channel = channels[channel_identifier];

         
        require(channel.state == 1);

        participant1 = recoverAddressFromCooperativeSettleSignature(
            channel_identifier,
            participant1_address,
            participant1_balance,
            participant2_address,
            participant2_balance,
            participant1_signature
        );

        participant2 = recoverAddressFromCooperativeSettleSignature(
            channel_identifier,
            participant1_address,
            participant1_balance,
            participant2_address,
            participant2_balance,
            participant2_signature
        );

        Participant storage participant1_state = channel.participants[participant1];
        Participant storage participant2_state = channel.participants[participant2];

        total_available_deposit = getChannelAvailableDeposit(
            participant1_state,
            participant2_state
        );

         
        delete channel.participants[participant1];
        delete channel.participants[participant2];
        delete channels[channel_identifier];

         
        delete participants_hash_to_channel_counter[pair_hash];


         
        if (participant1_balance > 0) {
            require(token.transfer(participant1, participant1_balance));
        }

        if (participant2_balance > 0) {
            require(token.transfer(participant2, participant2_balance));
        }

         
        require(participant1 == participant1_address);
        require(participant2 == participant2_address);

         
        require(total_available_deposit == (participant1_balance + participant2_balance));
        emit ChannelSettled(channel_identifier, participant1_balance, participant2_balance);

    }

     
     
     
     
    function getChannelIdentifier(address participant, address partner)
        view
        public
        returns (bytes32)
    {
        require(participant != 0x0);
        require(partner != 0x0);

         
        require(participant != partner);

        bytes32 pair_hash = getParticipantsHash(participant, partner);
        uint256 counter = participants_hash_to_channel_counter[pair_hash];
        return keccak256(abi.encodePacked(pair_hash, counter));
    }

    function getParticipantsHash(address participant, address partner)
        pure
        public
        returns (bytes32)
    {
        require(participant != 0x0);
        require(partner != 0x0);

         
        require(participant != partner);

         
         
        if (participant < partner) {
            return keccak256(abi.encodePacked(participant, partner));
        } else {
            return keccak256(abi.encodePacked(partner, participant));
        }
    }

    function getLocksrootIdentifier(
        address participant,
        address partner,
        bytes32 locksroot
    )
        pure
        public
        returns (bytes32 key)
    {
        require(locksroot != 0x0);

        bytes32 participants_hash = getParticipantsHash(participant, partner);

         
        key = keccak256(abi.encodePacked(participants_hash, participant, locksroot));
    }

    function updateBalanceProofData(
        Channel storage channel,
        address participant,
        uint256 nonce,
        bytes32 balance_hash
    )
        internal
    {
        Participant storage participant_state = channel.participants[participant];

         
         
        require(nonce > participant_state.nonce);

        participant_state.nonce = nonce;
        participant_state.balance_hash = balance_hash;
    }

    function updateUnlockData(
        address participant,
        address partner,
        uint256 locked_amount,
        bytes32 locksroot
    )
        internal
    {
         
        if (locked_amount == 0 || locksroot == 0) {
            return;
        }

        bytes32 key = getLocksrootIdentifier(participant, partner, locksroot);
        locksroot_identifier_to_locked_amount[key] = locked_amount;
    }

    function getChannelAvailableDeposit(
        Participant storage participant1_state,
        Participant storage participant2_state
    )
        view
        internal
        returns (uint256 total_available_deposit)
    {
        total_available_deposit = (
            participant1_state.deposit +
            participant2_state.deposit -
            participant1_state.withdrawn_amount -
            participant2_state.withdrawn_amount
        );
    }

    function getMaxPossibleReceivableAmount(
        SettlementData participant1_settlement,
        SettlementData participant2_settlement
    )
        view
        internal
        returns (uint256)
    {
        uint256 participant1_max_transferred;
        uint256 participant2_max_transferred;
        uint256 participant1_net_max_transferred;
        uint256 participant1_max_amount;

         
         
        participant1_max_transferred = failsafe_addition(
            participant1_settlement.transferred,
            participant1_settlement.locked
        );

         
         
        participant2_max_transferred = failsafe_addition(
            participant2_settlement.transferred,
            participant2_settlement.locked
        );

         
         
        require(participant2_max_transferred >= participant1_max_transferred);

        assert(participant1_max_transferred >= participant1_settlement.transferred);
        assert(participant2_max_transferred >= participant2_settlement.transferred);

         
         
        participant1_net_max_transferred = (
            participant2_max_transferred -
            participant1_max_transferred
        );

         
        participant1_max_amount = failsafe_addition(
            participant1_net_max_transferred,
            participant1_settlement.deposit
        );

         
        (participant1_max_amount, ) = failsafe_subtract(
            participant1_max_amount,
            participant1_settlement.withdrawn
        );
        return participant1_max_amount;
    }

    function verifyBalanceHashData(
        Participant storage participant,
        uint256 transferred_amount,
        uint256 locked_amount,
        bytes32 locksroot
    )
        view
        internal
        returns (bool)
    {
         
         
        if (participant.balance_hash == 0 &&
            transferred_amount == 0 &&
            locked_amount == 0 &&
            locksroot == 0
        ) {
            return true;
        }

         
        return participant.balance_hash == keccak256(abi.encodePacked(
            transferred_amount,
            locked_amount,
            locksroot
        ));
    }

     
     
     
     
    function getChannelInfo(address participant1, address participant2)
        view
        external
        returns (bytes32, uint256, uint8)
    {
        bytes32 channel_identifier;

        channel_identifier = getChannelIdentifier(participant1, participant2);
        Channel storage channel = channels[channel_identifier];

        return (
            channel_identifier,
            channel.settle_block_number,
            channel.state
        );
    }

     
     
     
     
     
    function getChannelParticipantInfo(address participant, address partner)
        view
        external
        returns (uint256, uint256, bool, bytes32, uint256)
    {
        bytes32 channel_identifier;
        channel_identifier = getChannelIdentifier(participant, partner);

        Participant storage participant_state = channels[channel_identifier].participants[
            participant
        ];

        return (
            participant_state.deposit,
            participant_state.withdrawn_amount,
            participant_state.is_the_closer,
            participant_state.balance_hash,
            participant_state.nonce
        );
    }

     
     
     
     
     
    function getParticipantLockedAmount(
        address participant1,
        address participant2,
        bytes32 locksroot
    )
        view
        public
        returns (uint256)
    {
        bytes32 channel_identifier;
        bytes32 unlock_key;

        channel_identifier = getChannelIdentifier(participant1, participant2);
        unlock_key = getLocksrootIdentifier(participant1, participant2, locksroot);

        return locksroot_identifier_to_locked_amount[unlock_key];
    }

     

    function recoverAddressFromBalanceProof(
        bytes32 channel_identifier,
        bytes32 balance_hash,
        uint256 nonce,
        bytes32 additional_hash,
        bytes signature
    )
        view
        internal
        returns (address signature_address)
    {
        bytes32 message_hash = keccak256(abi.encodePacked(
            balance_hash,
            nonce,
            additional_hash,
            channel_identifier,
            address(this),
            chain_id
        ));

        signature_address = ECVerify.ecverify(message_hash, signature);
    }

    function recoverAddressFromBalanceProofUpdateMessage(
        bytes32 channel_identifier,
        bytes32 balance_hash,
        uint256 nonce,
        bytes32 additional_hash,
        bytes closing_signature,
        bytes non_closing_signature
    )
        view
        internal
        returns (address signature_address)
    {
        bytes32 message_hash = keccak256(abi.encodePacked(
            balance_hash,
            nonce,
            additional_hash,
            channel_identifier,
            address(this),
            chain_id,
            closing_signature
        ));

        signature_address = ECVerify.ecverify(message_hash, non_closing_signature);
    }

    function recoverAddressFromCooperativeSettleSignature(
        bytes32 channel_identifier,
        address participant1,
        uint256 participant1_balance,
        address participant2,
        uint256 participant2_balance,
        bytes signature
    )
        view
        internal
        returns (address signature_address)
    {
        bytes32 message_hash = keccak256(abi.encodePacked(
            participant1,
            participant1_balance,
            participant2,
            participant2_balance,
            channel_identifier,
            address(this),
            chain_id
        ));

        signature_address = ECVerify.ecverify(message_hash, signature);
    }

    function recoverAddressFromWithdrawMessage(
        bytes32 channel_identifier,
        address participant,
        uint256 total_withdraw,
        bytes signature
    )
        view
        internal
        returns (address signature_address)
    {
        bytes32 message_hash = keccak256(abi.encodePacked(
            participant,
            total_withdraw,
            channel_identifier,
            address(this),
            chain_id
        ));

        signature_address = ECVerify.ecverify(message_hash, signature);
    }

    function verifyWithdrawSignatures(
        bytes32 channel_identifier,
        address participant,
        address partner,
        uint256 total_withdraw,
        bytes participant_signature,
        bytes partner_signature
    )
        view
        internal
    {
        address recovered_participant_address;
        address recovered_partner_address;

        recovered_participant_address = recoverAddressFromWithdrawMessage(
            channel_identifier,
            participant,
            total_withdraw,
            participant_signature
        );
        recovered_partner_address = recoverAddressFromWithdrawMessage(
            channel_identifier,
            participant,
            total_withdraw,
            partner_signature
        );
         
        require(participant == recovered_participant_address);
        require(partner == recovered_partner_address);
    }

    function getMerkleRootAndUnlockedAmount(bytes merkle_tree_leaves)
        view
        internal
        returns (bytes32, uint256)
    {
        uint256 length = merkle_tree_leaves.length;

         
         
        require(length % 96 == 0);

        uint256 i;
        uint256 total_unlocked_amount;
        uint256 unlocked_amount;
        bytes32 lockhash;
        bytes32 merkle_root;

        bytes32[] memory merkle_layer = new bytes32[](length / 96 + 1);

        for (i = 32; i < length; i += 96) {
            (lockhash, unlocked_amount) = getLockDataFromMerkleTree(merkle_tree_leaves, i);
            total_unlocked_amount += unlocked_amount;
            merkle_layer[i / 96] = lockhash;
        }

        length /= 96;

        while (length > 1) {
            if (length % 2 != 0) {
                merkle_layer[length] = merkle_layer[length - 1];
                length += 1;
            }

            for (i = 0; i < length - 1; i += 2) {
                if (merkle_layer[i] == merkle_layer[i + 1]) {
                    lockhash = merkle_layer[i];
                } else if (merkle_layer[i] < merkle_layer[i + 1]) {
                    lockhash = keccak256(abi.encodePacked(merkle_layer[i], merkle_layer[i + 1]));
                } else {
                    lockhash = keccak256(abi.encodePacked(merkle_layer[i + 1], merkle_layer[i]));
                }
                merkle_layer[i / 2] = lockhash;
            }
            length = i / 2;
        }

        merkle_root = merkle_layer[0];

        return (merkle_root, total_unlocked_amount);
    }

    function getLockDataFromMerkleTree(bytes merkle_tree_leaves, uint256 offset)
        view
        internal
        returns (bytes32, uint256)
    {
        uint256 expiration_block;
        uint256 locked_amount;
        uint256 reveal_block;
        bytes32 secrethash;
        bytes32 lockhash;

        if (merkle_tree_leaves.length <= offset) {
            return (lockhash, 0);
        }

        assembly {
            expiration_block := mload(add(merkle_tree_leaves, offset))
            locked_amount := mload(add(merkle_tree_leaves, add(offset, 32)))
            secrethash := mload(add(merkle_tree_leaves, add(offset, 64)))
        }

         
        lockhash = keccak256(abi.encodePacked(expiration_block, locked_amount, secrethash));

         
         
         
        reveal_block = secret_registry.getSecretRevealBlockHeight(secrethash);
        if (reveal_block == 0 || expiration_block <= reveal_block) {
            locked_amount = 0;
        }

        return (lockhash, locked_amount);
    }

    function min(uint256 a, uint256 b) pure internal returns (uint256)
    {
        return a > b ? b : a;
    }

    function max(uint256 a, uint256 b) pure internal returns (uint256)
    {
        return a > b ? a : b;
    }

     
     
     
     
    function failsafe_subtract(uint256 a, uint256 b)
        pure
        internal
        returns (uint256, uint256)
    {
        return a > b ? (a - b, b) : (0, a);
    }

     
     
     
     
    function failsafe_addition(uint256 a, uint256 b)
        pure
        internal
        returns (uint256)
    {
        uint256 sum = a + b;
        return sum >= a ? sum : MAX_SAFE_UINT256;
    }
}