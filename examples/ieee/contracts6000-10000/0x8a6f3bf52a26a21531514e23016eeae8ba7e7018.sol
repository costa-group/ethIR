{"erc20.sol":{"content":"pragma solidity \u003e=0.4.22 \u003c0.6.0;\n\n// ----------------------------------------------------------------------------\n// Safe maths\n// ----------------------------------------------------------------------------\nlibrary SafeMath {\n    function add(uint a, uint b) internal pure returns (uint c) {\n        c = a + b;\n        require(c \u003e= a);\n    }\n    function sub(uint a, uint b) internal pure returns (uint c) {\n        require(b \u003c= a);\n        c = a - b;\n    }\n    function mul(uint a, uint b) internal pure returns (uint c) {\n        c = a * b;\n        require(a == 0 || c / a == b);\n    }\n    function div(uint a, uint b) internal pure returns (uint c) {\n        require(b \u003e 0);\n        c = a / b;\n    }\n}\n\n\n// ----------------------------------------------------------------------------\n// ERC Token Standard #20 Interface\n// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md\n// ----------------------------------------------------------------------------\ncontract ERC20Interface {\n    function totalSupply() public constant returns (uint);\n    function balanceOf(address tokenOwner) public constant returns (uint balance);\n    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);\n    function transfer(address to, uint tokens) public returns (bool success);\n    function approve(address spender, uint tokens) public returns (bool success);\n    function transferFrom(address from, address to, uint tokens) public returns (bool success);\n\n    event Transfer(address indexed from, address indexed to, uint tokens);\n    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);\n}\n\n\n// ----------------------------------------------------------------------------\n// Contract function to receive approval and execute function in one call\n// ----------------------------------------------------------------------------\ncontract ApproveAndCallFallBack {\n    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;\n}\n\n\n// ----------------------------------------------------------------------------\n// Owned contract\n// ----------------------------------------------------------------------------\ncontract Owned {\n    address public owner;\n    address public newOwner;\n\n    event OwnershipTransferred(address indexed _from, address indexed _to);\n\n    function Owned() public {\n        owner = msg.sender;\n    }\n\n    modifier onlyOwner {\n        require(msg.sender == owner);\n        _;\n    }\n\n    function transferOwnership(address _newOwner) public onlyOwner {\n        newOwner = _newOwner;\n    }\n    function acceptOwnership() public {\n        require(msg.sender == newOwner);\n        OwnershipTransferred(owner, newOwner);\n        owner = newOwner;\n        newOwner = address(0);\n    }\n}\n\n\n// ----------------------------------------------------------------------------\n// ERC20 Token, with the addition of symbol, name and decimals and an\n// initial fixed supply\n// ----------------------------------------------------------------------------\ncontract ERC20Token is ERC20Interface, Owned {\n    using SafeMath for uint;\n\n    string public symbol;\n    string public  name;\n    uint8 public decimals;\n    uint public _totalSupply;\n\n    mapping(address =\u003e uint) balances;\n    mapping(address =\u003e mapping(address =\u003e uint)) allowed;\n\n    // ------------------------------------------------------------------------\n    // Constructor\n    // ------------------------------------------------------------------------\n    function ERC20Token() public {\n  \n    }\n\n    // ------------------------------------------------------------------------\n    // Total supply\n    // ------------------------------------------------------------------------\n    function totalSupply() public constant returns (uint) {\n        return _totalSupply;\n    }\n\n\n    // ------------------------------------------------------------------------\n    // Get the token balance for account `tokenOwner`\n    // ------------------------------------------------------------------------\n    function balanceOf(address tokenOwner) public constant returns (uint balance) {\n        return balances[tokenOwner];\n    }\n\n\n    // ------------------------------------------------------------------------\n    // Transfer the balance from token owner\u0027s account to `to` account\n    // - Owner\u0027s account must have sufficient balance to transfer\n    // - 0 value transfers are allowed\n    // ------------------------------------------------------------------------\n    function transfer(address to, uint tokens) public returns (bool success) {\n        balances[msg.sender] = balances[msg.sender].sub(tokens);\n        balances[to] = balances[to].add(tokens);\n        Transfer(msg.sender, to, tokens);\n        return true;\n    }\n\n\n    // ------------------------------------------------------------------------\n    // Token owner can approve for `spender` to transferFrom(...) `tokens`\n    // from the token owner\u0027s account\n    //\n    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md\n    // recommends that there are no checks for the approval double-spend attack\n    // as this should be implemented in user interfaces \n    // ------------------------------------------------------------------------\n    function approve(address spender, uint tokens) public returns (bool success) {\n        allowed[msg.sender][spender] = tokens;\n        Approval(msg.sender, spender, tokens);\n        return true;\n    }\n\n\n    // ------------------------------------------------------------------------\n    // Transfer `tokens` from the `from` account to the `to` account\n    // \n    // The calling account must already have sufficient tokens approve(...)-d\n    // for spending from the `from` account and\n    // - From account must have sufficient balance to transfer\n    // - Spender must have sufficient allowance to transfer\n    // - 0 value transfers are allowed\n    // ------------------------------------------------------------------------\n    function transferFrom(address from, address to, uint tokens) public returns (bool success) {\n        balances[from] = balances[from].sub(tokens);\n        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);\n        balances[to] = balances[to].add(tokens);\n        Transfer(from, to, tokens);\n        return true;\n    }\n\n\n    // ------------------------------------------------------------------------\n    // Returns the amount of tokens approved by the owner that can be\n    // transferred to the spender\u0027s account\n    // ------------------------------------------------------------------------\n    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {\n        return allowed[tokenOwner][spender];\n    }\n\n\n    // ------------------------------------------------------------------------\n    // Token owner can approve for `spender` to transferFrom(...) `tokens`\n    // from the token owner\u0027s account. The `spender` contract function\n    // `receiveApproval(...)` is then executed\n    // ------------------------------------------------------------------------\n    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {\n        allowed[msg.sender][spender] = tokens;\n        Approval(msg.sender, spender, tokens);\n        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);\n        return true;\n    }\n\n\n    // ------------------------------------------------------------------------\n    // Don\u0027t accept ETH\n    // ------------------------------------------------------------------------\n    function () public payable {\n        revert();\n    }\n\n\n    // ------------------------------------------------------------------------\n    // Owner can transfer out any accidentally sent ERC20 tokens\n    // ------------------------------------------------------------------------\n    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {\n        return ERC20Interface(tokenAddress).transfer(owner, tokens);\n    }\n}"},"mxx.sol":{"content":"pragma solidity \u003e=0.4.22 \u003c0.6.0;\n\nimport \"./erc20.sol\";\n\n// ----------------------------------------------------------------------------\n// \u0027MXX\u0027 token contract\n// Symbol      : MXX\n// Name        : Multiplier\n// Total supply: 9,000,000,000.00000000\n// Decimals    : 8\n// ----------------------------------------------------------------------------\n\ncontract Mxx is ERC20Token {\n\n    uint public _currentSupply;\n    address public mintAddress;\n    \n    event Mint(address indexed to, uint tokens);\n    event Burn(address indexed from, uint tokens);\n\n\n    modifier onlyMint {\n        require(msg.sender == owner || msg.sender == mintAddress);\n        _;\n    }\n\n    // ------------------------------------------------------------------------\n    // Constructor\n    // ------------------------------------------------------------------------\n    function Mxx() public {\n        symbol = \"MXX\";\n        name = \"Multiplier\";\n        decimals = 8;\n        _totalSupply = 9000000000 * 10**uint(decimals);\n    }\n\n    // ------------------------------------------------------------------------\n    // Owner can mint ERC20 tokens to recipient address\n    // _currentSupply increase\n    // balances[recipient] increase\n    // ------------------------------------------------------------------------       \n    function mint(address recipient, uint256 amount)\n        onlyMint \n        public\n    {\n        require(amount \u003e 0);\n        require(_currentSupply + amount \u003c= _totalSupply);\n        \n        _currentSupply = _currentSupply.add(amount);\n        balances[recipient] = balances[recipient].add(amount);\n        \n        emit Mint(recipient, amount);\n        emit Transfer(address(0), recipient, amount);\n    }\n  \n    // ------------------------------------------------------------------------\n    // Owner can burn ERC20 tokens to addres(0)\n    // _totalSupply decrease\n    // _currentSupply decrease\n    // balanceOf msg.sender decrease\n    // balanceOf addres(0) increase\n    // ------------------------------------------------------------------------    \n    function burn(uint256 amount) \n        onlyOwner\n        public \n    {\n        require(amount \u003e 0);\n        require(balances[msg.sender] \u003e= amount);\n        \n        balances[msg.sender] = balances[msg.sender].sub(amount);\n        balances[address(0)] = balances[address(0)].add(amount);\n        _totalSupply = _totalSupply.sub(amount);\n        _currentSupply = _currentSupply.sub(amount);\n        \n        emit Burn(msg.sender, amount);\n        emit Transfer(msg.sender, address(0), amount);\n    }    \n    \n    // Owner can change mint role\n    function changeMintRole(address addr)  \n        onlyOwner\n        public\n    {\n        require(addr != address(0x0));\n        require(addr != address(this));\n        \n        mintAddress = addr;\n    }\n}\n"}}