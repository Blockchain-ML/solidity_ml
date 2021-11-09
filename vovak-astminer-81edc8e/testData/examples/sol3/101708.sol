 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

pragma solidity >=0.5.12;

abstract contract PotLike {
    function drip() virtual external;
}

abstract contract JugLike {
    function drip(bytes32) virtual external;
}

abstract contract OsmLike {
    function poke() virtual external;
    function pass() virtual external view returns (bool);
}

abstract contract SpotLike {
    function poke(bytes32) virtual external;
}

contract MegaPoker {
    OsmLike constant public eth = OsmLike(0x81FE72B5A8d1A857d176C3E7d5Bd2679A9B85763);
    OsmLike constant public bat = OsmLike(0xB4eb54AF9Cc7882DF0121d26c5b97E802915ABe6);
    OsmLike constant public wbtc = OsmLike(0xf185d0682d50819263941e5f4EacC763CC5C6C42);
    PotLike constant public pot = PotLike(0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7);
    JugLike constant public jug = JugLike(0x19c0976f590D67707E62397C87829d896Dc0f1F1);
    SpotLike constant public spot = SpotLike(0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3);

    function poke() external {
        if (eth.pass()) eth.poke();
        if (bat.pass()) bat.poke();
        if (wbtc.pass()) wbtc.poke();
        
        spot.poke("ETH-A");
        spot.poke("BAT-A");
        spot.poke("WBTC-A");
        
        jug.drip("ETH-A");
        jug.drip("BAT-A");
        jug.drip("WBTC-A");
        jug.drip("USDC-A");
        jug.drip("USDC-B");
        jug.drip("TUSD-A");
        
        pot.drip();
    }
}