// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ERC-734 Key Holder (subset)
/// @notice Keys that may act for an identity. A key is `keccak256(abi.encode(address))`.
/// @dev Subset of the official interface: `execute`, `approve`, `getKey` and
///      `getKeysByPurpose` are left out.
///      Purposes: 1 = MANAGEMENT, 2 = ACTION, 3 = CLAIM signer.
///      Key types: 1 = ECDSA.
interface IERC734 {
    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);

    function addKey(bytes32 _key, uint256 _purpose, uint256 _keyType) external returns (bool success);
    function removeKey(bytes32 _key, uint256 _purpose) external returns (bool success);
    function getKeyPurposes(bytes32 _key) external view returns (uint256[] memory _purposes);
    function keyHasPurpose(bytes32 _key, uint256 _purpose) external view returns (bool exists);
}
