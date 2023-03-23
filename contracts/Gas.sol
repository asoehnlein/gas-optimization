// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;


contract GasContract  {
    address[5] public administrators;
    address private immutable contractOwner;
    uint256 public immutable totalSupply; // cannot be updated
    uint256 private constant tradePercent = 12;
    mapping(address => uint256) private balances;
    mapping(address => uint256) public whitelist;
    mapping(address => ImportantStruct) private whiteListStruct;
    mapping(address => Payment[]) private payments;

    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend,
        GroupPayment
    }
    
    History[] private paymentHistory; // when a payment was updated

    struct Payment {
        address admin; // administrators address
        address recipient;
        uint256 amount;
        uint256 paymentID;
        PaymentType paymentType;
    }

    struct History {
        address updatedBy;
        uint256 lastUpdate;
        uint256 blockNumber;
    }
    struct ImportantStruct {
        uint256 valueA; // max 3 digits
        uint256 bigValue;
        uint256 valueB; // max 3 digits
    }

    event AddedToWhitelist(address userAddress, uint256 tier);
    event Transfer(address recipient, uint256 amount);

    constructor(address[5] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        totalSupply = _totalSupply;

        for (uint256 ii = 0; ii < 5; ++ii) {
            administrators[ii] = _admins[ii];
            if (_admins[ii] == msg.sender) {
                balances[msg.sender] = totalSupply;
            }
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        external
    {
        require(checkForAdmin(msg.sender) || (msg.sender == contractOwner));
        require(_tier < 255);
        // whitelist[_userAddrs] = _tier;
        if (_tier > 3) {
            // whitelist[_userAddrs] -= _tier;
            whitelist[_userAddrs] = 3;
        } else {
            // whitelist[_userAddrs] -= _tier;
            whitelist[_userAddrs] = _tier;
        }
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function checkForAdmin(address _user) private view returns (bool admin_) {
        for (uint256 ii = 0; ii < 5; ++ii) {
            if (administrators[ii] == _user) {
                return true;
            }
        }
        return false;
    }

    function getPaymentHistory()
        private view
        returns (History[] memory paymentHistory_)
    {
        return paymentHistory;
    }

    function balanceOf(address _user) external view returns (uint256 balance_) {
        uint256 balance = balances[_user];
        return balance;
    }

    function getTradingMode() external pure returns (bool mode_) {
        return true;
    }

    function addHistory(address _updateAddress)
        private
        returns (bool status_)
    {
        History memory history;
        history.blockNumber = block.number;
        history.lastUpdate = block.timestamp;
        history.updatedBy = _updateAddress;
        paymentHistory.push(history);
        // bool[] memory status = new bool[](tradePercent);
        // for (uint256 i = 0; i < tradePercent; i++) {
        //     status[i] = true;
        // }
        // return (status[0] == true);
        return true;
    }

    function getPayments(address _user)
        public
        view
        returns (Payment[] memory payments_)
    {
        // require(_user != address(0));
        return payments[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public returns (bool status_) {
        address senderOfTx = msg.sender;
        // require(balances[senderOfTx] >= _amount);
        // require(bytes(_name).length < 9);
        balances[senderOfTx] -= _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);
        Payment memory payment;
        payment.admin = address(0);
        payment.paymentType = PaymentType.BasicPayment;
        payment.recipient = _recipient;
        payment.amount = _amount;
        ++payment.paymentID;
        payments[senderOfTx].push(payment);
        bool[] memory status = new bool[](tradePercent);
        for (uint256 i = 0; i < tradePercent; i++) {
            status[i] = true;
        }
        return (status[0] == true);
    }

    function updatePayment(
        address _user,
        uint256 _ID,
        uint256 _amount,
        PaymentType _type
    ) public {
        require(checkForAdmin(msg.sender) || (msg.sender == contractOwner));

        for (uint256 ii = 0; ii < payments[_user].length; ii++) {
            if (payments[_user][ii].paymentID == _ID) {
                payments[_user][ii].admin = _user;
                payments[_user][ii].paymentType = _type;
                payments[_user][ii].amount = _amount;
                addHistory(_user);
            }
        }
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount,
        ImportantStruct calldata
    ) public {
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        balances[msg.sender] += whitelist[msg.sender];
        balances[_recipient] -= whitelist[msg.sender];
    }
}
