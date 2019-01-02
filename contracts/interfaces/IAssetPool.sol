pragma solidity ^0.4.24;

import { ERC20 } from "./ERC20.sol";

interface IAssetPool {
	function addAsset(ERC20 asset) external;
	function removeAsset(ERC20 asset) external;
	function isAssetExist(ERC20 asset) external view returns (bool);
	function getAssetList() external view returns (address[]);
	function withdrawERC20(ERC20 asset, address to, uint256 value) external returns(bool);
	function approveERC20(ERC20 asset, address spender, uint256 value) external returns(bool);
	function withdrawETH(address to, uint256 value) external returns(bool);
	function depositETH() external payable;
	function getETHBalance() external view returns(uint256);
	function createSwap(ERC20 _supplyToken, uint256 _supplyTokenValue, uint256 _supplyETH, ERC20 _targetToken, uint256 _targetTokenValue, uint256 _targetETH, uint256 _deadline) external returns (address);
	function cancelSwap(address swapContract) external returns (bool);
	function isSwapExist(address swapContract) external view returns (bool);
	function getSwapList() external view returns(address[]);
	function deleteSwapHandler(bytes32 reason) external returns (bool);
	function swapETHHandler(address to, uint256 value) external returns (bool);

	event AddAsset(address indexed asset);
	event RemoveAsset(address indexed asset);
	event WithdrawERC20(address indexed asset, address to, uint256 value);
	event ApprovalERC20(address indexed asset, address indexed owner, address indexed spender, uint256 value);
	event WithdrawETH(address indexed to, uint256 value);
	event DepositETH(address indexed from, uint256 value);	
	event CreateSwap(address indexed swapContract, address indexed supplyToken, uint256 supplyValue, uint256 supplyETH, address indexed targetToken, uint256 targetValue, uint256 targetETH, uint256 deadline);
	event DeleteSwap(address indexed swapContract, bytes32 reason);
}