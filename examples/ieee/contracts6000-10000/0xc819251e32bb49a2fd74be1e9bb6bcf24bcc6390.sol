{{
  "language": "Solidity",
  "sources": {
    "/Users/igor/job/dev/protocol-wrappers/contracts/adapters/poolTogether/PoolTogetherAdapter.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.6.5;\npragma experimental ABIEncoderV2;\n\nimport { ProtocolAdapter } from \"../ProtocolAdapter.sol\";\n\n/**\n * @dev Pod contract interface.\n * Only the functions required for PoolTogetherAdapter contract are added.\n * The Pod contract is available here\n * github.com/pooltogether/pods/blob/master/contracts/Pod.sol.\n */\ninterface Pod {\n    function balanceOfUnderlying(address) external view returns (uint256);\n    function pendingDeposit(address) external view returns (uint256);\n}\n\n\n/**\n * @dev BasePool contract interface.\n * Only the functions required for PoolTogetherAdapter contract are added.\n * The BasePool contract is available here\n * github.com/pooltogether/pooltogether-contracts/blob/master/contracts/BasePool.sol.\n */\ninterface BasePool {\n    function totalBalanceOf(address) external view returns (uint256);\n}\n\n\n/**\n * @title Adapter for PoolTogether protocol.\n * @dev Implementation of ProtocolAdapter interface.\n * @author Igor Sobolev <sobolev@zerion.io>\n */\ncontract PoolTogetherAdapter is ProtocolAdapter {\n\n    string public constant override adapterType = \"Asset\";\n\n    string public constant override tokenType = \"PoolTogether pool\";\n\n    address internal constant DAI_POOL = 0x29fe7D60DdF151E5b52e5FAB4f1325da6b2bD958;\n    address internal constant USDC_POOL = 0x0034Ea9808E620A0EF79261c51AF20614B742B24;\n    address internal constant DAI_POD = 0x9F4C5D8d9BE360DF36E67F52aE55C1B137B4d0C4;\n    address internal constant USDC_POD = 0x6F5587E191C8b222F634C78111F97c4851663ba4;\n\n    /**\n     * @return Amount of tokens locked in the pool by the given account.\n     * @param token Address of the pool!\n     * @dev Implementation of ProtocolAdapter interface function.\n     */\n    function getBalance(address token, address account) external view override returns (uint256) {\n        uint256 totalBalance = BasePool(token).totalBalanceOf(account);\n        if (token == DAI_POOL) {\n            totalBalance += getPodBalance(DAI_POD, account);\n        } else if (token == USDC_POOL) {\n            totalBalance += getPodBalance(USDC_POD, account);\n        }\n\n        return totalBalance;\n    }\n\n    function getPodBalance(address pod, address account) internal view returns (uint256) {\n        return Pod(pod).balanceOfUnderlying(account) + Pod(pod).pendingDeposit(account);\n    }\n}\n"
    },
    "/Users/igor/job/dev/protocol-wrappers/contracts/adapters/ProtocolAdapter.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.6.5;\npragma experimental ABIEncoderV2;\n\n\n/**\n * @title Protocol adapter interface.\n * @dev adapterType(), tokenType(), and getBalance() functions MUST be implemented.\n * @author Igor Sobolev <sobolev@zerion.io>\n */\ninterface ProtocolAdapter {\n\n    /**\n     * @dev MUST return \"Asset\" or \"Debt\".\n     * SHOULD be implemented by the public constant state variable.\n     */\n    function adapterType() external pure returns (string memory);\n\n    /**\n     * @dev MUST return token type (default is \"ERC20\").\n     * SHOULD be implemented by the public constant state variable.\n     */\n    function tokenType() external pure returns (string memory);\n\n    /**\n     * @dev MUST return amount of the given token locked on the protocol by the given account.\n     */\n    function getBalance(address token, address account) external view returns (uint256);\n}\n"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    },
    "remappings": []
  }
}}