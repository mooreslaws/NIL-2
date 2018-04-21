pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/lifecycle/Destructible.sol";
import "zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/AddressUtils.sol";
import "zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "./IPFSeable.sol";

contract NIL2 is ERC721Token, IPFSeable, Pausable, Destructible {

    using SafeMath for uint256;
    using AddressUtils for address;

    string internal contractName_;
    string internal contractCID_;
    mapping (string => string) parameters_;
    string[] parametersKeys_;
    address internal byuer_;
    address internal supplier_;

    enum goodState {Ordered, Manufacturing, Manufactured, Delivery, Delivered, Payed}

    event GoodAdded(string name, string CID, uint price);
    event ParameterAdded(string param, string value);
    event ByuerMadeOrder(uint goodID, uint timestamp);
    event SupplierUpdatedOrderState(uint orderID, uint orderState);
    event ByuerConfirmedDelivery(uint orderID);
    event ByuerTransferPayment(uint orderID);

    modifier onlySupplier() {
        require(msg.sender == supplier_);
        _;
    }

    modifier onlyByuer() {
        require(msg.sender == byuer_);
        _;
    }

    modifier contractDataFilled() {
        require(parametersKeys_.length == 10);
        _;
    }

    struct GoodInfo {
        string name;
        string description;
        string CID;
        uint price;
    }

    struct Order {
        GoodInfo good;
        goodState state;
        uint orderTimestamp;
    }

    mapping (uint => bytes32) ordersMessages;

    GoodInfo[] internal supplierGoods;
    Order[] internal orders;

    function NIL2(
        string _contractName,
        string _supplierSymbol,
        string _contractCID,
        address _byuer,
        address _supplier
    )
        ERC721Token(_contractName, _supplierSymbol)
        public
        payable
    {
        contractName_ = _contractName;
        contractCID_ = _contractCID;
        byuer_ = _byuer;
        supplier_ = _supplier;
    }

    function getContractName()
        public
        view
        returns (string name)
    {
        return contractName_;
    }

    function getContractCID()
        public
        view
        returns (string CID)
    {
        return contractCID_;
    }

    function getByuer()
        public
        view
        returns (address byuer)
    {
        return byuer_;
    }

    function getSupplier()
        public
        view
        returns (address supplier)
    {
        return supplier_;
    }

    function getParameter(string _param)
        public
        view
        returns (string value)
    {
        return parameters_[_param];
    }

    function getParametersAmount()
        public
        view
        returns (uint amount)
    {
        return parametersKeys_.length;
    }

    function addContractParameter(string param_, string value_)
        public
        onlyOwner
    {
        parameters_[param_] = value_;
        parametersKeys_.push(param_);

        ParameterAdded(param_, value_);
    }

    function addGood(string name_, string description_, string CID_, uint price_)
        public
        onlySupplier
    {
        GoodInfo memory good = (GoodInfo(
        {
            name: name_,
            description: description_,
            CID: CID_,
            price: price_
        }));
        supplierGoods.push(good);

        GoodAdded(name_, CID_, price_);
    }

    function getGoodInfo(uint _goodID)
        public
        view
        returns(string, string, string, uint)
    {
        return (
            supplierGoods[_goodID].name,
            supplierGoods[_goodID].description,
            supplierGoods[_goodID].CID,
            supplierGoods[_goodID].price
        );
    }

    function makeOrder(uint _goodID)
        public
        payable
        onlyByuer
        contractDataFilled
        returns (uint ID)
    {
        require(msg.value == supplierGoods[_goodID].price);

        Order memory order = (Order(
        {
            good: supplierGoods[_goodID],
            state: goodState.Ordered,
            orderTimestamp: block.timestamp
        }));

        uint orderID = orders.push(order) - 1;
        _mint(supplier_, orderID);

        ByuerMadeOrder(_goodID, block.timestamp);

        return orderID;
    }

    function getOrder(uint _orderID)
        public
        view
        returns (string, string, uint, uint, goodState)
    {
        return(
            orders[_orderID].good.name,
            orders[_orderID].good.CID,
            orders[_orderID].good.price,
            orders[_orderID].orderTimestamp,
            orders[_orderID].state
        );
    }

    function supplierUpdateManufacturingState(uint _orderID, uint _orderState)
        public
        contractDataFilled
        onlySupplier
    {
        require(uint(goodState.Manufactured) >= _orderState && _orderState >= uint(goodState.Manufacturing));
        orders[_orderID].state = goodState(_orderState);

        SupplierUpdatedOrderState(_orderID, _orderState);
    }

    function supplierStartDelivery(uint _orderID, bytes32 _message)
        public
        contractDataFilled
        onlySupplier
    {
        orders[_orderID].state = goodState.Delivery;
        ordersMessages[_orderID] = _message;
    }

    function byuerConfirmedDelivery(uint _orderID, bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s)
        public
        contractDataFilled
        onlyByuer
    {
        require(ordersMessages[_orderID] == _hash);
        require(verifyByuerSignature(byuer_, _hash, _v, _r, _s));

        orders[_orderID].state = goodState.Delivered;

        super.removeTokenFrom(supplier_, _orderID);
        super.addTokenTo(byuer_, _orderID);

        transferPaymentToSupplier(_orderID);

        ByuerConfirmedDelivery(_orderID);
    }

    function verifyByuerSignature(address p, bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        private
        constant
        returns(bool)
    {
        return ecrecover(hash, v, r, s) == p;
    }

    function transferPaymentToSupplier(uint _orderID)
        private
    {
        supplier_.transfer(orders[_orderID].good.price);
        orders[_orderID].state = goodState.Payed;
        ByuerTransferPayment(_orderID);
    }
}
