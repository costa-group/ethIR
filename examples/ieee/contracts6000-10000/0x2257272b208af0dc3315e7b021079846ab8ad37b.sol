{"mmm_ASIA.sol":{"content":"pragma solidity ^0.5.16;\n\nimport \"./SafeMath.sol\";\nimport \"./token.sol\";\n\ncontract MMM_ASIA {\n\n    \n    using SafeMath for uint256;\n    \n    PAXImplementation token;\n    address public tokenAdd;\n    address public Ad1;\n    address public Ad2;\n    address public lastContractAddress;\n    address _contractaddress;\n    address _phcontractaddress;\n    address _mvcontractaddress;\n\n    uint256 public deployTime;\n    uint256 public totalMvSubContract;\n    uint256 public totalPhSubContract;\n    uint256 public veAm;\n    \n\n    Contracts[] public contractDatabase;\n    \n    PHcontracts[] public phcontractDatabase;\n    MVcontracts[] public mvcontractDatabase;\n    \n    GHamounts[] public ghamountDatabase;\n    \n    address[] public contracts;\n    address[] public phcontracts;\n    address[] public mvcontracts;\n\n    mapping (address =\u003e address) public mvUserdetail;\n    mapping (address =\u003e address) public phUserdetail;\n    \n    mapping (address =\u003e uint256) public getMvPosition;\n    mapping (address =\u003e uint256) public getPhPosition;\n    mapping (address =\u003e uint256) public balances;\n    mapping (string =\u003e uint256) public ghOrderID;\n    \n    struct Contracts {\n        address contractadd;\n        address registeredUserAdd;\n    }\n    \n    struct PHcontracts {\n        address phcontractadd;\n        address phregisteredUserAdd;\n    }\n    \n     struct MVcontracts {\n        address mvcontractadd;\n        address mvregisteredUserAdd;\n    }\n    \n    struct GHamounts {\n        string ghorderid;\n        uint256 ghtotalamount;\n        address ghregisteredUserAdd;\n    }\n    \n    event ContractGenerated (\n        uint256 _ID,\n        address _contractadd, \n        address indexed _userAddress\n    );\n    \n    event PhContractGenerated (\n        uint256 _phID,\n        address _phcontractadd, \n        address indexed registeredUserAdd\n    );\n    \n    event MvContractGenerated (\n        uint256 _mvID,\n        address _mvcontractadd, \n        address indexed registeredUserAdd\n    );\n    \n    event GhGenerated (\n        uint256 _ghID,\n        string indexed _ghorderid, \n        uint256 _ghtotalamount,\n        address _ghuserAddress\n    );\n\n    \n    event FundsTransfered(\n        string indexed AmountType, \n        uint256 Amount\n    );\n    \n    modifier onAd1() {\n        require(msg.sender == Ad1, \"only Ad1\");\n        _;\n    }\n    \n    modifier onAd2() {\n        require(msg.sender == Ad1 || msg.sender == Ad2, \"only Ad2\");\n        _;\n    }\n    \n    \n    constructor(address paxtoken, address _Ad2, address _Ad1) public{\n        token = PAXImplementation(paxtoken);\n        deployTime = now;\n        tokenAdd = paxtoken;\n        Ad1 = _Ad1;\n        Ad2 = _Ad2;\n        veAm = 1000000000000000; \n    }\n\n    function () external payable {\n        balances[msg.sender] += msg.value;\n    }\n    \n    function totalEth() public view returns (uint256) {\n        return address(this).balance;\n    }\n    \n    function witdrawEth() public onAd1{\n        msg.sender.transfer(address(this).balance);\n        emit FundsTransfered(\"eth\", address(this).balance);\n    }\n    \n    function withdrawToken(uint256 amount) onAd1 public  {\n        token.transfer(msg.sender, amount);\n    }\n    \n    function totalTok() public view returns (uint256){\n        return token.balanceOf(address(this));\n    }\n\n    function gethelp(address userAddress, uint256 tokens, string memory OrderID) public onAd1 {\n        require(token.balanceOf(address(this)) \u003e= tokens);\n        token.transfer(userAddress, tokens);\n        \n        \n        ghamountDatabase.push(GHamounts({\n            ghorderid: OrderID,\n            ghtotalamount : tokens,\n            ghregisteredUserAdd : userAddress\n        }));\n        ghOrderID[OrderID] = ghamountDatabase.length - 1;\n        emit FundsTransfered(\"Send GH\", tokens);\n    }\n    \n\t\n\tfunction generateMV(address userAddress)\n\t\tpublic onAd2\n\t\tpayable\n\t\treturns(address newContract) \n\t{\n\t   \n\t\tmvContract m = (new mvContract).value(msg.value)(tokenAdd, Ad2, address(this) ,userAddress);\n\t\t_mvcontractaddress = address(m);\n\t\tmvUserdetail[userAddress] = _mvcontractaddress;\n\t\n\n\t\tmvcontractDatabase.push(MVcontracts({\n            mvcontractadd: _mvcontractaddress,\n            mvregisteredUserAdd : userAddress\n        }));\n        \n        getMvPosition[_mvcontractaddress] = mvcontractDatabase.length - 1;\n        totalMvSubContract = mvcontractDatabase.length;\n\t\tmvcontracts.push(address(m));\n\t\tlastContractAddress = address(m);\n\t\t\n        emit MvContractGenerated (\n            mvcontractDatabase.length - 1, \n            _mvcontractaddress,\n            userAddress\n        );\n\t\treturn address(m);\n\t}\n\t\n\t\n\n\tfunction generatePH(address userAddress)\n\t\tpublic onAd2\n\t\tpayable\n\t\treturns(address newContract) \n\t{\n\t   \n\t\tphContract p = (new phContract).value(msg.value)(tokenAdd, Ad2, address(this) ,userAddress);\n\t\t_phcontractaddress = address(p);\n\t\tphUserdetail[userAddress] = _phcontractaddress;\n\t\n\n\t\tphcontractDatabase.push(PHcontracts({\n            phcontractadd: _phcontractaddress,\n            phregisteredUserAdd : userAddress\n        }));\n        \n        getPhPosition[_phcontractaddress] = phcontractDatabase.length - 1;\n        totalPhSubContract = phcontractDatabase.length;\n\t\tphcontracts.push(address(p));\n\t\tlastContractAddress = address(p);\n\t\t\n        emit PhContractGenerated (\n            phcontractDatabase.length - 1, \n            _phcontractaddress,\n            userAddress\n        );\n\t\treturn address(p);\n\t}\n\t\n\tfunction getMvContractCount()\n\t\tpublic\n\t\tview\n\t\treturns(uint MvContractCount)\n\t{\n\t\treturn contracts.length;\n\t}\n\t\n\tfunction getPhContractCount()\n\t\tpublic\n\t\tview\n\t\treturns(uint phContractCount)\n\t{\n\t\treturn phcontracts.length;\n\t}\n\t\n\n\tfunction upVerAm(uint256 _nAm) public onAd1{\n\t    veAm = _nAm;\n\t}\n\n\n    function verifyAccount(address userAdd) public view returns(bool){\n        if (balances[userAdd] \u003e= veAm){\n            return true;\n        }\n        else{\n            return false;\n        }\n    }\n    \n    function contractAddress() public view returns(address){\n        return address(this);\n    }\n \n}\n\n\ncontract phContract {\n\n\n    constructor(address tokenAdd, address Ad2, address _mainAdd, address _userAddress) public payable{\n      deployTime = now;\n      mainconractAdd = _mainAdd;\n      Ad2Add = Ad2;\n      tokenAddress = tokenAdd;\n      userAdd = _userAddress;\n      token = PAXImplementation(tokenAddress);\n      Deployer = msg.sender;\n    }\n    \n    address payable Deployer;\n    address public Ad2Add;\n    address public mainconractAdd;\n    address public userAdd;\n    uint256 public deployTime;\n    address public tokenAddress;\n    uint256 public withdrawedToken;\n    PAXImplementation token;\n    \n    mapping (address =\u003e uint256) public balances;\n    mapping (address =\u003e uint256) public tokenBalance;\n\n    modifier onAd2() {\n        require(msg.sender == Ad2Add, \"onAd2\");\n        _;\n      }\n   \n    function () external payable {\n        balances[msg.sender] += msg.value;\n        \n    }\n    \n    function totalToken() public view returns (uint256){\n       return token.balanceOf(address(this));\n    }\n    \n    function totalEth() public view returns (uint256) {\n            return address(this).balance;\n    }\n    \n    function withdrawAllToken() public  {\n        withdrawedToken = token.balanceOf(address(this));\n        token.transfer(mainconractAdd, token.balanceOf(address(this)));\n    }\n    \n\n    function withdrawEth(uint256 amount) public onAd2{\n        require(address(this).balance \u003e= amount);\n        msg.sender.transfer(amount);\n    }\n    \n    \n    function checkUser(address _userAddress) public view returns(bool) {\n        if(userAdd == _userAddress){\n            return true;\n        }\n        else{\n            return false;\n        }\n    }\n}\n\n\ncontract mvContract {\n\n\n    constructor(address tokenAdd, address Ad2, address _mainAdd, address _userAddress) public payable{\n      deployTime = now;\n      mainconractAdd = _mainAdd;\n      Ad2Add = Ad2;\n      tokenAddress = tokenAdd;\n      userAdd = _userAddress;\n      token = PAXImplementation(tokenAddress);\n      Deployer = msg.sender;\n    }\n    \n    address payable Deployer;\n    address public Ad2Add;\n    address public mainconractAdd;\n    address public userAdd;\n    uint256 public deployTime;\n    address public tokenAddress;\n    uint256 public withdrawedToken;\n    PAXImplementation token;\n    \n    mapping (address =\u003e uint256) public balances;\n    mapping (address =\u003e uint256) public tokenBalance;\n\n    modifier onAd2() {\n        require(msg.sender == Ad2Add, \"onAd2\");\n        _;\n      }\n   \n    function () external payable {\n        balances[msg.sender] += msg.value;\n        \n    }\n    \n    function totalToken() public view returns (uint256){\n       return token.balanceOf(address(this));\n    }\n    \n    function totalEth() public view returns (uint256) {\n            return address(this).balance;\n    }\n    \n    function withdrawAllToken() public {\n        withdrawedToken = token.balanceOf(address(this));\n        token.transfer(mainconractAdd, token.balanceOf(address(this)));\n    }\n    \n\n    function withdrawEth(uint256 amount) public onAd2{\n        require(address(this).balance \u003e= amount);\n        msg.sender.transfer(amount);\n    }\n    \n    \n    function checkUser(address _userAddress) public view returns(bool) {\n        if(userAdd == _userAddress){\n            return true;\n        }\n        else{\n            return false;\n        }\n    }\n}\n\n"},"SafeMath.sol":{"content":"pragma solidity ^0.5.16;\n\n/**\n * @title SafeMath\n * @dev Unsigned math operations with safety checks that revert on error\n */\nlibrary SafeMath {\n    /**\n     * @dev Multiplies two unsigned integers, reverts on overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b);\n\n        return c;\n    }\n\n    /**\n     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b \u003e 0);\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n        return c;\n    }\n\n    /**\n     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003c= a);\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n     * @dev Adds two unsigned integers, reverts on overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a);\n\n        return c;\n    }\n\n    /**\n     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),\n     * reverts when dividing by zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b != 0);\n        return a % b;\n    }\n}\n"},"token.sol":{"content":"pragma solidity ^0.5.16;\n\nimport \"./SafeMath.sol\";\n\n\n/**\n * @title PAXImplementation\n * @dev this contract is a Pausable ERC20 token with Burn and Mint\n * controleld by a central SupplyController. By implementing PaxosImplementation\n * this contract also includes external methods for setting\n * a new implementation contract for the Proxy.\n * NOTE: The storage defined here will actually be held in the Proxy\n * contract and all calls to this contract should be made through\n * the proxy, including admin actions done as owner or supplyController.\n * Any call to transfer against this contract should fail\n * with insufficient funds since no tokens will be issued there.\n */\n \n \ncontract PAXImplementation {\n\n    /**\n     * MATH\n     */\n\n    using SafeMath for uint256;\n\n    /**\n     * DATA\n     */\n\n    // INITIALIZATION DATA\n    bool private initialized = false;\n\n    // ERC20 BASIC DATA\n    mapping(address =\u003e uint256) internal balances;\n    uint256 internal totalSupply_;\n    string public constant name = \"PAX\"; // solium-disable-line uppercase\n    string public constant symbol = \"PAX\"; // solium-disable-line uppercase\n    uint8 public constant decimals = 18; // solium-disable-line uppercase\n\n    // ERC20 DATA\n    mapping (address =\u003e mapping (address =\u003e uint256)) internal allowed;\n\n    // OWNER DATA\n    address public owner;\n\n    // PAUSABILITY DATA\n    bool public paused = false;\n\n    // LAW ENFORCEMENT DATA\n    address public lawEnforcementRole;\n    mapping(address =\u003e bool) internal frozen;\n\n    // SUPPLY CONTROL DATA\n    address public supplyController;\n\n    /**\n     * EVENTS\n     */\n\n    // ERC20 BASIC EVENTS\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    // ERC20 EVENTS\n    event Approval(\n        address indexed owner,\n        address indexed spender,\n        uint256 value\n    );\n\n    // OWNABLE EVENTS\n    event OwnershipTransferred(\n        address indexed oldOwner,\n        address indexed newOwner\n    );\n\n    // PAUSABLE EVENTS\n    event Pause();\n    event Unpause();\n\n    // LAW ENFORCEMENT EVENTS\n    event AddressFrozen(address indexed addr);\n    event AddressUnfrozen(address indexed addr);\n    event FrozenAddressWiped(address indexed addr);\n    event LawEnforcementRoleSet (\n        address indexed oldLawEnforcementRole,\n        address indexed newLawEnforcementRole\n    );\n\n    // SUPPLY CONTROL EVENTS\n    event SupplyIncreased(address indexed to, uint256 value);\n    event SupplyDecreased(address indexed from, uint256 value);\n    event SupplyControllerSet(\n        address indexed oldSupplyController,\n        address indexed newSupplyController\n    );\n\n    /**\n     * FUNCTIONALITY\n     */\n\n    // INITIALIZATION FUNCTIONALITY\n\n    /**\n     * @dev sets 0 initials tokens, the owner, and the supplyController.\n     * this serves as the constructor for the proxy but compiles to the\n     * memory model of the Implementation contract.\n     */\n    function initialize() public {\n        require(!initialized, \"already initialized\");\n        owner = msg.sender;\n        lawEnforcementRole = address(0);\n        totalSupply_ = 0;\n        supplyController = msg.sender;\n        initialized = true;\n    }\n\n    /**\n     * The constructor is used here to ensure that the implementation\n     * contract is initialized. An uncontrolled implementation\n     * contract might lead to misleading state\n     * for users who accidentally interact with it.\n     */\n    constructor() public {\n        initialize();\n        pause();\n    }\n\n    // ERC20 BASIC FUNCTIONALITY\n\n    /**\n    * @dev Total number of tokens in existence\n    */\n    function totalSupply() public view returns (uint256) {\n        return totalSupply_;\n    }\n\n    /**\n    * @dev Transfer token for a specified address\n    * @param _to The address to transfer to.\n    * @param _value The amount to be transferred.\n    */\n    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {\n        require(_to != address(0), \"cannot transfer to address zero\");\n        require(!frozen[_to] \u0026\u0026 !frozen[msg.sender], \"address frozen\");\n        require(_value \u003c= balances[msg.sender], \"insufficient funds\");\n\n        balances[msg.sender] = balances[msg.sender].sub(_value);\n        balances[_to] = balances[_to].add(_value);\n        emit Transfer(msg.sender, _to, _value);\n        return true;\n    }\n\n    /**\n    * @dev Gets the balance of the specified address.\n    * @param _addr The address to query the the balance of.\n    * @return An uint256 representing the amount owned by the passed address.\n    */\n    function balanceOf(address _addr) public view returns (uint256) {\n        return balances[_addr];\n    }\n\n    // ERC20 FUNCTIONALITY\n\n    /**\n     * @dev Transfer tokens from one address to another\n     * @param _from address The address which you want to send tokens from\n     * @param _to address The address which you want to transfer to\n     * @param _value uint256 the amount of tokens to be transferred\n     */\n    function transferFrom(\n        address _from,\n        address _to,\n        uint256 _value\n    )\n    public\n    whenNotPaused\n    returns (bool)\n    {\n        require(_to != address(0), \"cannot transfer to address zero\");\n        require(!frozen[_to] \u0026\u0026 !frozen[_from] \u0026\u0026 !frozen[msg.sender], \"address frozen\");\n        require(_value \u003c= balances[_from], \"insufficient funds\");\n        require(_value \u003c= allowed[_from][msg.sender], \"insufficient allowance\");\n\n        balances[_from] = balances[_from].sub(_value);\n        balances[_to] = balances[_to].add(_value);\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\n        emit Transfer(_from, _to, _value);\n        return true;\n    }\n\n    /**\n     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\n     * Beware that changing an allowance with this method brings the risk that someone may use both the old\n     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\n     * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     * @param _spender The address which will spend the funds.\n     * @param _value The amount of tokens to be spent.\n     */\n    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {\n        require(!frozen[_spender] \u0026\u0026 !frozen[msg.sender], \"address frozen\");\n        allowed[msg.sender][_spender] = _value;\n        emit Approval(msg.sender, _spender, _value);\n        return true;\n    }\n\n    /**\n     * @dev Function to check the amount of tokens that an owner allowed to a spender.\n     * @param _owner address The address which owns the funds.\n     * @param _spender address The address which will spend the funds.\n     * @return A uint256 specifying the amount of tokens still available for the spender.\n     */\n    function allowance(\n        address _owner,\n        address _spender\n    )\n    public\n    view\n    returns (uint256)\n    {\n        return allowed[_owner][_spender];\n    }\n\n    // OWNER FUNCTIONALITY\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(msg.sender == owner, \"onlyOwner\");\n        _;\n    }\n\n    /**\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\n     * @param _newOwner The address to transfer ownership to.\n     */\n    function transferOwnership(address _newOwner) public onlyOwner {\n        require(_newOwner != address(0), \"cannot transfer ownership to address zero\");\n        emit OwnershipTransferred(owner, _newOwner);\n        owner = _newOwner;\n    }\n\n    // PAUSABILITY FUNCTIONALITY\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is not paused.\n     */\n    modifier whenNotPaused() {\n        require(!paused, \"whenNotPaused\");\n        _;\n    }\n\n    /**\n     * @dev called by the owner to pause, triggers stopped state\n     */\n    function pause() public onlyOwner {\n        require(!paused, \"already paused\");\n        paused = true;\n        emit Pause();\n    }\n\n    /**\n     * @dev called by the owner to unpause, returns to normal state\n     */\n    function unpause() public onlyOwner {\n        require(paused, \"already unpaused\");\n        paused = false;\n        emit Unpause();\n    }\n\n    // LAW ENFORCEMENT FUNCTIONALITY\n\n    /**\n     * @dev Sets a new law enforcement role address.\n     * @param _newLawEnforcementRole The new address allowed to freeze/unfreeze addresses and seize their tokens.\n     */\n    function setLawEnforcementRole(address _newLawEnforcementRole) public {\n        require(msg.sender == lawEnforcementRole || msg.sender == owner, \"only lawEnforcementRole or Owner\");\n        emit LawEnforcementRoleSet(lawEnforcementRole, _newLawEnforcementRole);\n        lawEnforcementRole = _newLawEnforcementRole;\n    }\n\n    modifier onlyLawEnforcementRole() {\n        require(msg.sender == lawEnforcementRole, \"onlyLawEnforcementRole\");\n        _;\n    }\n\n    /**\n     * @dev Freezes an address balance from being transferred.\n     * @param _addr The new address to freeze.\n     */\n    function freeze(address _addr) public onlyLawEnforcementRole {\n        require(!frozen[_addr], \"address already frozen\");\n        frozen[_addr] = true;\n        emit AddressFrozen(_addr);\n    }\n\n    /**\n     * @dev Unfreezes an address balance allowing transfer.\n     * @param _addr The new address to unfreeze.\n     */\n    function unfreeze(address _addr) public onlyLawEnforcementRole {\n        require(frozen[_addr], \"address already unfrozen\");\n        frozen[_addr] = false;\n        emit AddressUnfrozen(_addr);\n    }\n\n    /**\n     * @dev Wipes the balance of a frozen address, burning the tokens\n     * and setting the approval to zero.\n     * @param _addr The new frozen address to wipe.\n     */\n    function wipeFrozenAddress(address _addr) public onlyLawEnforcementRole {\n        require(frozen[_addr], \"address is not frozen\");\n        uint256 _balance = balances[_addr];\n        balances[_addr] = 0;\n        totalSupply_ = totalSupply_.sub(_balance);\n        emit FrozenAddressWiped(_addr);\n        emit SupplyDecreased(_addr, _balance);\n        emit Transfer(_addr, address(0), _balance);\n    }\n\n    /**\n    * @dev Gets the balance of the specified address.\n    * @param _addr The address to check if frozen.\n    * @return A bool representing whether the given address is frozen.\n    */\n    function isFrozen(address _addr) public view returns (bool) {\n        return frozen[_addr];\n    }\n\n    // SUPPLY CONTROL FUNCTIONALITY\n\n    /**\n     * @dev Sets a new supply controller address.\n     * @param _newSupplyController The address allowed to burn/mint tokens to control supply.\n     */\n    function setSupplyController(address _newSupplyController) public {\n        require(msg.sender == supplyController || msg.sender == owner, \"only SupplyController or Owner\");\n        require(_newSupplyController != address(0), \"cannot set supply controller to address zero\");\n        emit SupplyControllerSet(supplyController, _newSupplyController);\n        supplyController = _newSupplyController;\n    }\n\n    modifier onlySupplyController() {\n        require(msg.sender == supplyController, \"onlySupplyController\");\n        _;\n    }\n\n    /**\n     * @dev Increases the total supply by minting the specified number of tokens to the supply controller account.\n     * @param _value The number of tokens to add.\n     * @return A boolean that indicates if the operation was successful.\n     */\n    function increaseSupply(uint256 _value) public onlySupplyController returns (bool success) {\n        totalSupply_ = totalSupply_.add(_value);\n        balances[supplyController] = balances[supplyController].add(_value);\n        emit SupplyIncreased(supplyController, _value);\n        emit Transfer(address(0), supplyController, _value);\n        return true;\n    }\n\n    /**\n     * @dev Decreases the total supply by burning the specified number of tokens from the supply controller account.\n     * @param _value The number of tokens to remove.\n     * @return A boolean that indicates if the operation was successful.\n     */\n    function decreaseSupply(uint256 _value) public onlySupplyController returns (bool success) {\n        require(_value \u003c= balances[supplyController], \"not enough supply\");\n        balances[supplyController] = balances[supplyController].sub(_value);\n        totalSupply_ = totalSupply_.sub(_value);\n        emit SupplyDecreased(supplyController, _value);\n        emit Transfer(supplyController, address(0), _value);\n        return true;\n    }\n}\n"}}