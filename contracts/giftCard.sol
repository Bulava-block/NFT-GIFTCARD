// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract giftCard is ERC721Enumerable, Ownable {

    //this is the royalty address
    address public theBoss;
    IERC20 cardFiCoin;

    // what goes to us when users deposit money
    uint256 public depositRoyal;
    //what goes to us when users withdraw money
    uint256 public withdrawRoyal;

     // this stores all the added currencies
    IERC20[] public allowedCrypto;

    
    event Royalty(uint256 depositRoyal, uint256 withdrawRoyal);

    
        //this shows the info of the card you added the funds to
     event addedFunds(
        
        IERC721 _contractAddress,
        uint256 cardId,
        IERC20 _token,
        uint256 delayTime,
        uint256 cardFunds

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
        event portionTaken(uint256 amountRecived, uint256 royalty, uint256 remainingFunds);
        event addedCurrency(IERC20 token);
        event Signer(address signer);
        event currencyAttached(IERC721 minter, uint256 cardId, IERC20 currency, bool added);
        
        
    using SafeMath for uint256;
    using Address for address;

    constructor() ERC721("giftCard", "GC") {
        theBoss=0xd0f42F06212Ec949Af692b1d31Fd3f3D8Ddc05D7;
        cardFiCoin=IERC20(0xFf1c5b5Aa6362B8804BeD047163Ebe1a9B125869);
        addCurrency(cardFiCoin);
        setRoyalty(3, 5);

     }

         
        //NFT[IERC721][uint256]
        mapping (IERC721 => mapping (uint256 => Card)) public vaultBox ;
        

        // these are the stats that a card will have
        struct Card {
            //this shows the currency the card stores 
            IERC20 token; 
            //this shows the amount of the currency the card stores
            uint256 funds;  
            //this shows when you are alowed to claim the funds       
            uint256 moneyDate;

            bool currencyAdded;
        }

function executeSetIfSignatureMatch(
    uint8 v,
    bytes32 r,
    bytes32 s,
    string memory message,
    address sender
  ) public view returns (bool) {
    // require(block.timestamp < deadline, "Signed transaction expired");

    uint chainId;
    assembly {
      chainId := chainid()
    }
    bytes32 eip712DomainHash = keccak256(
        abi.encode(
            keccak256(
                "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
            ),
            keccak256(bytes("SetTest")),
            keccak256(bytes("1")),
            chainId,
            address(this)
        )
    );  

    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("set(string message,address sender)"),
          keccak256(abi.encodePacked(message)),
          sender
        )
    );

    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct));
    address signer = ecrecover(hash, v, r, s);
    require(signer == sender, "MyFunction: invalid signature");
    require(signer != address(0), "ECDSA: invalid signature");

    
    return signer == sender;
    
  }
        

            function setRoyalty(uint256 depositFee, uint256 withdrawFee) public onlyOwner {
                depositRoyal=depositFee;
                withdrawRoyal=withdrawFee;
                emit Royalty(depositRoyal, withdrawRoyal);
            }

            function seeRoyalty() public onlyOwner view returns(uint256, uint256){
                return(depositRoyal, withdrawRoyal);
            }
          
            //this tells you if the token is in database
        function tokenExist(IERC20 tokenAddress) public view returns(bool ifExist){
           
            for (uint256 i = 0; i < allowedCrypto.length; i++) {
            if (allowedCrypto[i] == tokenAddress) {
            return true;
                }
            }
            return false;
        }


        function showAllowedCrypto() public view returns (IERC20[] memory){
            return allowedCrypto;
        }

           //this adds new ERC20 to the list of accepted currencies
        function addCurrency(IERC20 _paytoken) public onlyOwner {
            
            require(tokenExist(_paytoken)==false,"this currency is already added");
            allowedCrypto.push(_paytoken);
              

            emit addedCurrency(_paytoken);
        } 

            //this attaches a token to an NFT and sets the delay time to 0
        function tokenToNft(IERC721 _contractAddress, uint256 _tokenId, IERC20 _currency) public {   
                require(vaultBox[_contractAddress][_tokenId].currencyAdded==false, "this token already has currency assigned");     
                require(tokenExist(_currency)==true,"this currency is not in our database yet");
                Card storage _Card =vaultBox[_contractAddress][_tokenId];
                
                _Card.token=_currency;
                _Card.funds=0;
                _Card.moneyDate=0;
                _Card.currencyAdded=true;
                emit currencyAttached(_contractAddress, _tokenId, _currency, _Card.currencyAdded );

        }       

       
        // this adds the amount of ERC20 to the NFT
        function sendTokens(IERC721 _contractAddress, uint256 _tokenId, uint256 _moneyDate, uint256 _howMuch) public payable{
            require(_howMuch>=100,"100 wei is minimum");
            require(block.timestamp>=vaultBox[_contractAddress][_tokenId].moneyDate, "you need to wait!");          
            IERC20 currency=vaultBox[_contractAddress][_tokenId].token;   
            vaultBox[_contractAddress][_tokenId].moneyDate=block.timestamp+_moneyDate;
            
             if(currency==cardFiCoin){
                 vaultBox[_contractAddress][_tokenId].funds=vaultBox[_contractAddress][_tokenId].funds+_howMuch;                                         
                 currency.transferFrom(msg.sender, address(this), _howMuch);
             } else{
                //this is a royality portion
                 uint256 royalty=(_howMuch*depositRoyal)/100;
                     //this is what the holder gets
                 uint256 holderPortion=_howMuch-royalty;
                 
                vaultBox[_contractAddress][_tokenId].funds=vaultBox[_contractAddress][_tokenId].funds+holderPortion;
                 currency.transferFrom(msg.sender, address(this), holderPortion);
                 currency.transferFrom(msg.sender, theBoss, royalty);
             }
            
            emit addedFunds(_contractAddress, _tokenId, currency,  vaultBox[_contractAddress][_tokenId].moneyDate, vaultBox[_contractAddress][_tokenId].funds);
        }


            // this shows the owner of this contract how much of pid currency is stored in the smart contract
            function contractBalance(IERC20 _currency) public onlyOwner view returns(uint256){
                        require(tokenExist(_currency));
                return _currency.balanceOf(address(this));
               
            }
        
     //this shows the balance of the card that an owner can redeem 
     //this shows how much longer you have to wait before you can claim the funds
    // this shows what currency this card holds 
        function cardInfo(IERC721 _contractAddress, uint256 _tokenId) public view
            returns (uint256 theRest, uint256 moneyDate, IERC20 currencyAddress, bool added){
                   
                return (vaultBox[_contractAddress][_tokenId].funds,
                        vaultBox[_contractAddress][_tokenId].moneyDate,
                        vaultBox[_contractAddress][_tokenId].token,
                        vaultBox[_contractAddress][_tokenId].currencyAdded);
        }


         //this allows you to take a portion of funds or the whole amount
        function takeSomeMoney(IERC721 _contractAddress, uint256 _tokenId, uint256 _amount, uint8 v,  bytes32 r,  bytes32 s, string memory message, address signerAddress) public payable{
            executeSetIfSignatureMatch(v, r, s, message, signerAddress);

            require(_amount>=100,"100 wei is minimum");
            require(_contractAddress.ownerOf(_tokenId)==msg.sender, "You are not th owner of this NFT");
            //Card memory _card=vaultBox[_contractAddress][_tokenId];
            require(block.timestamp>=vaultBox[_contractAddress][_tokenId].moneyDate, "you need to wait!");         
            require(_amount<=vaultBox[_contractAddress][_tokenId].funds, "Not enough funds on the card");           
            require(vaultBox[_contractAddress][_tokenId].token.balanceOf(address(this))>=_amount, "the Vault doesn't have enough funds to pay you");
                vaultBox[_contractAddress][_tokenId].funds=vaultBox[_contractAddress][_tokenId].funds-_amount;
                IERC20 currency=vaultBox[_contractAddress][_tokenId].token;
                if(currency==cardFiCoin){
                    currency.transfer(msg.sender, _amount);
                } else{
                    //this is a royality portion
                    uint256 royalty=(_amount*withdrawRoyal)/100;
                    //this is what the holder gets
                uint256 holderPortion=_amount-royalty;             
                currency.transfer(msg.sender, holderPortion);
                currency.transfer(theBoss, royalty);
                emit portionTaken(holderPortion, royalty, vaultBox[_contractAddress][_tokenId].funds);
                }                         
        }

        

}      