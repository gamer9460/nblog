---
title: "Blockchain Basics"
date: 2022-06-21T12:19:46+05:30
draft: true
tags: ["Blockchain"]
author: "Darshan Ghetiya"
authorDes: "Nurdsoft"

---

This article describes various aspects of a blockchain.

## What is a Blockchain?

**Blockchain** is a distributed database that is shared among nodes of a computer network. It stores information electronically in digital format. Blockchain technology is also referred to as a distributed ledger technology (**DLT**). It is an accounting system where the ledger (record of transactions) is distributed among a network of computers.
The term Blockchain refers to the fact that it is a **‘chain’** of **‘blocks’**. A ‘chain’ because everything is recorded in **chronological** order. And ‘blocks’ because the transactions are added to the chain in groups rather than individually. Let’s break down these two words and understand them individually.

### Block

A block records a number of transactions, among other data, similar to a page in a record-keeping book. Blocks are identified by their cryptographically secure hash which is used to retrieve them. A block contains the hash of the previous block and new transaction information. Blocks and the information within them must be verified by a network before new blocks can be created.

### Chain

In the blockchain, each transaction is stored in the form of hashes in the block, and each block referring the previous block address, so this creates a chain effect where the order of hashes cannot be changed. As a result, transactions are immutable once they’ve been added.

---

Now we have a basic of blockchain terminologies then, so let’s understand them in non-technical human-understandable language.

Blockchain uses a **cryptography** algorithm for securely transferring data in the network. So each individual has their private key and public key. By using that, each node can transfer the transaction in the network. Blockchains generally use the **SHA-256** hashing algorithm as their hash function to generate the next block hash address.

When some transaction happens in the blockchain, it will be not directly added to the blockchain, so first, that transaction will be added to the **transaction pool**. After that, some minors need to verify that transaction via solving a mathematical equation (**proof-of-work**) which needs a much computational power and, based on the blockchain configuration; it will automatically adjust the difficulty level, and mining time of each block, i.e., Bitcoin needs 10 minutes to add the block in the Bitcoin Blockchain network. For doing this computational work, the miners get a fraction of part of that blockchain as a **mining reward**. Once the miners verify this transaction, that will be added to the actual blockchain network, and this new chain will be broadcasted within all peer devices. This is how the blockchain network works, in simple words.

## Terminology

**Genesis block:** A Genesis Block is the name given to the first block of a blockchain, so when the Blockchain is initiated, this block will be created by default to start itself.

**Blockchain Difficulty:** Blockchain difficulty is a measure of how difficult it is to mine a block in a blockchain for a particular time that will be adjusted automatically based on the mining rate. The higher the difficulty needs hard to solve and the more computation power needed, it will be equally proposal to the security of the blockchain.

**Mining Rate / Hash Rate:** Hashrate is a measure of the computational power per second used when mining. More simply, it is the speed of mining. It is measured in units of hash/second, meaning how many calculations per second can be performed. Machines with a high hash power are highly efficient and can process a lot of data in a single second.

**Proof-of-work:** Proof of Work(PoW) is the original consensus algorithm in a blockchain network. The algorithm is used to confirm the transaction and creates a new block to the chain. In this algorithm, minors (a group of people) compete against each other to complete the transaction on the network. The process of competing against each other is called mining. As soon as miners successfully create a valid block, he gets rewarded. Producing a proof of work can be a random process with low probability. In this, a lot of trial and error is required before a valid proof of work is generated.
