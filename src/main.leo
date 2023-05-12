// The 'zkdex' program.

program privx_xyz.aleo {

    // Represent credits.aleo/credits
    record credits {
        owner: address,
        gates: u64,
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
    mapping balances: field => u64;
    // Locked balance of credits.aleo
    mapping locked: field => u64;

    // Balance of token stored on chain
    mapping token_balances: field => u64;
    mapping token_locked: field => u64;

    mapping orders: u64 => Order;

    // Variable to store the next order id
    mapping sequence: u64 => u64;

    // Mint token
    transition mint(to: address, quantity: u64) -> token{
        assert_eq(self.caller, aleo1t0uer3jgtsgmx5tq6x6f9ecu8tr57rzzfnc2dgmcqldceal0ls9qf6st7a);
        return token {
            owner: to,
            gates: 0u64,
            quantity: quantity,
        };
    }

    // Deposit credits on the program
    transition deposit(c: credits) {
        let hash: field = BHP256::hash(c.owner);
        // TODO: Need to support save credits in mapping
        return then finalize(hash, c.gates);
    }

    finalize deposit(hash: field, amount: u64) {
        let current_amount: u64 = Mapping::get_or_init(balances, hash, 0u64);
        Mapping::set(balances, hash, current_amount + amount);
    }

    // With draw credits stored on the program
    transition withdraw(amount: u64) -> credits{
        let c: credits = credits {
            owner: self.caller,
            gates: amount,
        };
        let hash: field = BHP256::hash(self.caller);
        return c then finalize(hash, amount);
    }

    finalize withdraw(hash: field, amount: u64) {
        let current_amount: u64 = Mapping::get_or_init(balances, hash, 0u64);
        Mapping::set(balances, hash, current_amount - amount);
    }

    transition buy(quantity: u64, price: u64) -> Order {
        let order: Order = new_order(quantity, price, true);
        return then finalize(order.owner_hash, quantity, price);
    }

    finalize buy(hash: field, quantity: u64, price: u64) {
        let current_amount: u64 = Mapping::get_or_init(balances, hash, 0u64);
        Mapping::set(balances, hash, current_amount - quantity * price);
        let locked_amount: u64 = Mapping::get_or_init(locked, hash, 0u64);
        Mapping::set(locked, hash, locked_amount + quantity * price);
    }

    transition sell(t: token, price: u64) {
        let order: Order = new_order(t.quantity, price, false);
        return then finalize(order.owner_hash, t.quantity, price);
    }

    finalize sell(hash: field, quantity: u64, price: u64) {
        let current_quantity: u64 = Mapping::get_or_init(token_locked, hash, 0u64);
        Mapping::set(token_locked, hash, current_quantity + quantity);
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
            let locked_amount: u64 = Mapping::get_or_init(locked, hash, 0u64);
            Mapping::set(locked, hash, locked_amount - order.quantity * order.price);
            let current_amount: u64 = Mapping::get_or_init(balances, hash, 0u64);
            Mapping::set(balances, hash, current_amount + order.quantity * order.price);
        }
        else {
            let locked_amount: u64 = Mapping::get_or_init(token_locked, hash, 0u64);
            Mapping::set(token_locked, hash, locked_amount - order.quantity);
            let current_amount: u64 = Mapping::get_or_init(token_balances, hash, 0u64);
            Mapping::set(token_balances, hash, current_amount + order.quantity);
        }
    }

    transition knockdown(buy_id: u64, sell_id: u64) {
        return then finalize(buy_id, sell_id);
    }

    finalize knockdown(buy_id: u64, sell_id: u64) {
        let buy_order: Order = Mapping::get(orders, buy_id);
        let sell_order: Order = Mapping::get(orders, sell_id);
        // Ensure orders is available
        assert_eq(buy_order.status, 0u8);
        assert_eq(sell_order.status, 0u8);

        // Assert the buy price >= sell price
        assert(buy_order.price >= sell_order.price);
        let dealed_quantity: u64 = 0u64;
        let dealed_price: u64 = sell_order.price;
        let dealed_amount: u64 = dealed_price * dealed_quantity;
        if buy_order.quantity >= sell_order.quantity {
            dealed_quantity = sell_order.quantity;
        } else {
            dealed_quantity = buy_order.quantity;
        }
        let dealed_buy_order: Order = modify_order_quantity(buy_order, dealed_quantity);
        let dealed_sell_order: Order = modify_order_quantity(sell_order, dealed_quantity);
        // Update orders' status
        Mapping::set(orders, buy_id, dealed_buy_order);
        Mapping::set(orders, sell_id, dealed_sell_order);

        let buyer_locked_credits: u64 = Mapping::get_or_init(locked, buy_order.owner_hash, 0u64);
        let seller_locked_credits: u64 = Mapping::get_or_init(balances, sell_order.owner_hash, 0u64);

        let buyer_locked_token: u64 = Mapping::get_or_init(token_locked, buy_order.owner_hash, 0u64);
        let seller_locked_token: u64 = Mapping::get_or_init(token_balances, sell_order.owner_hash, 0u64);


        // Buyer decrease the locked credist and increase the token
        Mapping::set(locked, buy_order.owner_hash, buyer_locked_credits - dealed_amount);
        Mapping::set(token_balances, buy_order.owner_hash, buyer_locked_token + dealed_quantity);

        // Seller increase the available credits and decrease the locked token
        Mapping::set(balances, sell_order.owner_hash, seller_locked_credits + dealed_amount);
        Mapping::set(token_locked, sell_order.owner_hash, seller_locked_token - dealed_quantity);
    }

    function new_order(amount: u64, price: u64, is_buy: bool) -> Order {
        let order: Order = Order {
            owner_hash: BHP256::hash(self.caller),
            is_buy: is_buy,
            quantity: amount,
            dealed_quantity: 0u64,
            price: price,
            status: 0u8,
        };
        return order;
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
        return Order {
            owner_hash: order.owner_hash,
            is_buy: order.is_buy,
            quantity: order.quantity - quantity,
            dealed_quantity: order.dealed_quantity + quantity,
            price: order.price,
            status: order.status,
        };
    }
}
