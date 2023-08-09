// The 'privx_exchange' program.
import privx_account.leo;

program privx_exchange_beta4.aleo {
    struct Pair {
        account: field,
        token_id: u64,
    }

    // CID stored on the filecoin
    struct TokenLogo {
        data1: u128,
        data2: u128,
        data3: u128,
        data4: u128
    }

    struct TokenMeta {
        minter: address,
        // unique token id
        token_id: u64,
        // Name of the token, 8 ASCII characters at most
        token_name: u128,
        // Symbol of the token, 4 ASCII characters at most
        token_symbol: u64,
        // CID stored on the filecoin
        token_logo: TokenLogo,

        // Circulating
        circulating: u64,
        // Max supply
        max_supply: u64,

        // Decimal
        decimals: u8,
    }

    struct Order {
        account: field,
        is_buy: bool,
        token_id: u64,
        amount: u64,
        dealed_amount: u64,
        price: u64,
        status: u8,
    }

    struct Setting {
        // Indicate token amount could be claimed.
        claim_amount: u64,
    }

    record Token {
        owner: address,
        token_id: u64,
        amount: u64,
    }

    mapping balance: Pair => u64;
    mapping registry: u64 => TokenMeta;
    mapping settings: u64 => Setting;

    // For Privx trade
    mapping deposited: Pair => u64;
    mapping locked: Pair => u64;

    mapping orders: u64 => Order;
    // 0u64 => next_token_id
    // 1u64 => next_order_id
    mapping sequence: u64 => u64;

    // price decimal
    mapping price_decimals: u64 => u8;

    function hash_account_to_field(account: privx_account.leo/Account) -> field {
        let account_hash: field = BHP256::hash_to_field(account.owner) + BHP256::hash_to_field(account.id);
        return account_hash;
    }

    // TokenId = 0 is the stablecoin to trade.
    transition register_stablecoin(public token_name: u128, public token_symbol: u64, public token_logo: TokenLogo, public max_supply: u64) {
        assert_eq(self.caller, aleo1pwr596ea2h328m970pgdu2z0y2hszfjr28x9p2d80haxwgca0q9sderecz);
        return then finalize(self.caller, token_name, token_symbol, token_logo, max_supply);
    }
    finalize register_stablecoin(caller: address, token_name: u128, token_symbol: u64, token_logo: TokenLogo, max_supply: u64) {
        let token_meta: TokenMeta = TokenMeta {
            minter: caller,
            token_id: 0u64,
            token_name: token_name,
            token_symbol: token_symbol,
            token_logo: token_logo,
            circulating: 0u64,
            max_supply: max_supply,
            decimals: 6u8,
        };
        let token_setting: Setting = Setting {
            claim_amount: 0u64,
        };
        Mapping::set(registry, 0u64, token_meta);
        Mapping::set(settings, 0u64, token_setting);
    }

    transition register(public token_name: u128, public token_symbol: u64, public token_logo: TokenLogo, public max_supply: u64) {
        return then finalize(self.caller, token_name, token_symbol, token_logo, max_supply);
    }

    finalize register(caller: address, token_name: u128, token_symbol: u64, token_logo: TokenLogo, max_supply: u64) {
        let next_id: u64 = Mapping::get_or_use(sequence, 0u64, 1u64);
        let token_meta: TokenMeta = TokenMeta {
            minter: caller,
            token_id: next_id,
            token_name: token_name,
            token_symbol: token_symbol,
            token_logo: token_logo,
            circulating: 0u64,
            max_supply: max_supply,
            decimals: 6u8,
        };
        Mapping::set(sequence, 0u64, next_id + 1u64);
        Mapping::set(registry, next_id, token_meta);
        let token_setting: Setting = Setting {
            claim_amount: 0u64,
        };
        Mapping::set(settings, next_id, token_setting);
    }

    transition change_minter(token_id: u64, new_minter: address) {
        return then finalize(token_id, self.caller, new_minter);
    }

    finalize change_minter(token_id: u64, old_minter: address, new_minter: address) {
        let token_meta: TokenMeta = Mapping::get(registry, token_id);
        assert_eq(token_meta.minter, old_minter);
        let updated_token_meta: TokenMeta = TokenMeta {
            minter: new_minter,
            token_id: token_meta.token_id,
            token_name: token_meta.token_name,
            token_symbol: token_meta.token_symbol,
            token_logo: token_meta.token_logo,
            circulating: token_meta.circulating,
            max_supply: token_meta.max_supply,
            decimals: token_meta.decimals
        };
        Mapping::set(registry, token_id, updated_token_meta);
    }

    transition change_setting(token_id: u64, new_setting: Setting) {
        return then finalize(self.caller, token_id, new_setting);
    }

    finalize change_setting(caller: address, token_id: u64, new_setting: Setting) {
        // Ensure caller own the token_id
        let meta: TokenMeta = Mapping::get(registry, token_id);
        assert_eq(meta.minter, caller);
        // Overwrite setting
        Mapping::set(settings, token_id, new_setting);
    }

    transition claim(public token_id: u64, account: privx_account.leo/Account) {
        let account_hash: field = hash_account_to_field(account);
        return then finalize(account_hash, token_id);
    }

    finalize claim(account: field, public token_id: u64) {
        let token_setting: Setting = Mapping::get(settings, token_id);
        let token_meta: TokenMeta = Mapping::get(registry, token_id);
        let key_pair: Pair = Pair {
            account: account,
            token_id: token_id,
        };
        let update_circulating: u64 = token_meta.circulating + token_setting.claim_amount;
        assert(update_circulating <= token_meta.max_supply);
        let update_token_meta: TokenMeta = TokenMeta {
            minter: token_meta.minter,
            token_id: token_meta.token_id,
            token_name: token_meta.token_name,
            token_symbol: token_meta.token_symbol,
            token_logo: token_meta.token_logo,
            circulating: update_circulating,
            max_supply: token_meta.max_supply,
            decimals: token_meta.decimals,
        };
        let current_amount: u64 = Mapping::get_or_use(balance, key_pair, 0u64);
        Mapping::set(balance, key_pair, current_amount + token_setting.claim_amount);
    }

    transition mint_public(public token_id: u64, public to_account: field, public amount: u64) {
        return then finalize(self.caller, token_id, to_account, amount);
    }

    finalize mint_public(minter: address, token_id: u64, to_account: field, amount: u64) {
        // Transaction will revert if the token_id is not exist.
        let token_meta: TokenMeta = Mapping::get(registry, token_id);
        assert_eq(minter, token_meta.minter);

        // Ensure the circulating <= max_supply
        let updated_circulating: u64 = token_meta.circulating + amount;
        assert(updated_circulating <= token_meta.max_supply);
        // let updated_token_meta: TokenMeta = update_meta_circulating(token_meta, updated_circulating);
        let updated_token_meta: TokenMeta = TokenMeta{
            minter: token_meta.minter,
            token_id: token_meta.token_id,
            token_logo: token_meta.token_logo,
            token_name: token_meta.token_name,
            token_symbol: token_meta.token_symbol,
            circulating: updated_circulating,
            max_supply: token_meta.max_supply,
            decimals: token_meta.decimals
        };
        Mapping::set(registry, token_id, updated_token_meta);

        // Increase the balance of `to`
        let key_pair: Pair = Pair {
            account: to_account,
            token_id: token_id
        };
        let current_amount: u64 = Mapping::get_or_use(balance, key_pair, 0u64);
        Mapping::set(balance, key_pair, current_amount + amount);
    }
    /* Transfer */

    transition transfer_private_to_public(token: Token, account: privx_account.leo/Account) {
        let to_account: field = hash_account_to_field(account);
        return then finalize(to_account, token.token_id, token.amount);
    }

    finalize transfer_private_to_public(to_account: field, token_id: u64, amount: u64) {
        let to_key: Pair = Pair {
            account: to_account,
            token_id: token_id,
        };
        let from_current_balance: u64 = Mapping::get_or_use(balance, to_key, 0u64);
        Mapping::set(balance, to_key, from_current_balance + amount);
    }

    transition transfer_public_to_private(token_id: u64, amount: u64, account: privx_account.leo/Account) -> Token {
        let token: Token = Token {
            owner: self.caller,
            token_id: token_id,
            amount: amount
        };
        let from_account: field = hash_account_to_field(account);
        return token then finalize(from_account, token_id, amount);
    }

    finalize transfer_public_to_private(from_account: field, token_id: u64, amount: u64) {
        let from_key: Pair = Pair {
            account: from_account,
            token_id: token_id,
        };
        let from_current_balance: u64 = Mapping::get(balance, from_key);
        Mapping::set(balance, from_key, from_current_balance - amount);
    }

    transition transfer_public(public token_id: u64, public to_account: field, public amount: u64, from: privx_account.leo/Account) {
        let from_account: field = hash_account_to_field(from);
        return then finalize(token_id, from_account, to_account, amount);
    }

    finalize transfer_public(token_id: u64, from_account: field, to_account: field, amount: u64) {
        // let from_key: Pair = new_pair(token_id, from);
        let from_key: Pair = Pair {
            account: from_account,
            token_id: token_id,
        };
        // let to_key: Pair = new_pair(token_id, to);
        let to_key: Pair = Pair {
            account: to_account,
            token_id: token_id
        };

        let from_current_balance: u64 = Mapping::get_or_use(balance, from_key, 0u64);
        let to_current_balance: u64 = Mapping::get_or_use(balance, to_key, 0u64);
        from_current_balance = from_current_balance - amount;
        to_current_balance = to_current_balance + amount;
        
        Mapping::set(balance, from_key, from_current_balance);
        Mapping::set(balance, to_key, to_current_balance);
    }
    
    transition transfer_private(token: Token, to: address, amount: u64) -> (Token, Token) {
        let token_from: Token = Token {
            owner: token.owner,
            token_id: token.token_id,
            amount: token.amount - amount
        };
        let token_to: Token = Token {
            owner: token.owner,
            token_id: token.token_id,
            amount: amount
        };
        return (token_from, token_to);
    }

    transition join(token1: Token, token2: Token) -> Token {
        assert_eq(token1.token_id, token2.token_id);
        let token: Token = Token {
            owner: self.caller,
            token_id: token1.token_id,
            amount: token1.amount + token2.amount
        };
        return token;
    }


    // Transfer from `default_balance_account` to `deposit_account`
    transition deposit(token_id: u64, amount: u64, account: privx_account.leo/Account) {
        let account_hash: field = hash_account_to_field(account);
        return then finalize(account_hash, token_id, amount);
    }

    finalize deposit(account: field, token_id: u64, amount: u64) {
        let pair: Pair = Pair {
            account: account,
            token_id: token_id,
        };
        let current_balance: u64 = Mapping::get(balance, pair);
        Mapping::set(balance, pair, current_balance - amount);
        let current_deposited: u64 = Mapping::get_or_use(deposited, pair, 0u64);
        Mapping::set(deposited, pair, current_deposited + amount);
    }

    transition withdraw(token_id: u64, amount: u64, account: privx_account.leo/Account) {
        let account_hash: field = hash_account_to_field(account);
        return then finalize(account_hash, token_id, amount);
    }

    finalize withdraw(account: field, token_id: u64, amount: u64) {
        let pair: Pair = Pair {
            account: account,
            token_id: token_id,
        };
        let current_deposited: u64 = Mapping::get_or_use(deposited, pair, 0u64);
        Mapping::set(deposited, pair, current_deposited - amount);
        let current_balance: u64 = Mapping::get(balance, pair);
        Mapping::set(balance, pair, current_balance + amount);
    }

    // Assume that token_id 0 is the stablecoin
    transition buy(public token_id: u64,public amount: u64, public price: u64, account: privx_account.leo/Account.record) {
        assert(amount > 0u64);
        assert(price > 0u64);
        assert(token_id > 0u64);
        let account_hash: field = hash_account_to_field(account);
        return then finalize(account_hash, token_id, amount, price);
    }

    finalize buy(account: field, token_id: u64, token_amount: u64, price: u64) {
        let price_decimal: u8 = Mapping::get_or_use(price_decimals, token_id, 6u8);
        let usdt_amount: u64 = token_amount * price / (10u64**price_decimal);
        // let buyer_key: Pair = new_pair(0u64, buyer);
        let buyer_key: Pair = Pair {
            account: account,
            token_id: 0u64,
        };

        // Transfer `USDT` from `deposited` to `locked`  
        let usdt_deposited: u64 = Mapping::get(deposited, buyer_key);
        Mapping::set(deposited, buyer_key, usdt_deposited - usdt_amount);

        let usdt_locked: u64 = Mapping::get_or_use(locked, buyer_key, 0u64);
        Mapping::set(locked, buyer_key, usdt_locked + usdt_amount);

        let next_id: u64 = Mapping::get_or_use(sequence, 1u64, 0u64);
        Mapping::set(sequence, 1u64, next_id + 1u64);
        // let order: Order = new_order(buyer, token_id, token_amount, price, true);
        let order: Order = Order {
            account: account,
            is_buy: true,
            token_id: token_id,
            amount: token_amount,
            dealed_amount: 0u64,
            price: price,
            status: 0u8,
        };
        Mapping::set(orders, next_id, order);
    }

    transition sell(public token_id: u64, public amount: u64, public price: u64, account: privx_account.leo/Account.record) {
        assert(amount > 0u64);
        assert(price > 0u64);
        assert(token_id > 0u64);
        let account_hash: field = hash_account_to_field(account);
        return then finalize(account_hash, token_id, amount, price);
    }

    finalize sell(account: field, token_id: u64, token_amount: u64, price: u64) {
        let price_decimal: u8 = Mapping::get_or_use(price_decimals, token_id, 6u8);
        let usdt_amount: u64 = token_amount * price / (10u64**price_decimal);
        // let seller_key: Pair = new_pair(token_id, seller);
        let seller_key: Pair = Pair {
            account: account,
            token_id: token_id,
        };

        // Transfer `Token` from `deposited` to `locked`  
        let token_deposited: u64 = Mapping::get(deposited, seller_key);
        Mapping::set(deposited, seller_key, token_deposited - token_amount);
        let token_locked: u64 = Mapping::get_or_use(locked, seller_key, 0u64);
        Mapping::set(locked, seller_key, token_locked + token_amount);

        let next_id: u64 = Mapping::get_or_use(sequence, 1u64, 0u64);
        Mapping::set(sequence, 1u64, next_id + 1u64);
        // let order: Order = new_order(seller, token_id, token_amount, price, false);
        let order: Order = Order {
            account: account,
            is_buy: false,
            token_id: token_id,
            amount: token_amount,
            dealed_amount: 0u64,
            price: price,
            status: 0u8,
        };
        Mapping::set(orders, next_id, order);
    }

    // transition cancel(public order_id: u64) {
    //     return then finalize(self.caller, order_id);
    // }

    // finalize cancel(caller: address, order_id: u64) {
    //     let order: Order = Mapping::get(orders, order_id);
    //     assert_eq(order.status, 0u8);
    //     assert_eq(order.placer, caller);
    //     let key_pair: Pair = Pair {
    //         addr: caller,
    //         token_id: order.token_id
    //     };
    //     let canceled_order: Order = cancel_order(order);
    //     Mapping::set(orders, order_id, canceled_order);
    //     if order.is_buy == true {
    //         // transfer USDT from `locked` to `deposited`
    //         let price_decimal: u8 = Mapping::get_or_use(price_decimals, order.token_id, 6u8);
    //         let usdt_amount: u64 = order.amount * order.price / (10u64**price_decimal);
    //         let usdt_locked: u64 = Mapping::get(locked, key_pair);
    //         let usdt_deposited: u64 = Mapping::get(deposited, key_pair);
    //         Mapping::set(locked, key_pair, usdt_locked - usdt_amount);
    //         Mapping::set(deposited, key_pair, usdt_deposited + usdt_amount);
    //     } else {
    //         // transfer TOKEN from `locked` to `deposited`
    //         let token_locked: u64 = Mapping::get(locked, key_pair);
    //         let token_deposited: u64 = Mapping::get(deposited, key_pair);
    //         Mapping::set(locked, key_pair, token_locked - order.amount);
    //         Mapping::set(deposited, key_pair, token_deposited + order.amount);
    //     }
    // }

    transition knockdown(public buy_id: u64, public sell_id: u64) {
        return then finalize(buy_id, sell_id);
    }

    finalize knockdown(buy_id: u64, sell_id: u64) {
        let buy_order: Order = Mapping::get(orders, buy_id);
        let sell_order: Order = Mapping::get(orders, sell_id);
        // 1.Ensure the orders is available
        assert_eq(buy_order.status, 0u8);
        assert_eq(sell_order.status, 0u8);
        assert(buy_order.amount > 0u64);
        assert(sell_order.amount > 0u64);
        assert_eq(buy_order.is_buy, true);
        assert_eq(sell_order.is_buy, false);
        // 2.Ensure the token_id is matched
        assert_eq(buy_order.token_id, sell_order.token_id);
        // 3.Ensure the buy order's price > sell order's price
        assert(buy_order.price >= sell_order.price);
        let price_decimal: u8 = Mapping::get_or_use(price_decimals, buy_order.token_id, 6u8);

        // token_amount = max(buy_order.amount, sell_order.amount)
        let price: u64 = sell_order.price;
        let token_amount: u64 = 0u64;
        if buy_order.amount > sell_order.amount {
            token_amount = sell_order.amount;
        } else {
            token_amount = buy_order.amount;
        }
        
        let dealed_usdt_amount: u64 = price * token_amount / (10u64**price_decimal);
        let max_usdt_amount: u64 = buy_order.price * token_amount / (10u64**price_decimal);
        let returned_usdt_to_buyer: u64 = max_usdt_amount - dealed_usdt_amount;

        // TODO: 1.charge the fee

        // 2. Update the order'status
        // let updated_buy_order: Order = update_order_amount(buy_order, token_amount);
        let updated_buy_order: Order = Order {
            account: buy_order.account,
            is_buy: buy_order.is_buy,
            token_id: buy_order.token_id,
            amount: buy_order.amount - token_amount,
            dealed_amount: buy_order.dealed_amount + token_amount,
            price: buy_order.price,
            status: 0u8,
        };
        // let updated_sell_order: Order = update_order_amount(sell_order, token_amount);
        let updated_sell_order: Order = Order {
            account: sell_order.account,
            is_buy: sell_order.is_buy,
            token_id: sell_order.token_id,
            amount: sell_order.amount - token_amount,
            dealed_amount: sell_order.dealed_amount + token_amount,
            price: sell_order.price,
            status: 0u8,
        };
        Mapping::set(orders, buy_id, updated_buy_order);
        Mapping::set(orders, sell_id, updated_sell_order);

        // 3. Transfer `usdt` from buyer's locked to seller's deposited
        // let buyer_usdt_key: Pair = new_pair(0u64, buy_order.placer);
        let buyer_usdt_key: Pair = Pair {
            account: buy_order.account,
            token_id: 0u64
        };
        // let seller_usdt_key: Pair = new_pair(0u64, sell_order.placer);
        let seller_usdt_key: Pair = Pair {
            account: sell_order.account,
            token_id: 0u64
        };
        let buyer_usdt_locked: u64 = Mapping::get(locked, buyer_usdt_key);
        Mapping::set(locked, buyer_usdt_key, buyer_usdt_locked - max_usdt_amount);
        let seller_usdt_deposited: u64 = Mapping::get_or_use(deposited, seller_usdt_key, 0u64);
        Mapping::set(deposited, seller_usdt_key, seller_usdt_deposited + dealed_usdt_amount);
        
        // 4. Return excessive amounts to buyer
        let buyer_usdt_deposited: u64 = Mapping::get(deposited, buyer_usdt_key);
        Mapping::set(deposited, buyer_usdt_key, buyer_usdt_deposited + returned_usdt_to_buyer);

        // 5. Transfer `token` from seller's locked to buyer's deposited
        let buyer_token_key: Pair = Pair {
            account: buy_order.account,
            token_id: buy_order.token_id,
        };
        let seller_token_key: Pair = Pair {
            account: sell_order.account,
            token_id: sell_order.token_id,
        };
        let seller_token_locked: u64 = Mapping::get(locked, seller_token_key);
        Mapping::set(locked, seller_token_key, seller_token_locked - token_amount);
        let buyer_token_deposited: u64 = Mapping::get_or_use(deposited, buyer_token_key, 0u64);
        Mapping::set(deposited, buyer_token_key, buyer_token_deposited + token_amount);
    }

    inline update_meta_circulating(token_meta: TokenMeta, new_circulating: u64) -> TokenMeta {
        return TokenMeta {
            minter: token_meta.minter,
            token_id: token_meta.token_id,
            token_name: token_meta.token_name,
            token_symbol: token_meta.token_symbol,
            token_logo: token_meta.token_logo,
            circulating: new_circulating,
            max_supply: token_meta.max_supply,
            decimals: token_meta.decimals
        };
    }

    inline new_pair(token_id: u64, account: field) -> Pair {
        return Pair {
            token_id: token_id,
            account: account,
        };
    }

    inline new_order(account: field, token_id: u64, amount: u64, price: u64, is_buy: bool) -> Order {
        return Order {
            account: account,
            is_buy: is_buy,
            token_id: token_id,
            amount: amount,
            dealed_amount: 0u64,
            price: price,
            status: 0u8,
        };
    }

    inline finish_order(order: Order) -> Order {
        return Order {
            account: order.account,
            is_buy: order.is_buy,
            token_id: order.token_id,
            amount: 0u64,
            dealed_amount: order.dealed_amount + order.amount,
            price: order.price,
            status: 2u8,
        };
    }

    inline cancel_order(order: Order) -> Order {
        return Order {
            account: order.account,
            is_buy: order.is_buy,
            token_id: order.token_id,
            amount: order.amount,
            dealed_amount: order.dealed_amount,
            price: order.price,
            status: 1u8,
        };
    }

    inline update_order_amount(order: Order, dealed_token_amount: u64) -> Order {
        return Order {
            account: order.account,
            is_buy: order.is_buy,
            token_id: order.token_id,
            amount: order.amount - dealed_token_amount,
            dealed_amount: order.dealed_amount + dealed_token_amount,
            price: order.price,
            status: 0u8,
        };
    }
}
