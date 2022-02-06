// SPDX-License-Identifier: GPL3
pragma solidity ^0.8.0;

/**
 * @dev Reference builder in the project
 */
contract Builders {
    // Plan designer entity (builder)
    struct Builder {
        address _address;
        bool parity;
        bytes32 publicKey;
    }

    struct BuilderJoinRequest {
        address builderAddress;
        bool parity;
        bytes32 publicKey;
    }

    mapping(address => Builder) public builders;
    address[] public buildersArray;

    mapping(address => BuilderJoinRequest) public builderRequests;
    address[] public builderRequestsArray;

    modifier onlyBuilder() {
        require(
            builders[msg.sender]._address != address(0),
            "Only builders are allowed to execute this."
        );
        _;
    }

    function getBuildersLength() public view returns (uint256) {
        return buildersArray.length;
    }

    function getBuilderRequestsLength() public view returns (uint256) {
        return builderRequestsArray.length;
    }

    /**
     * @notice Builder can update his public key.
     * @param parity based on header value (0x02/0x03 - false/true)
     * @param publicKey compressed public key value
     */
    function setBuilderPublickey(bool parity, bytes32 publicKey) public {
        require(
            builders[msg.sender]._address == msg.sender,
            "Sender is not builder"
        );
        builders[msg.sender].parity = parity;
        builders[msg.sender].publicKey = publicKey;
    }

    /**
     * @notice Already accepted builder can add new builder.
     * @param newBuilderAddress address of the new builder
     * @param parity based on header value (0x02/0x03 - false/true)
     * @param publicKey compressed public key value
     */
    function addBuilder(
        address newBuilderAddress,
        bool parity,
        bytes32 publicKey
    ) public onlyBuilder {
        require(
            builders[newBuilderAddress]._address == address(0),
            "Builder already exists"
        );

        builders[newBuilderAddress] = Builder({
            _address: newBuilderAddress,
            parity: parity,
            publicKey: publicKey
        });

        buildersArray.push(newBuilderAddress);
    }

    /**
     * @notice Anyone can request to become a builder.
     * @param parity based on header value (0x02/0x03 - false/true)
     * @param publicKey compressed public key value
     */
    function requestJoinBuilder(bool parity, bytes32 publicKey) public {
        require(
            builders[msg.sender]._address == address(0),
            "Builder already exists"
        );
        require(
            builderRequests[msg.sender].builderAddress == address(0),
            "Builder already requested join"
        );

        builderRequests[msg.sender] = BuilderJoinRequest({
            builderAddress: msg.sender,
            parity: parity,
            publicKey: publicKey
        });

        builderRequestsArray.push(msg.sender);
    }

    /**
     * @notice Already accepted builder can accept new builder.
     * @param newBuilderAddress address of the new builder
     */
    function acceptBuilderJoinRequest(address newBuilderAddress)
        public
        onlyBuilder
    {
        require(
            builderRequests[newBuilderAddress].builderAddress != address(0),
            "Address of new builder hasn't created request. Consider using addBuilder."
        );

        BuilderJoinRequest memory request = builderRequests[newBuilderAddress];

        addBuilder(newBuilderAddress, request.parity, request.publicKey);

        _removeRequest(newBuilderAddress);
    }

    /**
     * @notice Already accepted builder can accept new builder.
     * @param newBuilderAddress address of the new builder
     */
    function declineBuilderJoinRequest(address newBuilderAddress)
        public
        onlyBuilder
    {
        require(
            builderRequests[newBuilderAddress].builderAddress != address(0),
            "Address of new builder hasn't created request. Consider using addBuilder."
        );

        _removeRequest(newBuilderAddress);
    }

    function _removeRequest(address builderAddress) private onlyBuilder {
        for (uint256 i = 0; i < builderRequestsArray.length; i++) {
            if (builderRequestsArray[i] == builderAddress) {
                builderRequestsArray[i] = builderRequestsArray[
                    builderRequestsArray.length - 1
                ];
                builderRequestsArray.pop();

                delete builderRequests[builderAddress];

                break;
            }
        }
    }

    // TODO - add builder function ?
}
