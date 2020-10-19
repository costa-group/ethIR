{{
  "language": "Solidity",
  "sources": {
    "/home/julian/betx/betx-contracts/contracts/impl/trading/TokenTransferProxy.sol": {
      "keccak256": "0xfcc27c60c8b5a06a16265d38e9f39e60c4f91e5ad962497cc1440f18a77f32dc",
      "content": "pragma solidity 0.5.16;\npragma experimental ABIEncoderV2;\n\nimport \"../../interfaces/trading/IFillOrder.sol\";\nimport \"../../interfaces/trading/ITokenTransferProxy.sol\";\nimport \"openzeppelin-solidity/contracts/token/ERC20/IERC20.sol\";\n\n\n/// @title TokenTransferProxy\n/// @author Julian Wilson <julian@nextgenbt.com>\n/// @notice Transfers tokens on behalf of the user.\ncontract TokenTransferProxy is ITokenTransferProxy {\n\n    IFillOrder private fillOrder;\n\n    constructor (IFillOrder _fillOrder) public {\n        fillOrder = _fillOrder;\n    }\n\n    /// @notice Throws if the caller is not a fill order contract derivative\n    modifier onlyFillOrder() {\n        require(\n            msg.sender == address(fillOrder),\n            \"ONLY_FILL_ORDER\"\n        );\n        _;\n    }\n\n    /// @notice Uses `transferFrom` and ERC20 approval to transfer tokens.\n    ///         Only callable by whitelisted addresses.\n    /// @param token The address of the ERC20 token to transfer on the user's behalf.\n    /// @param from The address of the user.\n    /// @param to The destination address.\n    /// @param value The amount to transfer.\n    function transferFrom(\n        address token,\n        address from,\n        address to,\n        uint256 value\n    )\n        public\n        onlyFillOrder\n        returns (bool)\n    {\n        return IERC20(token).transferFrom(from, to, value);\n    }\n}\n"
    },
    "/home/julian/betx/betx-contracts/contracts/interfaces/trading/IFillOrder.sol": {
      "keccak256": "0x913ab0babd2dff79480ceb1870c6daab0ca4915e46e67fd8c8e2f919cb64c970",
      "content": "pragma solidity 0.5.16;\npragma experimental ABIEncoderV2;\n\nimport \"../../libraries/LibOrder.sol\";\n\ncontract IFillOrder {\n    function fillOrders(LibOrder.FillDetails memory, bytes memory) public;\n    function metaFillOrders(\n        LibOrder.FillDetails memory,\n        address,\n        bytes memory,\n        bytes memory)\n        public;\n}\n"
    },
    "/home/julian/betx/betx-contracts/contracts/interfaces/trading/ITokenTransferProxy.sol": {
      "keccak256": "0x2bef472beece894b0b8e3ce198a9f296bd659ee9e0490eeb80015254fdee4c86",
      "content": "pragma solidity 0.5.16;\n\ncontract ITokenTransferProxy {\n    function transferFrom(address, address, address, uint256)\n        public\n        returns (bool);\n}\n"
    },
    "/home/julian/betx/betx-contracts/contracts/libraries/LibOrder.sol": {
      "keccak256": "0xa391c14ee06c57f6c5f81ee05684535fa02e6e1ea7d83b0b03879f4cad128a0a",
      "content": "pragma solidity 0.5.16;\npragma experimental ABIEncoderV2;\n\nimport \"openzeppelin-solidity/contracts/math/SafeMath.sol\";\nimport \"openzeppelin-solidity/contracts/cryptography/ECDSA.sol\";\n\n\n/// @title LibOrder\n/// @author Julian Wilson <julian@nextgenbt.com>\n/// @notice Central definition for what an \"order\" is along with utilities for an order.\nlibrary LibOrder {\n    using SafeMath for uint256;\n\n    uint256 public constant ODDS_PRECISION = 10**20;\n\n    struct Order {\n        bytes32 marketHash;\n        address baseToken;\n        uint256 totalBetSize;\n        uint256 percentageOdds;\n        uint256 expiry;\n        uint256 salt;\n        address maker;\n        address executor;\n        bool isMakerBettingOutcomeOne;\n    }\n\n    struct FillObject {\n        Order[] orders;\n        bytes[] makerSigs;\n        uint256[] takerAmounts;\n        uint256 fillSalt;\n    }\n\n    struct FillDetails {\n        string action;\n        string market;\n        string betting;\n        string stake;\n        string odds;\n        string returning;\n        FillObject fills;\n    }\n\n    /// @notice Checks the parameters of the given order to see if it conforms to the protocol.\n    /// @param order The order to check.\n    /// @return A status string in UPPER_SNAKE_CASE. It will return \"OK\" if everything checks out.\n    // solhint-disable code-complexity\n    function getParamValidity(Order memory order)\n        internal\n        view\n        returns (string memory)\n    {\n        if (order.totalBetSize == 0) {return \"TOTAL_BET_SIZE_ZERO\";}\n        if (order.percentageOdds == 0 || order.percentageOdds >= ODDS_PRECISION) {return \"INVALID_PERCENTAGE_ODDS\";}\n        if (order.expiry < now) {return \"ORDER_EXPIRED\";}\n        if (order.baseToken == address(0)) {return \"BASE_TOKEN\";}\n        return \"OK\";\n    }\n\n    /// @notice Checks the signature of an order to see if\n    ///         it was an order signed by the given maker.\n    /// @param order The order to check.\n    /// @param makerSig The signature to compare.\n    /// @return true if the signature matches, false otherwise.\n    function checkSignature(Order memory order, bytes memory makerSig)\n        internal\n        pure\n        returns (bool)\n    {\n        bytes32 orderHash = getOrderHash(order);\n        return ECDSA.recover(ECDSA.toEthSignedMessageHash(orderHash), makerSig) == order.maker;\n    }\n\n    /// @notice Checks if an order's parameters conforms to the protocol's specifications.\n    /// @param order The order to check.\n    function assertValidParams(Order memory order) internal view {\n        require(\n            order.totalBetSize > 0,\n            \"TOTAL_BET_SIZE_ZERO\"\n        );\n        require(\n            order.percentageOdds > 0 && order.percentageOdds < ODDS_PRECISION,\n            \"INVALID_PERCENTAGE_ODDS\"\n        );\n        require(order.baseToken != address(0), \"INVALID_BASE_TOKEN\");\n        require(order.expiry > now, \"ORDER_EXPIRED\");\n    }\n\n    /// @notice Checks if an order has valid parameters including\n    ///         the signature and checks if the maker is not the taker.\n    /// @param order The order to check.\n    /// @param taker The hypothetical filler of this order, i.e., the taker.\n    /// @param makerSig The signature to check.\n    function assertValidAsTaker(Order memory order, address taker, bytes memory makerSig) internal view {\n        assertValidParams(order);\n        require(\n            checkSignature(order, makerSig),\n            \"SIGNATURE_MISMATCH\"\n        );\n        require(order.maker != taker, \"TAKER_NOT_MAKER\");\n    }\n\n    /// @notice Checks if the order has valid parameters\n    ///         and checks if the sender is the maker.\n    /// @param order The order to check.\n    /// @param sender The address to compare the maker to.\n    function assertValidAsMaker(Order memory order, address sender) internal view {\n        assertValidParams(order);\n        require(order.maker == sender, \"CALLER_NOT_MAKER\");\n    }\n\n    /// @notice Computes the hash of an order. Packs the arguments in order\n    ///         of the Order struct.\n    /// @param order The order to compute the hash of.\n    function getOrderHash(Order memory order) internal pure returns (bytes32) {\n        return keccak256(\n            abi.encodePacked(\n                order.marketHash,\n                order.baseToken,\n                order.totalBetSize,\n                order.percentageOdds,\n                order.expiry,\n                order.salt,\n                order.maker,\n                order.executor,\n                order.isMakerBettingOutcomeOne\n            )\n        );\n    }\n\n    function getOddsPrecision() internal pure returns (uint256) {\n        return ODDS_PRECISION;\n    }\n}"
    },
    "openzeppelin-solidity/contracts/cryptography/ECDSA.sol": {
      "keccak256": "0xb48974d92a87053dc1d6c5389f3d1b2ad522dec23afcb508eaa935d98dfdc0b6",
      "content": "pragma solidity ^0.5.0;\n\n/**\n * @title Elliptic curve signature operations\n * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d\n * TODO Remove this library once solidity supports passing a signature to ecrecover.\n * See https://github.com/ethereum/solidity/issues/864\n */\n\nlibrary ECDSA {\n    /**\n     * @dev Recover signer address from a message by using their signature\n     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.\n     * @param signature bytes signature, the signature is generated using web3.eth.sign()\n     */\n    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {\n        bytes32 r;\n        bytes32 s;\n        uint8 v;\n\n        // Check the signature length\n        if (signature.length != 65) {\n            return (address(0));\n        }\n\n        // Divide the signature in r, s and v variables\n        // ecrecover takes the signature parameters, and the only way to get them\n        // currently is to use assembly.\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            r := mload(add(signature, 0x20))\n            s := mload(add(signature, 0x40))\n            v := byte(0, mload(add(signature, 0x60)))\n        }\n\n        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions\n        if (v < 27) {\n            v += 27;\n        }\n\n        // If the version is correct return the signer address\n        if (v != 27 && v != 28) {\n            return (address(0));\n        } else {\n            return ecrecover(hash, v, r, s);\n        }\n    }\n\n    /**\n     * toEthSignedMessageHash\n     * @dev prefix a bytes32 value with \"\\x19Ethereum Signed Message:\"\n     * and hash the result\n     */\n    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {\n        // 32 is the length in bytes of hash,\n        // enforced by the type signature above\n        return keccak256(abi.encodePacked(\"\\x19Ethereum Signed Message:\\n32\", hash));\n    }\n}\n"
    },
    "openzeppelin-solidity/contracts/math/SafeMath.sol": {
      "keccak256": "0x965012d27b4262d7a41f5028cbb30c51ebd9ecd4be8fb30380aaa7a3c64fbc8b",
      "content": "pragma solidity ^0.5.0;\n\n/**\n * @title SafeMath\n * @dev Unsigned math operations with safety checks that revert on error\n */\nlibrary SafeMath {\n    /**\n    * @dev Multiplies two unsigned integers, reverts on overflow.\n    */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the\n        // benefit is lost if 'b' is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b);\n\n        return c;\n    }\n\n    /**\n    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.\n    */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b > 0);\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn't hold\n\n        return c;\n    }\n\n    /**\n    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\n    */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b <= a);\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n    * @dev Adds two unsigned integers, reverts on overflow.\n    */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c >= a);\n\n        return c;\n    }\n\n    /**\n    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),\n    * reverts when dividing by zero.\n    */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b != 0);\n        return a % b;\n    }\n}\n"
    },
    "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol": {
      "keccak256": "0x079c4e23ee448f529e43bfa3c4e8fb4be52cd0318ee923a276835bedf45b93d8",
      "content": "pragma solidity ^0.5.0;\n\n/**\n * @title ERC20 interface\n * @dev see https://github.com/ethereum/EIPs/issues/20\n */\ninterface IERC20 {\n    function transfer(address to, uint256 value) external returns (bool);\n\n    function approve(address spender, uint256 value) external returns (bool);\n\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\n\n    function totalSupply() external view returns (uint256);\n\n    function balanceOf(address who) external view returns (uint256);\n\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "libraries": {},
    "optimizer": {
      "details": {
        "constantOptimizer": true,
        "cse": true,
        "deduplicate": true,
        "jumpdestRemover": true,
        "orderLiterals": true,
        "peephole": true,
        "yul": true,
        "yulDetails": {
          "stackAllocation": true
        }
      },
      "runs": 200
    },
    "remappings": [],
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    }
  }
}}