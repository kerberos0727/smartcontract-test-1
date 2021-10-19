// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TheCrayBongs is ERC721Enumerable, Ownable {
    using Strings for uint256;
    
    event TokenPriceChanged(uint256 _tokenPrice);
    event BaseURIChanged(string _baseURI);
    event SaleMint(address minter);
    
    uint256 private     nextTokenId;
    uint256 public      tokenPrice = 0.03 ether;
    string  public      baseURIValue;
    
    mapping (uint256 => string) private _tokenURIs;
    
    constructor(
        
    ) ERC721("Dick Token", "Dick") {

    }

    // set token price
    function getTokenPrice() public view returns (uint256) {
        return tokenPrice;
    }

    function setTokenPrice(uint256 _tokenPrice) public onlyOwner {
        tokenPrice = _tokenPrice;
        emit TokenPriceChanged(_tokenPrice);
    }
    
    
    // set base URI
    function _baseURI() internal view override returns (string memory) {
        return baseURIValue;
    }

    function getBaseURI() public view returns (string memory) {
        return _baseURI();
    }

    function setBaseURI(string memory newBase) public onlyOwner {
        baseURIValue = newBase;
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();
        
        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(base, tokenId.toString()));
    }
    
    // mint token
    modifier validatePurchasePrice() {
        require(
            tokenPrice == msg.value,
            "Ether value sent is not correct"
        );
        _;
    }
    
    
    // please input this metadata for test, because you will waste your rinkeby ether if you use opensea test NFT
    // When you mint an NFT, Two addresses divide your ether.
    // https://gateway.pinata.cloud/ipfs/QmbkS59Q4pQpcfSbHJcBG7Hwpz5fHNvVnTAuvFrgUDbgH1
    function mintTokens(address payable treasury1, address payable treasury2, string memory tokenURI_) 
        public 
        payable 
        validatePurchasePrice()
    {
        // Gas optimization
        uint256 _nextTokenId = nextTokenId;

        // Make sure presale has been set up
        require(treasury1 != address(0), "Dick: treasury1 is not set");
        require(treasury2 != address(0), "Dick: treasury2 is not set");
        require(tokenPrice > 0, "Dick: token price not set");

        // The contract never holds any Ether. Everything gets redirected to treasury directly.
        treasury1.transfer(msg.value / 2);
        treasury2.transfer(msg.value / 2);

        _safeMint(msg.sender, _nextTokenId);
        _tokenURIs[_nextTokenId] = tokenURI_;
        nextTokenId += 1;

        emit SaleMint(msg.sender);
    }
}