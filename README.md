# privx-exchange-contract

Privx.exchange is a zkp-based decentralized order book service on Aleo platfrom. Comparing to previous works on other platforms, Privx.exchange aims to provide better user privacy protection.

We are still in developing stage & will publish plan and roadmap recently. Feel free to contact us via email: privx.exchange.lab@gmail.com, in case of any questions. Thanks for your interest!

## Build Guide

To compile this Aleo program, run:
```bash
aleo build
```

## Intruduction
You can trade in privx, which protects your privacy!

![image](https://cdn.jsdelivr.net/gh/ghostant-1017/img@main/img/image-20230605165056859.png)

### Buyer
1.The buyer can `deposit` credits into their `balance`

2.The buyer can then place orders using the `buy` which will create a `orderId`

3.The buyer can `cancel` the order

### Seller
1.The seller can `deposit_token` token into their `token_balance`

2.The seller can then place orders using the `sell` which will create a `orderId`

3.The seller can `cancel` the order

### Server
An offline server will process the orders through `knockdown`

### A description of your application and why it would add value to the Aleo ecosystem.

PrivX, a decentralized exchange built on Aleo, will bring immense value to the ecosystem. By leveraging Aleo's privacy features, PrivX ensures anonymous and secure crypto trading, eliminating the concern for centralization. It enhances liquidity, and attracts privacy-conscious users, positioning Aleo as a leading blockchain platform for private and secured trading. Additionally, there are some other benefits that PrivX may bring to the Aleo ecosystem.

- **Attract new users:** The privacy features of PrivX can attract new users to the Aleo ecosystem, who are looking for a secure and private way to trade crypto.
- **Increased adoption:** The adoption of Aleo can be increased by the presence of a privacy-preserving DEX like PrivX. This is because PrivX will make it easier for users to access and trade Aleo-based assets.
- **Development of new privacy-preserving applications:** The development of new privacy-preserving applications can be facilitated by the presence of PrivX, and our team will work and collaborate with these new projects to boost the ecosystem growth together.



### Instructions on how to execute your application.

`leo build`

### A description of parameters, functions, etc. This should live in the README for your project.

#### mapping

- credits_balance: store the **credits** balance of users 
- credits_deposited: store the deposit **credits** amount of users, can be used to `buy` other token. 
- credits_locked: store the locked **credits** amount of users, the locked amount is  buy  `Order`s'  credits amount.
- token_balances: store the **token** balance of users 
- token_deposited: store the deposit **token** amount of users, can be used to `buy` other token. 
- token_locked: store the locked **token** amount of users, the locked token amount is sell `Order`s' token amount.
- sequence: workaround to generate a seq id



#### struct

- Order: the required data of an order



#### function

##### 1.mint_credits

**Params** 

- address: the address to receive the credits
- amount: the quantity of credits to mint

**Description**

Mint specify amount credits to an address.

##### 2.deposit_credits

**Params**

- amount: the amount of credits to move from  `credits_balance` to `credits_deposited`

**Description**

Move specific amount credits from  `credits_balance` to `credits_deposited`

##### 3.withdraw_credits

**Params**

- amount: the amount to move from `credits_deposited` to `credits_balance`  

**Description**

Move specific amount credits from  `credits_deposited` to `credits_balance`

##### 4.mint_token

**Params** 

- address: the address to receive the token
- amount: the amount of token to mint

**Description**

Mint specify amount arc20's token to an address.

##### 5.deposit_token 

**Params**

- amount: the amount of credits to move from  `token_balance` to `token_deposited`

**Description**

Move specific amount credits from  `token_balance` to `token_deposited`

##### 6.withdraw_credits

**Params**

- amount: the amount to move from `token_deposited` to `token_balance`  

**Description**

Move specific amount credits from  `token_deposited` to `token_balance`

##### 7.buy

**Params**

- quantity: the order's quantity 
- price: the price willing to pay for single quantity of token

**Description**

decrease the `credits_deposited`, increase the `credits_locked` and generate a new **buy** `Order` with a seq `id`

**8.sell**

- quantity: the order's quantity 
- price: the price wiiling to sell for single quantity of token

**Description**

decrease the `token_deposited`, increaase the `token_locked` and genarate a new **sell** `Order` with a seq `id`

**9.knockdown**

Params

- sell_order_id: the transaction's sell order id
- buy_order_id: the transaction's buy order id

Description: Specify a sell order's id and a buy order's id and check whether the transaction conditions are met and if so, the transaction is completed.
