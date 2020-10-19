{{
  "language": "Solidity",
  "sources": {
    "/Users/igor/job/dev/defi-sdk/contracts/interactiveAdapters/weth/WethInteractiveAdapter.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n//\n// SPDX-License-Identifier: LGPL-3.0-only\n\npragma solidity 0.6.11;\npragma experimental ABIEncoderV2;\n\nimport { TokenAmount } from \"../../shared/Structs.sol\";\nimport { WethAdapter } from \"../../adapters/weth/WethAdapter.sol\";\nimport { InteractiveAdapter } from \"../InteractiveAdapter.sol\";\n\n\n/**\n * @dev WETH9 contract interface.\n * Only the functions required for WethInteractiveAdapter contract are added.\n * The WETH9 contract is available here\n * github.com/0xProject/0x-monorepo/blob/development/contracts/erc20/contracts/src/WETH9.sol.\n */\ninterface WETH9 {\n    function deposit() external payable;\n    function withdraw(uint256) external;\n}\n\n\n/**\n * @title Interactive adapter for Wrapped Ether.\n * @dev Implementation of InteractiveAdapter abstract contract.\n */\ncontract WethInteractiveAdapter is InteractiveAdapter, WethAdapter {\n\n    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;\n\n    /**\n     * @notice Wraps Ether in Wrapped Ether.\n     * @param tokenAmounts Array with one element - TokenAmount struct with\n     * ETH address (0xEeee...EEeE), ETH amount to be deposited, and amount type.\n     * @return tokensToBeWithdrawn Array with one element - WETH token address.\n     * @dev Implementation of InteractiveAdapter function.\n     */\n    function deposit(\n        TokenAmount[] memory tokenAmounts,\n        bytes memory\n    )\n        public\n        payable\n        override\n        returns (address[] memory tokensToBeWithdrawn)\n    {\n        require(tokenAmounts.length == 1, \"WIA: should be 1 tokenAmount\");\n        require(tokenAmounts[0].token == ETH, \"WIA: should be ETH\");\n\n        uint256 amount = getAbsoluteAmountDeposit(tokenAmounts[0]);\n\n        tokensToBeWithdrawn = new address[](1);\n        tokensToBeWithdrawn[0] = WETH;\n\n        try WETH9(WETH).deposit{value: amount}() { // solhint-disable-line no-empty-blocks\n        } catch Error(string memory reason) {\n            revert(reason);\n        } catch {\n            revert(\"WIA: deposit fail\");\n        }\n    }\n\n    /**\n     * @notice Unwraps Ether from Wrapped Ether.\n     * @param tokenAmounts Array with one element - TokenAmount struct with\n     * WETH token address, WETH token amount to be redeemed, and amount type.\n     * @return tokensToBeWithdrawn Array with one element - ETH address (0xEeee...EEeE).\n     * @dev Implementation of InteractiveAdapter function.\n     */\n    function withdraw(\n        TokenAmount[] memory tokenAmounts,\n        bytes memory\n    )\n        public\n        payable\n        override\n        returns (address[] memory tokensToBeWithdrawn)\n    {\n        require(tokenAmounts.length == 1, \"WIA: should be 1 tokenAmount\");\n        require(tokenAmounts[0].token == WETH, \"WIA: should be WETH\");\n\n        uint256 amount = getAbsoluteAmountWithdraw(tokenAmounts[0]);\n\n        tokensToBeWithdrawn = new address[](1);\n        tokensToBeWithdrawn[0] = ETH;\n\n        try WETH9(WETH).withdraw(amount) { // solhint-disable-line no-empty-blocks\n        } catch Error(string memory reason) {\n            revert(reason);\n        } catch {\n            revert(\"WIA: withdraw fail\");\n        }\n    }\n}\n"
    },
    "/Users/igor/job/dev/defi-sdk/contracts/shared/Structs.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n//\n// SPDX-License-Identifier: LGPL-3.0-only\n\npragma solidity 0.6.11;\npragma experimental ABIEncoderV2;\n\n\n// The struct consists of AbsoluteTokenAmount structs for\n// (base) token and its underlying tokens (if any).\nstruct FullAbsoluteTokenAmount {\n    AbsoluteTokenAmountMeta base;\n    AbsoluteTokenAmountMeta[] underlying;\n}\n\n\n// The struct consists of AbsoluteTokenAmount struct\n// with token address and absolute amount\n// and ERC20Metadata struct with ERC20-style metadata.\n// NOTE: 0xEeee...EEeE address is used for ETH.\nstruct AbsoluteTokenAmountMeta {\n    AbsoluteTokenAmount absoluteTokenAmount;\n    ERC20Metadata erc20metadata;\n}\n\n\n// The struct consists of ERC20-style token metadata.\nstruct ERC20Metadata {\n    string name;\n    string symbol;\n    uint8 decimals;\n}\n\n\n// The struct consists of protocol adapter's name\n// and array of AbsoluteTokenAmount structs\n// with token addresses and absolute amounts.\nstruct AdapterBalance {\n    bytes32 protocolAdapterName;\n    AbsoluteTokenAmount[] absoluteTokenAmounts;\n}\n\n\n// The struct consists of token address\n// and its absolute amount.\nstruct AbsoluteTokenAmount {\n    address token;\n    uint256 amount;\n}\n\n\n// The struct consists of token address,\n// and price per full share (1e18).\nstruct Component {\n    address token;\n    uint256 rate;\n}\n\n\n//=============================== Interactive Adapters Structs ====================================\n\n\nstruct TransactionData {\n    Action[] actions;\n    TokenAmount[] inputs;\n    Fee fee;\n    AbsoluteTokenAmount[] requiredOutputs;\n    uint256 nonce;\n}\n\n\nstruct Action {\n    bytes32 protocolAdapterName;\n    ActionType actionType;\n    TokenAmount[] tokenAmounts;\n    bytes data;\n}\n\n\nstruct TokenAmount {\n    address token;\n    uint256 amount;\n    AmountType amountType;\n}\n\n\nstruct Fee {\n    uint256 share;\n    address beneficiary;\n}\n\n\nenum ActionType { None, Deposit, Withdraw }\n\n\nenum AmountType { None, Relative, Absolute }\n"
    },
    "/Users/igor/job/dev/defi-sdk/contracts/adapters/weth/WethAdapter.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n//\n// SPDX-License-Identifier: LGPL-3.0-only\n\npragma solidity 0.6.11;\npragma experimental ABIEncoderV2;\n\nimport { ERC20 } from \"../../shared/ERC20.sol\";\nimport { ProtocolAdapter } from \"../ProtocolAdapter.sol\";\n\n\n/**\n * @title Adapter for Wrapped Ether.\n * @dev Implementation of ProtocolAdapter abstract contract.\n * @author Igor Sobolev <sobolev@zerion.io>\n */\ncontract WethAdapter is ProtocolAdapter {\n\n    /**\n     * @return Amount of WETH held by the given account.\n     * @dev Implementation of ProtocolAdapter abstract contract function.\n     */\n    function getBalance(\n        address token,\n        address account\n    )\n        public\n        view\n        override\n        returns (uint256)\n    {\n        return ERC20(token).balanceOf(account);\n    }\n}\n"
    },
    "/Users/igor/job/dev/defi-sdk/contracts/shared/ERC20.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n//\n// SPDX-License-Identifier: LGPL-3.0-only\n\npragma solidity 0.6.11;\npragma experimental ABIEncoderV2;\n\n\ninterface ERC20 {\n    function approve(address, uint256) external returns (bool);\n    function transfer(address, uint256) external returns (bool);\n    function transferFrom(address, address, uint256) external returns (bool);\n    function name() external view returns (string memory);\n    function symbol() external view returns (string memory);\n    function decimals() external view returns (uint8);\n    function totalSupply() external view returns (uint256);\n    function balanceOf(address) external view returns (uint256);\n    function allowance(address, address) external view returns (uint256);\n}\n"
    },
    "/Users/igor/job/dev/defi-sdk/contracts/adapters/ProtocolAdapter.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n//\n// SPDX-License-Identifier: LGPL-3.0-only\n\npragma solidity 0.6.11;\npragma experimental ABIEncoderV2;\n\n\n/**\n * @title Protocol adapter abstract contract.\n * @dev adapterType(), tokenType(), and getBalance() functions MUST be implemented.\n * @author Igor Sobolev <sobolev@zerion.io>\n */\nabstract contract ProtocolAdapter {\n\n    /**\n     * @dev MUST return amount and type of the given token\n     * locked on the protocol by the given account.\n     */\n    function getBalance(\n        address token,\n        address account\n    )\n        public\n        view\n        virtual\n        returns (uint256);\n}\n"
    },
    "/Users/igor/job/dev/defi-sdk/contracts/interactiveAdapters/InteractiveAdapter.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n//\n// SPDX-License-Identifier: LGPL-3.0-only\n\npragma solidity 0.6.11;\npragma experimental ABIEncoderV2;\n\nimport { ProtocolAdapter } from \"../adapters/ProtocolAdapter.sol\";\nimport { TokenAmount, AmountType } from \"../shared/Structs.sol\";\nimport { ERC20 } from \"../shared/ERC20.sol\";\n\n\n/**\n * @title Base contract for interactive protocol adapters.\n * @dev deposit() and withdraw() functions MUST be implemented\n * as well as all the functions from ProtocolAdapter abstract contract.\n * @author Igor Sobolev <sobolev@zerion.io>\n */\nabstract contract InteractiveAdapter is ProtocolAdapter {\n\n    uint256 internal constant DELIMITER = 1e18;\n    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\n\n    /**\n     * @dev The function must deposit assets to the protocol.\n     * @return MUST return assets to be sent back to the `msg.sender`.\n     */\n    function deposit(\n        TokenAmount[] memory tokenAmounts,\n        bytes memory data\n    )\n        public\n        payable\n        virtual\n        returns (address[] memory);\n\n    /**\n     * @dev The function must withdraw assets from the protocol.\n     * @return MUST return assets to be sent back to the `msg.sender`.\n     */\n    function withdraw(\n        TokenAmount[] memory tokenAmounts,\n        bytes memory data\n    )\n        public\n        payable\n        virtual\n        returns (address[] memory);\n\n    function getAbsoluteAmountDeposit(\n        TokenAmount memory tokenAmount\n    )\n        internal\n        view\n        virtual\n        returns (uint256)\n    {\n        address token = tokenAmount.token;\n        uint256 amount = tokenAmount.amount;\n        AmountType amountType = tokenAmount.amountType;\n\n        require(\n            amountType == AmountType.Relative || amountType == AmountType.Absolute,\n            \"IA: bad amount type\"\n        );\n        if (amountType == AmountType.Relative) {\n            require(amount <= DELIMITER, \"IA: bad amount\");\n\n            uint256 balance;\n            if (token == ETH) {\n                balance = address(this).balance;\n            } else {\n                balance = ERC20(token).balanceOf(address(this));\n            }\n\n            if (amount == DELIMITER) {\n                return balance;\n            } else {\n                return mul(balance, amount) / DELIMITER;\n            }\n        } else {\n            return amount;\n        }\n    }\n\n    function getAbsoluteAmountWithdraw(\n        TokenAmount memory tokenAmount\n    )\n        internal\n        view\n        virtual\n        returns (uint256)\n    {\n        address token = tokenAmount.token;\n        uint256 amount = tokenAmount.amount;\n        AmountType amountType = tokenAmount.amountType;\n\n        require(\n            amountType == AmountType.Relative || amountType == AmountType.Absolute,\n            \"IA: bad amount type\"\n        );\n        if (amountType == AmountType.Relative) {\n            require(amount <= DELIMITER, \"IA: bad amount\");\n\n            uint256 balance = getBalance(token, address(this));\n            if (amount == DELIMITER) {\n                return balance;\n            } else {\n                return mul(balance, amount) / DELIMITER;\n            }\n        } else {\n            return amount;\n        }\n    }\n\n    function mul(\n        uint256 a,\n        uint256 b\n    )\n        internal\n        pure\n        returns (uint256)\n    {\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, \"IA: mul overflow\");\n\n        return c;\n    }\n}\n"
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