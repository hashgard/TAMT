pragma solidity ^0.4.24;

import { ERC20 } from "./interfaces/ERC20.sol";
import { IAssetPool } from "./interfaces/IAssetPool.sol";
import { ISwap } from "./interfaces/ISwap.sol";
import { Ownable } from "./ownership/Ownable.sol";

contract AssetPool is IAssetPool, Ownable {
    address[] public assetList;
    address[] public swapList;
    
    modifier isAsset(ERC20 asset) {
        require(isAssetExist(asset), "this is not asset");
        _;
	}
	
	function assetIndex(ERC20 asset) public view returns (int256) {
	    for(uint256 i = 0; i < assetList.length; i++) {
	        if(asset == assetList[i]){
	            return int256(i);
	        }
	    }
	    return -1;
	}
	
	function isAssetExist(ERC20 asset) public view returns (bool) {
	    if(assetIndex(asset) != int256(-1)){
	        return true;
	    }else {
	        return false;
	    }
	}
	
    function addAsset(ERC20 asset) public onlyOwner {
        require(!isAssetExist(asset), "the asset has been existed already");
        assetList.push(asset);
        emit AddAsset(asset);
    }
    
	function removeAsset(ERC20 asset) public isAsset(asset) onlyOwner {
	    if(assetIndex(asset) != int256(assetList.length - 1)) {
	        assetList[uint256(assetIndex(asset))] = assetList[assetList.length-1];
	    }
	    delete assetList[assetList.length-1];
        assetList.length--;
        emit RemoveAsset(asset);
	}
	
	function getAssetList() public view returns (address[]) {
        return assetList;
	}
	
	function withdrawERC20(ERC20 asset, address to, uint256 value) public onlyOwner returns(bool) {
	    require(asset.transfer(to, value));
	    emit WithdrawERC20(asset, to, value);
	    return true;
	}
	
	function approveERC20(ERC20 asset, address spender, uint256 value) public onlyOwner returns(bool) {
	    require(asset.approve(spender, value));
	    emit ApprovalERC20(asset, this, spender, value);
	    return true;
	}
	
	function withdrawETH(address to, uint256 value) public onlyOwner returns(bool) {
	    to.transfer(value);
	    emit WithdrawETH(to, value);
	    return true;
	}
	
	function depositETH() public payable {
	    if(msg.value > 0) {
	        emit DepositETH(msg.sender, msg.value);
	    }
	}
	
	function getETHBalance() public view returns(uint256) {
	    return address(this).balance;
	}
	
	modifier inSwapList(address swapContract) {
        require(isSwapExist(swapContract), "this is not in swapList");
        _;
	}
	
	function swapIndex(address swapContract) public view returns (int256) {
	    for(uint256 i = 0; i < assetList.length; i++) {
	        if(swapContract == swapList[i]){
	            return int256(i);
	        }
	    }
	    return -1;
	}
	
	function isSwapExist(address swapContract) public view returns (bool) {
	    if(swapIndex(swapContract) != int256(-1)){
	        return true;
	    }else {
	        return false;
	    }
	}
	
	function getSwapList() public view returns(address[]) {
	    return swapList;
	}
	
	function createSwap(
	    ERC20 _supplyToken,
	    uint256 _supplyTokenValue,
	    uint256 _supplyETH,
	    ERC20 _targetToken,
	    uint256 _targetTokenValue,
	    uint256 _targetETH,
	    uint256 _deadline
	) public onlyOwner returns (address) {
        if(_supplyToken != address(0)) {
	        require(isAssetExist(_supplyToken), "the supplyToken is not in assetList");   
	    }
	    
	    if(_targetToken != address(0)) {
	        require(isAssetExist(_targetToken), "the targetToken is not in assetList");   
	    }
	    
	    address swap = new Swap(_supplyToken, _supplyTokenValue, _supplyETH, _targetToken, _targetTokenValue, _targetETH, _deadline);
        if(_supplyToken != address(0)) {
            require(_supplyToken.approve(swap, _supplyTokenValue));
        }
        swapList.push(swap);
        emit CreateSwap(swap, _supplyToken, _supplyTokenValue, _supplyETH, _targetToken, _targetTokenValue, _targetETH, _deadline);
        
        return swap;
	}
	
	function swapETHHandler(address to, uint256 value) public inSwapList(msg.sender) returns (bool) {
	    to.transfer(value);
	    return true;
	}
	
	function deleteSwapHandler(bytes32 reason) public inSwapList(msg.sender) returns (bool) {
        if(swapIndex(msg.sender) != int256(swapList.length-1)) {
            swapList[uint256(swapIndex(msg.sender))] = swapList[swapList.length-1];
        }
        
        delete swapList[swapList.length-1];
        swapList.length--;
        emit DeleteSwap(msg.sender, reason);
        return true;
	}
	
	function cancelSwap(address swapContract) public onlyOwner inSwapList(swapContract) returns (bool) {
	    require(ISwap(swapContract).cancelSwapHandler());
        // if supplyToken exists, set the allowance to 0 
        if(ISwap(swapContract).supplyToken() != address(0)) {
            ERC20(ISwap(swapContract).supplyToken()).approve(swapContract, 0);
        }
	    return true;
	}
	
	function() public payable {}
}