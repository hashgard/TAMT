import { ERC20 } from "./interfaces/ERC20.sol";

contract Swap is ISwap {
    address public seller;
    address public supplyToken;
    uint256 public supplyTokenValue;
    uint256 public supplyETH;
    address public targetToken;
    uint256 public targetTokenValue;
    uint256 public targetETH;
    uint256 public deadline;
    
    enum Status { WaitSwap, SwapDone, Canceled }
    Status public swapStatus;
    
    constructor(address _supplyToken, uint256 _supplyTokenValue, uint256 _supplyETH, address _targetToken, uint256 _targetTokenValue, uint256 _targetETH, uint256 _deadline) public {
        require(_deadline > now);
        require(( _supplyToken != address(0) && _supplyTokenValue != uint256(0) ) || _supplyETH != uint256(0));
        require(( _targetToken != address(0) && _targetTokenValue != uint256(0) ) || _targetETH != uint256(0));
        
        seller = msg.sender;
        deadline = _deadline;
        supplyToken = _supplyToken;
        supplyTokenValue = _supplyTokenValue;
        supplyETH = _supplyETH;
        targetToken = _targetToken;
        targetTokenValue = _targetTokenValue;
        targetETH = _targetETH;
        swapStatus = Status.WaitSwap;
    }
    
	function seller() public view returns(address) {
        return seller;
    }
    
	function supplyToken() public view returns(address) {
	    return supplyToken;
	}
	
	function supplyTokenValue() public view returns(uint256) {
	    return supplyTokenValue;
	}
	
	function supplyETH() public view returns(uint256) {
	    return supplyETH;
	}
	
	function targetToken() public view returns(address) {
	    return targetToken;
	}
	
	function targetTokenValue() public view returns(uint256) {
	    return targetTokenValue;
	}
	
	function targetETH() public view returns(uint256) {
	    return targetETH;
	}
	
	function deadline() public view returns(uint256) {
	    return deadline;    
	}
	function swapStatus() public view returns(uint8) {
	    return uint8(swapStatus);
	}
	
	function doSwap() public payable returns(bool) {
	    require(now <= deadline);
        require(swapStatus == Status.WaitSwap);
        
        // do swap
        if(targetToken != address(0)) {
            require(ERC20(targetToken).transferFrom(msg.sender, seller, targetTokenValue), "you transfer targetToken to seller failed");
        }
        if(targetETH != uint256(0)) {
            require(msg.value >= targetETH, "the ETH you send is sufficient");
            seller.transfer(msg.value);
        }
        if(supplyToken != address(0)) {
            require(ERC20(supplyToken).transferFrom(seller, msg.sender, supplyTokenValue), "buyer transfer supplyToken to you failed");
        }
        if(supplyETH != uint256(0)) {
            require(IAssetPool(seller).swapETHHandler(msg.sender, supplyETH), "seller transfer ETH to you failed");
        }
        swapStatus = Status.SwapDone;
        require(IAssetPool(seller).deleteSwapHandler(bytes32("done")));
        emit SwapDone(seller, msg.sender, supplyToken, supplyTokenValue, supplyETH, targetToken, targetTokenValue, targetETH);
        return true;
	}
	
	function cancelSwapHandler() public returns (bool) {
	    require(msg.sender == seller, "the caller must be the seller");
        require(swapStatus == Status.WaitSwap, "the swapStatus is not WaitSwap");
        require(IAssetPool(seller).deleteSwapHandler(bytes32("cancel")));
        
        // change the swap status
        swapStatus = Status.Canceled;
        return true;
	}
}