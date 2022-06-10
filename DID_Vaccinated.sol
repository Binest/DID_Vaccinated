// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

contract VaccineCredential {
    address private issuerAddress;
    uint256 private idCount;
    mapping(uint8 => string) private vaccineType;

    struct Credential{
        uint256 id;
        address issuer;
        uint8 vaccineType;
        string date;
    }

    mapping(address=>Credential) private credentials;
    mapping(address=>Credential) public IPFS;
    mapping(address=>Credential) private burdenofProof;

    constructor() {
        issuerAddress = msg.sender;
        idCount = 1;
        vaccineType[0] = "Pfizer";
        vaccineType[1] = "Moderna";
        vaccineType[2] = "Astrazeneca";
        vaccineType[3] = "Janssen";
    }

    function issueCredential(address _holderAddress, uint8 _vaccineType, string calldata _date) public returns(bool){
        require(issuerAddress == msg.sender, "Not Issuer");
				Credential storage credential = credentials[_holderAddress];
        require(credential.id == 0);
        credential.id = idCount;
        credential.issuer = msg.sender;
        credential.vaccineType = _vaccineType;
        credential.date = _date;
        
        idCount += 1;

        registerCredential(_holderAddress);

        return true;
    }

    function getCredential(address _holderAddress) public returns(bool){
        Credential memory personalStorage = credentials[_holderAddress];
        burdenofProof[_holderAddress] = personalStorage;
        return true;
    }

    function registerCredential (address _holderAddress) internal {
        Credential memory ipfs = credentials[_holderAddress];
        IPFS[_holderAddress]=ipfs ;
    }

    function tamperCredential (address _holderAddress, uint8 _vaccineType, string calldata _date) public{
        Credential storage tampered = burdenofProof[_holderAddress];
        tampered.vaccineType=_vaccineType;
        tampered.date=_date;
        }

    function hash(uint256 _id, address _issuer, uint8 _vaccineType, string memory _date) pure internal returns(bytes32) {
        return keccak256(abi.encodePacked(_id,_issuer,_vaccineType,_date));
    }

    function verifyCredential (address _holderAddress) view public returns(bool){
        Credential memory holderCredential = burdenofProof[_holderAddress];
        Credential memory ipfsCredential = IPFS[_holderAddress];
        bytes32 fromHolder = hash(holderCredential.id, holderCredential.issuer, holderCredential.vaccineType, holderCredential.date);
        bytes32 fromIpfs = hash(ipfsCredential.id, ipfsCredential.issuer, ipfsCredential.vaccineType, ipfsCredential.date);
        
        if(fromHolder==fromIpfs){
            return true;
        }else return false;
        }
}