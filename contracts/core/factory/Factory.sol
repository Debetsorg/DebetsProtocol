// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./FactoryConfig.sol";
import "./FactoryLogic.sol";

/**
 * @title Factory contract
 * @author Debet
 * @notice Implemention of the factory contract in debet protocol
 */
contract Factory is FactoryConfig, FactoryLogic {
    /**
     * @notice Initialize the factory contract
     * @param randomEngineAddr The random engine contract address
     * @param rewardsPoolAddr The rewards pool contract address
     * @param nativeWrapperAddr The wrapped native token contract address
     */
    function initialize(
        address randomEngineAddr,
        address rewardsPoolAddr,
        address nativeWrapperAddr
    ) external initializer {
        __Ownable_init();

        maxPrizeRate = 100;
        protocolInReferralFee = 0;
        defaultCountsToAddRewards = 100;

        randomEngine = randomEngineAddr;
        rewardsPool = rewardsPoolAddr;
        nativeWrapper = nativeWrapperAddr;
    }
}
