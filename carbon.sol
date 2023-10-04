// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CarbonControl {

    // Structure to represent a carbon credit
    struct CarbonCredit {
        address owner;  // Address of the carbon credit owner
        uint256 amount; // Amount of carbon credits
        uint256 price;  // Price per carbon credit in wei
    }

    // Mapping of carbon credit ID to CarbonCredit struct
    mapping(uint256 => CarbonCredit) public carbonCredits;

    // Mapping of users to their carbon credit balances
    mapping(address => uint256) public carbonCreditBalances;

    // Owner of the contract
    address public owner;

    // Initialize the contract with the owner
    constructor() {
        owner = msg.sender;
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Event emitted when a new carbon credit is created
    event CarbonCreditCreated(uint256 creditId, address owner, uint256 amount, uint256 price);

    // Function to create and sell carbon credits
    function createCarbonCredit(uint256 amount, uint256 price) public {
        require(amount > 0, "Amount must be greater than 0");
        require(price > 0, "Price must be greater than 0");

        uint256 creditId = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp)));
        carbonCredits[creditId] = CarbonCredit(msg.sender, amount, price);
        carbonCreditBalances[msg.sender] += amount;

        emit CarbonCreditCreated(creditId, msg.sender, amount, price);
    }

    // Function to buy carbon credits
    function buyCarbonCredits(uint256 creditId, uint256 amount) public payable {
        require(amount > 0, "Amount must be greater than 0");
        require(carbonCredits[creditId].owner != address(0), "Invalid carbon credit ID");
        require(msg.value == carbonCredits[creditId].price * amount, "Incorrect payment amount");

        carbonCreditBalances[carbonCredits[creditId].owner] -= amount;
        carbonCreditBalances[msg.sender] += amount;
        carbonCredits[creditId].owner = msg.sender;

        // Transfer payment to the previous owner
        payable(carbonCredits[creditId].owner).transfer(msg.value);
    }

    // Function to check the balance of carbon credits for a user
    function getCarbonCreditBalance() public view returns (uint256) {
        return carbonCreditBalances[msg.sender];
    }
}
