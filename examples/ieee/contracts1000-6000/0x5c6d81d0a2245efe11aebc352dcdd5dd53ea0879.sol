{{
  "language": "Solidity",
  "sources": {
    "/Users/igor/job/dev/defi-sdk/contracts/adapters/compound/CompoundTokenAdapter.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.6.5;\npragma experimental ABIEncoderV2;\n\nimport { ERC20 } from \"../../ERC20.sol\";\nimport { TokenMetadata, Component } from \"../../Structs.sol\";\nimport { CompoundRegistry } from \"./CompoundRegistry.sol\";\nimport { TokenAdapter } from \"../TokenAdapter.sol\";\n\n\n/**\n * @dev CToken contract interface.\n * Only the functions required for CompoundTokenAdapter contract are added.\n * The CToken contract is available here\n * github.com/compound-finance/compound-protocol/blob/master/contracts/CToken.sol.\n */\ninterface CToken {\n    function exchangeRateStored() external view returns (uint256);\n    function underlying() external view returns (address);\n}\n\n\n/**\n * @title Token adapter for CTokens.\n * @dev Implementation of TokenAdapter interface.\n * @author Igor Sobolev <sobolev@zerion.io>\n */\ncontract CompoundTokenAdapter is TokenAdapter {\n\n    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\n    address internal constant CETH = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;\n    address internal constant CRETH = 0xD06527D5e56A3495252A528C4987003b712860eE;\n    address internal constant CSAI = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;\n\n    /**\n     * @return TokenMetadata struct with ERC20-style token info.\n     * @dev Implementation of TokenAdapter interface function.\n     */\n    function getMetadata(address token) external view override returns (TokenMetadata memory) {\n        if (token == CSAI) {\n            return TokenMetadata({\n                token: CSAI,\n                name: \"Compound Sai\",\n                symbol: \"cSAI\",\n                decimals: uint8(8)\n            });\n        } else {\n            return TokenMetadata({\n                token: token,\n                name: ERC20(token).name(),\n                symbol: ERC20(token).symbol(),\n                decimals: ERC20(token).decimals()\n            });\n        }\n    }\n\n    /**\n     * @return Array of Component structs with underlying tokens rates for the given token.\n     * @dev Implementation of TokenAdapter interface function.\n     */\n    function getComponents(address token) external view override returns (Component[] memory) {\n        Component[] memory underlyingTokens = new Component[](1);\n\n        underlyingTokens[0] = Component({\n            token: getUnderlying(token),\n            tokenType: \"ERC20\",\n            rate: CToken(token).exchangeRateStored()\n        });\n\n        return underlyingTokens;\n    }\n\n    /**\n     * @dev Internal function to retrieve underlying token.\n     */\n    function getUnderlying(address token) internal view returns (address) {\n        if (token == CETH || token == CRETH) {\n            return ETH;\n        } else {\n            return CToken(token).underlying();\n        }\n    }\n}\n"
    },
    "/Users/igor/job/dev/defi-sdk/contracts/ERC20.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.6.5;\npragma experimental ABIEncoderV2;\n\n\ninterface ERC20 {\n    function approve(address, uint256) external returns (bool);\n    function transfer(address, uint256) external returns (bool);\n    function transferFrom(address, address, uint256) external returns (bool);\n    function name() external view returns (string memory);\n    function symbol() external view returns (string memory);\n    function decimals() external view returns (uint8);\n    function totalSupply() external view returns (uint256);\n    function balanceOf(address) external view returns (uint256);\n}\n"
    },
    "/Users/igor/job/dev/defi-sdk/contracts/Structs.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.6.5;\npragma experimental ABIEncoderV2;\n\n\nstruct ProtocolBalance {\n    ProtocolMetadata metadata;\n    AdapterBalance[] adapterBalances;\n}\n\n\nstruct ProtocolMetadata {\n    string name;\n    string description;\n    string websiteURL;\n    string iconURL;\n    uint256 version;\n}\n\n\nstruct AdapterBalance {\n    AdapterMetadata metadata;\n    FullTokenBalance[] balances;\n}\n\n\nstruct AdapterMetadata {\n    address adapterAddress;\n    string adapterType; // \"Asset\", \"Debt\"\n}\n\n\n// token and its underlying tokens (if exist) balances\nstruct FullTokenBalance {\n    TokenBalance base;\n    TokenBalance[] underlying;\n}\n\n\nstruct TokenBalance {\n    TokenMetadata metadata;\n    uint256 amount;\n}\n\n\n// ERC20-style token metadata\n// 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE address is used for ETH\nstruct TokenMetadata {\n    address token;\n    string name;\n    string symbol;\n    uint8 decimals;\n}\n\n\nstruct Component {\n    address token;\n    string tokenType;  // \"ERC20\" by default\n    uint256 rate;  // price per full share (1e18)\n}\n"
    },
    "/Users/igor/job/dev/defi-sdk/contracts/adapters/compound/CompoundRegistry.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.6.5;\n\n\n/**\n * @title Registry for Compound contracts.\n * @dev Implements the only function - getCToken(address).\n * @notice Call getCToken(token) function and get address\n * of CToken contract for the given token address.\n * @author Igor Sobolev <sobolev@zerion.io>\n */\ncontract CompoundRegistry {\n\n    mapping(address => address) internal cTokens;\n\n    constructor() public {\n        cTokens[0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359] = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;\n        cTokens[0x1985365e9f78359a9B6AD760e32412f4a445E862] = 0x158079Ee67Fce2f58472A96584A73C7Ab9AC95c1;\n        cTokens[0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE] = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;\n        cTokens[0x6B175474E89094C44Da98b954EedeAC495271d0F] = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;\n        cTokens[0x0D8775F648430679A709E98d2b0Cb6250d2887EF] = 0x6C8c6b02E7b2BE14d4fA6022Dfd6d75921D90E4E;\n        cTokens[0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599] = 0xC11b1268C1A384e55C48c2391d8d480264A3A7F4;\n        cTokens[0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48] = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;\n        cTokens[0xE41d2489571d322189246DaFA5ebDe1F4699F498] = 0xB3319f5D18Bc0D84dD1b4825Dcde5d5f7266d407;\n        cTokens[0xdAC17F958D2ee523a2206206994597C13D831ec7] = 0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9;\n    }\n\n    function getCToken(address token) external view returns (address) {\n        return cTokens[token];\n    }\n}\n"
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