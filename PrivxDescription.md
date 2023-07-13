### A description of your application and why it would add value to the Aleo ecosystem.

PrivX, a decentralized exchange built on Aleo, will bring immense value to the ecosystem. By leveraging Aleo's privacy features, PrivX ensures anonymous and secure crypto trading, eliminating the concern for centralization. It enhances liquidity, and attracts privacy-conscious users, positioning Aleo as a leading blockchain platform for private and secured trading. Additionally, there are some other benefits that PrivX may bring to the Aleo ecosystem.

- **Attract new users:** The privacy features of PrivX can attract new users to the Aleo ecosystem, who are looking for a secure and private way to trade crypto.
- **Increased adoption:** The adoption of Aleo can be increased by the presence of a privacy-preserving DEX like PrivX. This is because PrivX will make it easier for users to access and trade Aleo-based assets.
- **Development of new privacy-preserving applications:** The development of new privacy-preserving applications can be facilitated by the presence of PrivX, and our team will work and collaborate with these new projects to boost the ecosystem growth together.



### Instructions on how to execute your application.

`leo build`

### A description of parameters, functions, etc. This should live in the README for your project.**

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

- mint_credits: mint **credits**
- deposit_credits: from  `credits_balance` to `credits_deposited`
- withdraw_credits: from `credits_deposited` to `credits_balance`  
- mint_token: mint arc20's token 
- deposit_token: from `token_balance` to `token_deposited`
- withdraw_token: from `token_deposited` to `token_balance`
- **buy**: decrease the `credits_deposited`, increase the `credits_locked` and generate a new **buy** `Order` with a seq `id`
- **sell**: decrease the `token_deposited`, increaase the `token_locked` and genarate a new **sell** `Order` with a seq `id`
- **knockdown**: specify a sell order's id and a buy order's id and check whether the transaction conditions are met and if so, the transaction is completed.


