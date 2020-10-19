{"Bank.sol":{"content":"// SPDX-License-Identifier: BSD-3-Clause\r\n\r\npragma solidity 0.6.8;\r\n\r\nimport \"./SafeMath.sol\";\r\n\r\ncontract Bank {\r\n  struct Account {\r\n    uint amount;\r\n    uint received;\r\n    uint percentage;\r\n    bool exists;\r\n  }\r\n\r\n  uint internal constant ENTRY_ENABLED = 1;\r\n  uint internal constant ENTRY_DISABLED = 2;\r\n\r\n  mapping(address =\u003e Account) internal accountStorage;\r\n  mapping(uint =\u003e address) internal accountLookup;\r\n  mapping(uint =\u003e uint) internal agreementAmount;\r\n  uint internal reentry_status;\r\n  uint internal totalHolders;\r\n  uint internal systemBalance = 0;\r\n\r\n  using SafeMath for uint;\r\n\r\n  modifier hasAccount(address _account) {\r\n      require(accountStorage[_account].exists, \"Bank account dont exist!\");\r\n      _;\r\n    }\r\n\r\n  modifier blockReEntry() {      \r\n    require(reentry_status != ENTRY_DISABLED, \"Security Block\");\r\n    reentry_status = ENTRY_DISABLED;\r\n\r\n    _;\r\n\r\n    reentry_status = ENTRY_ENABLED;\r\n  }\r\n\r\n  function initiateDistribute() external hasAccount(msg.sender) {\r\n    uint amount = distribute(systemBalance);\r\n\r\n    systemBalance = systemBalance.sub(amount);\r\n  }\r\n\r\n  function distribute(uint _amount) internal returns (uint) {\r\n    require(_amount \u003e 0, \"No amount transferred\");\r\n\r\n    uint percentage = _amount.div(100);\r\n    uint total_used = 0;\r\n    uint pay = 0;\r\n\r\n    for (uint num = 0; num \u003c totalHolders;num++) {\r\n      pay = percentage * accountStorage[accountLookup[num]].percentage;\r\n\r\n      if (pay \u003e 0) {\r\n        if (total_used.add(pay) \u003e _amount) { //Ensure we do not pay out too much\r\n          pay = _amount.sub(total_used);\r\n        }\r\n\r\n        deposit(accountLookup[num], pay);\r\n        total_used = total_used.add(pay);\r\n      }\r\n\r\n      if (total_used \u003e= _amount) { //Ensure we stop if we have paid out everything\r\n        break;\r\n      }\r\n    }\r\n\r\n    return total_used;\r\n  }\r\n\r\n  function deposit(address _to, uint _amount) internal hasAccount(_to) {\r\n    accountStorage[_to].amount = accountStorage[_to].amount.add(_amount);\r\n  }\r\n\r\n  receive() external payable blockReEntry() {\r\n    systemBalance = systemBalance.add(msg.value);\r\n  }\r\n\r\n  function getSystemBalance() external view hasAccount(msg.sender) returns (uint) {\r\n    return systemBalance;\r\n  }\r\n\r\n  function getBalance() external view hasAccount(msg.sender) returns (uint) {\r\n    return accountStorage[msg.sender].amount;\r\n  }\r\n\r\n  function getReceived() external view hasAccount(msg.sender) returns (uint) {\r\n    return accountStorage[msg.sender].received;\r\n  }\r\n  \r\n  function withdraw(uint _amount) external payable hasAccount(msg.sender) blockReEntry() {\r\n    require(accountStorage[msg.sender].amount \u003e= _amount \u0026\u0026 _amount \u003e 0, \"Not enough funds\");\r\n\r\n    accountStorage[msg.sender].amount = accountStorage[msg.sender].amount.sub(_amount);\r\n    accountStorage[msg.sender].received = accountStorage[msg.sender].received.add(_amount);\r\n\r\n    (bool success, ) = msg.sender.call{ value: _amount }(\"\");\r\n    \r\n    require(success, \"Transfer failed\");\r\n  }\r\n\r\n  function withdrawTo(address payable _to, uint _amount) external hasAccount(msg.sender) blockReEntry() {\r\n    require(accountStorage[msg.sender].amount \u003e= _amount \u0026\u0026 _amount \u003e 0, \"Not enough funds\");\r\n\r\n    accountStorage[msg.sender].amount = accountStorage[msg.sender].amount.sub(_amount);\r\n    accountStorage[msg.sender].received = accountStorage[msg.sender].received.add(_amount);\r\n\r\n    (bool success, ) = _to.call{ value: _amount }(\"\");\r\n    \r\n    require(success, \"Transfer failed\");\r\n  }\r\n\r\n  function subPercentage(address _addr, uint _percentage) internal hasAccount(_addr) {\r\n      accountStorage[_addr].percentage = accountStorage[_addr].percentage.sub(_percentage);\r\n    }\r\n\r\n  function addPercentage(address _addr, uint _percentage) internal hasAccount(_addr) {\r\n      accountStorage[_addr].percentage = accountStorage[_addr].percentage.add(_percentage);\r\n    }\r\n\r\n  function getPercentage() external view hasAccount(msg.sender) returns (uint) {\r\n    return accountStorage[msg.sender].percentage;\r\n  }\r\n\r\n  function validateBalance() external hasAccount(msg.sender) returns (uint) { //Allow any account to verify/adjust contract balance\r\n    uint amount = systemBalance;\r\n\r\n    for (uint num = 0; num \u003c totalHolders;num++) {\r\n      amount = amount.add(accountStorage[accountLookup[num]].amount);\r\n    }\r\n\r\n    if (amount \u003c address(this).balance) {\r\n      uint balance = address(this).balance;\r\n      balance = balance.sub(amount);\r\n\r\n      systemBalance = systemBalance.add(balance);\r\n\r\n      return balance;\r\n    }\r\n\r\n    return 0;\r\n  }\r\n\r\n  function createAccount(address _addr, uint _amount, uint _percentage, uint _agreementAmount) internal {\r\n    accountStorage[_addr] = Account({amount: _amount, received: 0, percentage: _percentage, exists: true});\r\n    agreementAmount[totalHolders] = _agreementAmount;\r\n    accountLookup[totalHolders++] = _addr;\r\n  }\r\n\r\n  function deleteAccount(address _addr, address _to) internal hasAccount(_addr) {\r\n    deposit(_to, accountStorage[_addr].amount);\r\n\r\n    for (uint8 num = 0; num \u003c totalHolders;num++) {\r\n      if (accountLookup[num] == _addr) {\r\n        delete(accountLookup[num]);\r\n        break;\r\n      }\r\n    }\r\n\r\n    delete(accountStorage[_addr]);\r\n    totalHolders--;\r\n  }\r\n}"},"P1Distribute.sol":{"content":"// SPDX-License-Identifier: BSD-3-Clause\r\n\r\npragma solidity 0.6.8;\r\n\r\nimport \"./Bank.sol\";\r\n\r\ncontract P1Distribute is Bank {\r\n\r\n  constructor(address _rec1, uint _perc1, uint _amount1, address _rec2, uint _perc2, uint _amount2, address _rec3, uint _perc3, uint _amount3) public {\r\n    reentry_status = ENTRY_ENABLED;\r\n\r\n    require((_perc1 + _perc2 + _perc3) == 100, \"Percentage does not equal 100%\");\r\n\r\n    createAccount(_rec1, address(this).balance, _perc1, _amount1);\r\n    createAccount(_rec2, 0, _perc2, _amount2);\r\n    createAccount(_rec3, 0, _perc3, _amount3);\r\n  }\r\n}"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: BSD-3-Clause\n\npragma solidity ^0.6.0;\n\n/**\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it\u0027s recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, \"SafeMath: addition overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        return sub(a, b, \"SafeMath: subtraction overflow\");\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b \u003c= a, errorMessage);\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return div(a, b, \"SafeMath: division by zero\");\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b \u003e 0, errorMessage);\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        return mod(a, b, \"SafeMath: modulo by zero\");\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts with custom message when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b != 0, errorMessage);\n        return a % b;\n    }\n}\n"}}