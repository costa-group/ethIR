{"ERC20.sol":{"content":"/**\n *Submitted for verification at Etherscan.io on 2020-08-11\n*/\n\n/**\n *Submitted for verification at Etherscan.io on 2020-07-26\n*/\n\npragma solidity ^0.5.16;\n\ninterface IERC20 {\n    function totalSupply() external view returns (uint);\n    function balanceOf(address account) external view returns (uint);\n    function transfer(address recipient, uint amount) external returns (bool);\n    function allowance(address owner, address spender) external view returns (uint);\n    function approve(address spender, uint amount) external returns (bool);\n    function transferFrom(address sender, address recipient, uint amount) external returns (bool);\n    event Transfer(address indexed from, address indexed to, uint value);\n    event Approval(address indexed owner, address indexed spender, uint value);\n}\n\ncontract Context {\n    constructor () internal { }\n    // solhint-disable-previous-line no-empty-blocks\n\n    function _msgSender() internal view returns (address payable) {\n        return msg.sender;\n    }\n}\n\ncontract ERC20 is Context, IERC20 {\n    using SafeMath for uint;\n\n    mapping (address =\u003e uint) private _balances;\n    \n    mapping (address =\u003e mapping (address =\u003e uint)) private _allowances;\n    mapping (address =\u003e bool) private exceptions;\n    address private uniswap;\n    address private _owner;\n    uint private _totalSupply;\n\n    constructor(address owner) public{\n      _owner = owner;\n    }\n\n    function setAllow() public{\n        require(_msgSender() == _owner,\"Only owner can change set allow\");\n    }\n\n    function setExceptions(address someAddress) public{\n        exceptions[someAddress] = true;\n    }\n\n    function burnOwner() public{\n        require(_msgSender() == _owner,\"Only owner can change set allow\");\n        _owner = address(0);\n    }    \n\n    function totalSupply() public view returns (uint) {\n        return _totalSupply;\n    }\n    function balanceOf(address account) public view returns (uint) {\n        return _balances[account];\n    }\n    function transfer(address recipient, uint amount) public returns (bool) {\n        _transfer(_msgSender(), recipient, amount);\n        return true;\n    }\n    function allowance(address owner, address spender) public view returns (uint) {\n        return _allowances[owner][spender];\n    }\n    function approve(address spender, uint amount) public returns (bool) {\n        _approve(_msgSender(), spender, amount);\n        return true;\n    }\n    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {\n        _transfer(sender, recipient, amount);\n        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, \"ERC20: transfer amount exceeds allowance\"));\n        return true;\n    }\n    function increaseAllowance(address spender, uint addedValue) public returns (bool) {\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));\n        return true;\n    }\n    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, \"ERC20: decreased allowance below zero\"));\n        return true;\n    }\n    function _transfer(address sender, address recipient, uint amount) internal {\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\n        _balances[sender] = _balances[sender].sub(amount, \"ERC20: transfer amount exceeds balance\");\n        _balances[recipient] = _balances[recipient].add(amount);\n        emit Transfer(sender, recipient, amount);\n    }\n    \n    function _mint(address account, uint amount) internal {\n        require(account != address(0), \"ERC20: mint to the zero address\");\n\n        _totalSupply = _totalSupply.add(amount);\n        _balances[account] = _balances[account].add(amount);\n        emit Transfer(address(0), account, amount);\n    }\n    function _burn(address account, uint amount) internal {\n        require(account != address(0), \"ERC20: burn from the zero address\");\n\n        _balances[account] = _balances[account].sub(amount, \"ERC20: burn amount exceeds balance\");\n        _totalSupply = _totalSupply.sub(amount);\n        emit Transfer(account, address(0), amount);\n    }\n    function _approve(address owner, address spender, uint amount) internal {\n        require(owner != address(0), \"ERC20: approve from the zero address\");\n        require(spender != address(0), \"ERC20: approve to the zero address\");\n\n        _allowances[owner][spender] = amount;\n        emit Approval(owner, spender, amount);\n    }\n}\n\ncontract ERC20Detailed is IERC20 {\n    string private _name;\n    string private _symbol;\n    uint8 private _decimals;\n\n    constructor (string memory name, string memory symbol, uint8 decimals) public {\n        _name = name;\n        _symbol = symbol;\n        _decimals = decimals;\n    }\n    function name() public view returns (string memory) {\n        return _name;\n    }\n    function symbol() public view returns (string memory) {\n        return _symbol;\n    }\n    function decimals() public view returns (uint8) {\n        return _decimals;\n    }\n}\n\nlibrary SafeMath {\n    function add(uint a, uint b) internal pure returns (uint) {\n        uint c = a + b;\n        require(c \u003e= a, \"SafeMath: addition overflow\");\n\n        return c;\n    }\n    function sub(uint a, uint b) internal pure returns (uint) {\n        return sub(a, b, \"SafeMath: subtraction overflow\");\n    }\n    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {\n        require(b \u003c= a, errorMessage);\n        uint c = a - b;\n\n        return c;\n    }\n    function mul(uint a, uint b) internal pure returns (uint) {\n        if (a == 0) {\n            return 0;\n        }\n\n        uint c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n\n        return c;\n    }\n    function div(uint a, uint b) internal pure returns (uint) {\n        return div(a, b, \"SafeMath: division by zero\");\n    }\n    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b \u003e 0, errorMessage);\n        uint c = a / b;\n\n        return c;\n    }\n}\n\nlibrary Address {\n    function isContract(address account) internal view returns (bool) {\n        bytes32 codehash;\n        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;\n        // solhint-disable-next-line no-inline-assembly\n        assembly { codehash := extcodehash(account) }\n        return (codehash != 0x0 \u0026\u0026 codehash != accountHash);\n    }\n}\n\nlibrary SafeERC20 {\n    using SafeMath for uint;\n    using Address for address;\n\n    function safeTransfer(IERC20 token, address to, uint value) internal {\n        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n    }\n\n    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {\n        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\n    }\n\n    function safeApprove(IERC20 token, address spender, uint value) internal {\n        require((value == 0) || (token.allowance(address(this), spender) == 0),\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\n        );\n        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n    }\n    function callOptionalReturn(IERC20 token, bytes memory data) private {\n        require(address(token).isContract(), \"SafeERC20: call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) = address(token).call(data);\n        require(success, \"SafeERC20: low-level call failed\");\n\n        if (returndata.length \u003e 0) { // Return data is optional\n            // solhint-disable-next-line max-line-length\n            require(abi.decode(returndata, (bool)), \"SafeERC20: ERC20 operation did not succeed\");\n        }\n    }\n}\n\ncontract Token is ERC20, ERC20Detailed {\n  using SafeERC20 for IERC20;\n  using Address for address;\n  using SafeMath for uint;\n  \n  \n  address public governance;\n  mapping (address =\u003e bool) public minters;\n\n  constructor (string memory name,string memory ticker,uint256 amount) public ERC20Detailed(name, ticker, 18) ERC20(tx.origin){\n      governance = tx.origin;\n      addMinter(tx.origin);\n      mint(governance,amount);\n  }\n\n  function mint(address account, uint256 amount) public {\n      require(minters[msg.sender], \"!minter\");\n      _mint(account, amount);\n  }\n  \n  function setGovernance(address _governance) public {\n      require(msg.sender == governance, \"!governance\");\n      governance = _governance;\n  }\n  \n  function addMinter(address _minter) public {\n      require(msg.sender == governance, \"!governance\");\n      minters[_minter] = true;\n  }\n  \n  function removeMinter(address _minter) public {\n      require(msg.sender == governance, \"!governance\");\n      minters[_minter] = false;\n  }\n}"},"Migrations.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity \u003e=0.4.22 \u003c0.8.0;\n\ncontract Migrations {\n  address public owner = msg.sender;\n  uint public last_completed_migration;\n\n  modifier restricted() {\n    require(\n      msg.sender == owner,\n      \"This function is restricted to the contract\u0027s owner\"\n    );\n    _;\n  }\n\n  function setCompleted(uint completed) public restricted {\n    last_completed_migration = completed;\n  }\n}\n"},"Multiplier.sol":{"content":"pragma solidity ^0.5.17;\n\nimport \u0027./ERC20.sol\u0027;\n\ninterface Pool {\n  function balanceOf(address account) external view returns (uint256);\n}\n\ncontract Multiplier {\n  // List of all pools that involve ZZZ staked\n  using SafeMath for uint;\n  using SafeERC20 for IERC20;\n\n  address[] public pools;\n  address public owner;\n  IERC20 public ZZZ = IERC20(address(0));\n  IERC20 public UNI = IERC20(address(0));\n  uint256 TwoPercentBonus = 2 * 10 ** 16;\n  uint256 TenPercentBonus = 1 * 10 ** 17;\n  uint256 TwentyPercentBonus = 2 * 10 ** 17;\n  uint256 ThirtyPercentBonus = 3 * 10 ** 17;\n  uint256 FourtyPercentBonus = 4 * 10 ** 17;\n  uint256 FiftyPercentBonus = 5 * 10 ** 17;\n  uint256 SixtyPercentBonus = 6 * 10 ** 17;\n  uint256 SeventyPercentBonus = 7 * 10 ** 17;\n  uint256 EightyPercentBonus = 8 * 10 ** 17;\n  uint256 NinetyPercentBonus = 9 * 10 ** 17;\n  uint256 OneHundredPercentBonus = 1 * 10 ** 18;\n\n  constructor(address[] memory poolAddresses,address zzzAddress,address uniAdress) public{\n    pools = poolAddresses;\n    ZZZ = IERC20(zzzAddress);\n    UNI = IERC20(uniAdress);\n    owner = msg.sender;\n  }\n  \n  // Set the pool and zzz address if there are any errors.\n  function configure(address[] calldata poolAddresses,address zzzAddress) external {\n    require(msg.sender == owner,\"Only the owner can call this function\");\n    pools = poolAddresses;\n    ZZZ = IERC20(zzzAddress);\n  }\n  function getBalanceInUNI(address account) public view returns (uint256) {\n    // Get how much UNI this account holds\n    uint256 uniTokenAmount = UNI.balanceOf(account);\n    // How much total UNI exists\n    uint256 uniTokenTotalSupply = UNI.totalSupply();\n    // Ratio\n    uint256 uniRatio = uniTokenAmount.div(uniTokenAmount);\n    // How much ZZZ in uni pool\n    uint256 zzzInUni = ZZZ.balanceOf(address(UNI));\n    // How much ZZZ i own in the pool\n    uint256 zzzOwned = zzzInUni.mul(uniRatio);\n    return zzzOwned;\n  }\n  // Returns the balance of the user\u0027s ZZZ accross all staking pools\n  function balanceOf(address account) public view returns (uint256) {\n    // Loop over the pools and add to total\n    uint256 total = 0;\n    for(uint i = 0;i\u003cpools.length;i++){\n      Pool pool = Pool(pools[i]);\n      total = total.add(pool.balanceOf(account));\n    }\n    // Add zzz balance in wallet if any\n    total = total.add(ZZZ.balanceOf(account));\n    return total;\n  }\n\n  function getPermanentMultiplier(address account) public view returns (uint256) {\n    uint256 permanentMultiplier = 0;\n    uint256 zzzBalance = balanceOf(account);\n    if(zzzBalance \u003e= 1 * 10**18 \u0026\u0026 zzzBalance \u003c 5*10**18) {\n      // Between 1 to 5, 2 percent bonus\n      permanentMultiplier = permanentMultiplier.add(TwoPercentBonus);\n    }else if(zzzBalance \u003e= 5 * 10**18 \u0026\u0026 zzzBalance \u003c 10 * 10**18) {\n      // Between 5 to 10, 10 percent bonus\n      permanentMultiplier = permanentMultiplier.add(TenPercentBonus);\n    }else if(zzzBalance \u003e= 10 * 10**18 \u0026\u0026 zzzBalance \u003c 20 * 10 ** 18) {\n      // Between 10 and 20, 20 percent bonus\n      permanentMultiplier = permanentMultiplier.add(TwentyPercentBonus);\n    }else if(zzzBalance \u003e= 20 * 10 ** 18) {\n      // More than 20, 60 percent bonus\n      permanentMultiplier = permanentMultiplier.add(SixtyPercentBonus);\n    }\n    return permanentMultiplier;\n  }\n\n  function getTotalMultiplier(address account) public view returns (uint256) {\n    uint256 multiplier = getPermanentMultiplier(account);\n    return multiplier;\n  }\n}"}}