# Asset Pool

+ eip: ERCxxx
+ title: Asset Pool
+ author:
+ status: Draft
+ type: Standards Track
+ category: ERC
+ created: 2018-10-xx
+ require: ERC20

# Simple Summary

A simple and interoperable standard interface for managing multiple assets.


# Abstract

With the rise of the concept of security tokenization, different classes of assets and equities in the real world will gradually be recorded on the blockchain, and be circulated in the form of tokens. The related financial service business will then be transferred to the blockchain.

We envision that platform that can manage various kinds of digital assets is needed for many business scenarios. In addition to being secure, transparent, to meet governance and regulatory requirements, it must also be able to integrate with technology platforms that support its related businesses.


# Motivation

For the token of ERC20, the balance of an address is not stored in the state of the ETH address, but is kept by the token's smart contract. Most ETH wallet applications record this info, and tell the user which tokens the address holds.
In some scenarios, smart contracts of some services need to have the functionality of a wallet application, such as managing the ETH and ERC20 tokens, and accepting multi-party supervision and governance.

We expect a universal `Asset Pool` contract standard designed to ease the burden on the integration process among users, platforms and business.


# Requirements 

In addition to the basic functions, such as asset injection and extraction, `Asset Pool` contract should provide an interface for atomic exchange, managers of the `Asset Pool` can exchange assets point-to-point, reduce the dependence on centralized exchanges.

Referring to asset custody, index fund and other specific scenarios, there's the following requirements:

+ MUST be able to hold ETH and all ERC20 tokens.
+ MUST be able to manage ERC20 asset items.
+ MUST have a standard interface to inject assets and extract assets.
+ MUST have a standard interface to exchange assets with other address in the contract layer.
+ Should provide interoperable interface to support related services.


# Specification

## Asset Items Management

The assets managed by the `Asset Pool` contract are divided into two categories: ETH and ERC20 tokens. ETH is the native coin of the Ethereum network, the ETH balance of the contract address is stored directly in the state of the address. But the balance of the ERC20 token is kept by the ERC20 token's contract, if `Asset Pool` contract want to transfer these ERC20 assets to other address, must call corresponding token contract externally. Others can transfer ERC20 tokens to the `Asset Pool` contract at any time. Therefore, it is recommended that the `Asset Pool` contract just keep the list of ERC20 assets' contract addresses, manage these assets by external calls.

### addAsset
This function allows the owner to add a new ERC20 asset to the asset items list.  
When called, this function MUST emit the `AddAsset` event.

```
function addAsset(ERC20 asset) external;
```

### removeAsset
This function allows the owner to remove a ERC20 asset from the asset items list.  
The `RemoveAsset` event must be emitted every time this function is called. 

```
function removeAsset(ERC20 asset) external;
```

### isAssetExist
Query whether the ERC20 contract address is in the asset items list or not.

```
function isAssetExist(ERC20 asset) external view returns (bool);
```

### getAssetList
Return the list of ERC20 asset items.

```
function getAssetList() external view returns (address[]);
```


## Asset Management
For ETH, all management operations can be implemented inside the Asset Pool contract. For ERC20 asset, contract can manage these tokens by external calls.

### withdrawERC20
This function allows contract owner to withdraw ERC20 tokens from the `Asset Pool` contract. This is done by calling the `transfer` function of the external ERC20 contract.  
The `WithdrawERC20` event must be emitted every time this function is called.

```
function withdrawERC20(ERC20 asset, address to, uint256 value) external returns(bool);
```

### approveERC20
This function allows contract owner approve ERC20 tokens to other address. This is done by calling the `approve` function of the external ERC20 contract.  
The `ApprovalERC20` event must be emitted every time this function is called.

```
function approveERC20(ERC20 asset, address spender, uint256 value) external returns(bool);
```

### withdrawETH
This function allows the contract owner to withdraw ETH from the `Asset Pool` contract to the specific address.  
The `WithdrawETH` event must be emitted every time this function is called.

```
function withdrawETH(address to, uint256 value) external returns(bool);
```

### depositETH
By this function, deposit ETH to the `Asset Pool` contract.  
The `DepositETH` event must be emitted every time this function is called.

```
function depositETH() external payable;
```

### getETHBalance
Get the ETH balance of the `Asset Pool` contract.

```
function getETHBalance() external view returns(uint256);
```

## Asset Swap
Asset pool contract should be able to achieve asset swapping with other addresses in the layer of contract. Swap form includes ETH-to-ERC20, ERC20-to-ERC20 and ERC20-to-ETH. The `Asset Pool` contract will create `Swap` contract to process asset swap, and maintain the list of `Swap` contract's address.

### createSwap
This function allows manager to create new a `Swap` contract. New Swap contract will be initialized and the address will be added to the asset swap list by this function. The arguments include the token’s contract address, token amount, ETH amount supplied by the `Asset Pool` contract, and contract address of target ERC20 token, target token amount, target ETH amount, as well as the deadline of the `Swap` contract. The `CreateSwap` event must be emitted every time this function is called.

```
function createSwap(
        ERC20 _supplyToken,
        uint256 _supplyTokenValue,
        uint256 _supplyETH,
        ERC20 _targetToken,
        uint256 _targetTokenValue,
        uint256 _targetETH,
        uint256 _deadline
    ) external returns (address);
```

### cancelSwap
This function allows manager to cancel the specific asset swap contract, this function will call the `cancelSwapHandler`  function of the external `Swap` contract.  
If external call failed, this function must be reverted.

```
function cancelSwap(address swapContract) external returns (bool);
```

### isSwapExist
Query if current asset swap contract list contains the specific `Swap` contract.

```
function isSwapExist(address swapContract) external view returns (bool);
```

### getSwapList
Return the list of current asset swap contract list.

```
function getSwapList() external view returns(address[]);
```

### deleteSwapHandler
This function can only be called externally by these `Swap` contracts which exist in the asset swap contract list，will remove the caller address from the asset swap contract list.  
When called, this function MUST emit the `DeleteSwap` event, and indicate the reason for deletion.

```
function deleteSwapHandler(bytes32 reason) external returns (bool);
```

### swapETHHandler
This function can only be called by these `Swap` contracts which exist in the asset swap contract list，will transfer ETH to the caller address.

```
function swapETHHandler(address to, uint256 value) external returns (bool);
```


## Swap Contract
`Swap` contract will be created by createSwap function of the `Asset Pool` contract, to process asset swap logic, must be interoperable with the `Asset Pool` contract in both directions. There is coupling between Swap contract and `Asset Pool` contract.

### seller
Return the seller address of this `Swap` contract (i.e. the creator of the `Swap` contract).

```
function seller() external view returns(address);
```

### supplyToken
Return the contract address of the ERC20 token for sale.

```
function supplyToken() external view returns(address);
```

### supplyTokenValue
Return the amount of ERC20 token for sale.

```
function supplyTokenValue() external view returns(uint256);
```

### supplyETH
Return the ETH amount for sale.

```
function supplyETH() external view returns(uint256);
```

### targetToken
Return the target ERC20 token's address of the `Swap` contract.

```
function targetToken() external view returns(address);
```

### targetTokenValue
Return the target ERC20 token's amount of the `Swap` contract.

```
function targetTokenValue() external view returns(uint256);
```

### targetETH
Return the target ETH amount of the Swap contract.

```
function targetETH() external view returns(uint256);
```

### deadline
Return the deadline that can swap with the `Swap` contract.

```
function deadline() external view returns(uint256);
```

### swapStatus
Return the current status of the Swap contract, the returned result may be  0, 1 or 2, indicates waiting for swap, completed or canceled respectively.

```
function swapStatus() external view returns(uint8);
```

### doSwap
Calling this function can execute the swap process. If `targetETH` is not 0, must send enough ETH must be sent with the call. If `targetToken` exists, buyer need to approve  enough amount (greater than `targetTokenValue`) to the `Swap` contract before the call, and then call this function. If the balance of the buyer address in `targetToken` contract is not enough, the swap will fail.  
The `SwapDone` event must be emitted every time this function is called.

```
function doSwap() external payable returns(bool);
```

### cancelSwapHandler
This function can only be called by the seller. Will change the status of the Swap contract, and call seller's `deleteAssetSwapHandler` function externally.

```
function cancelSwapHandler() external returns (bool);
```

## Interface
```

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
	function createSwap(
        ERC20 _supplyToken,
        uint256 _supplyTokenValue,
        uint256 _supplyETH,
        ERC20 _targetToken,
        uint256 _targetTokenValue,
        uint256 _targetETH,
        uint256 _deadline
    ) external returns (address);
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
```

## Notes

`Asset Pool` contract creates `Swap` contract and use a list to keep all addresses of effective `Swap` contracts, `Asset Pool` contract must be interoperable with the Swap contract in both directions to support the execution of asset swap.

The `Swap` contract itself does not hold the ERC20 token or ETH for sale. If `Asset Pool` contract supplies ERC20 asset for swap，`createSwap` function will approve ERC20 token (amount is equal to supplyTokenValue) to the `Swap` contract. If it supplies ETH to `Swap` contract, when `doSwap` function is called in `Swap` contract, the `doSwap` function will then call the `supplyEthHandler` function externally to transfer ETH to the buyer address.

During swap process, the seller is `Asset Pool` contract, any other address can be the buyer to call the `doSwap` function of the `Swap` contract. If the buyer uses ERC20 token(`supplyToken`) to swap, the buyer need to approve enough amount of target ERC20 token to the `Swap` contract. Then, by calling the `doSwap` function, `transferFrom` will be executed to transfer ERC20 from the buyer to the seller. If the buyer use ETH to swap, the buyer can call the `doSwap` function directly, and need to attach enough ETH in the value field of the tx, then `doSwap` function will forward these ETH to the seller.

We believe our design is both flexible and secure, `Swap` contract does not hold the balance of the ETH or ERC20 tokens, just hold the approve amount of `Asset Pool` contract. It's also convenient for the buyer because the actual transfer only occurs when the call succeeds. You can cancel the approve to the `Swap` contract at any time. There's no need to add the refund function. In addition, this is beneficial for the `Asset Pool` contract. When `Asset Pool` creates a `Swap` contract, it does not transfer the assets for sale to `Swap` contract, so the `Asset Pool` contract can create many `Swap` contracts for different target assets with same amount, even if the balance of the `Asset Pool` contract does not hold enough balance, you can still create sell order. Before the exchange is completed, the supply asset is stored in the `Asset Pool` contract all the time, which is convenient for calculating the net pool value.

# TAMT

+ eip: ERCxxx
+ title: Trusted Asset Management Token (TAMT)
+ author:
+ status: Draft
+ type: Standards Track
+ category: ERC
+ created: 2018-10-xx
+ require: Asset Pool，ERC20


# Simple Summary
A standard interface for the issuance and management of token fund shares.


# Abstract
At present, some projects have achieved security token offering successfully -- under the supervision of the local security regulatory commission, these projects use tokens to represent the ownership of shares or interests, in order to improve the liquidity of security, and reduce the cost of issuance.

Corresponding to funds in the traditional security market, we need a simple and extendable standard to carry out business related to digital assets fund. TAMT is a based on `Asset Pool` standard, representing the ownership of the portfolio (ETH and ERC20 tokens), similar to the fund shares in the traditional finance.


# Motivation
With the development of the cryptocurrency market, many platforms have launched related fund products. Investors use cryptocurrency to purchase fund shares and entrust the managers to invest and gain profits. But most of the process is off the blockchain, still using the traditional assets management model. The entire process of assets management is not transparent enough, and the rights of the investors are often not guaranteed. We expect to be able to use a set of standards to make business processes as much as possible on the blockchain.

Therefore, we have designed the following interface, not only to complete the confirmation between the investor-owned fund share and the portfolio on the blockchain, but also the process of fund management and the history of investment are recorded on-chain, which enhances the reliability and trustfulness of the business.


# Requirements
A fund has two parties: the fund share and the underlying assets. The fund share can be represented by token, so the interface of TAMT should inherit from ERC20. The underlying assets are composed of some ERC20 tokens and ETH, Asset Pool standard provides related support. In addition, there are some specific conversion operations behaviors between the fund shares and the underlying assets: issuance, redemption, dividends, etc. We need a common interface to implement these functions.

Furthermore, token transfer need some restriction rules to be compliant with security laws and other contractual obligations.


# Specification

## Transfer Restriction

### transferRestriction
This function judges the token transfer restriction, the logic is implemented by issuer. The judgment must be performed inside the `transfer` and `transferFrom` function.

```
function transferRestriction(address from, address to, uint256 amount) external view returns(uint8);
```

### restrictionMessage
This function provides human-readable explanation of the reason code returned by `transferRestriction` function.

```
function restrictionMessage(uint8 reason) external view returns(string);
```

## Purchase

### canPurchase
Query if the fund is currently allowed to be purchased.

```
function canPurchase() external view returns(bool);
```

### purchaseSwitch
This function can only be called by the owner of the contract, to enable able or disable the purchase function of fund shares.    
The `PurchaseSwitch` event must be emitted every time this function is called.

```
function purchaseSwitch(bool status) external;
```

### purchase
Purchase fund shares by calling this function.  
The `Purchase` event must be emitted every time this function is called.

```
function purchase() external payable;
```

## Redeem

### canRedeem
Query if the fund is currently allowed to be redeemed.

```
function canRedeem() external view returns(bool);
```

### redeemSwitch
This function can only be called by the owner of the contract, to enable or disable the redemption of fund shares.  
The `RemeptionSwitch` event must be emitted every time this function is called.

```
function redeemSwitch(bool status) external;
```

### redeem
The holders of the fund shares can call this function to redeem fund of specific amount. The underlying assets will be sent back to the specific address in proportion, and the redeemed fund shares token must be destroyed from the total supply.  
The `Redeem` event must be emitted every time this function is called.

```
function redeem(uint256 value, address beneficiary) external;
```

## Interface
```
interface ITAMT is ERC20, IAssetPool {
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
```

# Backwards Compatibility
TAMT is fully backwards compatible with ERC20.