// The 'privx_exchange' program.

program privx_exchange.aleo {

    // // Represent credits.aleo/credits
    // record credits {
    //     owner: address,
    //     gates: u64,
    //     quantity: u64
    // }

    // // Represent any token to exchange
    // record token {
    //     owner: address,
    //     gates: u64,
    //     quantity: u64,
    // }

    struct Order {
        owner_hash: field,
        is_buy: bool,
        token_type: u64,
        quantity: u64,
        dealed_quantity: u64
        price: u64,
        // 0: available
        // 1: cancled
        // 2: dealed
        status: u8,
    }

    // Represent credits' balance, deposited balance, locked balance 
    mapping credits_balances: field => u64;
    mapping credits_deposited: field => u64;
    mapping credits_locked: field => u64;

    // Represent token's balance, deposited balance, locked balance 
    mapping token_balances: field => u64;
    mapping token_deposited: field => u64;
    mapping token_locked: field => u64;

    mapping token2_balances: field => u64;
    mapping token2_deposited: field => u64;
    mapping token2_locked: field => u64;


    mapping orders: u64 => Order;

    // Variable to store the next order id
    mapping sequence: u64 => u64;

    /* Mint */
    // transition mint_token(to: address, quantity: u64) -> token {
    //     assert_eq(self.caller, aleo1pwr596ea2h328m970pgdu2z0y2hszfjr28x9p2d80haxwgca0q9sderecz);
    //     return token {
    //         owner: to,
    //         gates: 0u64,
    //         quantity: quantity,
    //     };
    // }

    // ******************TEST CLAIM********************
    transition claim_credits() {
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash);
    }

    finalize claim_credits(hash: field) {
        let current_quantity: u64 = Mapping::get_or_init(credits_balances, hash, 0u64);
        Mapping::set(credits_balances, hash, current_quantity + 100000000u64);
    }

    transition claim_token() {
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash);
    }

    finalize claim_token(hash: field) {
        let current_quantity: u64 = Mapping::get_or_init(token_balances, hash, 0u64);
        Mapping::set(token_balances, hash, current_quantity + 100000000u64);
    }

    transition claim_token2() {
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash);
    }

    finalize claim_token2(hash: field) {
        let current_quantity: u64 = Mapping::get_or_init(token2_balances, hash, 0u64);
        Mapping::set(token_balances, hash, current_quantity + 100000000u64);
    }
    // ******************TEST CLAIM********************

    transition mint_token_public(to: address, quantity: u64) {
        assert_eq(self.caller, aleo1pwr596ea2h328m970pgdu2z0y2hszfjr28x9p2d80haxwgca0q9sderecz);
        let hash: field = BHP256::hash(to);
        return then finalize(hash, quantity);
    }
    
    finalize mint_token_public(hash: field, quantity: u64) {
        let current_quantity: u64 = Mapping::get_or_init(token_balances, hash, 0u64);
        Mapping::set(token_balances, hash, current_quantity + quantity);
    }

    transition mint_token2_public(to: address, quantity: u64) {
        assert_eq(self.caller, aleo1pwr596ea2h328m970pgdu2z0y2hszfjr28x9p2d80haxwgca0q9sderecz);
        let hash: field = BHP256::hash(to);
        return then finalize(hash, quantity);
    }
    
    finalize mint_token2_public(hash: field, quantity: u64) {
        let current_quantity: u64 = Mapping::get_or_init(token2_balances, hash, 0u64);
        Mapping::set(token2_balances, hash, current_quantity + quantity);
    }

    // transition mint_credits(to: address, quantity: u64) -> credits {
    //     assert_eq(self.caller, aleo1pwr596ea2h328m970pgdu2z0y2hszfjr28x9p2d80haxwgca0q9sderecz);
    //     return credits {
    //         owner: to,
    //         gates: 0u64,
    //         quantity: quantity,
    //     };
    // }

    transition mint_credits_public(to: address, quantity: u64) {
        assert_eq(self.caller, aleo1pwr596ea2h328m970pgdu2z0y2hszfjr28x9p2d80haxwgca0q9sderecz);
        let hash: field = BHP256::hash(to);
        return then finalize(hash, quantity);
    }
    
    finalize mint_credits_public(hash: field, quantity: u64) {
        let current_quantity: u64 = Mapping::get_or_init(credits_balances, hash, 0u64);
        Mapping::set(credits_balances, hash, current_quantity + quantity);
    }

    // Deposit credits on the program
    transition deposit_credits(amount: u64) {
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, amount);
    }

    finalize deposit_credits(hash: field, amount: u64) {
        let current_balance: u64 = Mapping::get_or_init(credits_balances, hash, 0u64);
        let current_deposited: u64 = Mapping::get_or_init(credits_deposited, hash, 0u64);    
        Mapping::set(credits_balances, hash, current_balance - amount);
        Mapping::set(credits_deposited, hash, current_deposited + amount);
    }

    // Withdraw credits stored on the dex
    transition withdraw_credits(amount: u64){
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, amount);
    }

    finalize withdraw_credits(hash: field, amount: u64) {
        let current_balance: u64 = Mapping::get_or_init(credits_balances, hash, 0u64);
        let current_deposited: u64 = Mapping::get_or_init(credits_deposited, hash, 0u64);
        Mapping::set(credits_balances, hash, current_balance + amount);
        Mapping::set(credits_deposited, hash, current_deposited - amount);
    }

    transition deposit_token(quantity: u64) {
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, quantity);
    }

    finalize deposit_token(hash: field, quantity: u64) {
        let current_balance: u64 = Mapping::get_or_init(token_balances, hash, 0u64);
        let current_deposited: u64 = Mapping::get_or_init(token_deposited, hash, 0u64);
        Mapping::set(token_balances, hash, current_balance - quantity);
        Mapping::set(token_deposited, hash, current_deposited + quantity);
    }

    transition deposit_token2(quantity: u64) {
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, quantity);
    }

    finalize deposit_token2(hash: field, quantity: u64) {
        let current_balance: u64 = Mapping::get_or_init(token2_balances, hash, 0u64);
        let current_deposited: u64 = Mapping::get_or_init(token2_deposited, hash, 0u64);
        Mapping::set(token2_balances, hash, current_balance - quantity);
        Mapping::set(token2_deposited, hash, current_deposited + quantity);
    }

    transition withdraw_token(quantity: u64) {
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, quantity);
    }

    finalize withdraw_token(hash: field, quantity: u64) {
        let current_balance: u64 = Mapping::get_or_init(token_balances, hash, 0u64);
        let current_deposited: u64 = Mapping::get_or_init(token_deposited, hash, 0u64);
        Mapping::set(token_balances, hash, current_balance + quantity);
        Mapping::set(token_deposited, hash, current_deposited - quantity);
    }

    transition withdraw_token2(quantity: u64) {
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, quantity);
    }

    finalize withdraw_token2(hash: field, quantity: u64) {
        let current_balance: u64 = Mapping::get_or_init(token2_balances, hash, 0u64);
        let current_deposited: u64 = Mapping::get_or_init(token2_deposited, hash, 0u64);
        Mapping::set(token2_balances, hash, current_balance + quantity);
        Mapping::set(token2_deposited, hash, current_deposited - quantity);
    }

    transition buy(quantity: u64, price: u64) -> Order {
        assert(quantity > 0u64);
        assert(price > 0u64);
        assert(quantity % 10000u64 == 0u64);
        assert(price % 10000u64 == 0u64);
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, quantity, price);
    }

    finalize buy(hash: field, quantity: u64, price: u64) {
        let order_amount: u64 = quantity * price / 1000000u64;

        let current_deposited: u64 = Mapping::get_or_init(credits_deposited, hash, 0u64);
        Mapping::set(credits_deposited, hash, current_deposited - order_amount);
        let locked_amount: u64 = Mapping::get_or_init(credits_locked, hash, 0u64);
        Mapping::set(credits_locked, hash, locked_amount + order_amount);

        let next_id: u64 = Mapping::get_or_init(sequence, 0u64, 0u64);
        Mapping::set(sequence, 0u64, next_id + 1u64);
        let order: Order = Order {
            owner_hash: hash,
            token_type: 1u64,
            is_buy: true,
            quantity: quantity,
            dealed_quantity: 0u64,
            price: price,
            status: 0u8,
        };
        // let order: Order = new_order(hash, quantity, price, true);
        Mapping::set(orders, next_id, order);
    }

    transition buy_2(quantity: u64, price: u64) -> Order {
        assert(quantity > 0u64);
        assert(price > 0u64);
        assert(quantity % 10000u64 == 0u64);
        assert(price % 10000u64 == 0u64);
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, quantity, price);
    }

    finalize buy_2(hash: field, quantity: u64, price: u64) {
        let order_amount: u64 = quantity * price / 1000000u64;

        let current_deposited: u64 = Mapping::get_or_init(credits_deposited, hash, 0u64);
        Mapping::set(credits_deposited, hash, current_deposited - order_amount);
        let locked_amount: u64 = Mapping::get_or_init(credits_locked, hash, 0u64);
        Mapping::set(credits_locked, hash, locked_amount + order_amount);

        let next_id: u64 = Mapping::get_or_init(sequence, 0u64, 0u64);
        Mapping::set(sequence, 0u64, next_id + 1u64);
        let order: Order = Order {
            owner_hash: hash,
            token_type: 2u64,
            is_buy: true,
            quantity: quantity,
            dealed_quantity: 0u64,
            price: price,
            status: 0u8,
        };
        // let order: Order = new_order(hash, quantity, price, true);
        Mapping::set(orders, next_id, order);
    }

    transition sell(quantity: u64, price: u64) {
        assert(quantity > 0u64);
        assert(price > 0u64);
        assert(quantity % 10000u64 == 0u64);
        assert(price % 10000u64 == 0u64);
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, quantity, price);
    }

    finalize sell(hash: field, quantity: u64, price: u64) {        
        let current_deposited: u64 = Mapping::get_or_init(token_deposited, hash, 0u64);
        Mapping::set(token_deposited, hash, current_deposited - quantity);
        let locked_quantity: u64 = Mapping::get_or_init(token_locked, hash, 0u64);
        Mapping::set(token_locked, hash, locked_quantity + quantity);

        let next_id: u64 = Mapping::get_or_init(sequence, 0u64, 0u64);
        Mapping::set(sequence, 0u64, next_id + 1u64);
        let order: Order = Order {
            owner_hash: hash,
            token_type: 1u64,
            is_buy: false,
            quantity: quantity,
            dealed_quantity: 0u64,
            price: price,
            status: 0u8,
        };
        // let order: Order = new_order(hash, quantity, price, false);
        Mapping::set(orders, next_id, order);
    }

    transition sell_2(quantity: u64, price: u64) {
        assert(quantity > 0u64);
        assert(price > 0u64);
        assert(quantity % 10000u64 == 0u64);
        assert(price % 10000u64 == 0u64);
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, quantity, price);
    }

    finalize sell_2(hash: field, quantity: u64, price: u64) {
        let current_deposited: u64 = Mapping::get_or_init(token2_deposited, hash, 0u64);
        Mapping::set(token2_deposited, hash, current_deposited - quantity);
        let locked_quantity: u64 = Mapping::get_or_init(token2_locked, hash, 0u64);
        Mapping::set(token2_locked, hash, locked_quantity + quantity);

        let next_id: u64 = Mapping::get_or_init(sequence, 0u64, 0u64);
        Mapping::set(sequence, 0u64, next_id + 1u64);
        let order: Order = Order {
            owner_hash: hash,
            token_type: 2u64,
            is_buy: false,
            quantity: quantity,
            dealed_quantity: 0u64,
            price: price,
            status: 0u8,
        };
        // let order: Order = new_order(hash, quantity, price, false);
        Mapping::set(orders, next_id, order);
    }

    // transition cancel(id: u64) {
    //     let hash: field = BHP256::hash(self.caller);
    //     return then finalize(hash, id);
    // }

    // finalize cancel(hash: field, id: u64) {
    //     let order: Order = Mapping::get(orders, id);
    //     // Ensure is the correct owner
    //     // Ensure the order is available
    //     assert_eq(order.owner_hash, hash);
    //     assert_eq(order.status, 0u8);


    //     // Modify order's status
    //     let canceled_order: Order = cancel_order(order);
    //     Mapping::set(orders, id, canceled_order);

    //     // If the canceled order is buy order, return the locked credits
    //     // If the canceled order is sell order, return the locked token
    //     if order.is_buy == true {
    //         let locked_amount: u64 = Mapping::get_or_init(credits_locked, hash, 0u64);
    //         Mapping::set(credits_locked, hash, locked_amount - order.quantity * order.price);
    //         let deposited_amount: u64 = Mapping::get_or_init(credits_deposited, hash, 0u64);
    //         Mapping::set(credits_deposited, hash, deposited_amount + order.quantity * order.price);
    //     }
    //     else {
    //         let locked_amount: u64 = Mapping::get_or_init(token_locked, hash, 0u64);
    //         Mapping::set(token_locked, hash, locked_amount - order.quantity);
    //         let deposited_amount: u64 = Mapping::get_or_init(token_deposited, hash, 0u64);
    //         Mapping::set(token_balances, hash, deposited_amount + order.quantity);
    //     }
    // }

    transition cancel_sell(id: u64) {
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, id);
    }

    finalize cancel_sell(hash: field, id: u64) {
        let order: Order = Mapping::get(orders, id);
        // Ensure is the correct owner
        // Ensure the order is available
        assert_eq(order.token_type, 1u64);
        assert_eq(order.owner_hash, hash);
        assert_eq(order.status, 0u8);
        assert_eq(order.is_buy, false);

        // Modify order's status
        let canceled_order: Order = cancel_order(order);
        Mapping::set(orders, id, canceled_order);

        // If the canceled order is buy order, return the locked credits
        // If the canceled order is sell order, return the locked token
        let locked_amount: u64 = Mapping::get_or_init(token_locked, hash, 0u64);
        Mapping::set(token_locked, hash, locked_amount - order.quantity);
        let deposited_amount: u64 = Mapping::get_or_init(token_deposited, hash, 0u64);
        Mapping::set(token_balances, hash, deposited_amount + order.quantity);
    }

    transition cancel_buy(id: u64) {
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, id);
    }

    finalize cancel_buy(hash: field, id: u64) {
        let order: Order = Mapping::get(orders, id);
        // Ensure is the correct owner
        // Ensure the order is available
        assert_eq(order.token_type, 1u64);
        assert_eq(order.owner_hash, hash);
        assert_eq(order.status, 0u8);
        assert_eq(order.is_buy, true);
        // Modify order's status
        let canceled_order: Order = cancel_order(order);
        Mapping::set(orders, id, canceled_order);

        let left_order_amount: u64 = order.quantity * order.price / 1000000u64; 
        let locked_amount: u64 = Mapping::get_or_init(credits_locked, hash, 0u64);
        Mapping::set(credits_locked, hash, locked_amount - left_order_amount);
        let deposited_amount: u64 = Mapping::get_or_init(credits_deposited, hash, 0u64);
        Mapping::set(credits_deposited, hash, deposited_amount + left_order_amount);
    }


    transition cancel_sell_2(id: u64) {
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, id);
    }

    finalize cancel_sell_2(hash: field, id: u64) {
        let order: Order = Mapping::get(orders, id);
        // Ensure is the correct owner
        // Ensure the order is available
        assert_eq(order.token_type, 2u64);
        assert_eq(order.owner_hash, hash);
        assert_eq(order.status, 0u8);
        assert_eq(order.is_buy, false);

        // Modify order's status
        let canceled_order: Order = cancel_order(order);
        Mapping::set(orders, id, canceled_order);

        // If the canceled order is buy order, return the locked credits
        // If the canceled order is sell order, return the locked token
        let locked_amount: u64 = Mapping::get_or_init(token2_locked, hash, 0u64);
        Mapping::set(token2_locked, hash, locked_amount - order.quantity);
        let deposited_amount: u64 = Mapping::get_or_init(token2_deposited, hash, 0u64);
        Mapping::set(token2_balances, hash, deposited_amount + order.quantity);
    }

    transition cancel_buy2(id: u64) {
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, id);
    }

    finalize cancel_buy2(hash: field, id: u64) {
        let order: Order = Mapping::get(orders, id);
        // Ensure is the correct owner
        // Ensure the order is available
        assert_eq(order.token_type, 2u64);
        assert_eq(order.owner_hash, hash);
        assert_eq(order.status, 0u8);
        assert_eq(order.is_buy, true);

        // Modify order's status
        let canceled_order: Order = cancel_order(order);
        Mapping::set(orders, id, canceled_order);
        
        let left_order_amount: u64 = order.quantity * order.price / 1000000u64; 
        let locked_amount: u64 = Mapping::get_or_init(credits_locked, hash, 0u64);
        Mapping::set(credits_locked, hash, locked_amount - left_order_amount);
        let deposited_amount: u64 = Mapping::get_or_init(credits_deposited, hash, 0u64);
        Mapping::set(credits_deposited, hash, deposited_amount + left_order_amount);
    }

    transition knockdown(buy_id: u64, sell_id: u64) {
        let caller_hash: field = BHP256::hash(self.caller);
        return then finalize(caller_hash, buy_id, sell_id);
    }

    finalize knockdown(caller_hash: field, buy_id: u64, sell_id: u64) {
        let buy_order: Order = Mapping::get(orders, buy_id);
        let sell_order: Order = Mapping::get(orders, sell_id);
        // Ensure orders is available
        assert_eq(buy_order.token_type, 1u64);
        assert_eq(sell_order.token_type, 1u64);
        assert_eq(buy_order.status, 0u8);
        assert_eq(sell_order.status, 0u8);
        assert_eq(buy_order.is_buy, true);
        assert_eq(sell_order.is_buy, false);

        // Assert the buy price >= sell price
        assert(buy_order.price >= sell_order.price);
        let dealed_quantity: u64 = 0u64;
        let dealed_price: u64 = sell_order.price;
        // if buy_order.quantity >= sell_order.quantity {
        //     dealed_quantity = sell_order.quantity;
        // } else {
        //     dealed_quantity = buy_order.quantity;
        // }
        assert(buy_order.quantity <= sell_order.quantity);
        dealed_quantity = buy_order.quantity;

        let dealed_amount: u64 = dealed_price * dealed_quantity / 1000000u64;
        let max_dealed_amount: u64 = buy_order.price * dealed_quantity / 1000000u64;
        let (real_quantity, token_fee): (u64, u64) = charge_fee(dealed_quantity);
        let (real_amount, credits_fee): (u64, u64) = charge_fee(dealed_amount);
        let buyer_return_amount: u64 = max_dealed_amount - dealed_amount;
        // 1.Caculate token fee
        let caller_token: u64 = Mapping::get_or_init(token_deposited, caller_hash, 0u64);
        Mapping::set(token_deposited, caller_hash, caller_token + token_fee);
        
        // 2.Caculate credits fee
        let caller_credits: u64 = Mapping::get_or_init(credits_deposited, caller_hash, 0u64);
        Mapping::set(credits_deposited, caller_hash, caller_credits + credits_fee);


        // 3.Update orders' status
        let dealed_buy_order: Order = modify_order_quantity(buy_order, dealed_quantity);
        let dealed_sell_order: Order = modify_order_quantity(sell_order, dealed_quantity);
        Mapping::set(orders, buy_id, dealed_buy_order);
        Mapping::set(orders, sell_id, dealed_sell_order);


        // 4.Update buyer's locked credits
        let buyer_locked_credits: u64 = Mapping::get_or_init(credits_locked, buy_order.owner_hash, 0u64);
        Mapping::set(credits_locked, buy_order.owner_hash, buyer_locked_credits - max_dealed_amount);
        // Update buyer's deposited credits
        let buyer_deposited_credits: u64 = Mapping::get_or_init(credits_deposited, buy_order.owner_hash, 0u64);
        Mapping::set(credits_deposited, buy_order.owner_hash, buyer_deposited_credits + buyer_return_amount);
        // Update buyer's deposited token
        let buyer_deposited_token: u64 = Mapping::get_or_init(token_deposited, buy_order.owner_hash, 0u64);
        Mapping::set(token_deposited, buy_order.owner_hash, buyer_deposited_token + real_quantity);
        

        // 5.Update seller's locked token
        let seller_locked_token: u64 = Mapping::get_or_init(token_locked, sell_order.owner_hash, 0u64);
        Mapping::set(token_locked, sell_order.owner_hash, seller_locked_token - dealed_quantity);
        // Update seller's deposited credits
        let seller_deposited_credits: u64 = Mapping::get_or_init(credits_deposited, sell_order.owner_hash, 0u64);
        Mapping::set(credits_deposited, sell_order.owner_hash, seller_deposited_credits + real_amount);
    }

    transition knockdown_gt(buy_id: u64, sell_id: u64) {
        let caller_hash: field = BHP256::hash(self.caller);
        return then finalize(caller_hash, buy_id, sell_id);
    }

    finalize knockdown_gt(caller_hash: field, buy_id: u64, sell_id: u64) {
        let buy_order: Order = Mapping::get(orders, buy_id);
        let sell_order: Order = Mapping::get(orders, sell_id);
        // Ensure orders is available
        assert_eq(buy_order.token_type, 1u64);
        assert_eq(sell_order.token_type, 1u64);
        assert_eq(buy_order.status, 0u8);
        assert_eq(sell_order.status, 0u8);
        assert_eq(buy_order.is_buy, true);
        assert_eq(sell_order.is_buy, false);

        // Assert the buy price >= sell price
        assert(buy_order.price >= sell_order.price);
        let dealed_quantity: u64 = 0u64;
        let dealed_price: u64 = sell_order.price;
        // if buy_order.quantity >= sell_order.quantity {
        //     dealed_quantity = sell_order.quantity;
        // } else {
        //     dealed_quantity = buy_order.quantity;
        // }
        assert(buy_order.quantity > sell_order.quantity);
        dealed_quantity = sell_order.quantity;

        let dealed_amount: u64 = dealed_price * dealed_quantity / 1000000u64;
        let max_dealed_amount: u64 = buy_order.price * dealed_quantity / 1000000u64;
        let (real_quantity, token_fee): (u64, u64) = charge_fee(dealed_quantity);
        let (real_amount, credits_fee): (u64, u64) = charge_fee(dealed_amount);
        let buyer_return_amount: u64 = max_dealed_amount - dealed_amount;
        // 1.Caculate token fee
        let caller_token: u64 = Mapping::get_or_init(token_deposited, caller_hash, 0u64);
        Mapping::set(token_deposited, caller_hash, caller_token + token_fee);
        
        // 2.Caculate credits fee
        let caller_credits: u64 = Mapping::get_or_init(credits_deposited, caller_hash, 0u64);
        Mapping::set(credits_deposited, caller_hash, caller_credits + credits_fee);


        // 3.Update orders' status
        let dealed_buy_order: Order = modify_order_quantity(buy_order, dealed_quantity);
        let dealed_sell_order: Order = modify_order_quantity(sell_order, dealed_quantity);
        Mapping::set(orders, buy_id, dealed_buy_order);
        Mapping::set(orders, sell_id, dealed_sell_order);


        // 4.Update buyer's locked credits
        let buyer_locked_credits: u64 = Mapping::get_or_init(credits_locked, buy_order.owner_hash, 0u64);
        Mapping::set(credits_locked, buy_order.owner_hash, buyer_locked_credits - max_dealed_amount);
        // Update buyer's deposited credits
        let buyer_deposited_credits: u64 = Mapping::get_or_init(credits_deposited, buy_order.owner_hash, 0u64);
        Mapping::set(credits_deposited, buy_order.owner_hash, buyer_deposited_credits + buyer_return_amount);
        // Update buyer's deposited token
        let buyer_deposited_token: u64 = Mapping::get_or_init(token_deposited, buy_order.owner_hash, 0u64);
        Mapping::set(token_deposited, buy_order.owner_hash, buyer_deposited_token + real_quantity);
        

        // 5.Update seller's locked token
        let seller_locked_token: u64 = Mapping::get_or_init(token_locked, sell_order.owner_hash, 0u64);
        Mapping::set(token_locked, sell_order.owner_hash, seller_locked_token - dealed_quantity);
        // Update seller's deposited credits
        let seller_deposited_credits: u64 = Mapping::get_or_init(credits_deposited, sell_order.owner_hash, 0u64);
        Mapping::set(credits_deposited, sell_order.owner_hash, seller_deposited_credits + real_amount);
    }

    transition knockdown_2(buy_id: u64, sell_id: u64) {
        let caller_hash: field = BHP256::hash(self.caller);
        return then finalize(caller_hash, buy_id, sell_id);
    }

    finalize knockdown_2(caller_hash: field, buy_id: u64, sell_id: u64) {
        let buy_order: Order = Mapping::get(orders, buy_id);
        let sell_order: Order = Mapping::get(orders, sell_id);
        // Ensure orders is available
        assert_eq(buy_order.token_type, 2u64);
        assert_eq(sell_order.token_type, 2u64);
        assert_eq(buy_order.status, 0u8);
        assert_eq(sell_order.status, 0u8);
        assert_eq(buy_order.is_buy, true);
        assert_eq(sell_order.is_buy, false);

        // Assert the buy price >= sell price
        assert(buy_order.price >= sell_order.price);
        let dealed_quantity: u64 = 0u64;
        let dealed_price: u64 = sell_order.price;
        // if buy_order.quantity >= sell_order.quantity {
        //     dealed_quantity = sell_order.quantity;
        // } else {
        //     dealed_quantity = buy_order.quantity;
        // }
        assert(buy_order.quantity <= sell_order.quantity);
        dealed_quantity = sell_order.quantity;

        let dealed_amount: u64 = dealed_price * dealed_quantity / 1000000u64;
        let max_dealed_amount: u64 = buy_order.price * dealed_quantity / 1000000u64;
        let (real_quantity, token_fee): (u64, u64) = charge_fee(dealed_quantity);
        let (real_amount, credits_fee): (u64, u64) = charge_fee(dealed_amount);
        let buyer_return_amount: u64 = max_dealed_amount - dealed_amount;
        // 1.Caculate token fee
        let caller_token: u64 = Mapping::get_or_init(token2_deposited, caller_hash, 0u64);
        Mapping::set(token2_deposited, caller_hash, caller_token + token_fee);
        
        // 2.Caculate credits fee
        let caller_credits: u64 = Mapping::get_or_init(credits_deposited, caller_hash, 0u64);
        Mapping::set(credits_deposited, caller_hash, caller_credits + credits_fee);


        // 3.Update orders' status
        let dealed_buy_order: Order = modify_order_quantity(buy_order, dealed_quantity);
        let dealed_sell_order: Order = modify_order_quantity(sell_order, dealed_quantity);
        Mapping::set(orders, buy_id, dealed_buy_order);
        Mapping::set(orders, sell_id, dealed_sell_order);


        // 4.Update buyer's locked credits
        let buyer_locked_credits: u64 = Mapping::get_or_init(credits_locked, buy_order.owner_hash, 0u64);
        Mapping::set(credits_locked, buy_order.owner_hash, buyer_locked_credits - max_dealed_amount);
        // Update buyer's deposited credits
        let buyer_deposited_credits: u64 = Mapping::get_or_init(credits_deposited, buy_order.owner_hash, 0u64);
        Mapping::set(credits_deposited, buy_order.owner_hash, buyer_deposited_credits + buyer_return_amount);
        // Update buyer's deposited token
        let buyer_deposited_token: u64 = Mapping::get_or_init(token2_deposited, buy_order.owner_hash, 0u64);
        Mapping::set(token2_deposited, buy_order.owner_hash, buyer_deposited_token + real_quantity);
        

        // 5.Update seller's locked token
        let seller_locked_token: u64 = Mapping::get_or_init(token2_locked, sell_order.owner_hash, 0u64);
        Mapping::set(token2_locked, sell_order.owner_hash, seller_locked_token - dealed_quantity);
        // Update seller's deposited credits
        let seller_deposited_credits: u64 = Mapping::get_or_init(credits_deposited, sell_order.owner_hash, 0u64);
        Mapping::set(credits_deposited, sell_order.owner_hash, seller_deposited_credits + real_amount);
    }

    transition knockdown_2_gt(buy_id: u64, sell_id: u64) {
        let caller_hash: field = BHP256::hash(self.caller);
        return then finalize(caller_hash, buy_id, sell_id);
    }

    finalize knockdown_2_gt(caller_hash: field, buy_id: u64, sell_id: u64) {
        let buy_order: Order = Mapping::get(orders, buy_id);
        let sell_order: Order = Mapping::get(orders, sell_id);
        // Ensure orders is available
        assert_eq(buy_order.token_type, 2u64);
        assert_eq(sell_order.token_type, 2u64);
        assert_eq(buy_order.status, 0u8);
        assert_eq(sell_order.status, 0u8);
        assert_eq(buy_order.is_buy, true);
        assert_eq(sell_order.is_buy, false);

        // Assert the buy price >= sell price
        assert(buy_order.price >= sell_order.price);
        let dealed_quantity: u64 = 0u64;
        let dealed_price: u64 = sell_order.price;
        // if buy_order.quantity >= sell_order.quantity {
        //     dealed_quantity = sell_order.quantity;
        // } else {
        //     dealed_quantity = buy_order.quantity;
        // }
        assert(buy_order.quantity > sell_order.quantity);
        dealed_quantity = sell_order.quantity;

        let dealed_amount: u64 = dealed_price * dealed_quantity / 1000000u64;
        let max_dealed_amount: u64 = buy_order.price * dealed_quantity / 1000000u64;
        let (real_quantity, token_fee): (u64, u64) = charge_fee(dealed_quantity);
        let (real_amount, credits_fee): (u64, u64) = charge_fee(dealed_amount);
        let buyer_return_amount: u64 = max_dealed_amount - dealed_amount;
        // 1.Caculate token fee
        let caller_token: u64 = Mapping::get_or_init(token2_deposited, caller_hash, 0u64);
        Mapping::set(token2_deposited, caller_hash, caller_token + token_fee);
        
        // 2.Caculate credits fee
        let caller_credits: u64 = Mapping::get_or_init(credits_deposited, caller_hash, 0u64);
        Mapping::set(credits_deposited, caller_hash, caller_credits + credits_fee);


        // 3.Update orders' status
        let dealed_buy_order: Order = modify_order_quantity(buy_order, dealed_quantity);
        let dealed_sell_order: Order = modify_order_quantity(sell_order, dealed_quantity);
        Mapping::set(orders, buy_id, dealed_buy_order);
        Mapping::set(orders, sell_id, dealed_sell_order);


        // 4.Update buyer's locked credits
        let buyer_locked_credits: u64 = Mapping::get_or_init(credits_locked, buy_order.owner_hash, 0u64);
        Mapping::set(credits_locked, buy_order.owner_hash, buyer_locked_credits - max_dealed_amount);
        // Update buyer's deposited credits
        let buyer_deposited_credits: u64 = Mapping::get_or_init(credits_deposited, buy_order.owner_hash, 0u64);
        Mapping::set(credits_deposited, buy_order.owner_hash, buyer_deposited_credits + buyer_return_amount);
        // Update buyer's deposited token
        let buyer_deposited_token: u64 = Mapping::get_or_init(token2_deposited, buy_order.owner_hash, 0u64);
        Mapping::set(token2_deposited, buy_order.owner_hash, buyer_deposited_token + real_quantity);
        

        // 5.Update seller's locked token
        let seller_locked_token: u64 = Mapping::get_or_init(token2_locked, sell_order.owner_hash, 0u64);
        Mapping::set(token2_locked, sell_order.owner_hash, seller_locked_token - dealed_quantity);
        // Update seller's deposited credits
        let seller_deposited_credits: u64 = Mapping::get_or_init(credits_deposited, sell_order.owner_hash, 0u64);
        Mapping::set(credits_deposited, sell_order.owner_hash, seller_deposited_credits + real_amount);
    }

    inline new_order(hash: field,token_type: u64, quantity: u64, price: u64, is_buy: bool) -> Order {
        return Order {
            owner_hash: hash,
            token_type: token_type,
            is_buy: is_buy,
            quantity: quantity,
            dealed_quantity: 0u64,
            price: price,
            status: 0u8,
        };
    }

    inline cancel_order(order: Order) -> Order {
        return Order {
            owner_hash: order.owner_hash,
            token_type: order.token_type,
            is_buy: order.is_buy,
            quantity: order.quantity,
            dealed_quantity: order.dealed_quantity,
            price: order.price,
            status: 1u8,
        };
    }

    inline finish_order(order: Order) -> Order {
        return Order {
            owner_hash: order.owner_hash,
            token_type: order.token_type,
            is_buy: order.is_buy,
            quantity: 0u64,
            dealed_quantity: order.dealed_quantity + order.quantity,
            price: order.price,
            status: 2u8,
        };
    }

    inline modify_order_quantity(order: Order, quantity: u64) -> Order {
        if order.quantity == quantity {
            return finish_order(order);
        }
        return Order {
            owner_hash: order.owner_hash,
            token_type: order.token_type,
            is_buy: order.is_buy,
            quantity: order.quantity - quantity,
            dealed_quantity: order.dealed_quantity + quantity,
            price: order.price,
            status: order.status,
        };
    }

    inline charge_fee(dealed_amount: u64) -> (u64, u64) {
        // 1‰
        let fee: u64 = dealed_amount / 1000u64 * 1u64;
        if fee == 0u64 {
            fee = 1u64;
        }
        let real_amount: u64 = dealed_amount - fee;
        return (real_amount, fee);
    }
}
