{"Address.sol":{"content":"pragma solidity ^0.5.5;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following \n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts\n        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned\n        // for accounts without code, i.e. `keccak256(\u0027\u0027)`\n        bytes32 codehash;\n        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;\n        // solhint-disable-next-line no-inline-assembly\n        assembly { codehash := extcodehash(account) }\n        return (codehash != accountHash \u0026\u0026 codehash != 0x0);\n    }\n\n    /**\n     * @dev Converts an `address` into `address payable`. Note that this is\n     * simply a type cast: the actual underlying value is not changed.\n     *\n     * _Available since v2.4.0._\n     */\n    function toPayable(address account) internal pure returns (address payable) {\n        return address(uint160(account));\n    }\n\n    /**\n     * @dev Replacement for Solidity\u0027s `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     *\n     * _Available since v2.4.0._\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance \u003e= amount, \"Address: insufficient balance\");\n\n        // solhint-disable-next-line avoid-call-value\n        (bool success, ) = recipient.call.value(amount)(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n}\n"},"Context.sol":{"content":"pragma solidity ^0.5.0;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with GSN meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\ncontract Context {\n    // Empty internal constructor, to prevent people from mistakenly deploying\n    // an instance of this contract, which should be used via inheritance.\n    constructor () internal { }\n    // solhint-disable-previous-line no-empty-blocks\n\n    function _msgSender() internal view returns (address payable) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view returns (bytes memory) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n}\n"},"IERC20.sol":{"content":"pragma solidity ^0.5.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\n * the optional functions; to access them see {ERC20Detailed}.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"},"Ownable.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./Context.sol\";\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\ncontract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor () internal {\n        address msgSender = _msgSender();\n        _owner = msgSender;\n        emit OwnershipTransferred(address(0), msgSender);\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(isOwner(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Returns true if the caller is the current owner.\n     */\n    function isOwner() public view returns (bool) {\n        return _msgSender() == _owner;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public onlyOwner {\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     */\n    function _transferOwnership(address newOwner) internal {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}\n"},"SafeERC20.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./IERC20.sol\";\nimport \"./SafeMath.sol\";\nimport \"./Address.sol\";\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20 {\n    using SafeMath for uint256;\n    using Address for address;\n\n    function safeTransfer(IERC20 token, address to, uint256 value) internal {\n        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n    }\n\n    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {\n        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\n    }\n\n    function safeApprove(IERC20 token, address spender, uint256 value) internal {\n        // safeApprove should only be called when setting an initial allowance,\n        // or when resetting it to zero. To increase and decrease it, use\n        // \u0027safeIncreaseAllowance\u0027 and \u0027safeDecreaseAllowance\u0027\n        // solhint-disable-next-line max-line-length\n        require((value == 0) || (token.allowance(address(this), spender) == 0),\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\n        );\n        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n    }\n\n    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {\n        uint256 newAllowance = token.allowance(address(this), spender).add(value);\n        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n    }\n\n    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {\n        uint256 newAllowance = token.allowance(address(this), spender).sub(value, \"SafeERC20: decreased allowance below zero\");\n        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n    }\n\n    /**\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\n     * @param token The token targeted by the call.\n     * @param data The call data (encoded using abi.encode or one of its variants).\n     */\n    function callOptionalReturn(IERC20 token, bytes memory data) private {\n        // We need to perform a low level call here, to bypass Solidity\u0027s return data size checking mechanism, since\n        // we\u0027re implementing it ourselves.\n\n        // A Solidity high level call has three parts:\n        //  1. The target address is checked to verify it contains contract code\n        //  2. The call itself is made, and success asserted\n        //  3. The return value is decoded, which in turn checks the size of the returned data.\n        // solhint-disable-next-line max-line-length\n        require(address(token).isContract(), \"SafeERC20: call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) = address(token).call(data);\n        require(success, \"SafeERC20: low-level call failed\");\n\n        if (returndata.length \u003e 0) { // Return data is optional\n            // solhint-disable-next-line max-line-length\n            require(abi.decode(returndata, (bool)), \"SafeERC20: ERC20 operation did not succeed\");\n        }\n    }\n}\n"},"SafeMath.sol":{"content":"pragma solidity ^0.5.0;\n\n/**\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it\u0027s recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, \"SafeMath: addition overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        return sub(a, b, \"SafeMath: subtraction overflow\");\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     *\n     * _Available since v2.4.0._\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b \u003c= a, errorMessage);\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return div(a, b, \"SafeMath: division by zero\");\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     *\n     * _Available since v2.4.0._\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b \u003e 0, errorMessage);\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        return mod(a, b, \"SafeMath: modulo by zero\");\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts with custom message when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     *\n     * _Available since v2.4.0._\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b != 0, errorMessage);\n        return a % b;\n    }\n}\n"},"TokenVesting.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./SafeERC20.sol\";\nimport \"./Ownable.sol\";\nimport \"./SafeMath.sol\";\n\n/**\n * @title TokenVesting\n * @dev A token holder contract that can release its token balance gradually like a\n * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the\n * owner.\n */\ncontract TokenVesting is Ownable {\n    // The vesting schedule is time-based (i.e. using block timestamps as opposed to e.g. block numbers), and is\n    // therefore sensitive to timestamp manipulation (which is something miners can do, to a certain degree). Therefore,\n    // it is recommended to avoid using short time durations (less than a minute). Typical vesting schemes, with a\n    // cliff period of a year and a duration of four years, are safe to use.\n    // solhint-disable not-rely-on-time\n\n    using SafeMath for uint256;\n    using SafeERC20 for IERC20;\n\n    event TokensReleased(address token, uint256 amount);\n    event TokenVestingRevoked(address token);\n\n    // beneficiary of tokens after they are released\n    address private _beneficiary;\n\n    // Durations and timestamps are expressed in UNIX time, the same units as block.timestamp.\n    uint256 private _cliff;\n    uint256 private _start;\n    uint256 private _duration;\n\n    bool private _revocable;\n\n    mapping (address =\u003e uint256) private _released;\n    mapping (address =\u003e bool) private _revoked;\n\n    /**\n     * @dev Creates a vesting contract that vests its balance of any ERC20 token to the\n     * beneficiary, gradually in a linear fashion until start + duration. By then all\n     * of the balance will have vested.\n     * @param beneficiary address of the beneficiary to whom vested tokens are transferred\n     * @param cliffDuration duration in seconds of the cliff in which tokens will begin to vest\n     * @param start the time (as Unix time) at which point vesting starts\n     * @param duration duration in seconds of the period in which the tokens will vest\n     * @param revocable whether the vesting is revocable or not\n     */\n    constructor (address beneficiary, uint256 start, uint256 cliffDuration, uint256 duration, bool revocable) public {\n        require(beneficiary != address(0), \"TokenVesting: beneficiary is the zero address\");\n        // solhint-disable-next-line max-line-length\n        require(cliffDuration \u003c= duration, \"TokenVesting: cliff is longer than duration\");\n        require(duration \u003e 0, \"TokenVesting: duration is 0\");\n        // solhint-disable-next-line max-line-length\n        require(start.add(duration) \u003e block.timestamp, \"TokenVesting: final time is before current time\");\n\n        _beneficiary = beneficiary;\n        _revocable = revocable;\n        _duration = duration;\n        _cliff = start.add(cliffDuration);\n        _start = start;\n    }\n\n    /**\n     * @return the beneficiary of the tokens.\n     */\n    function beneficiary() public view returns (address) {\n        return _beneficiary;\n    }\n\n    /**\n     * @return the cliff time of the token vesting.\n     */\n    function cliff() public view returns (uint256) {\n        return _cliff;\n    }\n\n    /**\n     * @return the start time of the token vesting.\n     */\n    function start() public view returns (uint256) {\n        return _start;\n    }\n\n    /**\n     * @return the duration of the token vesting.\n     */\n    function duration() public view returns (uint256) {\n        return _duration;\n    }\n\n    /**\n     * @return true if the vesting is revocable.\n     */\n    function revocable() public view returns (bool) {\n        return _revocable;\n    }\n\n    /**\n     * @return the amount of the token released.\n     */\n    function released(address token) public view returns (uint256) {\n        return _released[token];\n    }\n\n    /**\n     * @return true if the token is revoked.\n     */\n    function revoked(address token) public view returns (bool) {\n        return _revoked[token];\n    }\n\n    /**\n     * @notice Transfers vested tokens to beneficiary.\n     * @param token ERC20 token which is being vested\n     */\n    function release(IERC20 token) public {\n        uint256 unreleased = _releasableAmount(token);\n\n        require(unreleased \u003e 0, \"TokenVesting: no tokens are due\");\n\n        _released[address(token)] = _released[address(token)].add(unreleased);\n\n        token.safeTransfer(_beneficiary, unreleased);\n\n        emit TokensReleased(address(token), unreleased);\n    }\n\n    /**\n     * @notice Allows the owner to revoke the vesting. Tokens already vested\n     * remain in the contract, the rest are returned to the owner.\n     * @param token ERC20 token which is being vested\n     */\n    function revoke(IERC20 token) public onlyOwner {\n        require(_revocable, \"TokenVesting: cannot revoke\");\n        require(!_revoked[address(token)], \"TokenVesting: token already revoked\");\n\n        uint256 balance = token.balanceOf(address(this));\n\n        uint256 unreleased = _releasableAmount(token);\n        uint256 refund = balance.sub(unreleased);\n\n        _revoked[address(token)] = true;\n\n        token.safeTransfer(owner(), refund);\n\n        emit TokenVestingRevoked(address(token));\n    }\n\n    /**\n     * @dev Calculates the amount that has already vested but hasn\u0027t been released yet.\n     * @param token ERC20 token which is being vested\n     */\n    function _releasableAmount(IERC20 token) private view returns (uint256) {\n        return _vestedAmount(token).sub(_released[address(token)]);\n    }\n\n    /**\n     * @dev Calculates the amount that has already vested.\n     * @param token ERC20 token which is being vested\n     */\n    function _vestedAmount(IERC20 token) private view returns (uint256) {\n        uint256 currentBalance = token.balanceOf(address(this));\n        uint256 totalBalance = currentBalance.add(_released[address(token)]);\n\n        if (block.timestamp \u003c _cliff) {\n            return 0;\n        } else if (block.timestamp \u003e= _start.add(_duration) || _revoked[address(token)]) {\n            return totalBalance;\n        } else {\n            return totalBalance.mul(block.timestamp.sub(_start)).div(_duration);\n        }\n    }\n}\n"}}