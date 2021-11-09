 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

pragma solidity >=0.5.12;

interface OsmLike {
    function poke() external;
    function pass() external view returns (bool);
}

interface SpotLike {
    function poke(bytes32) external;
}

contract MegaPoker {
    OsmLike constant eth  = OsmLike(0x81FE72B5A8d1A857d176C3E7d5Bd2679A9B85763);
    OsmLike constant bat  = OsmLike(0xB4eb54AF9Cc7882DF0121d26c5b97E802915ABe6);
    OsmLike constant wbtc = OsmLike(0xf185d0682d50819263941e5f4EacC763CC5C6C42);
    OsmLike constant knc  = OsmLike(0xf36B79BD4C0904A5F350F1e4f776B81208c13069);
    OsmLike constant zrx  = OsmLike(0x7382c066801E7Acb2299aC8562847B9883f5CD3c);
    OsmLike constant mana = OsmLike(0x8067259EA630601f319FccE477977E55C6078C13);
    OsmLike constant usdt = OsmLike(0x7a5918670B0C390aD25f7beE908c1ACc2d314A3C);
    OsmLike constant comp = OsmLike(0xBED0879953E633135a48a157718Aa791AC0108E4);
    OsmLike constant link = OsmLike(0x9B0C694C6939b5EA9584e9b61C7815E8d97D9cC7);
    OsmLike constant lrc  = OsmLike(0x9eb923339c24c40Bef2f4AF4961742AA7C23EF3a);
    SpotLike constant spot = SpotLike(0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3);

    function poke() external {
        if ( eth.pass())  eth.poke();
        if ( bat.pass())  bat.poke();
        if (wbtc.pass()) wbtc.poke();
        if ( knc.pass())  knc.poke();
        if ( zrx.pass())  zrx.poke();
        if (mana.pass()) mana.poke();
        if (usdt.pass()) usdt.poke();
        if (comp.pass()) comp.poke();
        if (link.pass()) link.poke();
        if ( lrc.pass())  lrc.poke();

        spot.poke("ETH-A");
        spot.poke("BAT-A");
        spot.poke("WBTC-A");
        spot.poke("KNC-A");
        spot.poke("ZRX-A");
        spot.poke("MANA-A");
        spot.poke("USDT-A");
        spot.poke("COMP-A");
        spot.poke("LINK-A");
        spot.poke("LRC-A");
    }

    function pokeTemp() external {
        if ( eth.pass())  eth.poke();
        if ( bat.pass())  bat.poke();
        if (wbtc.pass()) wbtc.poke();
        if ( knc.pass())  knc.poke();
        if ( zrx.pass())  zrx.poke();
        if (mana.pass()) mana.poke();
        if (usdt.pass()) usdt.poke();
        if (comp.pass()) comp.poke();
        if (link.pass()) link.poke();
        if ( lrc.pass())  lrc.poke();

        spot.poke("ETH-A");
        spot.poke("BAT-A");
        spot.poke("WBTC-A");
        spot.poke("KNC-A");
        spot.poke("ZRX-A");
        spot.poke("MANA-A");
        spot.poke("USDT-A");
    }
}