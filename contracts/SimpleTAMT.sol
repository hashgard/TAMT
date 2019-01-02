pragma solidity ^0.4.24;

import { SafeMath } from "./math/SafeMath.sol";
import { ERC20 } from "./interfaces/ERC20.sol";
import { ITAMT } from "./interfaces/ITAMT.sol";
import { AssetPool } from "./AssetPool.sol";
import { StandardToken } from "./StandardToken.sol";
import { Ownable } from "./ownership/Ownable.sol";

contract SimpleTAMT is ITAMT, Ownable, AssetPool, StandardToken {
    using SafeMath for uint256;
    
    string public name;
	string public symbol;
	uint8 public decimals;
    uint8 public constant SUCCESS_CODE = 0;
    string public constant SUCCESS_MESSAGE = "SUCCESS";
    bool public canPurchase;
    bool public canRedeem;
    uint256 public fractions;
    uint256 public numerator;
    
    constructor(string _name, string _symbol, uint8 _decimals, uint256 _total, uint256 _fractions, uint256 _numerator) public {
        name = _name;
		symbol = _symbol;
		decimals = _decimals;
		totalSupply_ = _total.mul(10 ** uint256(_decimals));
    	balances[msg.sender] = totalSupply_;
    	fractions = _fractions;
    	numerator = _numerator;
    	emit Transfer(address(0), msg.sender, totalSupply_);
    }
    
    function canPurchase() public view returns(bool) {
        return canPurchase;
    }
    
    function canRedeem() public view returns(bool) {
        return canRedeem;
    }

    modifier notInRestriction(address from, address to, uint256 value) {
        uint8 restrictionCode = transferRestriction(from, to, value);
        require(restrictionCode == SUCCESS_CODE, restrictionMessage(restrictionCode));
        _;
    }
    
    function transferRestriction(address from, address to, uint256 value) public view returns (uint8) {
        return SUCCESS_CODE;
    }
        
    function restrictionMessage(uint8 restrictionCode) public view returns (string) {
        if (restrictionCode == SUCCESS_CODE) {
            return SUCCESS_MESSAGE;
        }
    }
    
    function transfer(address to, uint256 value) public notInRestriction(msg.sender, to, value) returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom (address from, address to, uint256 value) public notInRestriction(from, to, value) returns (bool) {
        return super.transferFrom(from, to, value);
    }
    
    function _mint(address account, uint256 value) internal returns (bool) {
  	    totalSupply_ = totalSupply_.sub(value);
  	    balances[account] = balances[account].add(value);
  	    emit Transfer(address(0), account, value);
  	    return true;
  	}
  	
  	function _burn(address account, uint256 value) internal returns (bool) {
  	    require(value <= balances[account]);
  	    totalSupply_ = totalSupply_.sub(value);
        balances[account] = balances[account].sub(value);
        emit Transfer(account, address(0), value);
        return true;
  	}
  	
  	function purchaseSwitch(bool status) public onlyOwner {
        require(canPurchase != status);
        canPurchase = status;
        emit PurchaseSwitch(status);
    }
    
    function redeemSwitch(bool status) public onlyOwner {
        require(canRedeem != status);
        canRedeem = status;
        emit RedeemSwitch(status);
    }
    
    function purchase() public payable returns (bool) {
        require(canPurchase);
        uint256 value = msg.value.mul(fractions).div(numerator);
        _mint(msg.sender, value);
        emit Purchase(msg.sender, value);
        return true;
    }
    
    function redeem(uint256 value, address beneficiary) public returns (bool) {
        require(canRedeem);
        require(beneficiary != address(0));
        require(value > 0 && value <= balances[msg.sender]);
        
        _burn(msg.sender, value);
        
        // redeem ETH
        uint256 redeemWei = (address(this).balance).mul(value).div(totalSupply_);
        if(redeemWei > 0){
            beneficiary.transfer(redeemWei);
        }
        
        // redeem ERC20
        for(uint256 i = 0; i < assetList.length; i++){
            uint256 totalToken = ERC20(assetList[i]).balanceOf(address(this));
            if(totalToken > 0) {
                uint256 amount = totalToken.mul(value).div(totalSupply_);
                if(amount > 0) {
                    require(ERC20(assetList[i]).transfer(beneficiary, amount));
                }
            }
        }
        
        emit Redeem(msg.sender, value, beneficiary);
        return true;
    }
} 
