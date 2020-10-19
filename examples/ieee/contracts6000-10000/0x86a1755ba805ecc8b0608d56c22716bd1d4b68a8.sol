{{
  "language": "Solidity",
  "sources": {
    "/Users/igor/job/dev/protocol-wrappers/contracts/adapters/curve/CurveRegistry.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n//\n// SPDX-License-Identifier: LGPL-3.0-only\n\npragma solidity 0.6.8;\n\nimport { Ownable } from \"../../Ownable.sol\";\n\n\nstruct PoolInfo {\n    address swap;       // stableswap contract address.\n    uint256 totalCoins; // Number of coins used in stableswap contract.\n    string name;        // Pool name (\"... Pool\").\n}\n\n\n/**\n * @title Registry for Curve contracts.\n * @dev Implements two getters - getSwapAndTotalCoins(address) and getName(address).\n * @notice Call getSwapAndTotalCoins(token) and getName(address) function and get address,\n * coins number, and name of stableswap contract for the given token address.\n * @author Igor Sobolev <sobolev@zerion.io>\n */\ncontract CurveRegistry is Ownable {\n\n    mapping (address => PoolInfo) internal poolInfo;\n\n    constructor() public {\n        poolInfo[0x845838DF265Dcd2c412A1Dc9e959c7d08537f8a2] = PoolInfo({\n            swap: 0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56,\n            totalCoins: 2,\n            name: \"Compound Pool\"\n        });\n        poolInfo[0x9fC689CCaDa600B6DF723D9E47D84d76664a1F23] = PoolInfo({\n            swap: 0x52EA46506B9CC5Ef470C5bf89f17Dc28bB35D85C,\n            totalCoins: 3,\n            name: \"T Pool\"\n        });\n        poolInfo[0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8] = PoolInfo({\n            swap: 0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51,\n            totalCoins: 4,\n            name: \"Y Pool\"\n        });\n        poolInfo[0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B] = PoolInfo({\n            swap: 0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27,\n            totalCoins: 4,\n            name: \"bUSD Pool\"\n        });\n        poolInfo[0xC25a3A3b969415c80451098fa907EC722572917F] = PoolInfo({\n            swap: 0xA5407eAE9Ba41422680e2e00537571bcC53efBfD,\n            totalCoins: 4,\n            name: \"sUSD Pool\"\n        });\n        poolInfo[0xD905e2eaeBe188fc92179b6350807D8bd91Db0D8] = PoolInfo({\n            swap: 0x06364f10B501e868329afBc005b3492902d6C763,\n            totalCoins: 4,\n            name: \"PAX Pool\"\n        });\n        poolInfo[0x1f2a662FB513441f06b8dB91ebD9a1466462b275] = PoolInfo({\n            swap: 0x9726e9314eF1b96E45f40056bEd61A088897313E,\n            totalCoins: 3,\n            name: \"tBTC Pool\"\n        });\n        poolInfo[0x7771F704490F9C0C3B06aFe8960dBB6c58CBC812] = PoolInfo({\n            swap: 0x8474c1236F0Bc23830A23a41aBB81B2764bA9f4F,\n            totalCoins: 2,\n            name: \"renBTC Pool\"\n        });\n    }\n\n    function setPoolInfo(\n        address token,\n        address swap,\n        uint256 totalCoins,\n        string calldata name\n    )\n        external\n        onlyOwner\n    {\n        poolInfo[token] = PoolInfo({\n            swap: swap,\n            totalCoins: totalCoins,\n            name: name\n        });\n    }\n\n    function getSwapAndTotalCoins(address token) external view returns (address, uint256) {\n        return (poolInfo[token].swap, poolInfo[token].totalCoins);\n    }\n\n    function getName(address token) external view returns (string memory) {\n        return poolInfo[token].name;\n    }\n}\n"
    },
    "/Users/igor/job/dev/protocol-wrappers/contracts/Ownable.sol": {
      "content": "// Copyright (C) 2020 Zerion Inc. <https://zerion.io>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with this program. If not, see <https://www.gnu.org/licenses/>.\n//\n// SPDX-License-Identifier: LGPL-3.0-only\n\npragma solidity 0.6.8;\npragma experimental ABIEncoderV2;\n\n\nabstract contract Ownable {\n\n    modifier onlyOwner {\n        require(msg.sender == owner, \"O: onlyOwner function!\");\n        _;\n    }\n\n    address public owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @notice Initializes owner variable with msg.sender address.\n     */\n    constructor() internal {\n        owner = msg.sender;\n        emit OwnershipTransferred(address(0), msg.sender);\n    }\n\n    /**\n     * @notice Transfers ownership to the desired address.\n     * The function is callable only by the owner.\n     */\n    function transferOwnership(address _owner) external onlyOwner {\n        require(_owner != address(0), \"O: new owner is the zero address!\");\n        emit OwnershipTransferred(owner, _owner);\n        owner = _owner;\n    }\n}\n"
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