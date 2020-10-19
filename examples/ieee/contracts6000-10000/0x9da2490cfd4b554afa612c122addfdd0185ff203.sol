{{
  "language": "Solidity",
  "sources": {
    "/Users/igor/job/dev/defi-sdk/contracts/adapters/keeperDao/KeeperDaoTokenAdapter.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.6.5;\npragma experimental ABIEncoderV2;\n\nimport { ERC20 } from \"../../ERC20.sol\";\nimport { TokenMetadata, Component } from \"../../Structs.sol\";\nimport { TokenAdapter } from \"../TokenAdapter.sol\";\n\n\n/**\n * @dev KToken contract interface.\n * Only the functions required for KeeperDaoTokenAdapter contract are added.\n */\ninterface KToken {\n    function underlying() external view returns (address);\n}\n\n\n/**\n * @dev LiquidityPoolV1 contract interface.\n * Only the functions required for KeeperDaoTokenAdapter contract are added.\n */\ninterface LiquidityPoolV1 {\n    function borrowableBalance(address) external view returns (uint256);\n}\n\n\n/**\n * @title Token adapter for KTokens.\n * @dev Implementation of TokenAdapter interface.\n * @author Igor Sobolev <sobolev@zerion.io>\n */\ncontract KeeperDaoTokenAdapter is TokenAdapter {\n\n    address internal constant POOL = 0xEB7e15B4E38CbEE57a98204D05999C3230d36348;\n\n    /**\n     * @return TokenMetadata struct with ERC20-style token info.\n     * @dev Implementation of TokenAdapter interface function.\n     */\n    function getMetadata(address token) external view override returns (TokenMetadata memory) {\n        return TokenMetadata({\n            token: token,\n            name: ERC20(token).name(),\n            symbol: ERC20(token).symbol(),\n            decimals: ERC20(token).decimals()\n        });\n    }\n\n    /**\n     * @return Array of Component structs with underlying tokens rates for the given token.\n     * @dev Implementation of TokenAdapter interface function.\n     */\n    function getComponents(address token) external view override returns (Component[] memory) {\n        Component[] memory underlyingTokens = new Component[](1);\n        address underlyingToken = KToken(token).underlying();\n        uint256 borrowableBalance = LiquidityPoolV1(POOL).borrowableBalance(underlyingToken);\n\n        underlyingTokens[0] = Component({\n            token: underlyingToken,\n            tokenType: \"ERC20\",\n            rate: borrowableBalance * 1e18 / ERC20(token).totalSupply()\n        });\n\n        return underlyingTokens;\n    }\n}\n"
    },
    "/Users/igor/job/dev/defi-sdk/contracts/ERC20.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.6.5;\npragma experimental ABIEncoderV2;\n\n\ninterface ERC20 {\n    function approve(address, uint256) external returns (bool);\n    function transfer(address, uint256) external returns (bool);\n    function transferFrom(address, address, uint256) external returns (bool);\n    function name() external view returns (string memory);\n    function symbol() external view returns (string memory);\n    function decimals() external view returns (uint8);\n    function totalSupply() external view returns (uint256);\n    function balanceOf(address) external view returns (uint256);\n}\n"
    },
    "/Users/igor/job/dev/defi-sdk/contracts/Structs.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.6.5;\npragma experimental ABIEncoderV2;\n\n\nstruct ProtocolBalance {\n    ProtocolMetadata metadata;\n    AdapterBalance[] adapterBalances;\n}\n\n\nstruct ProtocolMetadata {\n    string name;\n    string description;\n    string websiteURL;\n    string iconURL;\n    uint256 version;\n}\n\n\nstruct AdapterBalance {\n    AdapterMetadata metadata;\n    FullTokenBalance[] balances;\n}\n\n\nstruct AdapterMetadata {\n    address adapterAddress;\n    string adapterType; // \"Asset\", \"Debt\"\n}\n\n\n// token and its underlying tokens (if exist) balances\nstruct FullTokenBalance {\n    TokenBalance base;\n    TokenBalance[] underlying;\n}\n\n\nstruct TokenBalance {\n    TokenMetadata metadata;\n    uint256 amount;\n}\n\n\n// ERC20-style token metadata\n// 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE address is used for ETH\nstruct TokenMetadata {\n    address token;\n    string name;\n    string symbol;\n    uint8 decimals;\n}\n\n\nstruct Component {\n    address token;\n    string tokenType;  // \"ERC20\" by default\n    uint256 rate;  // price per full share (1e18)\n}\n"
    },
    "/Users/igor/job/dev/defi-sdk/contracts/adapters/TokenAdapter.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.6.5;\npragma experimental ABIEncoderV2;\n\nimport { TokenMetadata, Component } from \"../Structs.sol\";\n\n\n/**\n * @title Token adapter interface.\n * @dev getMetadata() and getComponents() functions MUST be implemented.\n * @author Igor Sobolev <sobolev@zerion.io>\n */\ninterface TokenAdapter {\n\n    /**\n     * @dev MUST return TokenMetadata struct with ERC20-style token info.\n     * struct TokenMetadata {\n     *     address token;\n     *     string name;\n     *     string symbol;\n     *     uint8 decimals;\n     * }\n     */\n    function getMetadata(address token) external view returns (TokenMetadata memory);\n\n    /**\n     * @dev MUST return array of Component structs with underlying tokens rates for the given token.\n     * struct Component {\n     *     address token;    // Address of token contract\n     *     string tokenType; // Token type (\"ERC20\" by default)\n     *     uint256 rate;     // Price per share (1e18)\n     * }\n     */\n    function getComponents(address token) external view returns (Component[] memory);\n}\n"
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