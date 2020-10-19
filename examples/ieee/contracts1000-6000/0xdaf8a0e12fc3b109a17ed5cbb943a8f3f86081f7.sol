{"ERC20contract.sol":{"content":"// \"SPDX-License-Identifier: UNLICENSED \"\r\npragma solidity ^0.6.0;\r\n// ----------------------------------------------------------------------------\r\n// ERC Token Standard #20 Interface\r\n// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md\r\n// ----------------------------------------------------------------------------\r\nabstract contract ERC20Interface {\r\n    function totalSupply() public virtual view returns (uint);\r\n    function balanceOf(address tokenOwner) public virtual view returns (uint256 balance);\r\n    function allowance(address tokenOwner, address spender) public virtual view returns (uint256 remaining);\r\n    function transfer(address to, uint256 tokens) public virtual returns (bool success);\r\n    function approve(address spender, uint256 tokens) public virtual returns (bool success);\r\n    function transferFrom(address from, address to, uint256 tokens) public virtual returns (bool success);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 tokens);\r\n    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);\r\n}"},"Owned.sol":{"content":"// \"SPDX-License-Identifier: UNLICENSED \"\r\npragma solidity ^0.6.0;\r\n// ----------------------------------------------------------------------------\r\n// Owned contract\r\n// ----------------------------------------------------------------------------\r\ncontract Owned {\r\n    address payable public owner;\r\n\r\n    event OwnershipTransferred(address indexed _from, address indexed _to);\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    function transferOwnership(address payable _newOwner) public onlyOwner {\r\n        owner = _newOwner;\r\n        emit OwnershipTransferred(msg.sender, _newOwner);\r\n    }\r\n}"},"SafeMath.sol":{"content":"// \"SPDX-License-Identifier: UNLICENSED \"\r\npragma solidity ^0.6.0;\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n *\r\n*/\r\n \r\nlibrary SafeMath {\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003e 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = a / b;\r\n    // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003c= a);\r\n    return a - b;\r\n  }\r\n\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a + b;\r\n    assert(c \u003e= a);\r\n    return c;\r\n  }\r\n  \r\n  function ceil(uint a, uint m) internal pure returns (uint r) {\r\n    return (a + m - 1) / m * m;\r\n  }\r\n}"},"SBX.sol":{"content":"pragma solidity ^0.6.0;\r\n// SPDX-License-Identifier: UNLICENSED\r\n\r\n// ----------------------------------------------------------------------------\r\n// \u0027Sports Betting Marketplace\u0027 token contract\r\n\r\n// Symbol      : SBX\r\n// Name        : Sports Betting Marketplace\r\n// Total supply: 200,000,000 (200 million) (30 million locked, 100K released weekly)\r\n// Decimals    : 18\r\n// ----------------------------------------------------------------------------\r\n\r\nimport \u0027./SafeMath.sol\u0027;\r\nimport \u0027./ERC20contract.sol\u0027;\r\nimport \u0027./Owned.sol\u0027;\r\n\r\n// ----------------------------------------------------------------------------\r\n// ERC20 Token, with the addition of symbol, name and decimals and assisted\r\n// token transfers\r\n// ----------------------------------------------------------------------------\r\ncontract SBX_TOKEN is ERC20Interface, Owned {\r\n    using SafeMath for uint256;\r\n    string public symbol = \"SBX\";\r\n    string public  name = \"Sports Betting Marketplace\";\r\n    uint256 public decimals = 18;\r\n    uint256 _totalSupply = 2e8* 10 ** (decimals);  // 200 million\r\n\r\n    uint256 public lockedTokens;\r\n    uint256 _contractStartTime;\r\n    uint256 _lastUpdated;\r\n    \r\n    mapping(address =\u003e uint256) balances;\r\n    mapping(address =\u003e mapping(address =\u003e uint256)) allowed;\r\n    \r\n    // ------------------------------------------------------------------------\r\n    // Constructor\r\n    // ------------------------------------------------------------------------\r\n    constructor() public {\r\n        owner = 0xe93ae81fe7Fa777DE976876BC276218e0C292d48;\r\n        balances[owner] = totalSupply();\r\n        \r\n        lockedTokens = 3e7 * 10 ** (decimals); // 30 million\r\n        _contractStartTime = now;\r\n        \r\n        emit Transfer(address(0),address(owner), totalSupply());\r\n    }\r\n    \r\n    /** ERC20Interface function\u0027s implementation **/\r\n    \r\n    // ------------------------------------------------------------------------\r\n    // Get the total supply of the tokens\r\n    // ------------------------------------------------------------------------\r\n    function totalSupply() public override view returns (uint256){\r\n       return _totalSupply; \r\n    }\r\n    \r\n    // ------------------------------------------------------------------------\r\n    // Get the token balance for account `tokenOwner`\r\n    // ------------------------------------------------------------------------\r\n    function balanceOf(address tokenOwner) public override view returns (uint256 balance) {\r\n        return balances[tokenOwner];\r\n    }\r\n\r\n    // ------------------------------------------------------------------------\r\n    // Transfer the balance from token owner\u0027s account to `to` account\r\n    // - Owner\u0027s account must have sufficient balance to transfer\r\n    // - 0 value transfers are allowed\r\n    // ------------------------------------------------------------------------\r\n    function transfer(address to, uint256 tokens) public override returns (bool success) {\r\n        // unlock tokens update\r\n        unlockTokens();\r\n        \r\n        // prevent transfer to 0x0, use burn instead\r\n        require(address(to) != address(0));\r\n        require(balances[msg.sender] \u003e= tokens);\r\n        require(balances[to] + tokens \u003e= balances[to]);\r\n        if(msg.sender == owner){\r\n            require(balances[msg.sender].sub(tokens) \u003e= lockedTokens);\r\n        }\r\n        \r\n        balances[msg.sender] = balances[msg.sender].sub(tokens);\r\n        balances[to] = balances[to].add(tokens);\r\n        \r\n        emit Transfer(msg.sender,to,tokens);\r\n        return true;\r\n    }\r\n    \r\n    // ------------------------------------------------------------------------\r\n    // Token owner can approve for `spender` to transferFrom(...) `tokens`\r\n    // from the token owner\u0027s account\r\n    // ------------------------------------------------------------------------\r\n    function approve(address spender, uint256 tokens) public override returns (bool success){\r\n        allowed[msg.sender][spender] = tokens;\r\n        emit Approval(msg.sender,spender,tokens);\r\n        return true;\r\n    }\r\n\r\n    // ------------------------------------------------------------------------\r\n    // Transfer `tokens` from the `from` account to the `to` account\r\n    // \r\n    // The calling account must already have sufficient tokens approve(...)-d\r\n    // for spending from the `from` account and\r\n    // - From account must have sufficient balance to transfer\r\n    // - Spender must have sufficient allowance to transfer\r\n    // - 0 value transfers are allowed\r\n    // ------------------------------------------------------------------------\r\n    function transferFrom(address from, address to, uint256 tokens) public override returns (bool success){\r\n        // unlock tokens update\r\n        unlockTokens();\r\n        \r\n        require(tokens \u003c= allowed[from][msg.sender]); //check allowance\r\n        require(balances[from] \u003e= tokens);\r\n        if(from == owner){\r\n            require(balances[msg.sender].sub(tokens) \u003e= lockedTokens);\r\n        }\r\n            \r\n        balances[from] = balances[from].sub(tokens);\r\n        balances[to] = balances[to].add(tokens);\r\n        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);\r\n        emit Transfer(from,to,tokens);\r\n        return true;\r\n    }\r\n    \r\n    // ------------------------------------------------------------------------\r\n    // Returns the amount of tokens approved by the owner that can be\r\n    // transferred to the spender\u0027s account\r\n    // ------------------------------------------------------------------------\r\n    function allowance(address tokenOwner, address spender) public override view returns (uint256 remaining) {\r\n        return allowed[tokenOwner][spender];\r\n    }\r\n    \r\n    // ------------------------------------------------------------------------\r\n    // Helper function to unlock tokens if applicable\r\n    // ------------------------------------------------------------------------\r\n    function unlockTokens() internal{\r\n        // release tokens from lock, depending on current time\r\n        uint256 timeFrame = 7 days; // 1 week\r\n        uint256 relativeTimeDifference = (now.sub(_contractStartTime)).div(timeFrame);\r\n        if(relativeTimeDifference \u003e _lastUpdated){\r\n            uint256 tokensToRelease = (relativeTimeDifference.sub(_lastUpdated)).mul(1e5 * 10 ** (decimals)); // 100K released per week\r\n            lockedTokens = lockedTokens.sub(tokensToRelease);\r\n            _lastUpdated = relativeTimeDifference;\r\n        }\r\n        \r\n    }\r\n}"}}