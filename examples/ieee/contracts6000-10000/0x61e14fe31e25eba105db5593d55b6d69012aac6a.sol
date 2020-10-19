{"EthSwap.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./waviii.sol\";\n\ncontract EthSwap {\n  string public name = \"wavSwap\";\n  Token public token;\n  uint public rate = 100;\n\n  event TokensPurchased(\n    address account,\n    address token,\n    uint amount,\n    uint rate\n  );\n\n  event TokensSold(\n    address account,\n    address token,\n    uint amount,\n    uint rate\n  );\n\n  constructor(Token _token) public {\n    token = _token;\n  }\n\n  function buyTokens() public payable {\n    // Calculate the number of tokens to buy\n    uint tokenAmount = msg.value * rate;\n\n    // Require that EthSwap has enough tokens\n    require(token.balanceOf(address(this)) \u003e= tokenAmount);\n\n    // Transfer tokens to the user\n    token.transfer(msg.sender, tokenAmount);\n\n    // Emit an event\n    emit TokensPurchased(msg.sender, address(token), tokenAmount, rate);\n  }\n\n  function sellTokens(uint _amount) public {\n    // User can\u0027t sell more tokens than they have\n    require(token.balanceOf(msg.sender) \u003e= _amount);\n\n    // Calculate the amount of Ether to redeem\n    uint etherAmount = _amount / rate;\n\n    // Require that EthSwap has enough Ether\n    require(address(this).balance \u003e= etherAmount);\n\n    // Perform sale\n    token.transferFrom(msg.sender, address(this), _amount);\n    msg.sender.transfer(etherAmount);\n\n    // Emit an event\n    emit TokensSold(msg.sender, address(token), _amount, rate);\n  }\n\n}\n"},"waviii.sol":{"content":"pragma solidity ^0.5.0;\n\ncontract Token {\n    string  public name = \"waviii\";\n    string  public symbol = \"waviii\";\n    uint256 public totalSupply = 1000000000000000000000000; // 1 million tokens\n    uint8   public decimals = 18;\n\n    event Transfer(\n        address indexed _from,\n        address indexed _to,\n        uint256 _value\n    );\n\n    event Approval(\n        address indexed _owner,\n        address indexed _spender,\n        uint256 _value\n    );\n\n    mapping(address =\u003e uint256) public balanceOf;\n    mapping(address =\u003e mapping(address =\u003e uint256)) public allowance;\n\n    constructor() public {\n        balanceOf[msg.sender] = totalSupply;\n    }\n\n    function transfer(address _to, uint256 _value) public returns (bool success) {\n        require(balanceOf[msg.sender] \u003e= _value);\n        balanceOf[msg.sender] -= _value;\n        balanceOf[_to] += _value;\n        emit Transfer(msg.sender, _to, _value);\n        return true;\n    }\n\n    function approve(address _spender, uint256 _value) public returns (bool success) {\n        allowance[msg.sender][_spender] = _value;\n        emit Approval(msg.sender, _spender, _value);\n        return true;\n    }\n\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {\n        require(_value \u003c= balanceOf[_from]);\n        require(_value \u003c= allowance[_from][msg.sender]);\n        balanceOf[_from] -= _value;\n        balanceOf[_to] += _value;\n        allowance[_from][msg.sender] -= _value;\n        emit Transfer(_from, _to, _value);\n        return true;\n    }\n}"}}