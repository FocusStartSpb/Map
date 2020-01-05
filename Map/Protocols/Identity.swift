//
//  Identity.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 02.01.2020.
//

protocol Identity
{
	static func === (lhs: Self, rhs: Self) -> Bool
	static func !== (lhs: Self, rhs: Self) -> Bool
}
