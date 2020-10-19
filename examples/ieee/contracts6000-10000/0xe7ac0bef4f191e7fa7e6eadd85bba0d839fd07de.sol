{"IERC20.sol":{"content":"pragma solidity ^0.5.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\n * the optional functions; to access them see `ERC20Detailed`.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a `Transfer` event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through `transferFrom`. This is\n     * zero by default.\n     *\n     * This value changes when `approve` or `transferFrom` are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * \u003e Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an `Approval` event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a `Transfer` event.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to `approve`. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"},"SimpleMultiSig.sol":{"content":"pragma solidity ^0.5.8;\n\nimport \"./IERC20.sol\";\n\ncontract SimpleMultiSig {\n    // EIP712 Precomputed hashes:\n    // keccak256(\"EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)\")\n    bytes32 constant EIP712DOMAINTYPE_HASH = 0xd87cd6ef79d4e2b95e15ce8abf732db51ec771f1ca2edccf22a46c729ac56472;\n\n    // keccak256(\"Simple MultiSig\")\n    bytes32 constant NAME_HASH = 0xb7a0bfa1b79f2443f4d73ebb9259cddbcd510b18be6fc4da7d1aa7b1786e73e6;\n\n    // keccak256(\"1\")\n    bytes32 constant VERSION_HASH = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;\n\n    // keccak256(\"MultiSigTransaction(address destination,uint256 value,bytes data,uint256 nonce,address executor,uint256 gasLimit)\")\n    bytes32 constant TXTYPE_HASH = 0x3ee892349ae4bbe61dce18f95115b5dc02daf49204cc602458cd4c1f540d56d7;\n\n    bytes32 constant SALT = 0x251543af6a222378665a76fe38dbceae4871a070b7fdaf5c6c30cf758dc33cc0;\n\n    uint256 constant THRESHOLD = 2;\n\n    uint256 public chainId;\n    address public master;\n\n    struct Wallet {\n        uint256 nonce; // mutable state\n        address owner;\n        uint256 value; // mutable state\n        bytes32 DOMAIN_SEPARATOR;\n        address erc20Addr;\n    }\n\n    mapping(bytes32 =\u003e Wallet) public wallets;\n\n    constructor(uint256 chainId_) public {\n        chainId = chainId_;\n        master = msg.sender;\n    }\n\n    function setMaster(address master_) external {\n        require(msg.sender == master, \"Only master can set master address\");\n        master = master_;\n    }\n\n    // Note that owners_ must be strictly increasing, in order to prevent duplicates\n    function createWallet(bytes32 id, address owner) internal {\n        Wallet storage wallet = wallets[id];\n        require(wallet.owner == address(0), \"Wallet already exists\");\n        wallet.owner = owner;\n\n        wallet.DOMAIN_SEPARATOR = keccak256(\n            abi.encode(\n                EIP712DOMAINTYPE_HASH,\n                NAME_HASH,\n                VERSION_HASH,\n                chainId,\n                this,\n                id\n            )\n        );\n    }\n\n    function getWallet(bytes32 id)\n        external\n        view\n        returns (uint256, address, uint256, bytes32, address)\n    {\n        Wallet storage wallet = wallets[id];\n        return (\n            wallet.nonce,\n            wallet.owner,\n            wallet.value,\n            wallet.DOMAIN_SEPARATOR,\n            wallet.erc20Addr\n        );\n    }\n\n    function createEthWallet(bytes32 id, address owner) external payable {\n        createWallet(id, owner);\n        wallets[id].value += msg.value;\n    }\n\n    function createErc20Wallet(\n        bytes32 id,\n        address owner,\n        address erc20Addr,\n        uint256 value\n    ) external {\n        createWallet(id, owner);\n        require(\n            IERC20(erc20Addr).transferFrom(msg.sender, address(this), value),\n            \"Transfer ERC20 token failed\"\n        );\n        wallets[id].value += value;\n        wallets[id].erc20Addr = erc20Addr;\n    }\n\n    function getTotalInputHash(\n        address recipient,\n        uint256 value,\n        uint256 nonce,\n        bytes32 DOMAIN_SEPARATOR,\n        bool isErc20\n    ) internal view returns (bytes32) {\n\n        bytes memory data;\n\n        if (isErc20) {\n            // get calldata\n            data = abi.encodeWithSignature(\n                \"transfer(address,uint256)\",\n                recipient,\n                value\n            );\n        }\n\n        // EIP712 scheme: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md\n        bytes32 txInputHash = keccak256(\n            abi.encode(\n                TXTYPE_HASH,\n                recipient,\n                value,\n                keccak256(data),\n                nonce,\n                master\n            )\n        );\n\n        bytes32 totalHash = keccak256(\n            abi.encodePacked(\"\\x19\\x01\", DOMAIN_SEPARATOR, txInputHash)\n        );\n\n        return totalHash;\n    }\n\n    // return signature to be signed\n    function getSig(bytes32 id, address recipient)\n        public\n        view\n        returns (bytes32)\n    {\n        Wallet storage wallet = wallets[id];\n\n        return\n            getTotalInputHash(\n                recipient,\n                wallet.value,\n                wallet.nonce,\n                wallet.DOMAIN_SEPARATOR,\n                wallet.erc20Addr != address(0x0)\n            );\n    }\n\n    function verifySigs(\n        bytes32 id,\n        uint8[] memory sigV,\n        bytes32[] memory sigR,\n        bytes32[] memory sigS,\n        address recipient\n    ) internal view {\n        require(sigR.length == THRESHOLD, \"Incorrect sig length\");\n        require(\n            sigR.length == sigS.length \u0026\u0026 sigR.length == sigV.length,\n            \"Sig length does not match\"\n        );\n\n        Wallet storage wallet = wallets[id];\n\n        // compute total input hash\n        bytes32 totalHash = getTotalInputHash(\n            recipient,\n            wallet.value,\n            wallet.nonce,\n            wallet.DOMAIN_SEPARATOR,\n            wallet.erc20Addr != address(0x0)\n        );\n\n        // master signed\n        require(\n            ecrecover(totalHash, sigV[0], sigR[0], sigS[0]) == master,\n            \"Invalid master sig\"\n        );\n\n        // owner signed\n        require(\n            ecrecover(totalHash, sigV[1], sigR[1], sigS[1]) == wallet.owner,\n            \"Invalid owner sig\"\n        );\n    }\n\n    function transfer(\n        bytes32 id,\n        uint8[] memory sigV,\n        bytes32[] memory sigR,\n        bytes32[] memory sigS,\n        address payable recipient\n    ) public {\n        // only master can execute\n        require(master == msg.sender, \"Incorrect executor\");\n\n        // verify signatures\n        verifySigs(id, sigV, sigR, sigS, recipient);\n\n        Wallet storage wallet = wallets[id];\n\n        wallet.nonce += 1;\n\n        if (wallet.erc20Addr != address(0x0)) {\n            // send erc20 tokens\n            require(\n                IERC20(wallet.erc20Addr).transfer(recipient, wallet.value),\n                \"Transfer ERC20 token failed\"\n            );\n        } else {\n            // send eth\n            recipient.transfer(wallet.value);\n        }\n\n        // safe to set wallet.value after transfer\n        // re-entry attack prevented by nonce\n        wallet.value = 0;\n    }\n\n    // disable payment\n    function() external {}\n}\n"}}