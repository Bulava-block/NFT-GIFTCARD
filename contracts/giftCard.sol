// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract giftCard is ERC721, Ownable {

    
    struct TokenInfo{
        IERC20 paytoken;
    }
     mapping(uint256=>TokenInfo) public allowedCrypto;
    

    using SafeMath for uint256;
    using Address for address;

    constructor() ERC721("giftCard", "GC") {
     }

       
        //current number of allowed currencies
        uint totalCurrencies;
        //current number of cards
        uint256 totalCards;

        // this assigns a number to a card
        mapping(uint256 => Card) public cards;
        
        

        // these are the stats that a card will have
        struct Card {
            //this shows the currency the card stores 
            uint256 coinPid; 
            //this shows the amount of the currency the card stores
            uint256 funds;  
            //this shows when you are alowed to claim the funds       
            uint256 moneyDate;
        }
          
           //this adds new ERC20 to the list of accepted currencies
        function addCurency(IERC20 _paytoken) public onlyOwner returns(uint256){
            
          totalCurrencies++;
          TokenInfo storage _tokenInfo=allowedCrypto[totalCurrencies];
          _tokenInfo.paytoken=_paytoken;
            return totalCurrencies;
        }  


    
        
        //this allows this smart contract to store currencies
        function sendTokens(uint256 pid, uint256 cardId, uint256 _moneyDate, uint256 howMuch) public payable{
            require(cards[cardId].coinPid==0, "This card already has a coin assigned to it");
            require(block.timestamp>=cards[cardId].moneyDate, "you need to wait!");
            TokenInfo storage tokens = allowedCrypto[pid]; 
            IERC20 paytoken;
            paytoken = tokens.paytoken;
            cards[cardId].coinPid=pid;
            cards[cardId].moneyDate=block.timestamp+_moneyDate;
            cards[cardId].funds=howMuch/2;
            paytoken.transferFrom(msg.sender, address(this), howMuch/2);
            // where we should store the capital
            paytoken.transferFrom(msg.sender, owner(), howMuch/2);
        }


            // this shows the owner how much of pid currency is stored in the smart contract
            function contractBalance(uint256 pid) public view onlyOwner returns(uint256){
              
                 TokenInfo storage tokens = allowedCrypto[pid]; 
                 IERC20 paytoken;
                 paytoken = tokens.paytoken;
                
                return paytoken.balanceOf(address(this));
            }
        

        //creates a card from scratch
     function createCard() public returns(uint256 moneyDate, uint256 funds, uint256 pid, uint256 idOfCard) {
        
        totalCards++;
        _safeMint(msg.sender, totalCards);

        Card storage _card=cards[totalCards];
        
        _card.moneyDate= 0;
        _card.funds=0;
        _card.coinPid=pid;
        
        return(_card.moneyDate, _card.funds, _card.coinPid, totalCards);
        
     }

        
      
     //this shows the balance of the card that an owner can redeem 
     // this shows how much longer you have to wait before you can claim the funds
     // this shows what currency this card holds 
        function cardInfo(uint256 cardId) public view
            returns (uint256 theRest, uint256 moneyDate, uint256 coinPid){
                   
                return (cards[cardId].funds,
                        cards[cardId].moneyDate,
                        cards[cardId].coinPid);

        }

    //this empties the card and sends everything to the redeemer
        function takeAll(uint256 cardId) public  {
            require(address(this).balance>=cards[cardId].funds, "The contract doesn't have enough funds to pay you");    //  do we need a variable 
            require(block.timestamp>=cards[cardId].moneyDate, "you need to wait!");                                      //
            cards[cardId].funds=0;
            TokenInfo storage tokens = allowedCrypto[cards[cardId].coinPid];
            IERC20 paytoken;
            paytoken = tokens.paytoken;
            paytoken.transfer(msg.sender, paytoken.balanceOf(address(this)));
        }
        //THIS FUNCTION DOESNT TAKE ANY ROYALTIES YET!


        function withdraw(uint256 _pid) public payable onlyOwner() {
            TokenInfo storage tokens = allowedCrypto[_pid];
            IERC20 paytoken;
            paytoken = tokens.paytoken;
            paytoken.transfer(msg.sender, paytoken.balanceOf(address(this)));
            
        }


                //this allows you to take a portion of funds or the whole amount
        function takeSomeMoney(uint256 cardId) public payable{
            require(address(this).balance>=msg.value, "The contract doesn't have enough funds to pay you");
            require(block.timestamp>=cards[cardId].moneyDate, "you need to wait!");         
            require(msg.value<=cards[cardId].funds, "Not enough funds on the card");
            TokenInfo storage tokens = allowedCrypto[cards[cardId].coinPid];
            IERC20 paytoken;
            paytoken = tokens.paytoken;
            paytoken.transfer(msg.sender, msg.value);
                //THIS FUNCTION DOESNT TAKE ANY ROYALTIES YET!
           
        }

                    //this allows you to lock your funds for x amount of time and multiple it 
        // function makeMoney(uint cardId) public{
        //         require(cards[cardId].funds!=0);
        //         cards[cardId].moneyDate=block.timestamp+10;
        //         cards[cardId].funds=cards[cardId].funds*2;
        // }




}      


    

