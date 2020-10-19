{"BRACE_Token.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./Context.sol\";\nimport \"./ERC20.sol\";\nimport \"./ERC20Detailed.sol\";\nimport \"./ERC20Mintable.sol\";\nimport \"./ERC20Pausable.sol\";\nimport \"./ERC20Burnable.sol\";\n\n/**\n * @title SimpleToken\n * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.\n * Note they can later distribute these tokens as they wish using `transfer` and other\n * `ERC20` functions.\n */\ncontract BraceToken is Context, ERC20, ERC20Detailed, ERC20Mintable, ERC20Pausable, ERC20Burnable {\n\n    /**\n     * @dev Constructor that gives _msgSender() all of existing tokens.\n     */\n    constructor () public ERC20Detailed(\"BRACE\", \"BRACE\", 8) {\n        _mint(_msgSender(), 0 * (10 ** uint256(decimals())));\n    }\n}"},"Context.sol":{"content":"pragma solidity ^0.5.0;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with GSN meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\ncontract Context {\n    // Empty internal constructor, to prevent people from mistakenly deploying\n    // an instance of this contract, which should be used via inheritance.\n    constructor () internal { }\n    // solhint-disable-previous-line no-empty-blocks\n\n    function _msgSender() internal view returns (address payable) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view returns (bytes memory) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n}\n"},"ERC20.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./Context.sol\";\nimport \"./IERC20.sol\";\nimport \"./SafeMath.sol\";\n\n/**\n * @dev Implementation of the {IERC20} interface.\n *\n * This implementation is agnostic to the way tokens are created. This means\n * that a supply mechanism has to be added in a derived contract using {_mint}.\n * For a generic mechanism see {ERC20Mintable}.\n *\n * TIP: For a detailed writeup see our guide\n * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How\n * to implement supply mechanisms].\n *\n * We have followed general OpenZeppelin guidelines: functions revert instead\n * of returning `false` on failure. This behavior is nonetheless conventional\n * and does not conflict with the expectations of ERC20 applications.\n *\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\n * This allows applications to reconstruct the allowance for all accounts just\n * by listening to said events. Other implementations of the EIP may not emit\n * these events, as it isn\u0027t required by the specification.\n *\n * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}\n * functions have been added to mitigate the well-known issues around setting\n * allowances. See {IERC20-approve}.\n */\ncontract ERC20 is Context, IERC20 {\n    using SafeMath for uint256;\n\n    mapping (address =\u003e uint256) private _balances;\n\n    mapping (address =\u003e mapping (address =\u003e uint256)) private _allowances;\n\n    uint256 private _totalSupply;\n\n    /**\n     * @dev See {IERC20-totalSupply}.\n     */\n    function totalSupply() public view returns (uint256) {\n        return _totalSupply;\n    }\n\n    /**\n     * @dev See {IERC20-balanceOf}.\n     */\n    function balanceOf(address account) public view returns (uint256) {\n        return _balances[account];\n    }\n\n    /**\n     * @dev See {IERC20-transfer}.\n     *\n     * Requirements:\n     *\n     * - `recipient` cannot be the zero address.\n     * - the caller must have a balance of at least `amount`.\n     */\n    function transfer(address recipient, uint256 amount) public returns (bool) {\n        _transfer(_msgSender(), recipient, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-allowance}.\n     */\n    function allowance(address owner, address spender) public view returns (uint256) {\n        return _allowances[owner][spender];\n    }\n\n    /**\n     * @dev See {IERC20-approve}.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function approve(address spender, uint256 amount) public returns (bool) {\n        _approve(_msgSender(), spender, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-transferFrom}.\n     *\n     * Emits an {Approval} event indicating the updated allowance. This is not\n     * required by the EIP. See the note at the beginning of {ERC20};\n     *\n     * Requirements:\n     * - `sender` and `recipient` cannot be the zero address.\n     * - `sender` must have a balance of at least `amount`.\n     * - the caller must have allowance for `sender`\u0027s tokens of at least\n     * `amount`.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {\n        _transfer(sender, recipient, amount);\n        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, \"ERC20: transfer amount exceeds allowance\"));\n        return true;\n    }\n\n    /**\n     * @dev Atomically increases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));\n        return true;\n    }\n\n    /**\n     * @dev Atomically decreases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     * - `spender` must have allowance for the caller of at least\n     * `subtractedValue`.\n     */\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, \"ERC20: decreased allowance below zero\"));\n        return true;\n    }\n\n    /**\n     * @dev Moves tokens `amount` from `sender` to `recipient`.\n     *\n     * This is internal function is equivalent to {transfer}, and can be used to\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\n     *\n     * Emits a {Transfer} event.\n     *\n     * Requirements:\n     *\n     * - `sender` cannot be the zero address.\n     * - `recipient` cannot be the zero address.\n     * - `sender` must have a balance of at least `amount`.\n     */\n    function _transfer(address sender, address recipient, uint256 amount) internal {\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\n\n        _balances[sender] = _balances[sender].sub(amount, \"ERC20: transfer amount exceeds balance\");\n        _balances[recipient] = _balances[recipient].add(amount);\n        emit Transfer(sender, recipient, amount);\n    }\n\n    /** @dev Creates `amount` tokens and assigns them to `account`, increasing\n     * the total supply.\n     *\n     * Emits a {Transfer} event with `from` set to the zero address.\n     *\n     * Requirements\n     *\n     * - `to` cannot be the zero address.\n     */\n    function _mint(address account, uint256 amount) internal {\n        require(account != address(0), \"ERC20: mint to the zero address\");\n\n        _totalSupply = _totalSupply.add(amount);\n        _balances[account] = _balances[account].add(amount);\n        emit Mint(account, amount);\n        emit Transfer(address(0), account, amount);\n    }\n\n    /**\n     * @dev Destroys `amount` tokens from `account`, reducing the\n     * total supply.\n     *\n     * Emits a {Transfer} event with `to` set to the zero address.\n     *\n     * Requirements\n     *\n     * - `account` cannot be the zero address.\n     * - `account` must have at least `amount` tokens.\n     */\n    function _burn(address account, uint256 amount) internal {\n        require(account != address(0), \"ERC20: burn from the zero address\");\n\n        _balances[account] = _balances[account].sub(amount, \"ERC20: burn amount exceeds balance\");\n        _totalSupply = _totalSupply.sub(amount);\n        emit Burn(account, amount);\n        emit Transfer(account, address(0), amount);\n    }\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.\n     *\n     * This is internal function is equivalent to `approve`, and can be used to\n     * e.g. set automatic allowances for certain subsystems, etc.\n     *\n     * Emits an {Approval} event.\n     *\n     * Requirements:\n     *\n     * - `owner` cannot be the zero address.\n     * - `spender` cannot be the zero address.\n     */\n    function _approve(address owner, address spender, uint256 amount) internal {\n        require(owner != address(0), \"ERC20: approve from the zero address\");\n        require(spender != address(0), \"ERC20: approve to the zero address\");\n\n        _allowances[owner][spender] = amount;\n        emit Approval(owner, spender, amount);\n    }\n\n    /**\n     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted\n     * from the caller\u0027s allowance.\n     *\n     * See {_burn} and {_approve}.\n     */\n    function _burnFrom(address account, uint256 amount) internal {\n        _burn(account, amount);\n        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, \"ERC20: burn amount exceeds allowance\"));\n    }\n}\n"},"ERC20Burnable.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./Context.sol\";\nimport \"./ERC20.sol\";\n\n/**\n * @dev Extension of {ERC20} that allows token holders to destroy both their own\n * tokens and those that they have an allowance for, in a way that can be\n * recognized off-chain (via event analysis).\n */\ncontract ERC20Burnable is Context, ERC20 {\n    /**\n     * @dev Destroys `amount` tokens from the caller.\n     *\n     * See {ERC20-_burn}.\n     */\n    function burn(uint256 amount) public {\n        _burn(_msgSender(), amount);\n    }\n\n    /**\n     * @dev See {ERC20-_burnFrom}.\n     */\n    function burnFrom(address account, uint256 amount) public {\n        _burnFrom(account, amount);\n    }\n}\n"},"ERC20Detailed.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./IERC20.sol\";\n\n/**\n * @dev Optional functions from the ERC20 standard.\n */\ncontract ERC20Detailed is IERC20 {\n    string private _name;\n    string private _symbol;\n    uint8 private _decimals;\n\n    /**\n     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of\n     * these values are immutable: they can only be set once during\n     * construction.\n     */\n    constructor (string memory name, string memory symbol, uint8 decimals) public {\n        _name = name;\n        _symbol = symbol;\n        _decimals = decimals;\n    }\n\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() public view returns (string memory) {\n        return _name;\n    }\n\n    /**\n     * @dev Returns the symbol of the token, usually a shorter version of the\n     * name.\n     */\n    function symbol() public view returns (string memory) {\n        return _symbol;\n    }\n\n    /**\n     * @dev Returns the number of decimals used to get its user representation.\n     * For example, if `decimals` equals `2`, a balance of `505` tokens should\n     * be displayed to a user as `5,05` (`505 / 10 ** 2`).\n     *\n     * Tokens usually opt for a value of 18, imitating the relationship between\n     * Ether and Wei.\n     *\n     * NOTE: This information is only used for _display_ purposes: it in\n     * no way affects any of the arithmetic of the contract, including\n     * {IERC20-balanceOf} and {IERC20-transfer}.\n     */\n    function decimals() public view returns (uint8) {\n        return _decimals;\n    }\n}\n"},"ERC20Mintable.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./ERC20.sol\";\nimport \"./MinterRole.sol\";\n\n/**\n * @dev Extension of {ERC20} that adds a set of accounts with the {MinterRole},\n * which have permission to mint (create) new tokens as they see fit.\n *\n * At construction, the deployer of the contract is the only minter.\n */\ncontract ERC20Mintable is ERC20, MinterRole {\n    /**\n     * @dev See {ERC20-_mint}.\n     *\n     * Requirements:\n     *\n     * - the caller must have the {MinterRole}.\n     */\n    function mint(address account, uint256 amount) public onlyMinter returns (bool) {\n        _mint(account, amount);\n        return true;\n    }\n}\n"},"ERC20Pausable.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./ERC20.sol\";\nimport \"./Pausable.sol\";\n\n/**\n * @title Pausable token\n * @dev ERC20 with pausable transfers and allowances.\n *\n * Useful if you want to stop trades until the end of a crowdsale, or have\n * an emergency switch for freezing all token transfers in the event of a large\n * bug.\n */\ncontract ERC20Pausable is ERC20, Pausable {\n    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {\n        return super.transfer(to, value);\n    }\n\n    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {\n        return super.transferFrom(from, to, value);\n    }\n\n    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {\n        return super.approve(spender, value);\n    }\n\n    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {\n        return super.increaseAllowance(spender, addedValue);\n    }\n\n    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {\n        return super.decreaseAllowance(spender, subtractedValue);\n    }\n}\n"},"IERC20.sol":{"content":"pragma solidity ^0.5.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\n * the optional functions; to access them see {ERC20Detailed}.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n    event Mint(address account, uint256 amount);\n    event Burn(address indexed account, uint256 amount);\n    \n}\n"},"MinterRole.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./Context.sol\";\nimport \"./Roles.sol\";\n\ncontract MinterRole is Context {\n    using Roles for Roles.Role;\n\n    event MinterAdded(address indexed account);\n    event MinterRemoved(address indexed account);\n\n    Roles.Role private _minters;\n\n    constructor () internal {\n        _addMinter(_msgSender());\n    }\n\n    modifier onlyMinter() {\n        require(isMinter(_msgSender()), \"MinterRole: caller does not have the Minter role\");\n        _;\n    }\n\n    function isMinter(address account) public view returns (bool) {\n        return _minters.has(account);\n    }\n\n    function addMinter(address account) public onlyMinter {\n        _addMinter(account);\n    }\n\n    function renounceMinter() public {\n        _removeMinter(_msgSender());\n    }\n\n    function _addMinter(address account) internal {\n        _minters.add(account);\n        emit MinterAdded(account);\n    }\n\n    function _removeMinter(address account) internal {\n        _minters.remove(account);\n        emit MinterRemoved(account);\n    }\n}\n"},"Pausable.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./Context.sol\";\nimport \"./PauserRole.sol\";\n\n/**\n * @dev Contract module which allows children to implement an emergency stop\n * mechanism that can be triggered by an authorized account.\n *\n * This module is used through inheritance. It will make available the\n * modifiers `whenNotPaused` and `whenPaused`, which can be applied to\n * the functions of your contract. Note that they will not be pausable by\n * simply including this module, only once the modifiers are put in place.\n */\ncontract Pausable is Context, PauserRole {\n    /**\n     * @dev Emitted when the pause is triggered by a pauser (`account`).\n     */\n    event Paused(address account);\n\n    /**\n     * @dev Emitted when the pause is lifted by a pauser (`account`).\n     */\n    event Unpaused(address account);\n\n    bool private _paused;\n\n    /**\n     * @dev Initializes the contract in unpaused state. Assigns the Pauser role\n     * to the deployer.\n     */\n    constructor () internal {\n        _paused = false;\n    }\n\n    /**\n     * @dev Returns true if the contract is paused, and false otherwise.\n     */\n    function paused() public view returns (bool) {\n        return _paused;\n    }\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is not paused.\n     */\n    modifier whenNotPaused() {\n        require(!_paused, \"Pausable: paused\");\n        _;\n    }\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is paused.\n     */\n    modifier whenPaused() {\n        require(_paused, \"Pausable: not paused\");\n        _;\n    }\n\n    /**\n     * @dev Called by a pauser to pause, triggers stopped state.\n     */\n    function pause() public onlyPauser whenNotPaused {\n        _paused = true;\n        emit Paused(_msgSender());\n    }\n\n    /**\n     * @dev Called by a pauser to unpause, returns to normal state.\n     */\n    function unpause() public onlyPauser whenPaused {\n        _paused = false;\n        emit Unpaused(_msgSender());\n    }\n}\n"},"PauserRole.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./Context.sol\";\nimport \"./Roles.sol\";\n\ncontract PauserRole is Context {\n    using Roles for Roles.Role;\n\n    event PauserAdded(address indexed account);\n    event PauserRemoved(address indexed account);\n\n    Roles.Role private _pausers;\n\n    constructor () internal {\n        _addPauser(_msgSender());\n    }\n\n    modifier onlyPauser() {\n        require(isPauser(_msgSender()), \"PauserRole: caller does not have the Pauser role\");\n        _;\n    }\n\n    function isPauser(address account) public view returns (bool) {\n        return _pausers.has(account);\n    }\n\n    function addPauser(address account) public onlyPauser {\n        _addPauser(account);\n    }\n\n    function renouncePauser() public {\n        _removePauser(_msgSender());\n    }\n\n    function _addPauser(address account) internal {\n        _pausers.add(account);\n        emit PauserAdded(account);\n    }\n\n    function _removePauser(address account) internal {\n        _pausers.remove(account);\n        emit PauserRemoved(account);\n    }\n}\n"},"Roles.sol":{"content":"pragma solidity ^0.5.0;\n\n/**\n * @title Roles\n * @dev Library for managing addresses assigned to a Role.\n */\nlibrary Roles {\n    struct Role {\n        mapping (address =\u003e bool) bearer;\n    }\n\n    /**\n     * @dev Give an account access to this role.\n     */\n    function add(Role storage role, address account) internal {\n        require(!has(role, account), \"Roles: account already has role\");\n        role.bearer[account] = true;\n    }\n\n    /**\n     * @dev Remove an account\u0027s access to this role.\n     */\n    function remove(Role storage role, address account) internal {\n        require(has(role, account), \"Roles: account does not have role\");\n        role.bearer[account] = false;\n    }\n\n    /**\n     * @dev Check if an account has this role.\n     * @return bool\n     */\n    function has(Role storage role, address account) internal view returns (bool) {\n        require(account != address(0), \"Roles: account is the zero address\");\n        return role.bearer[account];\n    }\n}\n"},"SafeMath.sol":{"content":"pragma solidity ^0.5.0;\n\n/**\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it\u0027s recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, \"SafeMath: addition overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        return sub(a, b, \"SafeMath: subtraction overflow\");\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     *\n     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.\n     * @dev Get it via `npm install @openzeppelin/contracts@next`.\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b \u003c= a, errorMessage);\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return div(a, b, \"SafeMath: division by zero\");\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n\n     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.\n     * @dev Get it via `npm install @openzeppelin/contracts@next`.\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b \u003e 0, errorMessage);\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        return mod(a, b, \"SafeMath: modulo by zero\");\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts with custom message when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     *\n     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.\n     * @dev Get it via `npm install @openzeppelin/contracts@next`.\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b != 0, errorMessage);\n        return a % b;\n    }\n}\n"}}