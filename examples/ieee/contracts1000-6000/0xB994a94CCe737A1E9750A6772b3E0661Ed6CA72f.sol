{"IErc20Token.sol":{"content":"pragma solidity ^0.5.0;\n\ninterface IErc20Token {\n    function transfer(address recipient, uint256 amount) external returns (bool);\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n}\n"},"NamedContract.sol":{"content":"pragma solidity ^0.5.0;\n\n/// @title Named Contract\n/// @author growlot (@growlot)\ncontract NamedContract {\n    /// @notice The name of contract, which can be set once\n    string public name;\n\n    /// @notice Sets contract name.\n    function setContractName(string memory newName) internal {\n        name = newName;\n    }\n}\n"},"SafeMath.sol":{"content":"pragma solidity ^0.5.0;\n\n/**\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it\u0027s recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, \"SafeMath: addition overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003c= a, \"SafeMath: subtraction overflow\");\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b \u003e 0, \"SafeMath: division by zero\");\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b != 0, \"SafeMath: modulo by zero\");\n        return a % b;\n    }\n}\n"},"Staking.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./SafeMath.sol\";\nimport \"./IErc20Token.sol\";\nimport \"../NamedContract.sol\";\nimport \"./StakingStorage.sol\";\nimport \"./StakingEvent.sol\";\n\n/// @title Staking Contract\n/// @author growlot (@growlot)\ncontract Staking is NamedContract, StakingStorage, StakingEvent {\n    using SafeMath for uint256;\n\n    constructor() public {\n        setContractName(\u0027Swipe Staking\u0027);\n    }\n\n    /********************\n     * STANDARD ACTIONS *\n     ********************/\n\n    /**\n     * @notice Gets the staked amount of the provided address.\n     *\n     * @return The staked amount\n     */\n    function getStakedAmount(address staker) public view returns (uint256) {\n        Checkpoint storage current = _stakedMap[staker][0];\n\n        return current.stakedAmount;\n    }\n\n    /**\n     * @notice Gets the prior staked amount of the provided address, at the provided block number.\n     *\n     * @return The staked amount\n     */\n    function getPriorStakedAmount(address staker, uint256 blockNumber) external view returns (uint256) {\n        if (blockNumber == 0) {\n            return getStakedAmount(staker);\n        }\n\n        Checkpoint storage current = _stakedMap[staker][0];\n\n        for (uint i = current.blockNumberOrCheckpointIndex; i \u003e 0; i--) {\n            Checkpoint storage checkpoint = _stakedMap[staker][i];\n            if (checkpoint.blockNumberOrCheckpointIndex \u003c= blockNumber) {\n                return checkpoint.stakedAmount;\n            }\n        }\n        \n        return 0;\n    }\n\n    /**\n     * @notice Stakes the provided amount of SXP from the message sender into this wallet.\n     *\n     * @param amount The amount to stake\n     */\n    function stake(uint256 amount) external {\n        require(\n            amount \u003e= _minimumStakeAmount,\n            \"Too small amount\"\n        );\n\n        Checkpoint storage current = _stakedMap[msg.sender][0];\n        current.blockNumberOrCheckpointIndex = current.blockNumberOrCheckpointIndex.add(1);\n        current.stakedAmount = current.stakedAmount.add(amount);\n        _stakedMap[msg.sender][current.blockNumberOrCheckpointIndex] = Checkpoint({\n            blockNumberOrCheckpointIndex: block.number,\n            stakedAmount: current.stakedAmount\n        });\n        _totalStaked = _totalStaked.add(amount);\n\n        emit Stake(\n            msg.sender,\n            amount\n        );\n\n        require(\n            IErc20Token(_sxpTokenAddress).transferFrom(\n                msg.sender,\n                address(this),\n                amount\n            ),\n            \"Stake failed\"\n        );\n    }\n\n    /**\n     * @notice Claims reward of the provided nonce.\n     *\n     * @param nonce The claim nonce uniquely identifying the authorization to claim\n     */\n    function claim(uint256 nonce) external {\n        uint256 amount = _approvedClaimMap[msg.sender][nonce];\n\n        require(\n            amount \u003e 0,\n            \"Invalid nonce\"\n        );\n\n        require(\n            _rewardPoolAmount \u003e= amount,\n            \"Insufficient reward pool\"\n        );\n\n        delete _approvedClaimMap[msg.sender][nonce];\n        _rewardPoolAmount = _rewardPoolAmount.sub(amount);\n\n        emit Claim(\n            msg.sender,\n            amount,\n            nonce\n        );\n\n        require(\n            IErc20Token(_sxpTokenAddress).transfer(\n                msg.sender,\n                amount\n            ),\n            \"Claim failed\"\n        );\n    }\n\n    /**\n     * @notice Withdraws the provided amount of staked\n     *\n     * @param amount The amount to withdraw\n    */\n    function withdraw(uint256 amount) external {\n        require(\n            getStakedAmount(msg.sender) \u003e= amount,\n            \"Exceeded amount\"\n        );\n\n        Checkpoint storage current = _stakedMap[msg.sender][0];\n        current.blockNumberOrCheckpointIndex = current.blockNumberOrCheckpointIndex.add(1);\n        current.stakedAmount = current.stakedAmount.sub(amount);\n        _stakedMap[msg.sender][current.blockNumberOrCheckpointIndex] = Checkpoint({\n            blockNumberOrCheckpointIndex: block.number,\n            stakedAmount: current.stakedAmount\n        });\n        _totalStaked = _totalStaked.sub(amount);\n\n        emit Withdraw(\n            msg.sender,\n            amount\n        );\n\n        require(\n            IErc20Token(_sxpTokenAddress).transfer(\n                msg.sender,\n                amount\n            ),\n            \"Withdraw failed\"\n        );\n    }\n\n    /*****************\n     * ADMIN ACTIONS *\n     *****************/\n\n    /**\n     * @notice Initializes contract.\n     *\n     * @param guardian Guardian address\n     * @param sxpTokenAddress SXP token address\n     * @param rewardProvider The reward provider address\n     */\n    function initialize(\n        address guardian,\n        address sxpTokenAddress,\n        address rewardProvider\n    ) external {\n        require(\n            !_initialized,\n            \"Contract has been already initialized\"\n        );\n\n        _guardian = guardian;\n        _sxpTokenAddress = sxpTokenAddress;\n        _rewardProvider = rewardProvider;\n        _minimumStakeAmount = 1000 * (10**18);\n        _rewardCycle = 1 days;\n        _rewardAmount = 40000 * (10**18);\n        _rewardCycleTimestamp = block.timestamp;\n        _initialized = true;\n\n        emit Initialize(\n            _guardian,\n            _sxpTokenAddress,\n            _rewardProvider,\n            _minimumStakeAmount,\n            _rewardCycle,\n            _rewardAmount,\n            _rewardCycleTimestamp\n        );\n    }\n\n    /**\n     * @notice Authorizes the transfer of guardianship from guardian to the provided address.\n     * NOTE: No transfer will occur unless authorizedAddress calls assumeGuardianship( ).\n     * This authorization may be removed by another call to this function authorizing\n     * the null address.\n     *\n     * @param authorizedAddress The address authorized to become the new guardian.\n     */\n    function authorizeGuardianshipTransfer(address authorizedAddress) external {\n        require(\n            msg.sender == _guardian,\n            \"Only the guardian can authorize a new address to become guardian\"\n        );\n\n        _authorizedNewGuardian = authorizedAddress;\n\n        emit GuardianshipTransferAuthorization(_authorizedNewGuardian);\n    }\n\n    /**\n     * @notice Transfers guardianship of this contract to the _authorizedNewGuardian.\n     */\n    function assumeGuardianship() external {\n        require(\n            msg.sender == _authorizedNewGuardian,\n            \"Only the authorized new guardian can accept guardianship\"\n        );\n        address oldValue = _guardian;\n        _guardian = _authorizedNewGuardian;\n        _authorizedNewGuardian = address(0);\n\n        emit GuardianUpdate(oldValue, _guardian);\n    }\n\n    /**\n     * @notice Updates the minimum stake amount.\n     *\n     * @param newMinimumStakeAmount The amount to be allowed as minimum to users\n     */\n    function setMinimumStakeAmount(uint256 newMinimumStakeAmount) external {\n        require(\n            msg.sender == _guardian || msg.sender == _rewardProvider,\n            \"Only the guardian or reward provider can set the minimum stake amount\"\n        );\n\n        require(\n            newMinimumStakeAmount \u003e 0,\n            \"Invalid amount\"\n        );\n\n        uint256 oldValue = _minimumStakeAmount;\n        _minimumStakeAmount = newMinimumStakeAmount;\n\n        emit MinimumStakeAmountUpdate(oldValue, _minimumStakeAmount);\n    }\n\n    /**\n     * @notice Updates the Reward Provider address, the only address that can provide reward.\n     *\n     * @param newRewardProvider The address of the new Reward Provider\n     */\n    function setRewardProvider(address newRewardProvider) external {\n        require(\n            msg.sender == _guardian,\n            \"Only the guardian can set the reward provider address\"\n        );\n\n        address oldValue = _rewardProvider;\n        _rewardProvider = newRewardProvider;\n\n        emit RewardProviderUpdate(oldValue, _rewardProvider);\n    }\n\n    /**\n     * @notice Updates the reward policy, the only address that can provide reward.\n     *\n     * @param newRewardCycle New reward cycle\n     * @param newRewardAmount New reward amount a cycle\n     */\n    function setRewardPolicy(uint256 newRewardCycle, uint256 newRewardAmount) external {\n        require(\n            msg.sender == _rewardProvider,\n            \"Only the reward provider can set the reward policy\"\n        );\n\n        _prevRewardCycle = _rewardCycle;\n        _prevRewardAmount = _rewardAmount;\n        _prevRewardCycleTimestamp = _rewardCycleTimestamp;\n        _rewardCycle = newRewardCycle;\n        _rewardAmount = newRewardAmount;\n        _rewardCycleTimestamp = block.timestamp;\n\n        emit RewardPolicyUpdate(\n            _prevRewardCycle,\n            _prevRewardAmount,\n            _rewardCycle,\n            _rewardAmount,\n            _rewardCycleTimestamp\n        );\n    }\n\n    /**\n     * @notice Deposits the provided amount into reward pool.\n     *\n     * @param amount The amount to deposit into reward pool\n     */\n    function depositRewardPool(uint256 amount) external {\n        require(\n            msg.sender == _rewardProvider,\n            \"Only the reword provider can deposit\"\n        );\n\n        _rewardPoolAmount = _rewardPoolAmount.add(amount);\n\n        emit DepositRewardPool(\n            msg.sender,\n            amount\n        );\n\n        require(\n            IErc20Token(_sxpTokenAddress).transferFrom(\n                msg.sender,\n                address(this),\n                amount\n            ),\n            \"Deposit reward pool failed\"\n        );\n    }\n\n    /**\n     * @notice Withdraws the provided amount from reward pool.\n     *\n     * @param amount The amount to withdraw from reward pool\n     */\n    function withdrawRewardPool(uint256 amount) external {\n        require(\n            msg.sender == _rewardProvider,\n            \"Only the reword provider can withdraw\"\n        );\n\n        require(\n            _rewardPoolAmount \u003e= amount,\n            \"Exceeded amount\"\n        );\n\n        _rewardPoolAmount = _rewardPoolAmount.sub(amount);\n\n        emit WithdrawRewardPool(\n            msg.sender,\n            amount\n        );\n\n        require(\n            IErc20Token(_sxpTokenAddress).transfer(\n                msg.sender,\n                amount\n            ),\n            \"Withdraw failed\"\n        );\n    }\n\n    /**\n     * @notice Approves the provided address to claim the provided amount.\n     *\n     * @param toAddress The address can claim reward\n     * @param amount The amount to claim\n     */\n    function approveClaim(address toAddress, uint256 amount) external returns(uint256) {\n        require(\n            msg.sender == _rewardProvider,\n            \"Only the reword provider can approve\"\n        );\n\n        require(\n            _rewardPoolAmount \u003e= amount,\n            \"Insufficient reward pool\"\n        );\n\n        _claimNonce = _claimNonce.add(1);\n        _approvedClaimMap[toAddress][_claimNonce] = amount;\n\n        emit ApproveClaim(\n            toAddress,\n            amount,\n            _claimNonce\n        );\n\n        return _claimNonce;\n    }\n    \n    /********************\n     * VALUE ACTIONS *\n     ********************/\n\n    /**\n     * @notice Does not accept ETH.\n     */\n    function () external payable {\n        revert();\n    }\n\n    /**\n     * @notice Transfers out any accidentally sent ERC20 tokens.\n     *\n     * @param tokenAddress ERC20 token address, must not SXP\n     * @param amount The amount to transfer out\n     */\n    function transferOtherErc20Token(address tokenAddress, uint256 amount) external returns (bool) {\n        require(\n            msg.sender == _guardian,\n            \"Only the guardian can transfer out\"\n        );\n\n        require(\n            tokenAddress != _sxpTokenAddress,\n            \"Can\u0027t transfer SXP token out\"\n        );\n\n        return IErc20Token(tokenAddress).transfer(\n            _guardian,\n            amount\n        );\n    }\n}\n"},"StakingEvent.sol":{"content":"pragma solidity ^0.5.0;\n\n/// @title Staking Event Contract\n/// @author growlot (@growlot)\ncontract StakingEvent {\n\n    event Initialize(\n        address indexed owner,\n        address indexed sxp,\n        address indexed rewardProvider,\n        uint256 minimumStakeAmount,\n        uint256 rewardCycle,\n        uint256 rewardAmount,\n        uint256 rewardCycleTimestamp\n    );\n\n    event Stake(\n        address indexed staker,\n        uint256 indexed amount\n    );\n\n    event Claim(\n        address indexed toAddress,\n        uint256 indexed amount,\n        uint256 indexed nonce\n    );\n\n    event Withdraw(\n        address indexed toAddress,\n        uint256 indexed amount\n    );\n\n    event GuardianshipTransferAuthorization(\n        address indexed authorizedAddress\n    );\n\n    event GuardianUpdate(\n        address indexed oldValue,\n        address indexed newValue\n    );\n\n    event MinimumStakeAmountUpdate(\n        uint256 indexed oldValue,\n        uint256 indexed newValue\n    );\n\n    event RewardProviderUpdate(\n        address indexed oldValue,\n        address indexed newValue\n    );\n\n    event RewardPolicyUpdate(\n        uint256 oldCycle,\n        uint256 oldAmount,\n        uint256 indexed newCycle,\n        uint256 indexed newAmount,\n        uint256 indexed newTimeStamp\n    );\n\n    event DepositRewardPool(\n        address indexed depositor,\n        uint256 indexed amount\n    );\n\n    event WithdrawRewardPool(\n        address indexed toAddress,\n        uint256 indexed amount\n    );\n\n    event ApproveClaim(\n        address indexed toAddress,\n        uint256 indexed amount,\n        uint256 indexed nonce\n    );\n}\n"},"StakingStorage.sol":{"content":"pragma solidity ^0.5.0;\n\n/// @title Staking Storage Contract\n/// @author growlot (@growlot)\ncontract StakingStorage {\n    struct Checkpoint {\n        uint256 blockNumberOrCheckpointIndex;\n        uint256 stakedAmount;\n    }\n\n    /// @notice Initialized flag - indicates that initialization was made once\n    bool internal _initialized;\n\n    address public _guardian;\n    address public _authorizedNewGuardian;\n\n    address public _sxpTokenAddress;\n\n    uint256 public _minimumStakeAmount;\n    mapping (address =\u003e mapping (uint256 =\u003e Checkpoint)) internal _stakedMap;\n    uint256 public _totalStaked;\n\n    uint256 public _prevRewardCycle;\n    uint256 public _prevRewardAmount;\n    uint256 public _prevRewardCycleTimestamp;\n    uint256 public _rewardCycle;\n    uint256 public _rewardAmount;\n    uint256 public _rewardCycleTimestamp;\n    uint256 public _rewardPoolAmount;\n    address public _rewardProvider;\n\n    uint256 public _claimNonce;\n    mapping (address =\u003e mapping (uint256 =\u003e uint256)) public _approvedClaimMap;\n}\n"}}