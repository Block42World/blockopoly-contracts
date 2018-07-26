pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "./World.sol";

/**
* @title Block42 land token contract
* @author Richard Fu (richardf@block42.world)
* @dev Complant with OpenZeppelin's implementation of the ERC721 spec
*
*/

contract Land is ERC721Token, Pausable {

  World internal world_;

  // Mapping from token id to it's width
  mapping(uint256 => uint16) internal widths_;

  // Mapping from token id to it's height
  mapping(uint256 => uint16) internal heights_;

  /**
  * @dev Constructor function
  */
  constructor(string _name, string _symbol, address _worldAddress) public
    ERC721Token(_name, _symbol) {
      world_ = World(_worldAddress);
  }

  /**
   * @dev Don't accept payment directly to contract
   */
  function() public payable {
    revert();
  }

  /**
   * @dev Throws if position not within valid range
   */
  modifier validPosition(uint32 _world, int64 _x, int64 _y) {
    require(isValidPosition(_world, _x, _y));
    _;
  }

  function isValidPosition(uint32 _world, int64 _x, int64 _y) internal pure returns (bool) {
    return _world >=0 && _world < 4e9 && _x > -1e12 && _x < 1e12 && _y > -1e12 && _y < 1e12;
  }

  /**
   * @dev Throws if size not within valid range
   */
  modifier validSize(uint16 _w, uint16 _h) {
    require(isValidSize(_w, _h));
    _;
  }

  function isValidSize(uint16 _w, uint16 _h) internal pure returns (bool) {
    return _w < 1e9 && _h < 1e9 && _w % 2 != 0 && _h %2 != 0;
  }

  /**
   * @dev Throws if called by any account other than the world owner or contract owner.
   */
  modifier onlyWorldOrContractOwner(uint32 _world) {
    require(msg.sender == world_.ownerOf(_world) || msg.sender == owner);
    _;
  }

  uint256 private constant FACTOR_WORLD = 0x0000000100000000000000000000000000000000000000000000000000000000;
  uint256 private constant FACTOR_X =     0x0000000000000000000000000000000000010000000000000000000000000000;
  uint256 private constant BITS_WORLD =   0xffffffff00000000000000000000000000000000000000000000000000000000;
  uint256 private constant BITS_X =       0x00000000ffffffffffffffffffffffffffff0000000000000000000000000000;
  uint256 private constant BITS_Y =       0x000000000000000000000000000000000000ffffffffffffffffffffffffffff;

  /**
   * @dev Encode world-index, x and y into a token ID
   * World has to be within 4B (2^32), x/y has to be within +- 1T (2^63)
   * Token ID is 256 bits, 32 bits for world, 112 bits each for x and y
   * @param _world uint32 world index start with 0 and max of 4B
   * @param _x int64 x-coordinate of the land, from -1T to +1T
   * @param _y int64 y-coordinate of the land, from -1T to +1T
   * @return uint256 representing the NFT identifier
   */
  function encodeTokenId(uint32 _world, int64 _x, int64 _y) public pure validPosition(_world, _x, _y) returns (uint256) {
    return ((_world * FACTOR_WORLD) & BITS_WORLD) | ((uint256(_x) * FACTOR_X) & BITS_X) |  (uint256(_y) & BITS_Y);
  }

  /**
   * @dev Decode a token ID into world-index, x and y
   * World has to be within 4B, x/y has to be within +- 1T
   * @param _tokenId the NFT identifier
   */
  function decodeTokenId(uint256 _tokenId) public pure returns (uint32 _world, int64 _x, int64 _y) {
    _world = uint8((_tokenId & BITS_WORLD) >> 224); // shift right for 2x112 bits
    _x = int32((_tokenId & BITS_X) >> 112); // shift right for 112 bits
    _y = int32(_tokenId & BITS_Y);
    require(isValidPosition(_world, _x, _y));
  }

  /**
   * @dev Gets the owner of the specified position
   */
  function ownerOf(uint32 _world, int64 _x, int64 _y) public view returns (address) {
    return ownerOf(encodeTokenId(_world, _x, _y));
  }

  /**
   * @dev Returns whether the specified land exists
   */
  function exists(uint32 _world, int64 _x, int64 _y) public view returns (bool) {
    return exists(encodeTokenId(_world, _x, _y));
  }

  /**
   * @dev Gets all owned lands of an account
   */
  function landsOf(address _owner) external view returns (uint32[], int64[], int64[]) {
    uint256 length = ownedTokens[_owner].length;
    uint32[] memory worlds = new uint32[](length);    
    int64[] memory xs = new int64[](length);
    int64[] memory ys = new int64[](length);
    uint32 world;
    int64 x;
    int64 y;
    for (uint i = 0; i < length; i++) {
      (world, x, y) = decodeTokenId(ownedTokens[_owner][i]);
      worlds[i] = world;
      xs[i] = x;
      ys[i] = y;
    }
    return (worlds, xs, ys);
  }

  /**
   * @dev Gets all owned lands of an account in a world
   */
  function landsOf(uint32 _world, address _owner) external view returns (int64[], int64[]) {
    uint256 length = ownedTokens[_owner].length;
    int64[] memory xs = new int64[](length);
    int64[] memory ys = new int64[](length);
    uint32 world;
    int64 x;
    int64 y;
    for (uint i = 0; i < length; i++) {
      (world, x, y) = decodeTokenId(ownedTokens[_owner][i]);
      if (world == _world) {
        xs[i] = x;
        ys[i] = y;
      }
    }
    return (xs, ys);
  }

  /**
   * @dev Creates a land for sale, only world owner or contract owner
   * Checking map overlap should be done in client side before
   */
  function create(uint32 _world, int64 _x, int64 _y, uint16 _w, uint16 _h) public onlyWorldOrContractOwner(_world) validPosition(_world, _x, _y) validSize(_w, _h) {
    uint256 tokenId = encodeTokenId(_world, _x, _y);
    super._mint(msg.sender, tokenId);
    widths_[tokenId] = _w;
    heights_[tokenId] = _h;
  }

  /**
   * @dev Destroys a land, only world owner or contract owner for their lands
   */
  function detroy(uint32 _world, int64 _x, int64 _y) public onlyWorldOrContractOwner(_world) validPosition(_world, _x, _y) {
    destroy(encodeTokenId(_world, _x, _y));
  }

  /**
   * @dev Destroys a land, only land owner, or approved person/contract
   */
  function destroy(uint256 _tokenId) public {
    require(isApprovedOrOwner(msg.sender, _tokenId));
    _burn(msg.sender, _tokenId);
  }

  /**
   * @dev Gets all alnds in array
   * @return array of x, y, w, h
   */
  function allLands(uint32 _checkWorld) public view returns (int64[], int64[]) {
    int64[] memory _xs = new int64[](allTokens.length);
    int64[] memory _ys = new int64[](allTokens.length);
    for (uint i = 0; i < allTokens.length; i++) {
      (uint32 _world, int64 _x, int64 _y) = decodeTokenId(allTokens[i]);
      if (_checkWorld != _world)
        continue;
      _xs[i] = _x;
      _ys[i] = _y;
    }
    return (_xs, _ys);
  }

  /**
   * @dev Resizes an existing land, only world owner or contract owner
   * Checking map overlap should be done in client side before
   */
  function resize(uint32 _world, int64 _x, int64 _y, uint16 _w, uint16 _h) public onlyWorldOrContractOwner(_world) validPosition(_world, _x, _y) validSize(_w, _h) {
    uint256 tokenId = encodeTokenId(_world, _x, _y);
    widths_[tokenId] = _w;
    heights_[tokenId] = _h;
  }

  /**
   * @dev Returns an URI for a given position
   * Throws if the land at the position does not exist. May return an empty string.
   */
  function tokenURI(uint32 _world, int64 _x, int64 _y) public view returns (string) {
    return tokenURI(encodeTokenId(_world, _x, _y));
  }

  /**
   * @dev Returns an URI for a given token ID
   * Throws if the token ID does not exist. May return an empty string.
   * @param _tokenId uint256 ID of the token to query
   */
  function tokenURI(uint256 _tokenId) public view returns (string) {
    bytes memory uriByte = bytes(tokenURIs[_tokenId]);
    if (uriByte.length == 0) {
      (uint32 world, int64 x, int64 y) = decodeTokenId(_tokenId);
      return string(abi.encodePacked("http://api.block42.world/lands/", _uint32ToString(world), "/", _int2str(x), "/", _int2str(y)));
    }
  }

  function _uint32ToString(uint32 i) internal pure returns (string) {
    return _int2str(int(i));
  }

  function _int2str(int i) internal pure returns (string){
      if (i == 0) return "0";
      bool negative = i < 0;
      uint j = uint(negative ? -i : i);
      uint l = j;     // Keep an unsigned copy
      uint len;
      while (j != 0){
          len++;
          j /= 10;
      }
      if (negative) ++len;  // Make room for '-' sign
      bytes memory bstr = new bytes(len);
      uint k = len - 1;
      while (l != 0){
          bstr[k--] = byte(48 + l % 10);
          l /= 10;
      }
      if (negative) {    // Prepend '-'
          bstr[0] = '-';
      }
      return string(bstr);
  }

}