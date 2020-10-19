{"Context.sol":{"content":"pragma solidity ^0.5.0;\r\n\r\ncontract Context {\r\n    constructor () internal { }\r\n\r\n    function _msgSender() internal view returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view returns (bytes memory) {\r\n        this;\r\n        return msg.data;\r\n    }\r\n}"},"ERC20.sol":{"content":"pragma solidity ^0.5.0;\r\n\r\nimport \"Context.sol\";\r\nimport \"IERC20.sol\";\r\nimport \"SafeMath.sol\";\r\n\r\ncontract ERC20 is Context, IERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    mapping (address =\u003e uint256) private _balances;\r\n\r\n    mapping (address =\u003e mapping (address =\u003e uint256)) private _allowances;\r\n\r\n    uint256 private _totalSupply;\r\n\r\n    \r\n    function totalSupply() public view returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    function balanceOf(address account) public view returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n\r\n    function transfer(address recipient, uint256 amount) public returns (bool) {\r\n        _transfer(_msgSender(), recipient, amount);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address owner, address spender) public view returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    function approve(address spender, uint256 amount) public returns (bool) {\r\n        _approve(_msgSender(), spender, amount);\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {\r\n        _transfer(sender, recipient, amount);\r\n        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, \"ERC20: transfer amount exceeds allowance\"));\r\n        return true;\r\n    }\r\n\r\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\r\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));\r\n        return true;\r\n    }\r\n\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\r\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, \"ERC20: decreased allowance below zero\"));\r\n        return true;\r\n    }\r\n\r\n    function _transfer(address sender, address recipient, uint256 amount) internal {\r\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\r\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\r\n\r\n        _balances[sender] = _balances[sender].sub(amount, \"ERC20: transfer amount exceeds balance\");\r\n        _balances[recipient] = _balances[recipient].add(amount);\r\n        emit Transfer(sender, recipient, amount);\r\n    }\r\n\r\n    function _mint(address account, uint256 amount) internal {\r\n        require(account != address(0), \"ERC20: mint to the zero address\");\r\n\r\n        _totalSupply = _totalSupply.add(amount);\r\n        _balances[account] = _balances[account].add(amount);\r\n        emit Transfer(address(0), account, amount);\r\n    }\r\n\r\n    function _burn(address account, uint256 amount) internal {\r\n        require(account != address(0), \"ERC20: burn from the zero address\");\r\n\r\n        _balances[account] = _balances[account].sub(amount, \"ERC20: burn amount exceeds balance\");\r\n        _totalSupply = _totalSupply.sub(amount);\r\n        emit Transfer(account, address(0), amount);\r\n    }\r\n\r\n    function _approve(address owner, address spender, uint256 amount) internal {\r\n        require(owner != address(0), \"ERC20: approve from the zero address\");\r\n        require(spender != address(0), \"ERC20: approve to the zero address\");\r\n\r\n        _allowances[owner][spender] = amount;\r\n        emit Approval(owner, spender, amount);\r\n    }\r\n\r\n    function _burnFrom(address account, uint256 amount) internal {\r\n        _burn(account, amount);\r\n        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, \"ERC20: burn amount exceeds allowance\"));\r\n    }\r\n}\r\n"},"ERC20Detailed.sol":{"content":"pragma solidity ^0.5.0;\r\n\r\nimport \"IERC20.sol\";\r\n\r\ncontract ERC20Detailed is IERC20 {\r\n    string private _name;\r\n    string private _symbol;\r\n    uint8 private _decimals;\r\n\r\n    constructor (string memory name, string memory symbol, uint8 decimals) public {\r\n        _name = name;\r\n        _symbol = symbol;\r\n        _decimals = decimals;\r\n    }\r\n\r\n    function name() public view returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    function symbol() public view returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    function decimals() public view returns (uint8) {\r\n        return _decimals;\r\n    }\r\n}"},"IERC20.sol":{"content":"pragma solidity ^0.5.0;\r\n\r\ninterface IERC20 {\r\n\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}"},"SafeMath.sol":{"content":"pragma solidity ^0.5.0;\r\n\r\nlibrary SafeMath {\r\n    \r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a + b;\r\n        require(c \u003e= a, \"SafeMath: addition overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \"SafeMath: subtraction overflow\");\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003c= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \"SafeMath: multiplication overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \"SafeMath: division by zero\");\r\n    }\r\n\r\n\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003e 0, errorMessage);\r\n        uint256 c = a / b;\r\n\r\n        return c;\r\n    }\r\n\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \"SafeMath: modulo by zero\");\r\n    }\r\n\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}"},"yfatm.sol":{"content":"pragma solidity ^0.5.0;\r\n\r\nimport \"ERC20.sol\";\r\nimport \"ERC20Detailed.sol\";\r\ncontract YFATM is ERC20, ERC20Detailed {\r\n    address owner;\r\n    using SafeMath for uint256;\r\n    ERC20 public token;\r\n\r\n    constructor () public ERC20Detailed(\"YFATOM\", \"YFATM\", 18) {\r\n        _mint(msg.sender, 15000 * (10 ** uint256(decimals())));\r\n        owner=msg.sender;\r\n    }\r\n    \r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n    \r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        require(newOwner != address(0));\r\n        owner = newOwner;\r\n    }\r\n}"}}