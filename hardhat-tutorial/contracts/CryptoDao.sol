// SPDX-License-Identifier: MIT
/*Launch a DAO for holders of CryptoDevs NFTs. NFT holders can vote to use ETH to purchase tokens 
//DAO contract 0x5Bc8E74C20B8435959fFC4f82a24824bE70f0F79
*/
pragma solidity ^0.8.19;
import "./Iroblox.sol";
import "./IUniswap.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CryptoDao is Ownable {
    //Interface of Iroblox
    Iroblox Roblox;
    IUniswap Uniswap;
    address public WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    
    //Proposal structs
    
    struct proposal {
        uint256 proposalId;   
        //Token want to buy
        address tokenAdress;
        //Amount eth to invest
        uint256 ethAmount;
        //deadline
        uint256 deadline;
        //YayVotes- the number of yayVotes for the proposal
        uint256 yayVotes;
        //NayVotes - the number of Nayvotes for the proposal
        uint256 nayVotes;
        ///the proposal status
        bool executed;
       
    }
    ///Mapping from the token Ids to booleans which indicate whether NFT has voted or not
    ///(proposalIds=>tokenIds=>Vote Status)
    mapping(uint256 => mapping(uint256 => bool)) voters;
    
    //An arrays of proposal
    proposal[] public Proposals;
    //Keep track of the number of proposals 
    uint256 public numProposals;

    //Modifier to check whether the user holds NFT

    modifier onlyApprover {
        require(
            Roblox.balanceOf(msg.sender) > 0, "You don't hold NFT"             
        );
        _;
    }
    //Modifier to check whether the user 
    modifier onlyActiveProposal(uint256 index) {
        require(Proposals[index].deadline > block.timestamp, "Deadline passed");
        _;
    }
    //Modifier to check inactive proposal
    modifier onlyInactiveProposal(uint256 index) {
        require(Proposals[index].deadline < block.timestamp, "Deadline passed");
        require(Proposals[index].executed == false, "Already executed");
        _;
    }

    //Create the contract
    constructor(address nftContract, address router) payable {
        Roblox = Iroblox(nftContract);
        Uniswap = IUniswap(router);
    }
    //Create a proposal
    function createProposal( address tokenAdress,uint256 ethAmount) public onlyApprover returns(uint256) {
       proposal memory _proposal;
       _proposal.proposalId = numProposals;
       _proposal.tokenAdress = tokenAdress;
       _proposal.ethAmount = ethAmount;
       _proposal.deadline = block.timestamp + 10 minutes;
       Proposals.push(_proposal);
       numProposals++;
       return numProposals - 1;
       
    }
     enum Vote {Yay, Nay}
    //Vote on a proposal
    function voteProposal(uint256 index,Vote vote) external onlyApprover onlyActiveProposal(index) {
        uint256 nftBalance = Roblox.balanceOf(msg.sender);
        uint256 voteNum = 0;
        proposal storage _proposal = Proposals[index];
        //Loop over all NFTs 
        for (uint256 i= 0; i<nftBalance; i++ ) {
            uint256 nftId = Roblox.tokenOfOwnerByIndex(msg.sender, i);
            if(!voters[index][nftId]) {
                voteNum++;
                voters[index][nftId] = true;
            }
        }
        require(voteNum > 0, "Already voted");

        if (vote == Vote.Nay) {
            _proposal.nayVotes += voteNum;
        } else {
            _proposal.yayVotes += voteNum;
        }
    }
    
    //Execute on a proposal
    function executeProposal(uint256 index) public onlyInactiveProposal(index) {
        proposal storage _proposal = Proposals[index];
        if (_proposal.yayVotes > _proposal.nayVotes) {
            address[] memory path = new address[](2);
            path[0] = WETH;
            path[1] = _proposal.tokenAdress;
            uint256 ethAmount = _proposal.ethAmount;
            uint256 mintAmount;
            Uniswap.swapExactETHForTokens{value: ethAmount}(mintAmount, path, msg.sender, block.timestamp);
        }
        _proposal.executed = true;
    }
    
    //Get NFT balance 
    function NFTBalance(address nftAddress) public view returns(uint256) {
        return Roblox.balanceOf(nftAddress);
    }
    //Get the proposal
    function getProposals() public view returns(proposal[] memory) {
        return Proposals;
    }
    //Get the proposal by index
    function getProposalbyIdex(uint256 index) public view returns(proposal memory) {
        return Proposals[index];
    }
    //Get the number of votes for a proposal for a specific address
    function getNumVotes(uint256 index, address nftHolder) public view returns(uint256) {
        uint256 nftBalance = Roblox.balanceOf(nftHolder);
        uint256 voteNum = 0;       
        //Loop over all NFTs 
        for (uint256 i= 0; i<nftBalance; i++ ) {
            uint256 nftId = Roblox.tokenOfOwnerByIndex(nftHolder, i);
            if(!voters[index][nftId]) {
                voteNum++;              
            }
        }
        return voteNum;
    }
    //Get the vote status for a proposal for an NFT ID
    function getVoteStatus(uint256 index, uint256 nftId) public view returns(bool) {
        return voters[index][nftId];
    }
  
    //Set the NFT address
    function setNFTContract(address nftContract) public onlyOwner {
        Roblox = Iroblox(nftContract);
    }
    //Set the router address 
    function setRouter(address router) public onlyOwner {
        Uniswap = IUniswap(router);
    }
    //Withdraw eth from the contract

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool sent,) = payable(owner()).call{value: amount}("");
        require(sent, "Failed to transfer");
    }

    // The following two functions allow the contract to accept ETH deposit
    receive() external payable {}
    fallback() external payable {}

    
}