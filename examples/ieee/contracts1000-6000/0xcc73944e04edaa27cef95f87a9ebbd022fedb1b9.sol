{"IERC20.sol":{"content":"pragma solidity ^0.6.0;\r\n\r\ninterface IERC20 {\r\n    function totalSupply() external view returns (uint256);\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}"},"IMVDFunctionalitiesManager.sol":{"content":"pragma solidity ^0.6.0;\n\ninterface IMVDFunctionalitiesManager {\n\n    function getProxy() external view returns (address);\n    function setProxy() external;\n\n    function init(address sourceLocation,\n        uint256 getMinimumBlockNumberSourceLocationId, address getMinimumBlockNumberFunctionalityAddress,\n        uint256 getEmergencyMinimumBlockNumberSourceLocationId, address getEmergencyMinimumBlockNumberFunctionalityAddress,\n        uint256 getEmergencySurveyStakingSourceLocationId, address getEmergencySurveyStakingFunctionalityAddress,\n        uint256 checkVoteResultSourceLocationId, address checkVoteResultFunctionalityAddress) external;\n\n    function addFunctionality(string calldata codeName, address sourceLocation, uint256 sourceLocationId, address location, bool submitable, string calldata methodSignature, string calldata returnAbiParametersArray, bool isInternal, bool needsSender) external;\n    function addFunctionality(string calldata codeName, address sourceLocation, uint256 sourceLocationId, address location, bool submitable, string calldata methodSignature, string calldata returnAbiParametersArray, bool isInternal, bool needsSender, uint256 position) external;\n    function removeFunctionality(string calldata codeName) external returns(bool removed, uint256 position);\n    function isValidFunctionality(address functionality) external view returns(bool);\n    function isAuthorizedFunctionality(address functionality) external view returns(bool);\n    function setCallingContext(address location) external returns(bool);\n    function clearCallingContext() external;\n    function getFunctionalityData(string calldata codeName) external view returns(address, uint256, string memory, address, uint256);\n    function hasFunctionality(string calldata codeName) external view returns(bool);\n    function getFunctionalitiesAmount() external view returns(uint256);\n    function functionalitiesToJSON() external view returns(string memory);\n    function functionalitiesToJSON(uint256 start, uint256 l) external view returns(string memory functionsJSONArray);\n    function functionalityNames() external view returns(string memory);\n    function functionalityNames(uint256 start, uint256 l) external view returns(string memory functionsJSONArray);\n    function functionalityToJSON(string calldata codeName) external view returns(string memory);\n\n    function preConditionCheck(string calldata codeName, bytes calldata data, uint8 submitable, address sender, uint256 value) external view returns(address location, bytes memory payload);\n\n    function setupFunctionality(address proposalAddress) external returns (bool);\n}"},"IMVDFunctionalityProposal.sol":{"content":"pragma solidity ^0.6.0;\n\ninterface IMVDFunctionalityProposal {\n\n    function init(string calldata codeName, address location, string calldata methodSignature, string calldata returnAbiParametersArray, string calldata replaces, address proxy) external;\n    function setCollateralData(bool emergency, address sourceLocation, uint256 sourceLocationId, bool submitable, bool isInternal, bool needsSender, address proposer, uint256 votesHardCap) external;\n\n    function getProxy() external view returns(address);\n    function getCodeName() external view returns(string memory);\n    function isEmergency() external view returns(bool);\n    function getSourceLocation() external view returns(address);\n    function getSourceLocationId() external view returns(uint256);\n    function getLocation() external view returns(address);\n    function isSubmitable() external view returns(bool);\n    function getMethodSignature() external view returns(string memory);\n    function getReturnAbiParametersArray() external view returns(string memory);\n    function isInternal() external view returns(bool);\n    function needsSender() external view returns(bool);\n    function getReplaces() external view returns(string memory);\n    function getProposer() external view returns(address);\n    function getSurveyEndBlock() external view returns(uint256);\n    function getSurveyDuration() external view returns(uint256);\n    function isVotesHardCapReached() external view returns(bool);\n    function getVotesHardCapToReach() external view returns(uint256);\n    function toJSON() external view returns(string memory);\n    function getVote(address addr) external view returns(uint256 accept, uint256 refuse);\n    function getVotes() external view returns(uint256, uint256);\n    function start() external;\n    function disable() external;\n    function isDisabled() external view returns(bool);\n    function isTerminated() external view returns(bool);\n    function accept(uint256 amount) external;\n    function retireAccept(uint256 amount) external;\n    function moveToAccept(uint256 amount) external;\n    function refuse(uint256 amount) external;\n    function retireRefuse(uint256 amount) external;\n    function moveToRefuse(uint256 amount) external;\n    function retireAll() external;\n    function withdraw() external;\n    function terminate() external;\n    function set() external;\n\n    event Accept(address indexed voter, uint256 amount);\n    event RetireAccept(address indexed voter, uint256 amount);\n    event MoveToAccept(address indexed voter, uint256 amount);\n    event Refuse(address indexed voter, uint256 amount);\n    event RetireRefuse(address indexed voter, uint256 amount);\n    event MoveToRefuse(address indexed voter, uint256 amount);\n    event RetireAll(address indexed voter, uint256 amount);\n}"},"IMVDFunctionalityProposalManager.sol":{"content":"pragma solidity ^0.6.0;\n\ninterface IMVDFunctionalityProposalManager {\n    function newProposal(string calldata codeName, address location, string calldata methodSignature, string calldata returnAbiParametersArray, string calldata replaces) external returns(address);\n    function checkProposal(address proposalAddress) external;\n    function getProxy() external view returns (address);\n    function setProxy() external;\n    function isValidProposal(address proposal) external view returns (bool);\n}"},"IMVDProxy.sol":{"content":"pragma solidity ^0.6.0;\n\ninterface IMVDProxy {\n\n    function init(address votingTokenAddress, address functionalityProposalManagerAddress, address stateHolderAddress, address functionalityModelsManagerAddress, address functionalitiesManagerAddress, address walletAddress) external;\n\n    function getDelegates() external view returns(address,address,address,address,address,address);\n    function getToken() external view returns(address);\n    function getMVDFunctionalityProposalManagerAddress() external view returns(address);\n    function getStateHolderAddress() external view returns(address);\n    function getMVDFunctionalityModelsManagerAddress() external view returns(address);\n    function getMVDFunctionalitiesManagerAddress() external view returns(address);\n    function getMVDWalletAddress() external view returns(address);\n    function setDelegate(uint256 position, address newAddress) external returns(address oldAddress);\n    function changeProxy(address newAddress, bytes calldata initPayload) external;\n    function isValidProposal(address proposal) external view returns (bool);\n    function isAuthorizedFunctionality(address functionality) external view returns(bool);\n    function newProposal(string calldata codeName, bool emergency, address sourceLocation, uint256 sourceLocationId, address location, bool submitable, string calldata methodSignature, string calldata returnParametersJSONArray, bool isInternal, bool needsSender, string calldata replaces) external returns(address proposalAddress);\n    function startProposal(address proposalAddress) external;\n    function disableProposal(address proposalAddress) external;\n    function transfer(address receiver, uint256 value, address token) external;\n    function transfer721(address receiver, uint256 tokenId, bytes calldata data, bool safe, address token) external;\n    function setProposal() external;\n    function read(string calldata codeName, bytes calldata data) external view returns(bytes memory returnData);\n    function submit(string calldata codeName, bytes calldata data) external payable returns(bytes memory returnData);\n    function callFromManager(address location, bytes calldata payload) external returns(bool, bytes memory);\n    function emitFromManager(string calldata codeName, address proposal, string calldata replaced, address replacedSourceLocation, uint256 replacedSourceLocationId, address location, bool submitable, string calldata methodSignature, bool isInternal, bool needsSender, address proposalAddress) external;\n\n    function emitEvent(string calldata eventSignature, bytes calldata firstIndex, bytes calldata secondIndex, bytes calldata data) external;\n\n    event ProxyChanged(address indexed newAddress);\n    event DelegateChanged(uint256 position, address indexed oldAddress, address indexed newAddress);\n\n    event Proposal(address proposal);\n    event ProposalCheck(address indexed proposal);\n    event ProposalSet(address indexed proposal, bool success);\n    event FunctionalitySet(string codeName, address indexed proposal, string replaced, address replacedSourceLocation, uint256 replacedSourceLocationId, address indexed replacedLocation, bool replacedWasSubmitable, string replacedMethodSignature, bool replacedWasInternal, bool replacedNeededSender, address indexed replacedProposal);\n\n    event Event(string indexed key, bytes32 indexed firstIndex, bytes32 indexed secondIndex, bytes data);\n}"},"MVDFunctionalityProposal.sol":{"content":"pragma solidity ^0.6.0;\n\nimport \"./IMVDFunctionalityProposal.sol\";\nimport \"./IMVDProxy.sol\";\nimport \"./IERC20.sol\";\n\ncontract MVDFunctionalityProposal is IMVDFunctionalityProposal{\n\n    bool private _collateralDataSet;\n\n    address private _proxy;\n    address private _token;\n    string private _codeName;\n    bool private _emergency;\n    address private _sourceLocation;\n    uint256 private _sourceLocationId;\n    address private _location;\n    bool private _submitable;\n    string private _methodSignature;\n    string private _returnAbiParametersArray;\n    bool private _isInternal;\n    bool private _needsSender;\n    string private _replaces;\n    uint256 private _surveyEndBlock;\n    uint256 private _surveyDuration;\n    bool private _terminated;\n    address private _proposer;\n    bool private _disabled;\n\n    mapping(address =\u003e uint256) private _accept;\n    mapping(address =\u003e uint256) private _refuse;\n    uint256 private _totalAccept;\n    uint256 private _totalRefuse;\n    mapping(address =\u003e bool) private _withdrawed;\n\n    uint256 private _votesHardCap;\n    bool private _votesHardCapReached;\n\n    constructor(string memory codeName, address location, string memory methodSignature, string memory returnAbiParametersArray,\n        string memory replaces, address proxy) public {\n        init(codeName, location, methodSignature, returnAbiParametersArray, replaces, proxy);\n    }\n\n    function init(string memory codeName, address location, string memory methodSignature, string memory returnAbiParametersArray,\n        string memory replaces, address proxy) public override {\n        require(_proxy == address(0), \"Already initialized!\");\n        _token = IMVDProxy(_proxy = proxy).getToken();\n        _codeName = codeName;\n        _location = location;\n        _methodSignature = methodSignature;\n        _returnAbiParametersArray = returnAbiParametersArray;\n        _replaces = replaces;\n    }\n\n    function setCollateralData(bool emergency, address sourceLocation, uint256 sourceLocationId, bool submitable, bool isInternal, bool needsSender, address proposer, uint256 votesHardCap) public override {\n        require(!_collateralDataSet, \"setCollateralData already called!\");\n        require(_proxy == msg.sender, \"Only Original Proxy can call this method!\");\n        _sourceLocation = sourceLocation;\n        _sourceLocationId = sourceLocationId;\n        _submitable = submitable;\n        _isInternal = isInternal;\n        _needsSender = needsSender;\n        _proposer = proposer;\n        _surveyDuration = toUint256(IMVDProxy(_proxy).read((_emergency = emergency) ? \"getMinimumBlockNumberForEmergencySurvey\" : \"getMinimumBlockNumberForSurvey\", bytes(\"\")));\n        _votesHardCap = votesHardCap;\n        _collateralDataSet = true;\n    }\n\n    function getProxy() public override view returns(address) {\n        return _proxy;\n    }\n\n    function getCodeName() public override view returns(string memory) {\n        return _codeName;\n    }\n\n    function isEmergency() public override view returns(bool) {\n        return _emergency;\n    }\n\n    function getSourceLocation() public override view returns(address) {\n        return _sourceLocation;\n    }\n\n    function getSourceLocationId() public override view returns(uint256) {\n        return _sourceLocationId;\n    }\n\n    function getLocation() public override view returns(address) {\n        return _location;\n    }\n\n    function isSubmitable() public override view returns(bool) {\n        return _submitable;\n    }\n\n    function getMethodSignature() public override view returns(string memory) {\n        return _methodSignature;\n    }\n\n    function getReturnAbiParametersArray() public override view returns(string memory) {\n        return _returnAbiParametersArray;\n    }\n\n    function isInternal() public override view returns(bool) {\n        return _isInternal;\n    }\n\n    function needsSender() public override view returns(bool) {\n        return _needsSender;\n    }\n\n    function getReplaces() public override view returns(string memory) {\n        return _replaces;\n    }\n\n    function getProposer() public override view returns(address) {\n        return _proposer;\n    }\n\n    function getSurveyEndBlock() public override view returns(uint256) {\n        return _surveyEndBlock;\n    }\n\n    function getSurveyDuration() public override view returns(uint256) {\n        return _surveyDuration;\n    }\n\n    function getVote(address addr) public override view returns(uint256 accept, uint256 refuse) {\n        accept = _accept[addr];\n        refuse = _refuse[addr];\n    }\n\n    function getVotes() public override view returns(uint256, uint256) {\n        return (_totalAccept, _totalRefuse);\n    }\n\n    function isTerminated() public override view returns(bool) {\n        return _terminated;\n    }\n\n    function isDisabled() public override view returns(bool) {\n        return _disabled;\n    }\n\n    function isVotesHardCapReached() public override view returns(bool) {\n        return _votesHardCapReached;\n    }\n\n    function getVotesHardCapToReach() public override view returns(uint256) {\n        return _votesHardCap;\n    }\n\n    function start() public override {\n        require(_collateralDataSet, \"Still waiting for setCollateralData to be called!\");\n        require(msg.sender == _proxy, \"Only Proxy can call this function!\");\n        require(_surveyEndBlock == 0, \"Already started!\");\n        require(!_disabled, \"Already disabled!\");\n        _surveyEndBlock = block.number + _surveyDuration;\n    }\n\n    function disable() public override {\n        require(_collateralDataSet, \"Still waiting for setCollateralData to be called!\");\n        require(msg.sender == _proxy, \"Only Proxy can call this function!\");\n        require(_surveyEndBlock == 0, \"Already started!\");\n        _disabled = true;\n        _terminated = true;\n    }\n\n    function toJSON() public override view returns(string memory) {\n        return string(abi.encodePacked(\n            \u0027{\u0027,\n            getFirstJSONPart(_sourceLocation, _sourceLocationId, _location),\n            \u0027\",\"submitable\":\u0027,\n            _submitable ? \"true\" : \"false\",\n            \u0027,\"emergency\":\u0027,\n            _emergency ? \"true\" : \"false\",\n            \u0027,\"isInternal\":\u0027,\n            _isInternal ? \"true\" : \"false\",\n            \u0027,\"needsSender\":\u0027,\n            _needsSender ? \"true\" : \"false\",\n            \u0027,\u0027,\n            getSecondJSONPart(),\n            \u0027,\"proposer\":\"\u0027,\n            toString(_proposer),\n            \u0027\",\"endBlock\":\u0027,\n            toString(_surveyEndBlock),\n            \u0027,\"terminated\":\u0027,\n            _terminated ? \"true\" : \"false\",\n            \u0027,\"accepted\":\u0027,\n            toString(_totalAccept),\n            \u0027,\"refused\":\u0027,\n            toString(_totalRefuse),\n            \u0027,\"disabled\":\u0027,\n            _disabled ? \u0027true\u0027 : \u0027false\u0027,\n            \u0027}\u0027)\n        );\n    }\n\n    function getSecondJSONPart() private view returns (string memory){\n        return string(abi.encodePacked(\n            \u0027\"codeName\":\"\u0027,\n            _codeName,\n            \u0027\",\"methodSignature\":\"\u0027,\n            _methodSignature,\n            \u0027\",\"returnAbiParametersArray\":\u0027,\n            formatReturnAbiParametersArray(_returnAbiParametersArray),\n            \u0027,\"replaces\":\"\u0027,\n            _replaces,\n            \u0027\"\u0027));\n    }\n\n    modifier duringSurvey() {\n        require(_collateralDataSet, \"Still waiting for setCollateralData to be called!\");\n        require(!_disabled, \"Survey disabled!\");\n        require(!_terminated, \"Survey Terminated!\");\n        require(!_votesHardCapReached, \"Votes Hard Cap reached!\");\n        require(_surveyEndBlock \u003e 0, \"Survey Not Started!\");\n        require(block.number \u003c _surveyEndBlock, \"Survey ended!\");\n        _;\n    }\n\n    modifier onSurveyEnd() {\n        require(_collateralDataSet, \"Still waiting for setCollateralData to be called!\");\n        require(!_disabled, \"Survey disabled!\");\n        require(_surveyEndBlock \u003e 0, \"Survey Not Started!\");\n        if(!_votesHardCapReached) {\n            require(block.number \u003e= _surveyEndBlock, \"Survey is still running!\");\n        }\n        _;\n    }\n\n    function _checkVotesHardCap() private {\n        if(_votesHardCap == 0 || (_totalAccept \u003c _votesHardCap \u0026\u0026 _totalRefuse \u003c _votesHardCap)) {\n            return;\n        }\n        _votesHardCapReached = true;\n        terminate();\n    }\n\n    function accept(uint256 amount) external override duringSurvey {\n        IERC20(_token).transferFrom(msg.sender, address(this), amount);\n        uint256 vote = _accept[msg.sender];\n        vote += amount;\n        _accept[msg.sender] = vote;\n        _totalAccept += amount;\n        emit Accept(msg.sender, amount);\n        _checkVotesHardCap();\n    }\n\n    function retireAccept(uint256 amount) external override duringSurvey {\n        require(_accept[msg.sender] \u003e= amount, \"Insufficient funds!\");\n        IERC20(_token).transfer(msg.sender, amount);\n        uint256 vote = _accept[msg.sender];\n        vote -= amount;\n        _accept[msg.sender] = vote;\n        _totalAccept -= amount;\n        emit RetireAccept(msg.sender, amount);\n    }\n\n    function moveToAccept(uint256 amount) external override duringSurvey {\n        require(_refuse[msg.sender] \u003e= amount, \"Insufficient funds!\");\n        uint256 vote = _refuse[msg.sender];\n        vote -= amount;\n        _refuse[msg.sender] = vote;\n        _totalRefuse -= amount;\n\n        vote = _accept[msg.sender];\n        vote += amount;\n        _accept[msg.sender] = vote;\n        _totalAccept += amount;\n        emit MoveToAccept(msg.sender, amount);\n        _checkVotesHardCap();\n    }\n\n    function refuse(uint256 amount) external override duringSurvey {\n        IERC20(_token).transferFrom(msg.sender, address(this), amount);\n        uint256 vote = _refuse[msg.sender];\n        vote += amount;\n        _refuse[msg.sender] = vote;\n        _totalRefuse += amount;\n        emit Refuse(msg.sender, amount);\n        _checkVotesHardCap();\n    }\n\n    function retireRefuse(uint256 amount) external override duringSurvey {\n        require(_refuse[msg.sender] \u003e= amount, \"Insufficient funds!\");\n        IERC20(_token).transfer(msg.sender, amount);\n        uint256 vote = _refuse[msg.sender];\n        vote -= amount;\n        _refuse[msg.sender] = vote;\n        _totalRefuse -= amount;\n        emit RetireRefuse(msg.sender, amount);\n    }\n\n    function moveToRefuse(uint256 amount) external override duringSurvey {\n        require(_accept[msg.sender] \u003e= amount, \"Insufficient funds!\");\n        uint256 vote = _accept[msg.sender];\n        vote -= amount;\n        _accept[msg.sender] = vote;\n        _totalAccept -= amount;\n\n        vote = _refuse[msg.sender];\n        vote += amount;\n        _refuse[msg.sender] = vote;\n        _totalRefuse += amount;\n        emit MoveToRefuse(msg.sender, amount);\n        _checkVotesHardCap();\n    }\n\n    function retireAll() external override duringSurvey {\n        require(_accept[msg.sender] + _refuse[msg.sender] \u003e 0, \"No votes!\");\n        uint256 acpt = _accept[msg.sender];\n        uint256 rfs = _refuse[msg.sender];\n        IERC20(_token).transfer(msg.sender, acpt + rfs);\n        _accept[msg.sender] = 0;\n        _refuse[msg.sender] = 0;\n        _totalAccept -= acpt;\n        _totalRefuse -= rfs;\n        emit RetireAll(msg.sender, acpt + rfs);\n    }\n\n    function withdraw() external override onSurveyEnd {\n        if(!_terminated \u0026\u0026 !_disabled) {\n            terminate();\n            return;\n        }\n        _withdraw(true);\n    }\n\n    function terminate() public override onSurveyEnd {\n        require(!_terminated, \"Already terminated!\");\n        IMVDProxy(_proxy).setProposal();\n        _withdraw(false);\n    }\n\n    function _withdraw(bool launchError) private {\n        require(!launchError || _accept[msg.sender] + _refuse[msg.sender] \u003e 0, \"Nothing to Withdraw!\");\n        require(!launchError || !_withdrawed[msg.sender], \"Already Withdrawed!\");\n        if(_accept[msg.sender] + _refuse[msg.sender] \u003e 0 \u0026\u0026 !_withdrawed[msg.sender]) {\n            IERC20(_token).transfer(msg.sender, _accept[msg.sender] + _refuse[msg.sender]);\n            _withdrawed[msg.sender] = true;\n        }\n    }\n\n    function set() public override onSurveyEnd {\n        require(msg.sender == _proxy, \"Unauthorized Access!\");\n        require(!_terminated, \"Already terminated!\");\n        _terminated = true;\n    }\n\n    function toUint256(bytes memory bs) public pure returns(uint256 x) {\n        if(bs.length \u003e= 32) {\n            assembly {\n                x := mload(add(bs, add(0x20, 0)))\n            }\n        }\n    }\n\n    function toString(address _addr) public pure returns(string memory) {\n        bytes32 value = bytes32(uint256(_addr));\n        bytes memory alphabet = \"0123456789abcdef\";\n\n        bytes memory str = new bytes(42);\n        str[0] = \u00270\u0027;\n        str[1] = \u0027x\u0027;\n        for (uint i = 0; i \u003c 20; i++) {\n            str[2+i*2] = alphabet[uint(uint8(value[i + 12] \u003e\u003e 4))];\n            str[3+i*2] = alphabet[uint(uint8(value[i + 12] \u0026 0x0f))];\n        }\n        return string(str);\n    }\n\n    function toString(uint _i) public pure returns(string memory) {\n        if (_i == 0) {\n            return \"0\";\n        }\n        uint j = _i;\n        uint len;\n        while (j != 0) {\n            len++;\n            j /= 10;\n        }\n        bytes memory bstr = new bytes(len);\n        uint k = len - 1;\n        while (_i != 0) {\n            bstr[k--] = byte(uint8(48 + _i % 10));\n            _i /= 10;\n        }\n        return string(bstr);\n    }\n\n    function getFirstJSONPart(address sourceLocation, uint256 sourceLocationId, address location) public pure returns(bytes memory) {\n        return abi.encodePacked(\n            \u0027\"sourceLocation\":\"\u0027,\n            toString(sourceLocation),\n            \u0027\",\"sourceLocationId\":\u0027,\n            toString(sourceLocationId),\n            \u0027,\"location\":\"\u0027,\n            toString(location)\n        );\n    }\n\n    function formatReturnAbiParametersArray(string memory m) public pure returns(string memory) {\n        bytes memory b = bytes(m);\n        if(b.length \u003c 2) {\n            return \"[]\";\n        }\n        if(b[0] != bytes1(\"[\")) {\n            return \"[]\";\n        }\n        if(b[b.length - 1] != bytes1(\"]\")) {\n            return \"[]\";\n        }\n        return m;\n    }\n}"},"MVDFunctionalityProposalManager.sol":{"content":"pragma solidity ^0.6.0;\n\nimport \"./IMVDFunctionalityProposalManager.sol\";\nimport \"./IMVDProxy.sol\";\nimport \"./MVDFunctionalityProposal.sol\";\nimport \"./IMVDFunctionalitiesManager.sol\";\n\ncontract MVDFunctionalityProposalManager is IMVDFunctionalityProposalManager {\n\n    address private _proxy;\n\n    mapping(address =\u003e bool) private _proposals;\n\n    modifier onlyProxy() {\n        require(msg.sender == address(_proxy), \"Only Proxy can call this functionality\");\n        _;\n    }\n\n    function newProposal(string memory codeName, address location, string memory methodSignature, string memory returnAbiParametersArray, string memory replaces) public override onlyProxy returns(address) {\n        return setProposal(codeName, location, methodSignature, replaces, address(new MVDFunctionalityProposal(codeName, location, methodSignature, returnAbiParametersArray, replaces, _proxy)));\n    }\n\n    function preconditionCheck(string memory codeName, address location, string memory methodSignature, string memory replaces) private view {\n\n        bool hasCodeName = !compareStrings(codeName, \"\");\n        bool hasReplaces = !compareStrings(replaces, \"\");\n\n        require((hasCodeName || !hasCodeName \u0026\u0026 !hasReplaces) ? location != address(0) : true, \"Cannot have zero address for functionality to set or one time functionality to call\");\n\n        require(location == address(0) || !compareStrings(methodSignature, \"\"), \"Cannot have empty string for methodSignature\");\n\n        require(hasCodeName || hasReplaces ? true : compareStrings(methodSignature, \"callOneTime(address)\"), \"One Time Functionality method signature allowed is callOneTime(address)\");\n\n        IMVDFunctionalitiesManager functionalitiesManager = IMVDFunctionalitiesManager(IMVDProxy(_proxy).getMVDFunctionalitiesManagerAddress());\n\n        require(hasCodeName \u0026\u0026 functionalitiesManager.hasFunctionality(codeName) ? compareStrings(codeName, replaces) : true, \"codeName is already used by another functionality\");\n\n        require(hasReplaces ? functionalitiesManager.hasFunctionality(replaces) : true, \"Cannot replace unexisting or inactive functionality\");\n    }\n\n    function setProposal(string memory codeName, address location, string memory methodSignature, string memory replaces, address proposalAddress) private returns(address) {\n\n        preconditionCheck(codeName, location, methodSignature, replaces);\n\n        _proposals[proposalAddress] = true;\n\n        return proposalAddress;\n    }\n\n    function checkProposal(address proposalAddress) public override onlyProxy {\n        require(_proposals[proposalAddress], \"Unauthorized Access!\");\n\n        IMVDFunctionalityProposal proposal = IMVDFunctionalityProposal(proposalAddress);\n\n        uint256 surveyEndBlock = proposal.getSurveyEndBlock();\n\n        require(surveyEndBlock \u003e 0, \"Survey was not started!\");\n\n        require(!proposal.isDisabled(), \"Proposal is disabled!\");\n\n        if(!proposal.isVotesHardCapReached()) {\n            require(block.number \u003e= surveyEndBlock, \"Survey is still running!\");\n        }\n\n        require(!proposal.isTerminated(), \"Survey already terminated!\");\n    }\n\n    function isValidProposal(address proposal) public override view returns (bool) {\n        return _proposals[proposal];\n    }\n\n    function getProxy() public override view returns (address) {\n        return _proxy;\n    }\n\n    function setProxy() public override {\n        require(_proxy == address(0) || _proxy == msg.sender, _proxy != address(0) ? \"Proxy already set!\" : \"Only Proxy can toggle itself!\");\n        _proxy = _proxy == address(0) ?  msg.sender : address(0);\n    }\n\n    function compareStrings(string memory a, string memory b) private pure returns(bool) {\n        return keccak256(bytes(a)) == keccak256(bytes(b));\n    }\n}"}}