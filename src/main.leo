// The 'zkdex' program.

program privx_xyz.aleo {

    // Represent credits.aleo/credits
    record credits {
        owner: address,
        gates: u64,
        quantity: u64
    }

    // Represent any token to exchange
    record token {
        owner: address,
        gates: u64,
        quantity: u64,
    }

    struct Order {
        owner_hash: field,
        is_buy: bool,
        quantity: u64,
        dealed_quantity: u64
        price: u64,
        // 0: available
        // 1: cancled
        // 2: dealed
        status: u8,
    }

    // Balance of credits.aleo
    mapping credits_balances: field => u64;
    // Locked balance of credits.aleo
    mapping credits_locked: field => u64;

    // Balance of token stored on chain
    mapping token_balances: field => u64;
    mapping token_locked: field => u64;

    mapping orders: u64 => Order;

    // Variable to store the next order id
    mapping sequence: u64 => u64;

    // Mint token
    transition mint_token(to: address, quantity: u64) -> token{
        assert_eq(self.caller, aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px);
        return token {
            owner: to,
            gates: 0u64,
            quantity: quantity,
        };
    }

    transition mint_token_public(to: address, quantity: u64) {
        assert_eq(self.caller, aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px);
        let hash: field = BHP256::hash(to);
        return then finalize(hash, quantity);
    }
    
    finalize mint_token_public(hash: field, quantity: u64) {
        let current_quantity: u64 = Mapping::get_or_init(token_balances, hash, 0u64);
        Mapping::set(token_balances, hash, current_quantity + quantity);
    }

    transition mint_credits(to: address, quantity: u64) -> credits {
        assert_eq(self.caller, aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px);
        return credits {
            owner: to,
            gates: 0u64,
            quantity: quantity,
        };
    }

    transition mint_credits_public(to: address, quantity: u64) {
        assert_eq(self.caller, aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px);
        let hash: field = BHP256::hash(to);
        return then finalize(hash, quantity);
    }
    
    finalize mint_credits_public(hash: field, quantity: u64) {
        let current_quantity: u64 = Mapping::get_or_init(credits_balances, hash, 0u64);
        Mapping::set(credits_balances, hash, current_quantity + quantity);
    }

    // Deposit credits on the program
    transition deposit_credits(c: credits) {
        let hash: field = BHP256::hash(c.owner);
        // TODO: Need to support save credits in mapping
        return then finalize(hash, c.quantity);
    }

    finalize deposit_credits(hash: field, amount: u64) {
        let current_amount: u64 = Mapping::get_or_init(credits_balances, hash, 0u64);
        Mapping::set(credits_balances, hash, current_amount + amount);
    }

    // With draw credits stored on the program
    transition withdraw_credits(amount: u64) -> credits{
        let c: credits = credits {
            owner: self.caller,
            gates: 0u64,
            quantity: amount,
        };
        let hash: field = BHP256::hash(self.caller);
        return c then finalize(hash, amount);
    }

    finalize withdraw_credits(hash: field, amount: u64) {
        let current_amount: u64 = Mapping::get_or_init(credits_balances, hash, 0u64);
        Mapping::set(credits_balances, hash, current_amount - amount);
    }

    transition deposit_token(t: token) {
        let hash: field = BHP256::hash(t.owner);
        return then finalize(hash, t.quantity);
    }

    finalize deposit_token(hash: field, quantity: u64) {
        let current_amount: u64 = Mapping::get_or_init(token_balances, hash, 0u64);
        Mapping::set(token_balances, hash, current_amount + quantity);
    }

    transition withdraw_token(quantity: u64) -> token {
        let hash: field = BHP256::hash(self.caller);
        let t: token = token {
            owner: self.caller,
            gates: 0u64,
            quantity: quantity,
        };
        return t then finalize(hash, quantity);
    }

    finalize withdraw_token(hash: field, quantity: u64) {
        let current_amount: u64 = Mapping::get_or_init(token_balances, hash, 0u64);
        Mapping::set(token_balances, hash, current_amount - quantity);
    }

    transition buy(quantity: u64, price: u64) -> Order {
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, quantity, price);
    }

    finalize buy(hash: field, quantity: u64, price: u64) {
        let current_amount: u64 = Mapping::get_or_init(credits_balances, hash, 0u64);
        Mapping::set(credits_balances, hash, current_amount - quantity * price);
        let locked_amount: u64 = Mapping::get_or_init(credits_locked, hash, 0u64);
        Mapping::set(credits_locked, hash, locked_amount + quantity * price);

        let next_id: u64 = Mapping::get_or_init(sequence, 0u64, 0u64);
        Mapping::set(sequence, 0u64, next_id + 1u64);
        let order: Order = Order {
            owner_hash: hash,
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
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, quantity, price);
    }

    finalize sell(hash: field, quantity: u64, price: u64) {
        let current_quantity: u64 = Mapping::get_or_init(token_balances, hash, 0u64);
        Mapping::set(token_balances, hash, current_quantity - quantity);
        let locked_quantity: u64 = Mapping::get_or_init(token_locked, hash, 0u64);
        Mapping::set(token_locked, hash, locked_quantity + quantity);

        let next_id: u64 = Mapping::get_or_init(sequence, 0u64, 0u64);
        Mapping::set(sequence, 0u64, next_id + 1u64);
        let order: Order = Order {
            owner_hash: hash,
            is_buy: false,
            quantity: quantity,
            dealed_quantity: 0u64,
            price: price,
            status: 0u8,
        };
        // let order: Order = new_order(hash, quantity, price, false);
        Mapping::set(orders, next_id, order);
    }
    transition cancel(id: u64) {
        let hash: field = BHP256::hash(self.caller);
        return then finalize(hash, id);
    }

    finalize cancel(hash: field, id: u64) {
        let order: Order = Mapping::get(orders, id);
        // Ensure is the correct owner
        // Ensure the order is available
        assert_eq(order.owner_hash, hash);
        assert_eq(order.status, 0u8);


        // Modify order's status
        let canceled_order: Order = cancel_order(order);
        Mapping::set(orders, id, canceled_order);

        // If the canceled order is buy order, return the locked credits
        // If the canceled order is sell order, return the locked token
        if order.is_buy == true {
            let locked_amount: u64 = Mapping::get_or_init(credits_locked, hash, 0u64);
            Mapping::set(credits_locked, hash, locked_amount - order.quantity * order.price);
            let current_amount: u64 = Mapping::get_or_init(credits_balances, hash, 0u64);
            Mapping::set(credits_balances, hash, current_amount + order.quantity * order.price);
        }
        else {
            let locked_amount: u64 = Mapping::get_or_init(token_locked, hash, 0u64);
            Mapping::set(token_locked, hash, locked_amount - order.quantity);
            let current_amount: u64 = Mapping::get_or_init(token_balances, hash, 0u64);
            Mapping::set(token_balances, hash, current_amount + order.quantity);
        }
    }

    transition knockdown(buy_id: u64, sell_id: u64) {
        let caller_hash: field = BHP256::hash(self.caller);
        return then finalize(caller_hash, buy_id, sell_id);
    }

    finalize knockdown(caller_hash: field, buy_id: u64, sell_id: u64) {
        let buy_order: Order = Mapping::get(orders, buy_id);
        let sell_order: Order = Mapping::get(orders, sell_id);
        // Ensure orders is available
        assert_eq(buy_order.status, 0u8);
        assert_eq(sell_order.status, 0u8);

        // Assert the buy price >= sell price
        assert(buy_order.price >= sell_order.price);
        let dealed_quantity: u64 = 0u64;
        let dealed_price: u64 = sell_order.price;
        if buy_order.quantity >= sell_order.quantity {
            dealed_quantity = sell_order.quantity;
        } else {
            dealed_quantity = buy_order.quantity;
        }
        let dealed_amount: u64 = dealed_price * dealed_quantity;
        let buyer_unlocked_amount: u64 = buy_order.price * dealed_quantity;
        // Update orders' status
        let dealed_buy_order: Order = modify_order_quantity(buy_order, dealed_quantity);
        let dealed_sell_order: Order = modify_order_quantity(sell_order, dealed_quantity);
        Mapping::set(orders, buy_id, dealed_buy_order);
        Mapping::set(orders, sell_id, dealed_sell_order);

        // Get the locked credits and token
        let buyer_locked_credits: u64 = Mapping::get_or_init(credits_locked, buy_order.owner_hash, 0u64);
        let seller_current_credits: u64 = Mapping::get_or_init(credits_balances, sell_order.owner_hash, 0u64);

        let buyer_current_token: u64 = Mapping::get_or_init(token_balances, buy_order.owner_hash, 0u64);
        let seller_locked_token: u64 = Mapping::get_or_init(token_locked, sell_order.owner_hash, 0u64);

        let caller_credits: u64 = Mapping::get_or_init(credits_balances, caller_hash, 0u64);
        let caller_token: u64 = Mapping::get_or_init(token_balances, caller_hash, 0u64);

        // Buyer decrease the locked credits and increase the token
        // Fees are collected in the form of tokens
        let (real_quantity, token_fee): (u64, u64) = charge_fee(dealed_quantity);
        Mapping::set(credits_locked, buy_order.owner_hash, buyer_locked_credits - buyer_unlocked_amount);
        Mapping::set(token_balances, buy_order.owner_hash, buyer_current_token + real_quantity);
        Mapping::set(token_balances, caller_hash, caller_token + token_fee);

        // Seller increase the available credits and decrease the locked token
        // Fees are collected in the form of credits
        let (real_amount, credits_fee): (u64, u64) = charge_fee(dealed_amount);
        Mapping::set(token_locked, sell_order.owner_hash, seller_locked_token - dealed_quantity);
        Mapping::set(credits_balances, sell_order.owner_hash, seller_current_credits + real_amount);
        Mapping::set(credits_balances, caller_hash, caller_credits + credits_fee);
    }

    inline new_order(hash: field, amount: u64, price: u64, is_buy: bool) -> Order {
        return Order {
            owner_hash: hash,
            is_buy: is_buy,
            quantity: amount,
            dealed_quantity: 0u64,
            price: price,
            status: 0u8,
        };
    }

    inline cancel_order(order: Order) -> Order {
        return Order {
            owner_hash: order.owner_hash,
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
