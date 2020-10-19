{"IUnifiedStableFarming.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.7.0;\n\ninterface IUnifiedStableFarming {\n\n    function percentage() external view returns(uint256[] memory);\n\n    //Earn pumping uSD - Means swap a chosen stableCoin for uSD, then burn the difference of uSD to obtain a greater uSD value in Uniswap Pool tokens\n    function earnByPump(\n        address stableCoinAddress,\n        uint256 pairIndex,\n        uint256 pairAmount,\n        uint256 amount0,\n        uint256 amount1,\n        address tokenAddress,\n        uint256 tokenValue) external;\n\n    //Earn dumping uSD - Means mint uSD then swap uSD for the chosen Uniswap Pool tokens\n    function earnByDump(\n        address stableCoinAddress,\n        uint256 pairIndex,\n        uint256 amount0,\n        uint256 amount1,\n        uint256 amount0Min,\n        uint256 amount1Min,\n        uint256[] calldata tokenIndices,\n        uint256[] calldata stableCoinAmounts) external;\n}\n\ninterface IStableCoin {\n\n    function allowedPairs() external view returns (address[] memory);\n\n    function fromTokenToStable(address tokenAddress, uint256 amount)\n        external\n        view\n        returns (uint256);\n\n    function mint(\n        uint256 pairIndex,\n        uint256 amount0,\n        uint256 amount1,\n        uint256 amount0Min,\n        uint256 amount1Min\n    ) external returns (uint256);\n\n    function burn(\n        uint256 pairIndex,\n        uint256 pairAmount,\n        uint256 amount0,\n        uint256 amount1\n    ) external returns (uint256, uint256);\n}\n\ninterface IUniswapV2Pair {\n    function token0() external view returns (address);\n    function token1() external view returns (address);\n}\n\ninterface IUniswapV2Router {\n    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);\n    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);\n}\n\ninterface IERC20 {\n    function balanceOf(address account) external view returns (uint256);\n    function transfer(address recipient, uint256 amount) external returns (bool);\n    function allowance(address owner, address spender) external view returns (uint256);\n    function approve(address spender, uint256 amount) external returns (bool);\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n}"},"UnifiedStableFarming.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.7.0;\n\nimport \"./IUnifiedStableFarming.sol\";\n\ncontract UnifiedStableFarming is IUnifiedStableFarming {\n    address\n        private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;\n\n    uint256[] private _percentage;\n\n    constructor(uint256[] memory percentage) {\n        assert(percentage.length == 2);\n        _percentage = percentage;\n    }\n\n    function percentage() public override view returns(uint256[] memory) {\n        return _percentage;\n    }\n\n    //Earn pumping uSD - Means swap a chosen stableCoin for uSD, then burn the difference of uSD to obtain a greater uSD value in Uniswap Pool tokens\n    function earnByPump(\n        address stableCoinAddress,\n        uint256 pairIndex,\n        uint256 pairAmount,\n        uint256 amount0,\n        uint256 amount1,\n        address tokenAddress,\n        uint256 tokenValue\n    ) public override {\n        require(\n            _isValidPairToken(stableCoinAddress, tokenAddress),\n            \"Choosen token address is not in a valid pair\"\n        );\n        _transferToMeAndCheckAllowance(\n            tokenAddress,\n            tokenValue,\n            UNISWAP_V2_ROUTER\n        );\n        uint256 stableCoinAmount = _swap(\n            tokenAddress,\n            stableCoinAddress,\n            tokenValue,\n            address(this)\n        );\n        (uint256 return0, uint256 return1) = IStableCoin(stableCoinAddress)\n            .burn(pairIndex, pairAmount, amount0, amount1);\n        (address token0, address token1, ) = _getPairData(\n            stableCoinAddress,\n            pairIndex\n        );\n        require(\n            _isPumpOK(\n                stableCoinAddress,\n                tokenAddress,\n                tokenValue,\n                token0,\n                return0,\n                token1,\n                return1,\n                stableCoinAmount\n            ),\n            \"Values are not coherent\"\n        );\n        _flushToSender(token0, token1, stableCoinAddress);\n    }\n\n    function _isPumpOK(\n        address stableCoinAddress,\n        address tokenAddress,\n        uint256 tokenValue,\n        address token0,\n        uint256 return0,\n        address token1,\n        uint256 return1,\n        uint256 stableCoinAmount\n    ) private view returns (bool) {\n        IStableCoin stableCoin = IStableCoin(stableCoinAddress);\n        uint256 cumulative = stableCoin.fromTokenToStable(\n            tokenAddress,\n            tokenValue\n        );\n        cumulative += stableCoin.fromTokenToStable(token0, return0);\n        cumulative += stableCoin.fromTokenToStable(token1, return1);\n        uint256 percentage = (cumulative * _percentage[0]) / _percentage[1];\n        uint256 cumulativePlus = cumulative + percentage;\n        uint256 cumulativeMinus = cumulative - percentage;\n        return\n            stableCoinAmount \u003e= cumulativeMinus \u0026\u0026\n            stableCoinAmount \u003c= cumulativePlus;\n    }\n\n    //Earn dumping uSD - Means mint uSD then swap uSD for the chosen Uniswap Pool tokens\n    function earnByDump(\n        address stableCoinAddress,\n        uint256 pairIndex,\n        uint256 amount0,\n        uint256 amount1,\n        uint256 amount0Min,\n        uint256 amount1Min,\n        uint256[] memory tokenIndices,\n        uint256[] memory stableCoinAmounts\n    ) public override {\n        require(\n            tokenIndices.length \u003e 0 \u0026\u0026 tokenIndices.length \u003c= 2,\n            \"You must choose at least one of the two Tokens\"\n        );\n        require(\n            tokenIndices.length == stableCoinAmounts.length,\n            \"Token Indices and StableCoin Amounts must have the same length\"\n        );\n        (address token0, address token1) = _prepareForDump(\n            stableCoinAddress,\n            pairIndex,\n            amount0,\n            amount1\n        );\n        IStableCoin(stableCoinAddress).mint(\n            pairIndex,\n            amount0,\n            amount1,\n            amount0Min,\n            amount1Min\n        );\n        for (uint256 i = 0; i \u003c tokenIndices.length; i++) {\n            _swap(\n                stableCoinAddress,\n                tokenIndices[i] == 0 ? token0 : token1,\n                stableCoinAmounts[i],\n                msg.sender\n            );\n        }\n        _flushToSender(token0, token1, stableCoinAddress);\n    }\n\n    function _transferTokens(\n        address stableCoinAddress,\n        uint256 pairIndex,\n        uint256 amount0,\n        uint256 amount1\n    ) private {\n        (address token0, address token1, ) = _getPairData(\n            stableCoinAddress,\n            pairIndex\n        );\n        IERC20(token0).transferFrom(msg.sender, address(this), amount0);\n        IERC20(token1).transferFrom(msg.sender, address(this), amount1);\n    }\n\n    function _getPairData(address stableCoinAddress, uint256 pairIndex)\n        private\n        view\n        returns (\n            address token0,\n            address token1,\n            address pairAddress\n        )\n    {\n        IUniswapV2Pair pair = IUniswapV2Pair(\n            pairAddress = IStableCoin(stableCoinAddress)\n                .allowedPairs()[pairIndex]\n        );\n        token0 = pair.token0();\n        token1 = pair.token1();\n    }\n\n    function _checkAllowance(\n        address tokenAddress,\n        uint256 value,\n        address spender\n    ) private {\n        IERC20 token = IERC20(tokenAddress);\n        if (token.allowance(address(this), spender) \u003c= value) {\n            token.approve(spender, value);\n        }\n    }\n\n    function _transferToMeAndCheckAllowance(\n        address tokenAddress,\n        uint256 value,\n        address spender\n    ) private {\n        IERC20(tokenAddress).transferFrom(msg.sender, address(this), value);\n        _checkAllowance(tokenAddress, value, spender);\n    }\n\n    function _prepareForDump(\n        address stableCoinAddress,\n        uint256 pairIndex,\n        uint256 amount0,\n        uint256 amount1\n    ) private returns (address token0, address token1) {\n        (token0, token1, ) = _getPairData(stableCoinAddress, pairIndex);\n        _transferToMeAndCheckAllowance(token0, amount0, stableCoinAddress);\n        _transferToMeAndCheckAllowance(token1, amount1, stableCoinAddress);\n    }\n\n    function _flushToSender(\n        address token0,\n        address token1,\n        address token2\n    ) private {\n        _flushToSender(token0);\n        _flushToSender(token1);\n        _flushToSender(token2);\n    }\n\n    function _flushToSender(address tokenAddress) private {\n        if (tokenAddress == address(0)) {\n            return;\n        }\n        IERC20 token = IERC20(tokenAddress);\n        uint256 balanceOf = token.balanceOf(address(this));\n        if (balanceOf \u003e 0) {\n            token.transfer(msg.sender, balanceOf);\n        }\n    }\n\n    function _swap(\n        address tokenIn,\n        address tokenOut,\n        uint256 amountIn,\n        address receiver\n    ) private returns (uint256) {\n        _checkAllowance(tokenIn, amountIn, UNISWAP_V2_ROUTER);\n\n        IUniswapV2Router uniswapV2Router = IUniswapV2Router(UNISWAP_V2_ROUTER);\n\n        address[] memory path = new address[](2);\n        path[0] = tokenIn;\n        path[1] = tokenOut;\n        return\n            uniswapV2Router.swapExactTokensForTokens(\n                amountIn,\n                uniswapV2Router.getAmountsOut(amountIn, path)[1],\n                path,\n                receiver,\n                block.timestamp + 1000\n            )[1];\n    }\n\n    function _isValidPairToken(address stableCoinAddress, address tokenAddress)\n        private\n        view\n        returns (bool)\n    {\n        address[] memory allowedPairs = IStableCoin(stableCoinAddress)\n            .allowedPairs();\n        for (uint256 i = 0; i \u003c allowedPairs.length; i++) {\n            IUniswapV2Pair pair = IUniswapV2Pair(allowedPairs[i]);\n            if (pair.token0() == tokenAddress) {\n                return true;\n            }\n            if (pair.token1() == tokenAddress) {\n                return true;\n            }\n        }\n        return false;\n    }\n}\n"}}