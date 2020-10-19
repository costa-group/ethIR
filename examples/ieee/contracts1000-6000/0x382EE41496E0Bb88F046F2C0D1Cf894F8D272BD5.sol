{"IOwnershipTransferrable.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.7.0;\n\ninterface IOwnershipTransferrable {\n  function transferOwnership(address owner) external;\n  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n}\n"},"IVybeBorrower.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.7.0;\n\ninterface IVybeBorrower {\n  function loaned(uint256 amount, uint256 owed) external;\n}\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.7.0;\n\nimport \"./IOwnershipTransferrable.sol\";\n\nabstract contract Ownable is IOwnershipTransferrable {\n  address private _owner;\n\n  constructor(address owner) {\n    _owner = owner;\n    emit OwnershipTransferred(address(0), _owner);\n  }\n\n  function owner() public view returns (address) {\n    return _owner;\n  }\n\n  modifier onlyOwner() {\n    require(_owner == msg.sender, \"Ownable: caller is not the owner\");\n    _;\n  }\n\n  function transferOwnership(address newOwner) override external onlyOwner {\n    require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n    emit OwnershipTransferred(_owner, newOwner);\n    _owner = newOwner;\n  }\n}\n"},"ReentrancyGuard.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity 0.7.0;\n\nabstract contract ReentrancyGuard {\n  bool private _entered;\n\n  modifier noReentrancy() {\n    require(!_entered);\n    _entered = true;\n    _;\n    _entered = false;\n  }\n}\n"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.7.0;\n\nlibrary SafeMath {\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\n    uint256 c = a + b;\n    require(c \u003e= a);\n    return c;\n  }\n\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n    require(b \u003c= a);\n    uint256 c = a - b;\n    return c;\n  }\n\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n    if (a == 0) {\n      return 0;\n    }\n    uint256 c = a * b;\n    require(c / a == b);\n    return c;\n  }\n\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\n    require(b \u003e 0);\n    uint256 c = a / b;\n    return c;\n  }\n\n  function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n    require(b != 0);\n    return a % b;\n  }\n}\n"},"Vybe.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.7.0;\n\nimport \"./SafeMath.sol\";\nimport \"./Ownable.sol\";\n\ncontract Vybe is Ownable {\n  using SafeMath for uint256;\n\n  uint256 constant UINT256_MAX = ~uint256(0);\n\n  string private _name;\n  string private _symbol;\n  uint8 private _decimals;\n\n  uint256 private _totalSupply;\n  mapping(address =\u003e uint256) private _balances;\n  mapping(address =\u003e mapping(address =\u003e uint256)) private _allowances;\n\n  event Transfer(address indexed from, address indexed to, uint256 value);\n  event Approval(address indexed owner, address indexed spender, uint256 value);\n\n  constructor() Ownable(msg.sender) {\n    _name = \"Vybe\";\n    _symbol = \"VYBE\";\n    _decimals = 18;\n\n    _totalSupply = 2000000 * 1e18;\n    _balances[msg.sender] = _totalSupply;\n    emit Transfer(address(0), msg.sender, _totalSupply);\n  }\n\n  function name() external view returns (string memory) {\n    return _name;\n  }\n\n  function symbol() external view returns (string memory) {\n    return _symbol;\n  }\n\n  function decimals() external view returns (uint8) {\n    return _decimals;\n  }\n\n  function totalSupply() external view returns (uint256) {\n    return _totalSupply;\n  }\n\n  function balanceOf(address account) external view returns (uint256) {\n    return _balances[account];\n  }\n\n  function allowance(address owner, address spender) external view returns (uint256) {\n    return _allowances[owner][spender];\n  }\n\n  function transfer(address recipient, uint256 amount) external returns (bool) {\n    _transfer(msg.sender, recipient, amount);\n    return true;\n  }\n\n  function approve(address spender, uint256 amount) external returns (bool) {\n    _approve(msg.sender, spender, amount);\n    return true;\n  }\n\n  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {\n    _transfer(sender, recipient, amount);\n    if (_allowances[msg.sender][sender] != UINT256_MAX) {\n      _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));\n    }\n    return true;\n  }\n\n  function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {\n    _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));\n    return true;\n  }\n\n  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {\n    _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));\n    return true;\n  }\n\n  function _transfer(address sender, address recipient, uint256 amount) internal {\n    require(sender != address(0));\n    require(recipient != address(0));\n\n    _balances[sender] = _balances[sender].sub(amount);\n    _balances[recipient] = _balances[recipient].add(amount);\n    emit Transfer(sender, recipient, amount);\n  }\n\n  function _approve(address owner, address spender, uint256 amount) internal {\n    require(owner != address(0));\n    require(spender != address(0));\n\n    _allowances[owner][spender] = amount;\n    emit Approval(owner, spender, amount);\n  }\n\n  function mint(address account, uint256 amount) external onlyOwner {\n    _totalSupply = _totalSupply.add(amount);\n    _balances[account] = _balances[account].add(amount);\n    emit Transfer(address(0), account, amount);\n  }\n\n  function burn(uint256 amount) external returns (bool) {\n    _balances[msg.sender] = _balances[msg.sender].sub(amount);\n    _totalSupply = _totalSupply.sub(amount);\n    emit Transfer(msg.sender, address(0), amount);\n    return true;\n  }\n}\n"},"VybeLoan.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.7.0;\n\nimport \"./SafeMath.sol\";\nimport \"./ReentrancyGuard.sol\";\nimport \"./Ownable.sol\";\nimport \"./Vybe.sol\";\nimport \"./IVybeBorrower.sol\";\n\ncontract VybeLoan is ReentrancyGuard, Ownable {\n  using SafeMath for uint256;\n\n  Vybe private _VYBE;\n  uint256 internal _feeDivisor = 100;\n\n  event Loaned(uint256 amount, uint256 profit);\n\n  constructor(address VYBE, address vybeStake) Ownable(vybeStake) {\n    _VYBE = Vybe(VYBE);\n  }\n\n  function loan(uint256 amount) external noReentrancy {\n    uint256 profit = amount.div(_feeDivisor);\n    uint256 owed = amount.add(profit);\n    require(_VYBE.transferFrom(owner(), msg.sender, amount));\n\n    IVybeBorrower(msg.sender).loaned(amount, owed);\n\n    require(_VYBE.transferFrom(msg.sender, owner(), amount));\n    require(_VYBE.transferFrom(msg.sender, address(this), profit));\n    require(_VYBE.burn(profit));\n\n    emit Loaned(amount, profit);\n  }\n}\n"}}