{"lynctoken.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\n    /**\r\n     * LYNC Network\r\n     * https://lync.network\r\n     *\r\n     * Additional details for contract and wallet information:\r\n     * https://lync.network/tracking/\r\n     *\r\n     * The cryptocurrency network designed for passive token rewards for its community.\r\n     */\r\n\r\npragma solidity ^0.7.0;\r\n\r\nimport \"./safemath.sol\";\r\n\r\ncontract LYNCToken {\r\n\r\n    //Enable SafeMath\r\n    using SafeMath for uint256;\r\n\r\n    //Token details\r\n    string constant public name = \"LYNC Network\";\r\n    string constant public symbol = \"LYNC\";\r\n    uint8 constant public decimals = 18;\r\n\r\n    //Reward pool and owner address\r\n    address public owner;\r\n    address public rewardPoolAddress;\r\n\r\n    //Supply and tranasction fee\r\n    uint256 public maxTokenSupply = 1e24;   // 1,000,000 tokens\r\n    uint256 public feePercent = 1;          // initial transaction fee percentage\r\n    uint256 public feePercentMax = 10;      // maximum transaction fee percentage\r\n\r\n    //Events\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _tokens);\r\n    event Approval(address indexed _owner,address indexed _spender, uint256 _tokens);\r\n    event TranserFee(uint256 _tokens);\r\n    event UpdateFee(uint256 _fee);\r\n    event RewardPoolUpdated(address indexed _rewardPoolAddress, address indexed _newRewardPoolAddress);\r\n    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);\r\n    event OwnershipRenounced(address indexed _previousOwner, address indexed _newOwner);\r\n\r\n    //Mappings\r\n    mapping(address =\u003e uint256) public balanceOf;\r\n    mapping(address =\u003e mapping(address =\u003e uint256)) private allowances;\r\n\r\n    //On deployment\r\n    constructor () {\r\n        owner = msg.sender;\r\n        rewardPoolAddress = address(this);\r\n        balanceOf[msg.sender] = maxTokenSupply;\r\n        emit Transfer(address(0), msg.sender, maxTokenSupply);\r\n    }\r\n\r\n    //ERC20 totalSupply\r\n    function totalSupply() public view returns (uint256) {\r\n        return maxTokenSupply;\r\n    }\r\n\r\n    //ERC20 transfer\r\n    function transfer(address _to, uint256 _tokens) public returns (bool) {\r\n        transferWithFee(msg.sender, _to, _tokens);\r\n        return true;\r\n    }\r\n\r\n    //ERC20 transferFrom\r\n    function transferFrom(address _from, address _to, uint256 _tokens) public returns (bool) {\r\n        require(_tokens \u003c= balanceOf[_from], \"Not enough tokens in the approved address balance\");\r\n        require(_tokens \u003c= allowances[_from][msg.sender], \"token amount is larger than the current allowance\");\r\n        transferWithFee(_from, _to, _tokens);\r\n        allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_tokens);\r\n        return true;\r\n    }\r\n\r\n    //ERC20 approve\r\n    function approve(address _spender, uint256 _tokens) public returns (bool) {\r\n        allowances[msg.sender][_spender] = _tokens;\r\n        emit Approval(msg.sender, _spender, _tokens);\r\n        return true;\r\n    }\r\n\r\n    //ERC20 allowance\r\n    function allowance(address _owner, address _spender) public view returns (uint256) {\r\n        return allowances[_owner][_spender];\r\n    }\r\n\r\n    //Transfer with transaction fee applied\r\n    function transferWithFee(address _from, address _to, uint256 _tokens) internal returns (bool) {\r\n        require(balanceOf[_from] \u003e= _tokens, \"Not enough tokens in the senders balance\");\r\n        uint256 _feeAmount = (_tokens.mul(feePercent)).div(100);\r\n        balanceOf[_from] = balanceOf[_from].sub(_tokens);\r\n        balanceOf[_to] = balanceOf[_to].add(_tokens.sub(_feeAmount));\r\n        balanceOf[rewardPoolAddress] = balanceOf[rewardPoolAddress].add(_feeAmount);\r\n        emit Transfer(_from, _to, _tokens.sub(_feeAmount));\r\n        emit Transfer(_from, rewardPoolAddress, _feeAmount);\r\n        emit TranserFee(_tokens);\r\n        return true;\r\n    }\r\n\r\n    //Update transaction fee percentage\r\n    function updateFee(uint256 _updateFee) public onlyOwner {\r\n        require(_updateFee \u003c= feePercentMax, \"Transaction fee cannot be greater than 10%\");\r\n        feePercent = _updateFee;\r\n        emit UpdateFee(_updateFee);\r\n    }\r\n\r\n    //Update the reward pool address\r\n    function updateRewardPool(address _newRewardPoolAddress) public onlyOwner {\r\n        require(_newRewardPoolAddress != address(0), \"New reward pool address cannot be a zero address\");\r\n        rewardPoolAddress = _newRewardPoolAddress;\r\n        emit RewardPoolUpdated(rewardPoolAddress, _newRewardPoolAddress);\r\n    }\r\n\r\n    //Transfer current token balance to the reward pool address\r\n    function rewardPoolBalanceTransfer() public onlyOwner returns (bool) {\r\n        uint256 _currentBalance = balanceOf[address(this)];\r\n        transferWithFee(address(this), rewardPoolAddress, _currentBalance);\r\n        return true;\r\n    }\r\n\r\n    //Transfer ownership to new owner\r\n    function transferOwnership(address _newOwner) public onlyOwner {\r\n        require(_newOwner != address(0), \"New owner cannot be a zero address\");\r\n        emit OwnershipTransferred(owner, _newOwner);\r\n        owner = _newOwner;\r\n    }\r\n\r\n    //Remove owner from the contract\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipRenounced(owner, address(0));\r\n        owner = address(0);\r\n    }\r\n\r\n    //Modifiers\r\n    modifier onlyOwner() {\r\n        require(owner == msg.sender, \"Only current owner can call this function\");\r\n        _;\r\n    }\r\n}\r\n"},"safemath.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.7.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * `SafeMath` restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `+` operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a + b;\r\n        require(c \u003e= a, \"SafeMath: addition overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \"SafeMath: subtraction overflow\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003c= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `*` operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \"SafeMath: multiplication overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \"SafeMath: division by zero\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003e 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \"SafeMath: modulo by zero\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n"}}