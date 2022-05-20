// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GUN_NFT721 is ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address public owner;
    uint public price_token_per_gun=1000*10**18;
    uint public price_bnb_per_gun=10**15;
    IERC20 public tokenZombie;
    bool public pay_via_token=true;
    bool public pay_via_bnb=true;

    constructor(address _tokenZombie) ERC721("GUN NFT", "GUN") {
        owner = msg.sender;
        tokenZombie = IERC20(_tokenZombie);
    }

    modifier checkOwner(){
        require(msg.sender==owner, "[1] You are not owner.");
        _;
    }

    function buy_Gun_via_Token(uint amount) public{
        require(pay_via_token==true, "[-3] You can not mint gun via token.");
        require(amount>0, "[0] Wrong amount");
        require(tokenZombie.balanceOf(msg.sender)>=amount*price_token_per_gun, "[-1]You dont have enought ZOMBIE");
        require(tokenZombie.allowance(msg.sender, address(this))>=amount*price_token_per_gun, "[-2] You have not approved yet.");
        tokenZombie.transferFrom(msg.sender, address(this), amount*price_token_per_gun);
        for(uint count=1; count<=amount; count++){
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _mint(msg.sender, newItemId);
        }
    }

    function buy_Gun_via_BNB(uint amount) public payable{
        require(pay_via_bnb==true, "[-3] You can not mint gun via BNB.");
        require(amount>0, "[0] Wrong amount");
        require(msg.value>=amount*price_bnb_per_gun, "[-1]You don't pay enought BNB");
        for(uint count=1; count<=amount; count++){
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _mint(msg.sender, newItemId);
        }
    }

    function getCurrentTokenId() public view returns(uint){
        return _tokenIds.current();
    }

    // update price_token_per_gun, rut token/BNB, pay_via_token, pay_via_bnb
    function update_token_address(address newAddress) public checkOwner{
        tokenZombie = IERC20(newAddress);
    }

    function withdraw_token(address receiver) public checkOwner{
        uint amount = tokenZombie.balanceOf(address(this));
        tokenZombie.transfer(receiver, amount);
    }

    function withdraw_BNB(address receiver, uint amount) public checkOwner{
        require(address(this).balance>amount, "BNB balance is zero");
        payable(receiver).transfer(amount);
    }

    function update_price_token(uint newAmount) public checkOwner{
        require(newAmount>0, "Amount must not be zero");
        price_token_per_gun = newAmount;
    }

    function update_price_BNB(uint newAmount) public checkOwner{
        require(newAmount>0, "Amount must not be zero");
        price_bnb_per_gun = newAmount;
    }

    function update_status_token(bool newStatus) public checkOwner{
        pay_via_token = newStatus;
    }

    function update_status_BNB(bool newStatus) public checkOwner{
        pay_via_bnb = newStatus;
    }

}