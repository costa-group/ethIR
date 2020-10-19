{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.7.0;\r\n\r\n/*\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with GSN meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\nabstract contract Context {\r\n    function _msgSender() internal virtual view returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal virtual view returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\n"},"ERC20-mint-unwrap.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.7.0;\r\n\r\nimport \"./Context.sol\";\r\nimport \"./IERC20.sol\";\r\nimport \"./SafeMath.sol\";\r\n\r\n/**\r\n * @dev Here is how to audit this contract.\r\n *\r\n * Step 1: get the totalSupply of wrapped tokens\r\n * 1. Navigate to etherscan.io\r\n * 2. Search for this contract address\r\n * 3. Click on the tab labelled `Contract`\r\n * 4. Click on the button labelled `Read Contract`\r\n * 5. Click on `totalSupply`\r\n *\r\n * Step 2: get the amount of underlying tokens owned by this contract\r\n * 1. Navigate to etherscan.io\r\n * 2. Search for the underlying token address\r\n * 3. Click on the tab labelled `Contract`\r\n * 4. Click on the button labelled `Read Contract`\r\n * 5. Click on `balanceOf`\r\n * 6. Enter this contract address, then click on `Query`.\r\n *\r\n * if step 1 equals step 2, then...\r\n *   the amount of underlying tokens owned by this contract\r\n * equals\r\n *   the amount of wrapped tokens that got minted, and life is good.\r\n */\r\ncontract ERC20 is Context, IERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    address private _owner;\r\n    uint256 private _totalSupply;\r\n    address private _underlying;\r\n\r\n    bytes32[] private _transactions;\r\n    mapping (address =\u003e uint256) private _balances;\r\n    mapping (address =\u003e mapping (address =\u003e uint256)) private _allowances;\r\n\r\n    string private _name;\r\n    string private _symbol;\r\n    uint8 private _decimals;\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(msg.sender == _owner);\r\n        _;\r\n    }    \r\n\r\n    /**\r\n     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with\r\n     * a default value of 18.\r\n     *\r\n     * `underlying` is the other ERC20 token address that is bridged/wrapped by\r\n     * this contract.\r\n     *\r\n     * All of these values are immutable: they can only be set once during\r\n     * construction.\r\n     */\r\n    constructor (string memory name, string memory symbol, address underlying) {\r\n        _owner = _msgSender();\r\n        _name = name;\r\n        _symbol = symbol;\r\n        _decimals = 18;\r\n        _underlying = underlying;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the name of the token.\r\n     */\r\n    function name() public view returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the symbol of the token, usually a shorter version of the\r\n     * name.\r\n     */\r\n    function symbol() public view returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the number of decimals used to get its user representation.\r\n     * For example, if `decimals` equals `2`, a balance of `505` tokens should\r\n     * be displayed to a user as `5,05` (`505 / 10 ** 2`).\r\n     *\r\n     * Tokens usually opt for a value of 18, imitating the relationship between\r\n     * Ether and Wei.\r\n     */\r\n    function decimals() public view returns (uint8) {\r\n        return _decimals;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the underlying ERC20 token address that is bridged/wrapped\r\n     * by this contract.\r\n     */\r\n    function underlying() public view returns (address) {\r\n        return _underlying;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the specified transaction got minted, otherwise\r\n     * false.\r\n     */\r\n    function minted(bytes32 transaction) public view returns (bool) {\r\n        return _minted(transaction);\r\n    }    \r\n\r\n    /**\r\n     * @dev See {IERC20-totalSupply}.\r\n     */\r\n    function totalSupply() public view override returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-balanceOf}.\r\n     */\r\n    function balanceOf(address account) public view override returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transfer}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `recipient` cannot be the zero address.\r\n     * - the caller must have a balance of at least `amount`.\r\n     */\r\n    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\r\n        _transfer(_msgSender(), recipient, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Creates `amount` tokens and assigns them to `recipient`, increasing\r\n     * the total supply.\r\n     *\r\n     * Emits a {Transfer} event with `from` set to the zero address.\r\n     * \r\n     * Requirements:\r\n     *\r\n     * - cannot get called by anyone but the owner address.\r\n     * - `transaction` cannot be zero.\r\n     * - `recipient` cannot be the zero address.\r\n     * - `transaction` cannot exist (if it does, the contract does not mistakenly mint again)\r\n     */    \r\n    function mint(bytes32 transaction, address recipient, uint256 amount) public virtual onlyOwner returns (bool) {\r\n        require(transaction != bytes32(0), \"ERC20: transaction is zero\");\r\n        require(recipient != address(0), \"ERC20: mint to the zero address\");\r\n        require(_minted(transaction) == false, \"ERC20: transaction has been minted\");\r\n\r\n        _mint(recipient, amount);\r\n\r\n        _transactions.push(transaction);\r\n        \r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers `amount` of the underlying ERC20 token from this\r\n     * contract address to `msg.sender`, then destroys `amount` wrapped\r\n     * tokens from `msg.sender`, reducing the total supply.\r\n     *\r\n     * Emits a {Transfer} event with `to` set to the zero address.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `msg.sender` must have at least `amount` tokens.\r\n     */\r\n    function unwrap(uint256 amount) public virtual returns (bool) {      \r\n        require(_balances[_msgSender()] \u003e= amount, \"ERC20: unwrap amount exceeds balance\");\r\n\r\n        require(ERC20(_underlying).transfer(_msgSender(), amount), \"ERC20: underlying.transfer() returned false\");\r\n\r\n        _burn(_msgSender(), amount);\r\n        \r\n        return true;\r\n    }    \r\n\r\n    /**\r\n     * @dev See {IERC20-allowance}.\r\n     */\r\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-approve}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\r\n        _approve(_msgSender(), spender, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transferFrom}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance. This is not\r\n     * required by the EIP. See the note at the beginning of {ERC20}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `source` and `recipient` cannot be the zero address.\r\n     * - `source` must have a balance of at least `amount`.\r\n     * - the caller must have allowance for `source`\u0027s tokens of at least\r\n     *   `amount`.\r\n     */\r\n    function transferFrom(address source, address recipient, uint256 amount) public virtual override returns (bool) {\r\n        require(source != address(0), \"ERC20: transfer from the zero address\");\r\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\r\n\r\n        require(_balances[source] \u003e= amount, \"ERC20: transfer amount exceeds balance\");\r\n\r\n        if (source != _msgSender() \u0026\u0026 _allowances[source][_msgSender()] != uint(-1)) {           \r\n            require(_allowances[source][_msgSender()] \u003e= amount, \"ERC20: transfer amount exceeds allowance\");\r\n            _approve(source, _msgSender(), _allowances[source][_msgSender()].sub(amount));\r\n        }\r\n\r\n        _transfer(source, recipient, amount);\r\n        \r\n        return true;\r\n    }    \r\n\r\n    /**\r\n     * @dev Moves tokens `amount` from `sender` to `recipient`.\r\n     *\r\n     * This is internal function is equivalent to {transfer}, and can be used to\r\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `sender` cannot be the zero address.\r\n     * - `recipient` cannot be the zero address.\r\n     * - `sender` must have a balance of at least `amount`.\r\n     */\r\n    function _transfer(address sender, address recipient, uint256 amount) internal virtual {\r\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\r\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\r\n\r\n        _balances[sender] = _balances[sender].sub(amount, \"ERC20: transfer amount exceeds balance\");\r\n        _balances[recipient] = _balances[recipient].add(amount);\r\n\r\n        emit Transfer(sender, recipient, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Creates `amount` tokens and assigns them to `account`, increasing\r\n     * the total supply.\r\n     *\r\n     * Emits a {Transfer} event with `from` set to the zero address.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `to` cannot be the zero address.\r\n     */\r\n    function _mint(address account, uint256 amount) internal virtual {\r\n        require(account != address(0), \"ERC20: mint to the zero address\");\r\n\r\n        _totalSupply = _totalSupply.add(amount);\r\n        _balances[account] = _balances[account].add(amount);\r\n\r\n        emit Transfer(address(0), account, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the specified transaction got minted, otherwise\r\n     * false.\r\n     */\r\n    function _minted(bytes32 transaction) internal view returns (bool) {\r\n        for (uint i; i \u003c _transactions.length; i++) {\r\n            if (_transactions[i] == transaction) {\r\n                return true;\r\n            }\r\n        }\r\n        return false;\r\n    }       \r\n\r\n    /**\r\n     * @dev Destroys `amount` tokens from `account`, reducing the\r\n     * total supply.\r\n     *\r\n     * Emits a {Transfer} event with `to` set to the zero address.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `account` cannot be the zero address.\r\n     * - `account` must have at least `amount` tokens.\r\n     */\r\n    function _burn(address account, uint256 amount) internal virtual {\r\n        require(account != address(0), \"ERC20: burn from the zero address\");\r\n\r\n        _balances[account] = _balances[account].sub(amount, \"ERC20: burn amount exceeds balance\");\r\n        _totalSupply = _totalSupply.sub(amount);\r\n\r\n        emit Transfer(account, address(0), amount);\r\n    }    \r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the `owner`\u0027s tokens.\r\n     *\r\n     * This internal function is equivalent to `approve`, and can be used to\r\n     * e.g. set automatic allowances for certain subsystems, etc.\r\n     *\r\n     * Emits an {Approval} event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `owner` cannot be the zero address.\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function _approve(address owner, address spender, uint256 amount) internal virtual {\r\n        require(owner != address(0), \"ERC20: approve from the zero address\");\r\n        require(spender != address(0), \"ERC20: approve to the zero address\");\r\n\r\n        _allowances[owner][spender] = amount;\r\n\r\n        emit Approval(owner, spender, amount);\r\n    }                                    \r\n}"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.7.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by `account`.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount)\r\n        external\r\n        returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that `spender` will be\r\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender)\r\n        external\r\n        view\r\n        returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\r\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(\r\n        address sender,\r\n        address recipient,\r\n        uint256 amount\r\n    ) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n     * another (`to`).\r\n     *\r\n     * Note that `value` may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n     * a call to {approve}. `value` is the new allowance.\r\n     */\r\n    event Approval(\r\n        address indexed owner,\r\n        address indexed spender,\r\n        uint256 value\r\n    );\r\n}\r\n"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.7.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * `SafeMath` restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `+` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a + b;\r\n        require(c \u003e= a, \"SafeMath: addition overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \"SafeMath: subtraction overflow\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    ) internal pure returns (uint256) {\r\n        require(b \u003c= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `*` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \"SafeMath: multiplication overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \"SafeMath: division by zero\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    ) internal pure returns (uint256) {\r\n        require(b \u003e 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \"SafeMath: modulo by zero\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    ) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n"}}