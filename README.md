# privx-xyz-contract

Privx.xyz is a zkp-based decentralized order book service on Aleo platfrom. Comparing to previous works on other platforms, Privx.xyz aims to provide better user privacy protection.

We are still in developing stage & will publish plan and roadmap recently. Feel free to contact us via email: privx.xyz.lab@gmail.com, in case of any questions. Thanks for your interest!

## Build Guide

To compile this Aleo program, run:
```bash
aleo build
```

## Intruduction
You can trade in privx, which protects your privacy!

![image](https://user-images.githubusercontent.com/53888545/238601232-53786b4b-05cd-42ac-bdee-52892a6c2318.png)

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
