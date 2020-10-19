{"ERC20Swap.sol":{"content":"// SPDX-License-Identifier: AGPL-3.0-or-later\n\npragma solidity 0.7.1;\n\nimport \"./TransferHelper.sol\";\n\ncontract ERC20Swap {\n    uint8 constant public version = 1;\n\n    mapping (bytes32 =\u003e bool) public swaps;\n\n    event Lockup(\n        bytes32 indexed preimageHash,\n        uint256 amount,\n        address tokenAddress,\n        address claimAddress,\n        address indexed refundAddress,\n        uint timelock\n    );\n\n    event Claim(bytes32 indexed preimageHash, bytes32 preimage);\n    event Refund(bytes32 indexed preimageHash);\n\n    function hashValues(\n        bytes32 preimageHash,\n        uint256 amount,\n        address tokenAddress,\n        address claimAddress,\n        address refundAddress,\n        uint timelock\n    ) private pure returns (bytes32) {\n        return keccak256(abi.encodePacked(\n            preimageHash,\n            amount,\n            tokenAddress,\n            claimAddress,\n            refundAddress,\n            timelock\n        ));\n    }\n\n    function checkSwapExists(bytes32 hash) private view {\n        require(swaps[hash] == true, \"ERC20Swap: swap does not exist\");\n    }\n\n    function lock(\n        bytes32 preimageHash,\n        uint256 amount,\n        address tokenAddress,\n        address claimAddress,\n        uint timelock\n    ) external {\n        require(amount \u003e 0, \"ERC20Swap: amount must not be zero\");\n\n        TransferHelper.safeTransferFrom(tokenAddress, msg.sender, address(this), amount);\n\n        bytes32 hash = hashValues(\n            preimageHash,\n            amount,\n            tokenAddress,\n            claimAddress,\n            msg.sender,\n            timelock\n        );\n\n        require(swaps[hash] == false, \"ERC20Swap: swap exists already\");\n        swaps[hash] = true;\n\n        emit Lockup(preimageHash, amount, tokenAddress, claimAddress, msg.sender, timelock);\n    }\n\n    function claim(\n        bytes32 preimage,\n        uint amount,\n        address tokenAddress,\n        address refundAddress,\n        uint timelock\n    ) external {\n        bytes32 preimageHash = sha256(abi.encodePacked(preimage));\n        bytes32 hash = hashValues(\n            preimageHash,\n            amount,\n            tokenAddress,\n            msg.sender,\n            refundAddress,\n            timelock\n        );\n\n        checkSwapExists(hash);\n        delete swaps[hash];\n\n        emit Claim(preimageHash, preimage);\n\n        TransferHelper.safeTransfer(tokenAddress, msg.sender, amount);\n    }\n\n    function refund(\n        bytes32 preimageHash,\n        uint amount,\n        address tokenAddress,\n        address claimAddress,\n        uint timelock\n    ) external {\n        require(timelock \u003c= block.number, \"ERC20Swap: swap has not timed out yet\");\n\n        bytes32 hash = hashValues(\n            preimageHash,\n            amount,\n            tokenAddress,\n            claimAddress,\n            msg.sender,\n            timelock\n        );\n\n        checkSwapExists(hash);\n        delete swaps[hash];\n\n        emit Refund(preimageHash);\n\n        TransferHelper.safeTransfer(tokenAddress, msg.sender, amount);\n    }\n}\n"},"TransferHelper.sol":{"content":"// SPDX-License-Identifier: GPL-3.0-or-later\n\npragma solidity 0.7.1;\n\n// Copyright 2020 Uniswap team\n// Based on: https://github.com/Uniswap/uniswap-lib/blob/master/contracts/libraries/TransferHelper.sol\nlibrary TransferHelper {\n    function safeTransfer(address token, address to, uint value) internal {\n        // bytes4(keccak256(bytes(\u0027transfer(address,uint256)\u0027)));\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));\n        require(\n            success \u0026\u0026 (data.length == 0 || abi.decode(data, (bool))),\n            \"TransferHelper: could not transfer ERC20 tokens\"\n        );\n    }\n\n    function safeTransferFrom(address token, address from, address to, uint value) internal {\n        // bytes4(keccak256(bytes(\u0027transferFrom(address,address,uint256)\u0027)));\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));\n        require(\n            success \u0026\u0026 (data.length == 0 || abi.decode(data, (bool))),\n            \"TransferHelper: could not transferFrom ERC20 tokens\"\n        );\n    }\n}\n"}}