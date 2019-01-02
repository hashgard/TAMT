pragma solidity ^0.4.24;

interface ITAMT {
	function transferRestriction(address from, address to, uint256 amount) external view returns(uint8);
	function restrictionMessage(uint8 reason) external view returns(string);
	function canPurchase() external view returns(bool);
	function purchaseSwitch(bool status) external;
	function purchase() external payable returns (bool);
	function canRedeem() external view returns(bool);
	function redeemSwitch(bool status) external;
	function redeem(uint256 value, address beneficiary) external returns (bool);
	
	event PurchaseSwitch(bool stauts);
	event RedeemSwitch(bool stauts);
	event Purchase(address purchaser, uint256 value);
	event Redeem(address redeemer, uint256 value, address beneficiary);
}