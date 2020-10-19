{{
  "language": "Solidity",
  "sources": {
    "/mnt/c/Users/Igor/Desktop/job/dev/zeriontech/defi-sdk/contracts/adapters/curve/CurveTokenAdapter.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\r\n//\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n//\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\r\n// GNU General Public License for more details.\r\n//\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\r\n\r\npragma solidity 0.6.5;\r\npragma experimental ABIEncoderV2;\r\n\r\nimport { ERC20 } from \"../../ERC20.sol\";\r\nimport { TokenMetadata, Component } from \"../../Structs.sol\";\r\nimport { TokenAdapter } from \"../TokenAdapter.sol\";\r\n\r\n/**\r\n * @dev CurveRegistry contract interface.\r\n * Only the functions required for CurveTokenAdapter contract are added.\r\n * The CurveRegistry contract is available here\r\n * github.com/zeriontech/defi-sdk/blob/master/contracts/adapters/curve/CurveRegistry.sol.\r\n */\r\ninterface CurveRegistry {\r\n    function getSwapAndTotalCoins(address) external view returns (address, uint256);\r\n    function getName(address) external view returns (string memory);\r\n}\r\n\r\n\r\n/**\r\n * @dev stableswap contract interface.\r\n * Only the functions required for CurveTokenAdapter contract are added.\r\n * The stableswap contract is available here\r\n * github.com/curvefi/curve-contract/blob/compounded/vyper/stableswap.vy.\r\n */\r\n// solhint-disable-next-line contract-name-camelcase\r\ninterface stableswap {\r\n    function coins(int128) external view returns (address);\r\n    function balances(int128) external view returns (uint256);\r\n}\r\n\r\n\r\n/**\r\n * @title Token adapter for Curve pool tokens.\r\n * @dev Implementation of TokenAdapter interface.\r\n * @author Igor Sobolev <sobolev@zerion.io>\r\n */\r\ncontract CurveTokenAdapter is TokenAdapter {\r\n\r\n    address internal constant REGISTRY = 0x86A1755BA805ecc8B0608d56c22716bd1d4B68A8;\r\n    address internal constant CDAI = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;\r\n    address internal constant CUSDC = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;\r\n    address internal constant YDAIV2 = 0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01;\r\n    address internal constant YUSDCV2 = 0xd6aD7a6750A7593E092a9B218d66C0A814a3436e;\r\n    address internal constant YUSDTV2 = 0x83f798e925BcD4017Eb265844FDDAbb448f1707D;\r\n    address internal constant YTUSDV2 = 0x73a052500105205d34Daf004eAb301916DA8190f;\r\n    address internal constant YDAIV3 = 0xC2cB1040220768554cf699b0d863A3cd4324ce32;\r\n    address internal constant YUSDCV3 = 0x26EA744E5B887E5205727f55dFBE8685e3b21951;\r\n    address internal constant YUSDTV3 = 0xE6354ed5bC4b393a5Aad09f21c46E101e692d447;\r\n    address internal constant YBUSDV3 = 0x04bC0Ab673d88aE9dbC9DA2380cB6B79C4BCa9aE;\r\n    address internal constant YCDAI = 0x99d1Fa417f94dcD62BfE781a1213c092a47041Bc;\r\n    address internal constant YCUSDC = 0x9777d7E2b60bB01759D0E2f8be2095df444cb07E;\r\n    address internal constant YCUSDT = 0x1bE5d71F2dA660BFdee8012dDc58D024448A0A59;\r\n\r\n    /**\r\n     * @return TokenMetadata struct with ERC20-style token info.\r\n     * @dev Implementation of TokenAdapter interface function.\r\n     */\r\n    function getMetadata(address token) external view override returns (TokenMetadata memory) {\r\n        return TokenMetadata({\r\n            token: token,\r\n            name: getPoolName(token),\r\n            symbol: ERC20(token).symbol(),\r\n            decimals: ERC20(token).decimals()\r\n        });\r\n    }\r\n\r\n    /**\r\n     * @return Array of Component structs with underlying tokens rates for the given token.\r\n     * @dev Implementation of TokenAdapter interface function.\r\n     */\r\n    function getComponents(address token) external view override returns (Component[] memory) {\r\n        (address swap, uint256 totalCoins) = CurveRegistry(REGISTRY).getSwapAndTotalCoins(token);\r\n        Component[] memory underlyingComponents= new Component[](totalCoins);\r\n\r\n        address underlyingToken;\r\n        for (uint256 i = 0; i < totalCoins; i++) {\r\n            underlyingToken = stableswap(swap).coins(int128(i));\r\n            underlyingComponents[i] = Component({\r\n                token: underlyingToken,\r\n                tokenType: getTokenType(underlyingToken),\r\n                rate: stableswap(swap).balances(int128(i)) * 1e18 / ERC20(token).totalSupply()\r\n            });\r\n        }\r\n\r\n        return underlyingComponents;\r\n    }\r\n\r\n    /**\r\n     * @return Pool name.\r\n     */\r\n    function getPoolName(address token) internal view returns (string memory) {\r\n        return CurveRegistry(REGISTRY).getName(token);\r\n    }\r\n\r\n    function getTokenType(address token) internal pure returns (string memory) {\r\n        if (token == CDAI || token == CUSDC) {\r\n            return \"CToken\";\r\n        } else if (\r\n            token == YDAIV2 ||\r\n            token == YUSDCV2 ||\r\n            token == YUSDTV2 ||\r\n            token == YTUSDV2 ||\r\n            token == YDAIV3 ||\r\n            token == YUSDCV3 ||\r\n            token == YUSDTV3 ||\r\n            token == YBUSDV3 ||\r\n            token == YCDAI ||\r\n            token == YCUSDC ||\r\n            token == YCUSDT\r\n        ) {\r\n            return \"YToken\";\r\n        } else {\r\n            return \"ERC20\";\r\n        }\r\n    }\r\n}\r\n"
    },
    "/mnt/c/Users/Igor/Desktop/job/dev/zeriontech/defi-sdk/contracts/ERC20.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\r\n//\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n//\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\r\n// GNU General Public License for more details.\r\n//\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\r\n\r\npragma solidity 0.6.5;\r\npragma experimental ABIEncoderV2;\r\n\r\n\r\ninterface ERC20 {\r\n    function approve(address, uint256) external returns (bool);\r\n    function transfer(address, uint256) external returns (bool);\r\n    function transferFrom(address, address, uint256) external returns (bool);\r\n    function name() external view returns (string memory);\r\n    function symbol() external view returns (string memory);\r\n    function decimals() external view returns (uint8);\r\n    function totalSupply() external view returns (uint256);\r\n    function balanceOf(address) external view returns (uint256);\r\n}\r\n"
    },
    "/mnt/c/Users/Igor/Desktop/job/dev/zeriontech/defi-sdk/contracts/Structs.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\r\n//\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n//\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\r\n// GNU General Public License for more details.\r\n//\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\r\n\r\npragma solidity 0.6.5;\r\npragma experimental ABIEncoderV2;\r\n\r\n\r\nstruct ProtocolBalance {\r\n    ProtocolMetadata metadata;\r\n    AdapterBalance[] adapterBalances;\r\n}\r\n\r\n\r\nstruct ProtocolMetadata {\r\n    string name;\r\n    string description;\r\n    string websiteURL;\r\n    string iconURL;\r\n    uint256 version;\r\n}\r\n\r\n\r\nstruct AdapterBalance {\r\n    AdapterMetadata metadata;\r\n    FullTokenBalance[] balances;\r\n}\r\n\r\n\r\nstruct AdapterMetadata {\r\n    address adapterAddress;\r\n    string adapterType; // \"Asset\", \"Debt\"\r\n}\r\n\r\n\r\n// token and its underlying tokens (if exist) balances\r\nstruct FullTokenBalance {\r\n    TokenBalance base;\r\n    TokenBalance[] underlying;\r\n}\r\n\r\n\r\nstruct TokenBalance {\r\n    TokenMetadata metadata;\r\n    uint256 amount;\r\n}\r\n\r\n\r\n// ERC20-style token metadata\r\n// 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE address is used for ETH\r\nstruct TokenMetadata {\r\n    address token;\r\n    string name;\r\n    string symbol;\r\n    uint8 decimals;\r\n}\r\n\r\n\r\nstruct Component {\r\n    address token;\r\n    string tokenType;  // \"ERC20\" by default\r\n    uint256 rate;  // price per full share (1e18)\r\n}\r\n"
    },
    "/mnt/c/Users/Igor/Desktop/job/dev/zeriontech/defi-sdk/contracts/adapters/TokenAdapter.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\r\n//\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n//\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\r\n// GNU General Public License for more details.\r\n//\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\r\n\r\npragma solidity 0.6.5;\r\npragma experimental ABIEncoderV2;\r\n\r\nimport { TokenMetadata, Component } from \"../Structs.sol\";\r\n\r\n\r\n/**\r\n * @title Token adapter interface.\r\n * @dev getMetadata() and getComponents() functions MUST be implemented.\r\n * @author Igor Sobolev <sobolev@zerion.io>\r\n */\r\ninterface TokenAdapter {\r\n\r\n    /**\r\n     * @dev MUST return TokenMetadata struct with ERC20-style token info.\r\n     * struct TokenMetadata {\r\n     *     address token;\r\n     *     string name;\r\n     *     string symbol;\r\n     *     uint8 decimals;\r\n     * }\r\n     */\r\n    function getMetadata(address token) external view returns (TokenMetadata memory);\r\n\r\n    /**\r\n     * @dev MUST return array of Component structs with underlying tokens rates for the given token.\r\n     * struct Component {\r\n     *     address token;    // Address of token contract\r\n     *     string tokenType; // Token type (\"ERC20\" by default)\r\n     *     uint256 rate;     // Price per share (1e18)\r\n     * }\r\n     */\r\n    function getComponents(address token) external view returns (Component[] memory);\r\n}\r\n"
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