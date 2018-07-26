pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

/**
* @title Block42 land token contract
* @author Richard Fu (richardf@block42.world)
* @dev Complant with OpenZeppelin's implementation of the ERC721 spec
*
*/

contract World is ERC721Token, Pausable {

  /**
  * @dev Constructor function
  */
  constructor(string _name, string _symbol) public
    ERC721Token(_name, _symbol)
  { }

  /**
   * @dev Create a new world and assign to himself, contract owner only
   * @param _tokenId uint256 ID of the token
   */
  function create(uint256 _tokenId) public onlyOwner {
    createAndTransfer(msg.sender, _tokenId);
  }

  /**
   * @dev Create a new world and assign to someone, contract owner only
   * @param _tokenId uint256 ID of the token
   */
  function createAndTransfer(address _to, uint256 _tokenId) public onlyOwner {
    require(!exists(_tokenId));
    _mint(_to, _tokenId);
  }

  /** 
   * @dev Owner of contract can retake the ownership of a world, ONLY when world 
   * owner is extremely inactive or damaging the community
   * @param _tokenId uint256 ID of the token to expropriate
   */
  function expropriate(uint256 _tokenId) public onlyOwner {
    address owner = ownerOf(_tokenId);
    clearApproval(owner, _tokenId);
    removeTokenFrom(owner, _tokenId);
    addTokenTo(msg.sender, _tokenId);
    emit Transfer(owner, msg.sender, _tokenId);
  }

}