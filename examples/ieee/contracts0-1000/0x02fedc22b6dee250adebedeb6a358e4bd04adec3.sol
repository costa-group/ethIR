{{
  "language": "Solidity",
  "sources": {
    "/Users/igor/job/dev/defi-sdk/contracts/adapters/pickle/PickleStakingV2Adapter.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.6.5;\npragma experimental ABIEncoderV2;\n\nimport { ProtocolAdapter } from \"../ProtocolAdapter.sol\";\n\n\n/**\n * @dev UserInfo struct from MasterChef contract.\n * The MasterChef contract is available here\n * github.com/pickle-finance/contracts/blob/master/YieldFarming/MasterChef.sol.\n */\nstruct UserInfo {\n    uint256 amount;\n    uint256 rewardDebt;\n}\n\n\n/**\n * @dev PoolInfo struct from MasterChef contract.\n * The MasterChef contract is available here\n * github.com/pickle-finance/contracts/blob/master/YieldFarming/MasterChef.sol.\n */\nstruct PoolInfo {\n    address lpToken;\n    uint256 allocPoint;\n    uint256 lastRewardBlock;\n    uint256 accSushiPerShare;\n}\n\n\n/**\n * @dev MasterChef contract interface.\n * Only the functions required for PickleStakingV2Adapter contract are added.\n * The MasterChef contract is available here\n * github.com/pickle-finance/contracts/blob/master/YieldFarming/MasterChef.sol.\n */\ninterface MasterChef {\n    function poolLength() external view returns (uint256);\n    function poolInfo(uint256) external view returns (PoolInfo memory);\n    function userInfo(uint256, address) external view returns (UserInfo memory);\n    function pendingPickle(uint256, address) external view returns (uint256);\n}\n\n\n/**\n * @title Adapter for Pickle protocol (staking).\n * @dev Implementation of ProtocolAdapter interface.\n * @author Igor Sobolev <sobolev@zerion.io>\n */\ncontract PickleStakingV2Adapter is ProtocolAdapter {\n\n    string public constant override adapterType = \"Asset\";\n\n    string public constant override tokenType = \"ERC20\";\n\n    address internal constant PICKLE = 0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5;\n    address internal constant MASTER_CHEF = 0xbD17B1ce622d73bD438b9E658acA5996dc394b0d;\n\n    /**\n     * @return Amount of staked tokens / claimable rewards for a given account.\n     * @dev Implementation of ProtocolAdapter interface function.\n     */\n    function getBalance(address token, address account) external view override returns (uint256) {\n        uint256 length = MasterChef(MASTER_CHEF).poolLength();\n\n        if (token == PICKLE) {\n            uint256 totalRewards = 0;\n\n            for(uint256 i = 0; i < length; i++) {\n                totalRewards += MasterChef(MASTER_CHEF).pendingPickle(i, account);\n            }\n\n            return totalRewards;\n        } else {\n            PoolInfo memory pool;\n            for(uint256 i = 0; i < length; i++) {\n                pool = MasterChef(MASTER_CHEF).poolInfo(i);\n\n                if (pool.lpToken == token) {\n                    return MasterChef(MASTER_CHEF).userInfo(i, account).amount;\n                }\n            }\n\n            return 0;\n        }\n    }\n}\n"
    },
    "/Users/igor/job/dev/defi-sdk/contracts/adapters/ProtocolAdapter.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.6.5;\npragma experimental ABIEncoderV2;\n\n\n/**\n * @title Protocol adapter interface.\n * @dev adapterType(), tokenType(), and getBalance() functions MUST be implemented.\n * @author Igor Sobolev <sobolev@zerion.io>\n */\ninterface ProtocolAdapter {\n\n    /**\n     * @dev MUST return \"Asset\" or \"Debt\".\n     * SHOULD be implemented by the public constant state variable.\n     */\n    function adapterType() external pure returns (string memory);\n\n    /**\n     * @dev MUST return token type (default is \"ERC20\").\n     * SHOULD be implemented by the public constant state variable.\n     */\n    function tokenType() external pure returns (string memory);\n\n    /**\n     * @dev MUST return amount of the given token locked on the protocol by the given account.\n     */\n    function getBalance(address token, address account) external view returns (uint256);\n}\n"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 1000000
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