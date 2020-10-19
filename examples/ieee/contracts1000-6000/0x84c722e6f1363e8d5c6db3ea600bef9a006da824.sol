{"ERC20Interface.sol":{"content":"pragma solidity ^0.5.9;\n\ncontract ERC20Interface\n{\n    event Transfer( address indexed _from, address indexed _to, uint _value);\n    event Approval( address indexed _owner, address indexed _spender, uint _value);\n    \n    function totalSupply() view public returns (uint _supply);\n    function balanceOf( address _who ) public view returns (uint _value);\n    function transfer( address _to, uint _value) public returns (bool _success);\n    function approve( address _spender, uint _value ) public returns (bool _success);\n    function allowance( address _owner, address _spender ) public view returns (uint _allowance);\n    function transferFrom( address _from, address _to, uint _value) public returns (bool _success);\n}"},"MisBloc.sol":{"content":"pragma solidity ^0.5.9;\n\nimport \"./ERC20Interface.sol\";\nimport \"./OwnerHelper.sol\";\nimport \"./SafeMath.sol\";\n\ncontract MisBloc  is ERC20Interface, OwnerHelper\n{\n    using SafeMath for uint;\n    \n    string public name;\n    uint public decimals;\n    string public symbol;\n    \n    uint constant private E18 = 1000000000000000000;\n    uint constant private month = 2592000;\n    \n    // Total                                      300,000,000\n    uint constant public maxTotalSupply         = 300000000 * E18;\n\n    // Sale                                        45,000,000 (15%)\n    uint constant public maxSaleSupply          =  45000000 * E18;\n\n    // Development                                 60,000,000 (20%)\n    uint constant public maxDevSupply           =  60000000 * E18;\n\n    // Marketing                                   66,000,000 (22%)\n    uint constant public maxMktSupply           =  66000000 * E18;\n\n    // Ecosystem                                   54,000,000 (18%)\n    uint constant public maxEcoSupply           =  54000000 * E18;\n\n    // Reserve                                     30,000,000 (10%)\n    uint constant public maxReserveSupply       =  30000000 * E18;\n\n    // Team                                        30,000,000 (10%)\n    uint constant public maxTeamSupply          =  30000000 * E18;\n\n    // Advisor                                     15,000,000 (5%)\n    uint constant public maxAdvisorSupply       =  15000000 * E18;\n    \n    uint constant public teamVestingSupply      = 1250000 * E18;\n    uint constant public teamVestingLockDate    = 12 * month;\n    uint constant public teamVestingTime        = 24;\n\n    uint constant public advisorVestingSupply   = 1250000 * E18;\n    uint constant public advisorVestingLockDate = 12 * month;\n    uint constant public advisorVestingTime     = 12;\n    \n    uint public totalTokenSupply;\n    uint public tokenIssuedSale;\n    uint public tokenIssuedDev;\n    uint public tokenIssuedMkt;\n    uint public tokenIssuedEco;\n    uint public tokenIssuedRsv;\n    uint public tokenIssuedTeam;\n    uint public tokenIssuedAdv;\n    \n    uint public burnTokenSupply;\n    \n    mapping (address =\u003e uint) public balances;\n    mapping (address =\u003e mapping ( address =\u003e uint )) public approvals;\n\n    mapping (address =\u003e uint) public lockWallet;\n    \n    mapping (uint =\u003e uint) public tmVestingTimer;\n    mapping (uint =\u003e uint) public tmVestingBalances;\n    mapping (uint =\u003e uint) public advVestingTimer;\n    mapping (uint =\u003e uint) public advVestingBalances;\n        \n    bool public tokenLock = true;\n    bool public saleTime = true;\n    uint public endSaleTime = 0;\n\n    event SaleIssue(address indexed _to, uint _tokens);\n    event DevIssue(address indexed _to, uint _tokens);\n    event MktIssue(address indexed _to, uint _tokens);\n    event EcoIssue(address indexed _to, uint _tokens);\n    event RsvIssue(address indexed _to, uint _tokens);\n    event TeamIssue(address indexed _to, uint _tokens);\n    event AdvIssue(address indexed _to, uint _tokens);\n\n    event Burn(address indexed _from, uint _tokens);\n    \n    event TokenUnLock(address indexed _to, uint _tokens);\n    event EndSale(uint _date);\n    \n    constructor() public\n    {\n        name        = \"MISBLOC\";\n        decimals    = 18;\n        symbol      = \"MSB\";\n        \n        totalTokenSupply = 300000000 * E18;\n        balances[owner] = totalTokenSupply;\n\n        tokenIssuedSale     = 0;\n        tokenIssuedDev      = 0;\n        tokenIssuedMkt      = 0;\n        tokenIssuedEco      = 0;\n        tokenIssuedRsv      = 0;\n        tokenIssuedTeam     = 0;\n        tokenIssuedAdv      = 0;     \n\n        burnTokenSupply     = 0;\n        \n        require(maxTotalSupply == maxSaleSupply + maxDevSupply + maxMktSupply + maxEcoSupply + maxReserveSupply + maxTeamSupply + maxAdvisorSupply);\n    }\n\n    function totalSupply() view public returns (uint) \n    {\n        return totalTokenSupply;\n    }\n    \n    function balanceOf(address _who) view public returns (uint) \n    {\n        uint balance = balances[_who];\n        \n        balance = balance.add(lockWallet[_who]);\n        \n        return balance;\n    }\n    \n    function transfer(address _to, uint _value) public returns (bool) \n    {\n        require(isTransferable() == true);\n        require(balances[msg.sender] \u003e= _value);\n        \n        balances[msg.sender] = balances[msg.sender].sub(_value);\n        balances[_to] = balances[_to].add(_value);\n        \n        emit Transfer(msg.sender, _to, _value);\n        \n        return true;\n    }\n    \n    function approve(address _spender, uint _value) public returns (bool)\n    {\n        require(isTransferable() == true);\n        require(balances[msg.sender] \u003e= _value);\n        \n        approvals[msg.sender][_spender] = _value;\n        \n        emit Approval(msg.sender, _spender, _value);\n        \n        return true; \n    }\n    \n    function allowance(address _owner, address _spender) view public returns (uint) \n    {\n        return approvals[_owner][_spender];\n    }\n\n    function transferFrom(address _from, address _to, uint _value) public returns (bool) \n    {\n        require(isTransferable() == true);\n        require(balances[_from] \u003e= _value);\n        require(approvals[_from][msg.sender] \u003e= _value);\n        \n        approvals[_from][msg.sender] = approvals[_from][msg.sender].sub(_value);\n        balances[_from] = balances[_from].sub(_value);\n        balances[_to]  = balances[_to].add(_value);\n        \n        emit Transfer(_from, _to, _value);\n        \n        return true;\n    }\n        \n    function saleIssue(address _to, uint _value) onlyOwner public\n    {   \n        uint tokens = _value * E18;\n        require(maxSaleSupply \u003e= tokenIssuedSale.add(tokens));\n                \n        balances[msg.sender] = balances[msg.sender].sub(tokens);\n        balances[_to] = balances[_to].add(tokens);\n        tokenIssuedSale = tokenIssuedSale.add(tokens);\n        \n        emit SaleIssue(_to, tokens);\n\n        emit Transfer(msg.sender, _to, tokens);\n    }\n    \n    function devIssue(address _to, uint _value) onlyOwner public\n    {\n        uint tokens = _value * E18;\n        require(saleTime == false);\n        require(maxDevSupply \u003e= tokenIssuedDev.add(tokens));        \n        \n        balances[msg.sender] = balances[msg.sender].sub(tokens);\n        balances[_to] = balances[_to].add(tokens);\n        tokenIssuedDev = tokenIssuedDev.add(tokens);\n        \n        emit DevIssue(_to, tokens);\n\n        emit Transfer(msg.sender, _to, tokens);\n    }\n\n    function mktIssue(address _to, uint _value) onlyOwner public\n    {\n        uint tokens = _value * E18;\n        require(saleTime == false);\n        require(maxMktSupply \u003e= tokenIssuedMkt.add(tokens));        \n\n        balances[msg.sender] = balances[msg.sender].sub(tokens);\n        balances[_to] = balances[_to].add(tokens);\n        tokenIssuedMkt = tokenIssuedMkt.add(tokens);\n        \n        emit MktIssue(_to, tokens);\n\n        emit Transfer(msg.sender, _to, tokens);\n    }\n    \n    function ecoIssue(address _to, uint _value) onlyOwner public\n    {\n        uint tokens = _value * E18;\n        require(saleTime == false);\n        require(maxEcoSupply \u003e= tokenIssuedEco.add(tokens));\n        \n        balances[msg.sender] = balances[msg.sender].sub(tokens);\n        balances[_to] = balances[_to].add(tokens);\n        tokenIssuedEco = tokenIssuedEco.add(tokens);\n        \n        emit EcoIssue(_to, tokens);\n\n        emit Transfer(msg.sender, _to, tokens);\n    }\n\n    function rsvIssue(address _to, uint _value) onlyOwner public\n    {\n        uint tokens = _value * E18;\n        require(saleTime == false);\n        require(maxReserveSupply \u003e= tokenIssuedRsv.add(tokens));\n        \n        balances[msg.sender] = balances[msg.sender].sub(tokens);\n        balances[_to] = balances[_to].add(tokens);\n        tokenIssuedRsv = tokenIssuedRsv.add(tokens);\n        \n        emit RsvIssue(_to, tokens);\n\n        emit Transfer(msg.sender, _to, tokens);\n    }\n\n    function teamIssue(address _to) onlyOwner public\n    {\n        require(saleTime == false);\n        require(tokenIssuedTeam == 0);\n        \n        uint tokens = maxTeamSupply;\n\n        balances[msg.sender] = balances[msg.sender].sub(tokens);\n\n        lockWallet[_to]    = lockWallet[_to].add(maxTeamSupply);\n        \n        tokenIssuedTeam = tokenIssuedTeam.add(tokens);\n                \n        emit TeamIssue(_to, tokens);\n\n        emit Transfer(msg.sender, _to, tokens);\n    }\n\n    function advisorIssue(address _to) onlyOwner public\n    {\n        require(saleTime == false);\n        require(tokenIssuedAdv == 0);\n        \n        uint tokens = maxAdvisorSupply;\n\n        balances[msg.sender] = balances[msg.sender].sub(tokens);\n\n        lockWallet[_to]    = lockWallet[_to].add(maxAdvisorSupply);\n\n        tokenIssuedAdv = tokenIssuedAdv.add(tokens);\n        \n        emit AdvIssue(_to, tokens);\n\n        emit Transfer(msg.sender, _to, tokens);\n    }   \n        \n    function teamUnlock(address _to, uint _time) onlyManager public\n    {\n        require(saleTime == false);\n        require( _time \u003c teamVestingTime);\n        \n        uint nowTime = now;\n        require( nowTime \u003e tmVestingTimer[_time] );\n        \n        uint tokens = teamVestingSupply;\n\n        require(tokens == tmVestingBalances[_time]);\n        require(lockWallet[_to] \u003e 0);\n        \n        balances[_to] = balances[_to].add(tokens);\n        tmVestingBalances[_time] = 0;\n        lockWallet[_to] = lockWallet[_to].sub(tokens);\n        \n        emit TokenUnLock(_to, tokens);\n\n        emit Transfer(msg.sender, _to, tokens);\n    }\n\n    function advisorUnlock(address _to, uint _time) onlyManager public\n    {\n        require(saleTime == false);\n        require( _time \u003c advisorVestingTime);\n        \n        uint nowTime = now;\n        require( nowTime \u003e advVestingTimer[_time] );\n        \n        uint tokens = advisorVestingSupply;\n\n        require(tokens == advVestingBalances[_time]);\n        require(lockWallet[_to] \u003e 0);\n        \n        balances[_to] = balances[_to].add(tokens);\n        advVestingBalances[_time] = 0;\n        lockWallet[_to] = lockWallet[_to].sub(tokens);\n        \n        emit TokenUnLock(_to, tokens);\n\n        emit Transfer(msg.sender, _to, tokens);\n    }\n\n    function endSale() onlyOwner public\n    {\n        require(saleTime == true);\n        \n        saleTime = false;\n        \n        uint nowTime = now;\n        endSaleTime = nowTime;\n        \n        for(uint i = 0; i \u003c teamVestingTime; i++)\n        {\n            tmVestingTimer[i] = endSaleTime + teamVestingLockDate + (i * month);\n            tmVestingBalances[i] = teamVestingSupply;\n        }\n        \n        for(uint i = 0; i \u003c advisorVestingTime; i++)\n        {\n            advVestingTimer[i] = endSaleTime + advisorVestingLockDate + (i * advisorVestingLockDate);\n            advVestingBalances[i] = advisorVestingSupply;\n        }\n        \n        emit EndSale(endSaleTime);\n    }\n\n    function setTokenUnlock() onlyManager public\n    {\n        require(tokenLock == true);\n        require(saleTime == false);\n        \n        tokenLock = false;\n    }\n    \n    function setTokenLock() onlyManager public\n    {\n        require(tokenLock == false);\n        \n        tokenLock = true;\n    }\n    \n    function isTransferable() private view returns (bool)\n    {\n        if(tokenLock == false)\n        {\n            return true;\n        }\n        else if(msg.sender == owner)\n        {\n            return true;\n        }\n        \n        return false;\n    }\n\n    function transferAnyERC20Token(address tokenAddress, uint tokens) onlyOwner public returns (bool success)\n    {\n        return ERC20Interface(tokenAddress).transfer(manager, tokens);\n    }\n    \n    function burnToken(uint _value) onlyManager public\n    {\n        uint tokens = _value * E18;\n        \n        require(balances[msg.sender] \u003e= tokens);\n        \n        balances[msg.sender] = balances[msg.sender].sub(tokens);\n        burnTokenSupply = burnTokenSupply.add(tokens);\n        totalTokenSupply = totalTokenSupply.sub(tokens);\n        \n        emit Burn(msg.sender, tokens);\n    }\n    \n    function close() onlyOwner public\n    {\n        selfdestruct(msg.sender);\n    }\n    \n}"},"OwnerHelper.sol":{"content":"pragma solidity ^0.5.9;\n\ncontract OwnerHelper\n{\n  \taddress public owner;\n    address public manager;\n\n  \tevent ChangeOwner(address indexed _from, address indexed _to);\n    event ChangeManager(address indexed _from, address indexed _to);\n\n  \tmodifier onlyOwner\n\t{\n\t\trequire(msg.sender == owner);\n\t\t_;\n  \t}\n  \t\n    modifier onlyManager\n    {\n        require(msg.sender == manager);\n        _;\n    }\n\n  \tconstructor() public\n\t{\n\t\towner = msg.sender;\n  \t}\n  \t\n  \tfunction transferOwnership(address _to) onlyOwner public\n  \t{\n    \trequire(_to != owner);\n        require(_to != manager);\n    \trequire(_to != address(0x0));\n\n        address from = owner;\n      \towner = _to;\n  \t    \n      \temit ChangeOwner(from, _to);\n  \t}\n\n    function transferManager(address _to) onlyOwner public\n    {\n        require(_to != owner);\n        require(_to != manager);\n        require(_to != address(0x0));\n        \n        address from = manager;\n        manager = _to;\n        \n        emit ChangeManager(from, _to);\n    }\n}"},"SafeMath.sol":{"content":"pragma solidity ^0.5.9;\n\nlibrary SafeMath\n{\n\n  function mul(uint256 a, uint256 b) internal pure returns (uint256)\n    \t{\n\t\tuint256 c = a * b;\n\t\tassert(a == 0 || c / a == b);\n\n\t\treturn c;\n  \t}\n\n  \tfunction div(uint256 a, uint256 b) internal pure returns (uint256)\n\t{\n\t\tuint256 c = a / b;\n\n\t\treturn c;\n  \t}\n\n  \tfunction sub(uint256 a, uint256 b) internal pure returns (uint256)\n\t{\n\t\tassert(b \u003c= a);\n\n\t\treturn a - b;\n  \t}\n\n  \tfunction add(uint256 a, uint256 b) internal pure returns (uint256)\n\t{\n\t\tuint256 c = a + b;\n\t\tassert(c \u003e= a);\n\n\t\treturn c;\n  \t}\n}"}}