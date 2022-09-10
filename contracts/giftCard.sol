// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;



import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract giftCard is ERC721, Ownable {

    
    //this address gets percentage from deposits
    

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
        
        //this shows when you are alowed to claim the funds
        uint256 moneyDate;
        uint256 funds;       
        address balanceOwner;

    }
        // this allows this contract to receive ethers
       function sendmoney(uint256 cardId) external payable returns(uint256 moneyDate, uint256 funds){
            
            cards[cardId].moneyDate=block.timestamp+10;
            cards[cardId].funds=(msg.value)/2;
            (bool success, ) = owner().call{value: (msg.value)/2}("");
            require(success, "Failed to send Ether");


            return(cards[cardId].moneyDate, cards[cardId].funds);
       }

        function contractBalance() public view returns(uint){
            return address(this).balance;
        }

        //creates a card from scratch
     function createCard() public returns(uint256 moneyDate, uint256 balance, address balanceOwner) {
        

        totalCards++;
        _safeMint(msg.sender, totalCards);

        Card storage _card=cards[totalCards];
        
        _card.moneyDate= 0;
        _card.funds=0;
        _card.balanceOwner=msg.sender;
        return(_card.moneyDate, _card.funds, _card.balanceOwner);
        
     }

        
      
     //this shows the balance of the card that an owner can redeem 
     // this shows how much longer you have to wait before you can claim the funds  
        function cardInfo(uint256 cardId) public view
            returns (uint256 theRest, uint256 moneyDate){
                   
                return (cards[cardId].funds,
                        cards[cardId].moneyDate);

        }

    //this empties the card and sends everything to the redeemer
        function claimAll(uint256 cardId, address payable to) public  {
            require(address(this).balance>=cards[cardId].funds, "The contract doesn't have enough funds to pay you");
             require(block.timestamp>=cards[cardId].moneyDate, "you need to wait!");
             require(cards[cardId].balanceOwner==to, "the funds belong to a different person");

            (bool success, ) = to.call{value: cards[cardId].funds}("");
            require(success, "Failed to send Ether");
            
        }


                //this allows you to take a portion of funds or the whole amount
        function takeSomeMoney(uint256 cardId, address payable to) public payable{
            require(address(this).balance>=msg.value, "The contract doesn't have enough funds to pay you");
            require(block.timestamp>=cards[cardId].moneyDate, "you need to wait!");
            require(cards[cardId].balanceOwner==to, "the funds belong to a different person");
            require(msg.value<=cards[cardId].funds, "Not enough funds on the card");

            (bool success, ) = to.call{value: msg.value}("");
            require(success, "Failed to send Ether");
            
        }

                    //this allows you to lock your funds for x amount of time and multiple it 
        function makeMoney(uint cardId) public{
                require(cards[cardId].funds!=0);
                cards[cardId].moneyDate=block.timestamp+10;
                cards[cardId].funds=cards[cardId].funds*2;
        }




}      


    

