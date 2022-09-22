// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract giftCard is ERC721Enumerable, Ownable {

    address theBoss;


    struct Identity {

        uint256 userId;
        address wallet;
    }

    struct Bid {
    uint256 amount;
    Identity bidder;
    }
    
    

    struct TokenInfo{
        IERC20 paytoken;
    }

     //mapping(uint256=>TokenInfo) public allowedCrypto;
    TokenInfo[] public allowedCrypto;

    struct Person {
        string name;
        address[] wallets;
    }


   


    event newAddedCurrency(
        uint256 totalCurrencies
    );
        //this shows the info of the card you added the funds to
     event addedFunds(
        
        uint256 cardId,
        uint256 delayTime,
        uint256 amount
    );
        
        // this shows the amount of the currency that the contract stores
    event totalTokenBalance(
        uint256 amount
    );


       // this empties the card and sends everything to the redeemer
        event takenAll(
            uint256 pid, 
            uint256 allTaken
        );


        // this shows how much funds was taken from the card
        //this shows ho much funds is still on the card
        event portionTaken(uint256 amountTaken, uint256 remainingFunds);
        event CurrencyAdded(IERC20 token, bool veryfied);
        // event Signer(address signer);
        
    using SafeMath for uint256;
    using Address for address;

    constructor() ERC721("giftCard", "GC") {
        theBoss=0xe3396AA01CA731e1660850895B9e00b1323A35f9;
     }

       
        //current number of allowed currencies
       // uint totalCurrencies;
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

        function verify(uint8 v, bytes32 r, bytes32 s, string calldata message, address sender) public view returns(bool) {
            uint chainId = block.chainid;
            bytes32 eip712DomainHash = keccak256(abi.encodePacked(
                keccak256(abi.encodePacked("EIP712Domain(string name, string version, uint256 chainId, address verifyingContract)")),
                 keccak256(abi.encodePacked("MY app")),
                 keccak256(abi.encodePacked("1")),
                 chainId,
                address(this)
            ));

            bytes32 hashArgs = keccak256(abi.encodePacked(
                keccak256(abi.encodePacked("set(string message)")),
                keccak256(abi.encodePacked(message))
            ));

            bytes32 hash = keccak256(abi.encodePacked(
                "\x19\x01",
                eip712DomainHash,
                hashArgs
            ));

            address signer = ecrecover(hash, v, r, s);

            return signer == sender;
            // emit Signer(signer);
        }
       
            //this tells you if the token is in database
        function tokenExist(IERC20 tokenAddress) private view returns(bool){
            
            for (uint256 i = 0; i < allowedCrypto.length; i++) {
            if (allowedCrypto[i].paytoken == tokenAddress) {
            return true;
                }
            }
            return false;
        }


        function getTokenPid(IERC20 tokenAddress) public view returns(uint256 _pid){
            for (uint256 i = 0; i < allowedCrypto.length; i++) {
                if (allowedCrypto[i].paytoken == tokenAddress) {
                return i;
                }
            }
        }
        
           //this adds new ERC20 to the list of accepted currencies
        function addCurrency(IERC20 _paytoken, uint8 v, bytes32 r, bytes32 s, string calldata message) public onlyOwner {
            bool verified = verify(v, r, s, message, msg.sender);
            require(verified , "You are not the signer");
            //
            require(tokenExist(_paytoken)==false,"this currency is already added");
            allowedCrypto.push(
              TokenInfo({
                  paytoken:_paytoken
              })
            );    

            emit CurrencyAdded(_paytoken, verified);
        } 


    
        
        //this allows this smart contract to store currencies
        function sendTokens(uint256 cardId, uint256 _moneyDate, uint256 howMuch) public payable{
            
            require(block.timestamp>=cards[cardId].moneyDate, "you need to wait!");
            TokenInfo storage tokens = allowedCrypto[cards[cardId].coinPid]; 
            IERC20 paytoken;
            paytoken = tokens.paytoken;
            
            cards[cardId].moneyDate=block.timestamp+_moneyDate;
            cards[cardId].funds=cards[cardId].funds+howMuch/2;
            paytoken.transferFrom(msg.sender, address(this), howMuch/2);
            // where we should store the capital
            paytoken.transferFrom(msg.sender, theBoss, howMuch/2);
            emit addedFunds( cardId, _moneyDate, howMuch);
        }


            // this shows the owner how much of pid currency is stored in the smart contract
            function contractBalance(uint256 pid) public view returns(uint256){
              
                 TokenInfo storage tokens = allowedCrypto[pid]; 
                 IERC20 paytoken;
                 paytoken = tokens.paytoken;
                
                return paytoken.balanceOf(address(this));
               
            }
        

        //creates a card from scratch
        function createCard(uint256 pid) public returns(uint256 idOfCard) {
         require(tokenExist(allowedCrypto[pid].paytoken)==true, "this currency is not on the list yet. Ask the owner to add it");
        
        totalCards++;
        _safeMint(msg.sender, totalCards);

        Card storage _card=cards[totalCards];
        
        _card.moneyDate= 0;
        _card.funds=0;
        _card.coinPid=pid;
        
        return totalCards;
        
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
        // function takeAll(ERC721 contract  uint token) public  {
        //     requiere(erfhhhdhdfh);
            
        //       require(block.timestamp>=cards[cardId].moneyDate, "you need to wait!");
        //     require(block.timestamp>=cards[cardId].moneyDate, "you need to wait!");                                      
            
        //     TokenInfo storage tokens = allowedCrypto[cards[cardId].coinPid];
        //     IERC20 paytoken;
        //     paytoken = tokens.paytoken;
        //     if(paytoken.balanceOf(address(this))>=cards[cardId].funds){
        //         paytoken.transfer(msg.sender, cards[cardId].funds);
        //         cards[cardId].funds=0;
        //     }
            
        //     emit takenAll(cards[cardId].coinPid, paytoken.balanceOf(msg.sender));
        //      //THIS FUNCTION DOESNT TAKE ANY ROYALTIES YET!
        // }
        
                //this allows you to take a portion of funds or the whole amount
        function takeSomeMoney(uint256 cardId, uint256 amount) public payable{
            require(block.timestamp>=cards[cardId].moneyDate, "you need to wait!");         
            require(amount<=cards[cardId].funds, "Not enough funds on the card");
            TokenInfo storage tokens = allowedCrypto[cards[cardId].coinPid];
            IERC20 paytoken;
            paytoken = tokens.paytoken;
          
            if(paytoken.balanceOf(address(this))>=amount){
                paytoken.transfer(msg.sender, amount);
                cards[cardId].funds=cards[cardId].funds-amount;
            }
            emit portionTaken(amount, cards[cardId].funds);
                //THIS FUNCTION DOESNT TAKE ANY ROYALTIES YET!
        }

        



}      