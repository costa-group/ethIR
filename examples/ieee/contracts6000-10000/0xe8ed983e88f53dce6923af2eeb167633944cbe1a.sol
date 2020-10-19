{"GRT.sol":{"content":"pragma solidity ^0.6.7;\n\nimport \"./SafeMath.sol\";\n\n\ncontract GRT {\n    using SafeMath for uint256;\n\n    string private _name;\n    string private _symbol;\n    uint8 private _decimals;\n    address private _owner;\n    uint256 private _totalSupply;\n\n    mapping(address =\u003e uint256) private _balances;\n\n    mapping(address =\u003e mapping(address =\u003e uint256)) private _allowances;\n\n    constructor(\n        string memory name,\n        string memory symbol,\n        uint8 decimals,\n        uint256 totalSupply\n    ) public {\n        _name = name;\n        _symbol = symbol;\n        _decimals = decimals;\n        _owner = msg.sender;\n        _mint(msg.sender, totalSupply);\n    }\n\n    function name() public view returns (string memory) {\n        return _name;\n    }\n\n    function symbol() public view returns (string memory) {\n        return _symbol;\n    }\n\n    function decimals() public view returns (uint8) {\n        return _decimals;\n    }\n\n    function totalSupply() public view returns (uint256) {\n        return _totalSupply;\n    }\n\n    function balanceOf(address account) public view returns (uint256) {\n        return _balances[account];\n    }\n\n    function transfer(address recipient, uint256 amount) public returns (bool) {\n        _transfer(msg.sender, recipient, amount);\n        return true;\n    }\n\n    function allowance(address owner, address spender)\n        public\n        view\n        returns (uint256)\n    {\n        return _allowances[owner][spender];\n    }\n\n    function approve(address spender, uint256 value) public returns (bool) {\n        _approve(msg.sender, spender, value);\n        return true;\n    }\n\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) public returns (bool) {\n        _transfer(sender, recipient, amount);\n        _approve(\n            sender,\n            msg.sender,\n            _allowances[sender][msg.sender].sub(amount)\n        );\n        return true;\n    }\n\n    function increaseAllowance(address spender, uint256 addedValue)\n        public\n        returns (bool)\n    {\n        _approve(\n            msg.sender,\n            spender,\n            _allowances[msg.sender][spender].add(addedValue)\n        );\n        return true;\n    }\n\n    function decreaseAllowance(address spender, uint256 subtractedValue)\n        public\n        returns (bool)\n    {\n        _approve(\n            msg.sender,\n            spender,\n            _allowances[msg.sender][spender].sub(subtractedValue)\n        );\n        return true;\n    }\n\n    function resetOwner(address newOwner) public returns (bool) {\n        require(msg.sender == _owner, \"ERC20: must be owner\");\n\n        _owner = newOwner;\n\n        return true;\n    }\n\n    function _transfer(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) internal {\n        _balances[sender] = _balances[sender].sub(amount);\n        _balances[recipient] = _balances[recipient].add(amount);\n        emit Transfer(sender, recipient, amount);\n    }\n\n    function _mint(address account, uint256 amount) internal {\n        require(account != address(0), \"ERC20: mint to the zero address\");\n\n        _totalSupply = _totalSupply.add(amount);\n        _balances[account] = _balances[account].add(amount);\n        emit Transfer(address(0), account, amount);\n    }\n\n    function _approve(\n        address owner,\n        address spender,\n        uint256 value\n    ) internal {\n        require(owner != address(0), \"ERC20: approve from the zero address\");\n        require(spender != address(0), \"ERC20: approve to the zero address\");\n\n        _allowances[owner][spender] = value;\n        emit Approval(owner, spender, value);\n    }\n\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    event Approval(\n        address indexed owner,\n        address indexed spender,\n        uint256 value\n    );\n}\n"},"SafeMath.sol":{"content":"pragma solidity ^0.6.7;\n\n\n/**\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it\u0027s recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, \"SafeMath: addition overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003c= a, \"SafeMath: subtraction overflow\");\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b \u003e 0, \"SafeMath: division by zero\");\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b != 0, \"SafeMath: modulo by zero\");\n        return a % b;\n    }\n}\n"}}