 

pragma solidity ^0.5.12;

interface DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) external view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}


interface OSMLike {
    function peep() external view returns (bytes32, bool);
}

interface Spotty {
    function ilks(bytes32) external view returns (PipLike pip, uint256 mat);
}

interface PipLike {
    function read() external view returns (bytes32);
}

interface EndLike {
    function spot() external view returns (Spotty);
}

contract BudConnector is DSAuth {

    mapping(address => bool) public authorized;
    OSMLike public osm;
    EndLike public end;

    constructor(OSMLike osm_, EndLike end_) public {
        osm = osm_;
        end = end_;
    }

    function authorize(address addr) external auth {
        authorized[addr] = true;
    }

    function peep() external returns (bytes32, bool) {
        require(authorized[msg.sender], "!authorized");
        return osm.peep();
    }

    function read(bytes32 ilk) external returns (bytes32) {
        require(authorized[msg.sender], "!authorized");
        (PipLike pip,) = end.spot().ilks(ilk);
        return pip.read();
    }
}