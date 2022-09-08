// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;



import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract giftCard is ERC721 {

    //

    using SafeMath for uint256;
    using Address for address;

    constructor() ERC721("giftCard", "GC") {
        
    }

    //current number of cards
    uint256 totalCards;

    // this assigns a number to a card
    mapping(uint256 => Card) public cards;
    
    //this shows when the funds were loaded inside the card

    // these are the stats that a card will have
    struct Card {
        //this shows when the funds were loaded inside the card
        uint256 dateOfStart;
        //this shows when you are alowed to claim the funds
        uint256 moneyDate;
        uint256 balance;       
        address balanceOwner;

    }
        // this allows this contract to receive ethers
       function sendmoney(uint256 cardId) external payable{
            cards[cardId].dateOfStart=block.timestamp;
            cards[cardId].moneyDate=cards[cardId].dateOfStart+30000;
            cards[cardId].balance=msg.value;
       }

        function contractBalance() public view returns(uint){
            return address(this).balance;
        }

        //creates a card from scratch
     function createCard() public payable{
        

        totalCards++;
        _safeMint(msg.sender, totalCards);

        Card storage _card=cards[totalCards];
        _card.dateOfStart=0;
        _card.moneyDate= 0;
        _card.balance=0;
        _card.balanceOwner=msg.sender;
        
     }

        
      
     //this shows the balance of the card that an owner can redeem 
     // this shows how much longer you have to wait before you can claim the funds  
        function cardInfo(uint256 cardId) public view
            returns (uint256 theRest, uint256 waitTime){

                return (cards[cardId].balance,
                        block.timestamp-cards[cardId].moneyDate);

        }

    //this empties the card and sends everything to the redeemer
        function claimAll(uint256 cardId, address payable to) public payable{
            require(block.timestamp>=cards[cardId].moneyDate);
            require(cards[cardId].balanceOwner==to);

            to.transfer(cards[cardId].balance);
            
        }



        function takeSomeMoney(uint256 cardId, address payable to) public payable{
            require(block.timestamp>=cards[cardId].moneyDate);
            require(cards[cardId].balanceOwner==to);
            require(msg.value<=cards[cardId].balance);

            to.transfer(msg.value);
            
        }

}



    

