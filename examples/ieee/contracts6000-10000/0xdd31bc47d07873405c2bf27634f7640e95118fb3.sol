{{
  "language": "Solidity",
  "sources": {
    "/mnt/c/Users/Igor/Desktop/job/dev/zeriontech/defi-sdk/contracts/adapters/compound/CompoundGovernanceAdapter.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\r\n//\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n//\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\r\n// GNU General Public License for more details.\r\n//\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\r\n\r\npragma solidity 0.6.5;\r\npragma experimental ABIEncoderV2;\r\n\r\nimport { ERC20 } from \"../../ERC20.sol\";\r\nimport { ProtocolAdapter } from \"../ProtocolAdapter.sol\";\r\n\r\n\r\n/**\r\n * @dev CompMarketState contract interface.\r\n * Only the functions required for CompoundGovernanceAdapter contract are added.\r\n * The CompMarketState struct is available here\r\n * github.com/compound-finance/compound-protocol/blob/master/contracts/ComptrollerStorage.sol.\r\n */\r\nstruct CompMarketState {\r\n    uint224 index;\r\n    uint32 block;\r\n}\r\n\r\n\r\n/**\r\n * @dev Comptroller contract interface.\r\n * Only the functions required for CompoundGovernanceAdapter contract are added.\r\n * The Comptroller contract is available here\r\n * github.com/compound-finance/compound-protocol/blob/master/contracts/Comptroller.sol.\r\n */\r\ninterface Comptroller {\r\n    function getAllMarkets() external view returns (address[] memory);\r\n    function compBorrowState(address) external view returns (CompMarketState memory);\r\n    function compSupplyState(address) external view returns (CompMarketState memory);\r\n    function compBorrowerIndex(address, address) external view returns (uint256);\r\n    function compSupplierIndex(address, address) external view returns (uint256);\r\n    function compAccrued(address) external view returns (uint256);\r\n}\r\n\r\n\r\n/**\r\n * @dev CToken contract interface.\r\n * Only the functions required for CompoundGovernanceAdapter contract are added.\r\n * The CToken contract is available here\r\n * github.com/compound-finance/compound-protocol/blob/master/contracts/CToken.sol.\r\n */\r\ninterface CToken {\r\n    function borrowBalanceStored(address) external view returns (uint256);\r\n    function borrowIndex() external view returns (uint256);\r\n    function balanceOf(address) external view returns (uint256);\r\n}\r\n\r\n\r\n/**\r\n * @title Asset adapter for Compound Governance.\r\n * @dev Implementation of ProtocolAdapter interface.\r\n * @author Igor Sobolev <sobolev@zerion.io>\r\n */\r\ncontract CompoundGovernanceAdapter is ProtocolAdapter {\r\n\r\n    string public constant override adapterType = \"Asset\";\r\n\r\n    string public constant override tokenType = \"ERC20\";\r\n\r\n    address internal constant COMPTROLLER = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;\r\n\r\n    /**\r\n     * @return Amount of unclaimed COMP by the given account.\r\n     * @dev Implementation of ProtocolAdapter interface function.\r\n     */\r\n    function getBalance(address, address account) external view override returns (uint256) {\r\n        uint256 balance = Comptroller(COMPTROLLER).compAccrued(account);\r\n        address[] memory allMarkets = Comptroller(COMPTROLLER).getAllMarkets();\r\n\r\n        for (uint256 i = 0; i < allMarkets.length; i++) {\r\n            balance += borrowerComp(account, allMarkets[i]);\r\n            balance += supplierComp(account, allMarkets[i]);\r\n        }\r\n\r\n        return balance;\r\n    }\r\n\r\n    function borrowerComp(address account, address cToken) internal view returns (uint256) {\r\n        uint256 borrowerIndex = Comptroller(COMPTROLLER).compBorrowerIndex(cToken, account);\r\n\r\n        if (borrowerIndex > 0) {\r\n            uint256 borrowIndex = uint256(Comptroller(COMPTROLLER).compBorrowState(cToken).index);\r\n            require(borrowIndex >= borrowerIndex, \"CGA: underflow!\");\r\n            uint256 deltaIndex = borrowIndex - borrowerIndex;\r\n            uint256 borrowerAmount = mul(\r\n                CToken(cToken).borrowBalanceStored(account),\r\n                1e18\r\n            ) / CToken(cToken).borrowIndex();\r\n            uint256 borrowerDelta = mul(borrowerAmount, deltaIndex) / 1e36;\r\n            return borrowerDelta;\r\n        } else {\r\n            return 0;\r\n        }\r\n    }\r\n\r\n    function supplierComp(address account, address cToken) internal view returns (uint256) {\r\n        uint256 supplierIndex = Comptroller(COMPTROLLER).compSupplierIndex(cToken, account);\r\n        uint256 supplyIndex = uint256(Comptroller(COMPTROLLER).compSupplyState(cToken).index);\r\n        if (supplierIndex == 0 && supplyIndex > 0) {\r\n            supplierIndex = 1e36;\r\n        }\r\n        require(supplyIndex >= supplierIndex, \"CGA: underflow!\");\r\n        uint256 deltaIndex = supplyIndex - supplierIndex;\r\n        uint256 supplierAmount = CToken(cToken).balanceOf(account);\r\n        uint256 supplierDelta = mul(supplierAmount, deltaIndex) / 1e36;\r\n\r\n        return supplierDelta;\r\n    }\r\n\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \"CGA: mul overflow\");\r\n\r\n        return c;\r\n    }\r\n}\r\n"
    },
    "/mnt/c/Users/Igor/Desktop/job/dev/zeriontech/defi-sdk/contracts/ERC20.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\r\n//\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n//\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\r\n// GNU General Public License for more details.\r\n//\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\r\n\r\npragma solidity 0.6.5;\r\npragma experimental ABIEncoderV2;\r\n\r\n\r\ninterface ERC20 {\r\n    function approve(address, uint256) external returns (bool);\r\n    function transfer(address, uint256) external returns (bool);\r\n    function transferFrom(address, address, uint256) external returns (bool);\r\n    function name() external view returns (string memory);\r\n    function symbol() external view returns (string memory);\r\n    function decimals() external view returns (uint8);\r\n    function totalSupply() external view returns (uint256);\r\n    function balanceOf(address) external view returns (uint256);\r\n}\r\n"
    },
    "/mnt/c/Users/Igor/Desktop/job/dev/zeriontech/defi-sdk/contracts/adapters/ProtocolAdapter.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\r\n//\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n//\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\r\n// GNU General Public License for more details.\r\n//\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\r\n\r\npragma solidity 0.6.5;\r\npragma experimental ABIEncoderV2;\r\n\r\n\r\n/**\r\n * @title Protocol adapter interface.\r\n * @dev adapterType(), tokenType(), and getBalance() functions MUST be implemented.\r\n * @author Igor Sobolev <sobolev@zerion.io>\r\n */\r\ninterface ProtocolAdapter {\r\n\r\n    /**\r\n     * @dev MUST return \"Asset\" or \"Debt\".\r\n     * SHOULD be implemented by the public constant state variable.\r\n     */\r\n    function adapterType() external pure returns (string memory);\r\n\r\n    /**\r\n     * @dev MUST return token type (default is \"ERC20\").\r\n     * SHOULD be implemented by the public constant state variable.\r\n     */\r\n    function tokenType() external pure returns (string memory);\r\n\r\n    /**\r\n     * @dev MUST return amount of the given token locked on the protocol by the given account.\r\n     */\r\n    function getBalance(address token, address account) external view returns (uint256);\r\n}\r\n"
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