pragma solidity ^0.4.24;

 

library SafeMath {
    int256 constant private INT256_MIN = -2**255;

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function mul(int256 a, int256 b) internal pure returns (int256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN));  

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        require(b > 0);
        uint256 c = a / b;
         

        return c;
    }

     
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0);  
        require(!(b == -1 && a == INT256_MIN));  

        int256 c = a / b;

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

     
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

     
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

     
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract LWIAY is Ownable {
    
    using SafeMath for uint;
    
    event NewEpisode(uint id);
    event NewMeme(uint id);
    event EpisodeEdited(uint id);
    event MemeEdited(uint id);
    
    uint public episodeCount;
    uint public memeCount;
    uint public totalPaid;  
    
     
    mapping(uint => string) payouts;
    
     
    mapping(uint => uint[]) episodeToMemes;
    
    
    struct Episode {
        string title;
        string url;
        uint32 date;
    }
    
    
    struct Meme {
        string author;
        string title;
        string url;
        string thumbnail;
        uint reward;
    }
    
    
    Episode[] public episodes;
    Meme[] public memes;


    function addEpisode(
        string memory _title,
        string memory _url,
        uint32 _date
    ) 
    
    public onlyOwner {
        uint id = episodes.push(Episode(
            _title, 
            _url,
            _date
        )) -1;
        
        episodeCount++;
        emit NewEpisode(id);
    }
    
    
    function addMeme(
        string memory _author,
        string memory _title,
        string memory _url,
        string memory _thumbnail,
        uint _reward,
        uint _episode
    ) 
    
    public onlyOwner {
        uint id = memes.push(Meme(
            _author,
            _title,
            _url,
            _thumbnail,
            _reward)) -1;
        
        memeCount++;
        episodeToMemes[_episode].push(uint(id));
        emit NewMeme(id);
    }
    
    
    function editEpisode(uint _id, string _title, string _url, uint32 _date) external onlyOwner {
        episodes[_id].title = _title;
        episodes[_id].url = _url;
        episodes[_id].date = _date;
        
        emit EpisodeEdited(_id);
    }
    

    function editMemes(uint _id, string _author, string _title, string _url, string _thumbnail, uint _reward) external onlyOwner {
        memes[_id].author = _author;
        memes[_id].title = _title;
        memes[_id].url = _url;
        memes[_id].thumbnail = _thumbnail;
        memes[_id].reward = _reward;
        
        emit MemeEdited(_id);
    }
    
    
    function addPayout(uint _id, uint _amount, string _hash) external onlyOwner {
        payouts[_id] = _hash;
        totalPaid = totalPaid.add(_amount);
    }
    
    
    function getMemesForEpisode(uint _id) external view returns (uint[]) {
        return episodeToMemes[_id];
    }
    
    
    function getEpisodeData(uint _id) external view returns (string, string, uint32) {
        return (episodes[_id].title, episodes[_id].url, episodes[_id].date);
    }
    
    
    function getMemeData(uint _id) external view returns (string, string, string, string, uint) {
        return (memes[_id].author, memes[_id].title, memes[_id].url, memes[_id].thumbnail, memes[_id].reward);
    }


}