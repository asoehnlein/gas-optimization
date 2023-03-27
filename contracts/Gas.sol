// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;


contract GasContract  {
    address private immutable contractOwner;
    uint256 public immutable totalSupply; // cannot be updated
    mapping(address => uint256) private balances;
    mapping(address => uint256) public whitelist;
    mapping(address => Payment[]) private payments;
    
    struct Payment {
        uint256 amount;
        uint256 paymentType;
    }

    struct ImportantStruct {
        uint8 valueA; // max 3 digits
    }

    address[5] public administrators;

    event Transfer(address recipient, uint256 amount);

    constructor(address[5] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        totalSupply = _totalSupply;
        balances[msg.sender] = totalSupply;
        unchecked {
            for (uint256 ii = 0; ii < 5; ++ii) {
                administrators[ii] = _admins[ii];
            }
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        external
    {
        require(checkForAdmins(msg.sender) );
        whitelist[_userAddrs] = (_tier &3);
    }

    function checkForAdmins(address _user) private view returns (bool) 
    {
        unchecked {
            for (uint256 ii = 0; ii < 5; ++ii) {
                if (administrators[ii] == _user) {
                    return true;
                }
            }
            return false;
        }        
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
        unchecked{
            balances[msg.sender] -= _amount;
            balances[_recipient] += _amount;
            emit Transfer(_recipient, _amount);
            Payment memory payment;
            payment.amount = _amount;
            payments[msg.sender].push(payment);
        }
    }

    function updatePayment(
        address _user,
        uint256 ,
        uint256 _amount,
        uint256 _type
    ) external {
        require(checkForAdmins(msg.sender));
        payments[_user][0].paymentType = _type;
        payments[_user][0].amount = _amount;
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount,
        ImportantStruct calldata
    ) external {
        unchecked {
            balances[msg.sender] -= _amount;
            balances[_recipient] += _amount;
            balances[msg.sender] += whitelist[msg.sender];
            balances[_recipient] -= whitelist[msg.sender];
        }
    }
}
