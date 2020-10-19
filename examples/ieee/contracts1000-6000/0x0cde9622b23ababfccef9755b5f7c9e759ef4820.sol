{"CrowdProposal.sol":{"content":"// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.6.10;\npragma experimental ABIEncoderV2;\n\nimport \u0027./ICompound.sol\u0027;\n\ncontract CrowdProposal {\n    /// @notice The crowd proposal author\n    address payable public immutable author;\n\n    /// @notice Governance proposal data\n    address[] public targets;\n    uint[] public values;\n    string[] public signatures;\n    bytes[] public calldatas;\n    string public description;\n\n    /// @notice COMP token contract address\n    address public immutable comp;\n    /// @notice Compound protocol `GovernorAlpha` contract address\n    address public immutable governor;\n\n    /// @notice Governance proposal id\n    uint public govProposalId;\n    /// @notice Terminate flag\n    bool public terminated;\n\n    /// @notice An event emitted when the governance proposal is created\n    event CrowdProposalProposed(address indexed proposal, address indexed author, uint proposalId);\n    /// @notice An event emitted when the crowd proposal is terminated\n    event CrowdProposalTerminated(address indexed proposal, address indexed author);\n     /// @notice An event emitted when delegated votes are transfered to the governance proposal\n    event CrowdProposalVoted(address indexed proposal, uint proposalId);\n\n    /**\n    * @notice Construct crowd proposal\n    * @param author_ The crowd proposal author\n    * @param targets_ The ordered list of target addresses for calls to be made\n    * @param values_ The ordered list of values (i.e. msg.value) to be passed to the calls to be made\n    * @param signatures_ The ordered list of function signatures to be called\n    * @param calldatas_ The ordered list of calldata to be passed to each call\n    * @param description_ The block at which voting begins: holders must delegate their votes prior to this block\n    * @param comp_ `COMP` token contract address\n    * @param governor_ Compound protocol `GovernorAlpha` contract address\n    */\n    constructor(address payable author_,\n                address[] memory targets_,\n                uint[] memory values_,\n                string[] memory signatures_,\n                bytes[] memory calldatas_,\n                string memory description_,\n                address comp_,\n                address governor_) public {\n        author = author_;\n\n        // Save proposal data\n        targets = targets_;\n        values = values_;\n        signatures = signatures_;\n        calldatas = calldatas_;\n        description = description_;\n\n        // Save Compound contracts data\n        comp = comp_;\n        governor = governor_;\n\n        terminated = false;\n\n        // Delegate votes to the crowd proposal\n        IComp(comp_).delegate(address(this));\n    }\n\n    /// @notice Create governance proposal\n    function propose() external returns (uint) {\n        require(govProposalId == 0, \u0027CrowdProposal::propose: gov proposal already exists\u0027);\n        require(!terminated, \u0027CrowdProposal::propose: proposal has been terminated\u0027);\n\n        // Create governance proposal and save proposal id\n        govProposalId = IGovernorAlpha(governor).propose(targets, values, signatures, calldatas, description);\n        emit CrowdProposalProposed(address(this), author, govProposalId);\n\n        return govProposalId;\n    }\n\n    /// @notice Terminate the crowd proposal, send back staked COMP tokens\n    function terminate() external {\n        require(msg.sender == author, \u0027CrowdProposal::terminate: only author can terminate\u0027);\n        require(!terminated, \u0027CrowdProposal::terminate: proposal has been already terminated\u0027);\n\n        terminated = true;\n\n        // Transfer staked COMP tokens from the crowd proposal contract back to the author\n        IComp(comp).transfer(author, IComp(comp).balanceOf(address(this)));\n\n        emit CrowdProposalTerminated(address(this), author);\n    }\n\n    /// @notice Vote for the governance proposal with all delegated votes\n    function vote() external {\n        require(govProposalId \u003e 0, \u0027CrowdProposal::vote: gov proposal has not been created yet\u0027);\n        IGovernorAlpha(governor).castVote(govProposalId, true);\n\n        emit CrowdProposalVoted(address(this), govProposalId);\n    }\n}\n"},"ICompound.sol":{"content":"// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.6.10;\npragma experimental ABIEncoderV2;\n\ninterface IComp {\n    function delegate(address delegatee) external;\n    function balanceOf(address account) external view returns (uint);\n    function transfer(address dst, uint rawAmount) external returns (bool);\n    function transferFrom(address src, address dst, uint rawAmount) external returns (bool);\n}\n\ninterface IGovernorAlpha {\n    function propose(address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description) external returns (uint);\n    function castVote(uint proposalId, bool support) external;\n}"}}