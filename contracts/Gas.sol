// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;


contract GasContract  {
    address[5] public administrators;
    address private immutable contractOwner;
    uint256 public immutable totalSupply; // cannot be updated
  //  uint256 private constant tradePercent = 12;
    mapping(address => uint256) private balances;
    mapping(address => uint256) public whitelist;
//    mapping(address => ImportantStruct) private whiteListStruct;
    mapping(address => Payment[]) private payments;

    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend,
        GroupPayment
    }
    
    struct Payment {
        address admin; // administrators address
        address recipient;
        uint256 amount;
        uint256 paymentID;
        PaymentType paymentType;
    }

    struct ImportantStruct {
        uint256 valueA; // max 3 digits
    }

    event Transfer(address recipient, uint256 amount);

    constructor(address[5] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        totalSupply = _totalSupply;
        unchecked {
            for (uint256 ii = 0; ii < 5; ++ii) {
                administrators[ii] = _admins[ii];
                if (_admins[ii] == msg.sender) {
                    balances[msg.sender] = totalSupply;
                }
            }
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        external
    {
        require((checkForAdmin(msg.sender) || (msg.sender == contractOwner)));
        whitelist[_userAddrs] = (_tier >= 3 ? 3 : _tier);
    }

    function checkForAdmin(address _user) private view returns (bool) {
        unchecked {
            for (uint256 ii = 0; ii < 5; ++ii) {
                if (administrators[ii] == _user) {
                    return true;
                }
            }
        }
        return false;
    }

    function balanceOf(address _user) external view returns (uint256) {
        return balances[_user];
    }

    function getTradingMode() external pure returns (bool) {
        return true;
    }

    function getPayments(address _user)
        public
        view
        returns (Payment[] memory payments_)
    {
        return payments[_user];
    }

    function transfer(
        address _recipient,
        uint64 _amount,
        string  calldata
    ) external {
        unchecked{
            address senderOfTx = msg.sender;
            balances[senderOfTx] -= _amount;
            balances[_recipient] += _amount;
            emit Transfer(_recipient, _amount);
            Payment memory payment;    
            payment.paymentType = PaymentType.BasicPayment;
            payment.recipient = _recipient;
            payment.amount = _amount;
            ++payment.paymentID;
            payments[senderOfTx].push(payment);
        }
    }

    function updatePayment(
        address _user,
        uint256 _ID,
        uint256 _amount,
        PaymentType _type
    ) public {
        require(checkForAdmin(msg.sender) || (msg.sender == contractOwner));
        unchecked{
            for (uint256 ii = 0; ii < payments[_user].length; ii++) {
                if (payments[_user][ii].paymentID == _ID) {
                    payments[_user][ii].admin = _user;
                    payments[_user][ii].paymentType = _type;
                    payments[_user][ii].amount = _amount;
                }
            }
        }
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount,
        ImportantStruct calldata
    ) public {
        unchecked {
            balances[msg.sender] -= _amount;
            balances[_recipient] += _amount;
            balances[msg.sender] += whitelist[msg.sender];
            balances[_recipient] -= whitelist[msg.sender];
        }
    }
}
