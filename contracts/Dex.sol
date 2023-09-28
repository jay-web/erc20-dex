pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Dex {
    IERC20 public associatedTokens;

    uint256 price;
    address owner;

// info : here we are passing token address in the constructor, so we can access its functionality, 
// info : i.e why data type is IERC20
    constructor (IERC20 _token, uint256 _price)  {
        associatedTokens = _token;
        price =  _price;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

// info: sell function in which we allowed this contract address to sell the token on behalf of owner of this contract
// * First = get the allowed token
// * Second - transfer the allowed token from owner account to this contract account
// * It should only be called by owner

function sell() external onlyOwner {
    uint256 allowance = associatedTokens.allowance(owner, address(this));
    require(allowance > 0, "Atleast one token allowed to transfer for sell");

    bool sent = associatedTokens.transferFrom(owner, address(this), allowance );

    require(sent, "Transfer failed");
}

// info: withdraw tokens function in which owner can withdraw the left tokens which not been selled and transfer it to own account

function withdrawTokens() external onlyOwner {
    uint balance = associatedTokens.balanceOf(address(this));
    associatedTokens.transfer(msg.sender, balance);
}

// info: withdraw funds function in which owner can withdraw the funds which has received by selling tokens

function withdrawFunds() external onlyOwner {
    (bool sent, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(sent, "Transfer failed");
}

// info: get price function will return the price in wei of the passed number of tokens

function getPrice(uint256 numberOfTokens) public view returns(uint256){
    return numberOfTokens * price;
}

// info: get token balance function will return left number of tokens in the account

function getTokenBalance() public view returns(uint256){
    return associatedTokens.balanceOf(address(this));
}

// info: buy function in which caller can buy the passed token by paying required amount

function buy(uint256 numberOfTokens) external payable {
    require(numberOfTokens <= getTokenBalance(), "not enough token");
    uint256 priceToBuy = getPrice(numberOfTokens);
    require(msg.value == priceToBuy, "not enough amount transfered to buy");

    associatedTokens.transfer(msg.sender, numberOfTokens);
}



}