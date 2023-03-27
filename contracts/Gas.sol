// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;


contract GasContract  {
    uint256 public immutable totalSupply; // cannot be updated
    mapping(address => uint256) private balances;
    mapping(address => uint256) public whitelist;
    mapping(address => Payment[]) private payments;

    struct Payment {
        uint256 amount;
        uint256 paymentType;
    }
       address[5] public administrators;
    struct ImportantStruct {
        uint8 valueA; // max 3 digits
    }
 

    event Transfer(address recipient, uint256 amount);

    constructor(address[5] memory _admins, uint256 _totalSupply) {
        totalSupply = _totalSupply;
        administrators = _admins;
    }
    function addToWhitelist(address _userAddrs, uint256 _tier)
        external
    {
        whitelist[_userAddrs] =_tier;
    }

    function balanceOf(address _user) external view returns (uint256) {
        return balances[_user];
    }

    function getTradingMode() external pure returns (bool) {
        return true;
    }

    function getPayments(address _user)
        external
        view 
        returns (Payment[] memory payments_)
    {
        return payments[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata
    ) external {
        payments[msg.sender].push(Payment(1, _amount));
        unchecked {
        balances[_recipient] += _amount;

        emit Transfer(_recipient, _amount);
        }
    }

    function updatePayment(
        address _user,
        uint256 ,
        uint256 _amount,
        uint256 _type
    ) external {
        payments[_user][0].paymentType = _type;
        payments[_user][0].amount = _amount;
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount,
        ImportantStruct calldata
    ) external {
        unchecked 
        {
            uint256  temp = _amount - whitelist[msg.sender];
            balances[msg.sender] -= temp;
            balances[_recipient] += temp;
        }
    }
}
