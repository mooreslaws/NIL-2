pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/lifecycle/Destructible.sol";
import "zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/AddressUtils.sol";
import "zeppelin-solidity/contracts/lifecycle/Pausable.sol";


contract NIL2 is ERC721Token, Ownable, Pausable, Destructible {

    using SafeMath for uint256;
    using AddressUtils for address;

    string internal contractName_;
    string internal contractCID_;
    mapping (string => string) parameters_;
    address internal byuer_;
    address internal supplier_;

    enum goodState {Ordered, Manufacturing, Manufactured, Delivery, Delivered, Payed}

    event GoodAdded(string name, string CID, uint price);
    event ParameterAdded(string param, string value);
    event ByuerMadeOrder(uint goodID, uint timestamp);

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

    function addContractParameter(string param_, string value_)
        public
        onlyOwner
    {
        parameters_[param_] = value_;

        ParameterAdded(param_, value_);
    }

    function addGood(string name_, string description_, string CID_, uint price_)
        public
    {
        require(msg.sender == supplier_);
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
        returns (uint ID)
    {
        require(msg.sender == byuer_);
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
}
