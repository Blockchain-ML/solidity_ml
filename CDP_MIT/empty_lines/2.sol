pragma solidity ^0.7.6;
contract foo {
function foo1(x){
	for (int i=1;i<=10;i++)
		x=x-1;
	return x;
}
function foo2(){
	y=y+z;
	x=y/foo1(z);
}
}
