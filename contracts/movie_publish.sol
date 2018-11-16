//solium-disable linebreak-style
pragma solidity ^0.4.23;

contract movie_publish {
    uint256 movieTokenCounter;
    uint256 movieCounter; 
    address[] owners_list;
    struct file {
        uint256 id;
        string name;
        uint256 price;
    }
    struct movietoken{
        uint256 id;
        file movie;
        string ownerPkey;
        string movieHash;
    }
    file[] files_list;
    movietoken[] movieTokens_list;
    mapping (uint256 => address) file_to_owner;
    mapping (uint256 => uint) file_to_index;
    mapping (address => uint) owner_to_index;
    mapping (uint256 => uint) movietoken_to_index;
    mapping (uint256 => address) movietoken_to_owner;

    //events
    event MovieTokenPurchased(address sender, address movieOwner);

    function buyMovieToken(uint256 id, string _ownerPkey) public payable{
        uint256 weiAmount = msg.value;
        if (_validMovie(id)){
            if(_validAmount(id, weiAmount)){
                _createMovieToken(msg.sender, id, _ownerPkey);
                _forwardFunds(id);
            }
        }
        emit MovieTokenPurchased(msg.sender, file_to_owner[id]);
    }

    function createMovie(string _name, uint256 _price) public {
        if (!_exist(msg.sender)) owners_list.push(msg.sender);
        file memory movie;
        movieCounter++;
        movie.id = movieCounter;
        movie.name = _name;
        movie.price = _price;
        files_list.push(movie);
        file_to_index[movie.id] = files_list.length-1;
        file_to_owner[movie.id] = msg.sender;

    }

    function addHashToMovieToken (uint256 _id, string _hash) public {
        uint index = movietoken_to_index[_id];
        movieTokens_list[index].movieHash = _hash;
        emit HashReadyToPublish(
            movieTokens_list[index].movie.name,
            movietoken_to_owner[_id],
            _hash
        );
    }

    function _exist(address owner) private view returns(bool) { 
        for (uint i = 0; i < owners_list.length; i++){
            if (owners_list[i] == owner) break;
        }
        if (i == owners_list.length) return false;
        return true;
    }
    function _validMovie(uint256 id) private view returns(bool){
        if (file_to_owner[id] == address(0)) return false;
        return true;
    }    

    function _validAmount(uint256 id, uint256 weiAmount) private view returns(bool){
        file movieFile = files_list[file_to_index[id]];
        if (weiAmount < movieFile.price) return false;
        return true;
    }

    function _createMovieToken(address sender, uint256 id, string ownerPkey) private {
        movietoken memory token;
        movieTokenCounter++;
        token.id = movieTokenCounter;
        file movieFile = files_list[file_to_index[id]];
        token.movie = movieFile;
        token.ownerPkey = ownerPkey;
        movieTokens_list.push(token);
        movietoken_to_owner[token.id] = sender;
        movietoken_to_index[token.id] = movieTokens_list.length - 1;
    }    

    function _forwardFunds(uint256 id) private {
        file_to_owner[id].transfer(msg.value);
    }
     


}
