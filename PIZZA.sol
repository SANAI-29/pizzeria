// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Contract {


    address owner;


    enum Roles{
        NoneRole,
        User,
        Admin,
        Manager
    }

    struct pizzaData {
        uint id;
        string name;
        string description;
        string ingredients;
        string photoImg;
        uint  price;
    }

    struct drinksData {
        uint256 id;
        string name;
        string description;
        string ingredients;
        string photoImg;
        uint256  price;
    }
 
    struct User {
        string login;
        string password;
    } 

    struct basketStruct {
        uint256 id;
        string name;
        uint256 quantity;
        uint256 price;
    }

    struct ChequeStruct{
        uint id;
        string owner;
        string listPizzas;
        string listDrinck;
        string totalPrice;
    }

    mapping (address => Roles) public roles;
    mapping (address => User) public users;
    mapping (address => basketStruct[]) public basket;
    mapping (address => basketStruct[][]) public cheques;

    pizzaData[] pizzas;
    drinksData[] drinks;

    modifier CheckAdmin() {
        require(roles[msg.sender] == Roles.Admin, "not admin");
        _;
    }

    modifier CheckManager() {
        require(roles[msg.sender] == Roles.Manager, "not manager");
        _;
    }

    modifier CheckUser() {
        require(roles[msg.sender] == Roles.User, "not user");
        _;
    }



//смотреть роль
    function  getRole() public view returns(Roles) {
        return roles[msg.sender];
    }




// функции пользователя                                                                                     
    function registr(string memory _login, string memory _password) public {
        require(keccak256(abi.encode(users[msg.sender].login)) == keccak256(abi.encode("")), "user is already registered");
        users[msg.sender] = User(_login, _password);
        roles[msg.sender] = Roles.User;
    }

    function authorization(string memory _login, string memory _password) public view returns(string memory) {
        require(keccak256(abi.encode(_login)) == keccak256(abi.encode(users[msg.sender].login)), "incorrect login"); 
        require(keccak256(abi.encode(_password)) == keccak256(abi.encode(users[msg.sender].password)), "incorrect password");
        return users[msg.sender].login;
    }



// функции менеджера 

    //Создание, удаление пицц и просмотр пицц
    function createManager(address _newManager) public CheckAdmin() {
        require(roles[_newManager] != Roles.Manager, "already manager");
        roles[_newManager] = Roles.Manager;
    }
//создать пиццу
    function createNewPizza(string memory _name, string memory _description, string memory _ingredients, string memory _photoImg, uint _price) public CheckManager() {
        uint ID = pizzas.length ;

        pizzas.push(pizzaData(ID, _name, _description, _ingredients, _photoImg, _price));
    }
// просмотр пицц по индексу
    function getPizza(uint256 _index) public view returns(pizzaData memory) {
        return pizzas[_index]; 
    }


// просмотр всех пиццх
    function getAllPizza() public view returns (pizzaData[] memory) {
        return pizzas;
    }


//удалить пииццу
    function dellPIzza(uint _index) public {
        require(_index < pizzas.length, "There is no pizza");
        pizzas[_index] = pizzas[pizzas.length -1];
        pizzas.pop();
    }




// Добавить пиццу в корзину
    function bascetPizza(uint _index, uint _amount) public {
        require (_index < pizzas.length, "There is no such pizza");
        require(_amount < 100, "This amount is not available");
        require(_amount > 0, "Quantity of pizza must be greater than 0");


        basket[msg.sender].push(basketStruct(pizzas[_index].id, pizzas[_index].name, _amount, pizzas[_index].price));
        }

//удалить пиццу из корзины
    function dellBascetPizza(uint _index) public {
            require(_index < basket[msg.sender].length, "There is no such element.");
            require(basket[msg.sender].length > 0, "Basket is empty");


            basket[msg.sender][_index] = basket[msg.sender][basket[msg.sender].length -1];
            basket[msg.sender].pop();
        }




//НАПИТКИ
//создание нового напитка
    function creatDrink (string memory _name, string memory _description, string memory _ingredients, string memory _photoImg, uint256 _price) public {
        uint ID = drinks.length;

        drinks.push(drinksData(ID, _name, _description, _ingredients, _photoImg, _price));
    }


//просмотр всех напитков
    function getAllDrinks() public view returns (drinksData[] memory) {
        return drinks;
    }

//просмотр напитков по индексу
    function getDrinks(uint256 _index) public view returns (drinksData memory) {
        return drinks[_index];
    }


//удалить напиток
   function dellDrinks(uint _index) public {
        require(_index < drinks.length, "There is no pizza");
        drinks[_index] = drinks[drinks.length -1];
        drinks.pop();
    }


//добавить напиток в корзину
    function bascetDrinks(uint _index, uint _amount) public {
        require (_index < drinks.length, "There is no such drinks");
        require(_amount < 100, "This amount is not available");
        require(_amount > 0, "Quantity of drinks must be greater than 0");


        basket[msg.sender].push(basketStruct(drinks[_index].id, drinks[_index].name, _amount, drinks[_index].price));
    }


//удалить напиток из корзины
     function dellBasketDrinks(uint _index) public {
        require(_index < basket[msg.sender].length, "There is no such drinks");
        require(basket[msg.sender].length > 0, "Basket is empty");

        basket[msg.sender][_index] = basket[msg.sender][basket[msg.sender].length -1];
        basket[msg.sender].pop();
    }



//смотреть всю корзину
    function getBascet () public view returns(basketStruct[] memory) {
        return basket[msg.sender];
    }

//удалить корзину всю
    function clearBasket() public {
        delete basket[msg.sender];
    }

//покупка 
    function buyBasket() public payable {
        require(basket[msg.sender].length > 0, "Basket is empty");

        uint256 totalPrice = 0;
    
        for (uint256 i = 0; i < basket[msg.sender].length; i++) {
            totalPrice += basket[msg.sender][i].price * basket[msg.sender][i].quantity;
        }

        require(msg.value >= totalPrice, "Not enough money");

        payable(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4).call{value: msg.value - totalPrice};

       
        cheques[msg.sender].push(basket[msg.sender]);

        delete basket[msg.sender];
    }


//смотреть  чек
    function getCheque () public view returns(basketStruct[][] memory) {
        return cheques[msg.sender];
    }


//ВЫход
    function exit() public {
        roles[msg.sender] = Roles.NoneRole;
        }
}
