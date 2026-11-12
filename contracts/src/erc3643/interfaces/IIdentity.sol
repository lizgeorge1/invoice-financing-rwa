// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC734} from "./IERC734.sol";
import {IERC735} from "./IERC735.sol";

/// @title ONCHAINID identity
/// @notice One contract per investor: their keys plus the claims made about them.
/// @dev The official IIdentity also declares `isClaimValid` (for self-attested
///      claims). Here that lives only on IClaimIssuer.
interface IIdentity is IERC734, IERC735 {}
