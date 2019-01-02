pragma solidity ^0.4.24;

interface ISwap {
	function seller() external view returns(address);
	function supplyToken() external view returns(address);
	function supplyTokenValue() external view returns(uint256);
	function supplyETH() external view returns(uint256);
	function targetToken() external view returns(address);
	function targetTokenValue() external view returns(uint256);
	function targetETH() external view returns(uint256);
	function deadline() external view returns(uint256);
	function swapStatus() external view returns(uint8);	
	function doSwap() external payable returns(bool);
	function cancelSwapHandler() external returns (bool);
	
	event SwapDone(address seller, address buyer, address supplyToken, uint256 supplyValue, uint256 supplyETH, address targetToken, uint256 targetValue, uint256 targetETH);
}