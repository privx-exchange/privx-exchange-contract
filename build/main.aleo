program privx_exchange.aleo;

struct Pair:
    addr as address;
    token_id as u64;

struct TokenLogo:
    data1 as u128;
    data2 as u128;
    data3 as u128;
    data4 as u128;

struct TokenMeta:
    minter as address;
    token_id as u64;
    token_name as u128;
    token_symbol as u64;
    token_logo as TokenLogo;
    circulating as u64;
    max_supply as u64;
    decimals as u8;

struct Order:
    placer as address;
    is_buy as boolean;
    token_id as u64;
    amount as u64;
    dealed_amount as u64;
    price as u64;
    status as u8;

struct Setting:
    claim_amount as u64;


mapping balance:
	key left as Pair.public;
	value right as u64.public;


mapping registry:
	key left as u64.public;
	value right as TokenMeta.public;


mapping settings:
	key left as u64.public;
	value right as Setting.public;


mapping deposited:
	key left as Pair.public;
	value right as u64.public;


mapping locked:
	key left as Pair.public;
	value right as u64.public;


mapping orders:
	key left as u64.public;
	value right as Order.public;


mapping sequence:
	key left as u64.public;
	value right as u64.public;


mapping price_decimals:
	key left as u64.public;
	value right as u8.public;

function register_stablecoin:
    input r0 as u128.public;
    input r1 as u64.public;
    input r2 as TokenLogo.public;
    input r3 as u64.public;
    assert.eq self.caller aleo1pwr596ea2h328m970pgdu2z0y2hszfjr28x9p2d80haxwgca0q9sderecz;

    finalize self.caller r0 r1 r2 r3;

finalize register_stablecoin:
    input r0 as address.public;
    input r1 as u128.public;
    input r2 as u64.public;
    input r3 as TokenLogo.public;
    input r4 as u64.public;
    pow 10u64 6u8 into r5;
    mul r4 r5 into r6;
    cast r0 0u64 r1 r2 r3 0u64 r6 6u8 into r7 as TokenMeta;
    cast 0u64 into r8 as Setting;
    set r7 into registry[0u64];
    set r8 into settings[0u64];


function register:
    input r0 as u128.public;
    input r1 as u64.public;
    input r2 as TokenLogo.public;
    input r3 as u64.public;

    finalize self.caller r0 r1 r2 r3;

finalize register:
    input r0 as address.public;
    input r1 as u128.public;
    input r2 as u64.public;
    input r3 as TokenLogo.public;
    input r4 as u64.public;
    get.or_use sequence[0u64] 1u64 into r5;
    pow 10u64 6u8 into r6;
    mul r4 r6 into r7;
    cast r0 r5 r1 r2 r3 0u64 r7 6u8 into r8 as TokenMeta;
    add r5 1u64 into r9;
    set r9 into sequence[0u64];
    set r8 into registry[r5];
    cast 0u64 into r10 as Setting;
    set r10 into settings[r5];


function change_minter:
    input r0 as u64.private;
    input r1 as address.private;

    finalize r0 self.caller r1;

finalize change_minter:
    input r0 as u64.public;
    input r1 as address.public;
    input r2 as address.public;
    get registry[r0] into r3;
    assert.eq r3.minter r1;
    cast r2 r3.token_id r3.token_name r3.token_symbol r3.token_logo r3.circulating r3.max_supply r3.decimals into r4 as TokenMeta;
    set r4 into registry[r0];


function change_setting:
    input r0 as u64.private;
    input r1 as Setting.private;

    finalize self.caller r0 r1;

finalize change_setting:
    input r0 as address.public;
    input r1 as u64.public;
    input r2 as Setting.public;
    get registry[r1] into r3;
    assert.eq r3.minter r0;
    set r2 into settings[r1];


function claim:
    input r0 as u64.public;

    finalize self.caller r0;

finalize claim:
    input r0 as address.public;
    input r1 as u64.public;
    get settings[r1] into r2;
    cast r0 r1 into r3 as Pair;
    get.or_use balance[r3] 0u64 into r4;
    add r4 r2.claim_amount into r5;
    set r5 into balance[r3];


function mint_public:
    input r0 as u64.public;
    input r1 as address.public;
    input r2 as u64.public;

    finalize self.caller r0 r1 r2;

finalize mint_public:
    input r0 as address.public;
    input r1 as u64.public;
    input r2 as address.public;
    input r3 as u64.public;
    get registry[r1] into r4;
    assert.eq r0 r4.minter;
    add r4.circulating r3 into r5;
    lte r5 r4.max_supply into r6;
    assert.eq r6 true;
    cast r4.minter r4.token_id r4.token_name r4.token_symbol r4.token_logo r5 r4.max_supply r4.decimals into r7 as TokenMeta;
    set r7 into registry[r1];
    cast r2 r1 into r8 as Pair;
    get.or_use balance[r8] 0u64 into r9;
    add r9 r3 into r10;
    set r10 into balance[r8];


function transfer_public:
    input r0 as u64.public;
    input r1 as address.public;
    input r2 as u64.public;

    finalize r0 self.caller r1 r2;

finalize transfer_public:
    input r0 as u64.public;
    input r1 as address.public;
    input r2 as address.public;
    input r3 as u64.public;
    cast r1 r0 into r4 as Pair;
    cast r2 r0 into r5 as Pair;
    get.or_use balance[r4] 0u64 into r6;
    get.or_use balance[r5] 0u64 into r7;
    sub r6 r3 into r8;
    add r7 r3 into r9;
    set r8 into balance[r4];
    set r9 into balance[r5];


function deposit:
    input r0 as u64.private;
    input r1 as u64.private;

    finalize self.caller r0 r1;

finalize deposit:
    input r0 as address.public;
    input r1 as u64.public;
    input r2 as u64.public;
    cast r0 r1 into r3 as Pair;
    get balance[r3] into r4;
    sub r4 r2 into r5;
    set r5 into balance[r3];
    get.or_use deposited[r3] 0u64 into r6;
    add r6 r2 into r7;
    set r7 into deposited[r3];


function withdraw:
    input r0 as u64.private;
    input r1 as u64.private;

    finalize self.caller r0 r1;

finalize withdraw:
    input r0 as address.public;
    input r1 as u64.public;
    input r2 as u64.public;
    cast r0 r1 into r3 as Pair;
    get.or_use deposited[r3] 0u64 into r4;
    sub r4 r2 into r5;
    set r5 into deposited[r3];
    get balance[r3] into r6;
    add r6 r2 into r7;
    set r7 into balance[r3];


function buy:
    input r0 as u64.public;
    input r1 as u64.public;
    input r2 as u64.public;
    gt r1 0u64 into r3;
    assert.eq r3 true;
    gt r2 0u64 into r4;
    assert.eq r4 true;
    gt r0 0u64 into r5;
    assert.eq r5 true;

    finalize self.caller r0 r1 r2;

finalize buy:
    input r0 as address.public;
    input r1 as u64.public;
    input r2 as u64.public;
    input r3 as u64.public;
    get.or_use price_decimals[r1] 6u8 into r4;
    mul r2 r3 into r5;
    pow 10u64 r4 into r6;
    div r5 r6 into r7;
    cast r0 0u64 into r8 as Pair;
    get deposited[r8] into r9;
    sub r9 r7 into r10;
    set r10 into deposited[r8];
    get.or_use locked[r8] 0u64 into r11;
    add r11 r7 into r12;
    set r12 into locked[r8];
    get.or_use sequence[1u64] 0u64 into r13;
    add r13 1u64 into r14;
    set r14 into sequence[1u64];
    cast r0 true r1 r2 0u64 r3 0u8 into r15 as Order;
    set r15 into orders[r13];


function sell:
    input r0 as u64.public;
    input r1 as u64.public;
    input r2 as u64.public;
    gt r1 0u64 into r3;
    assert.eq r3 true;
    gt r2 0u64 into r4;
    assert.eq r4 true;
    gt r0 0u64 into r5;
    assert.eq r5 true;

    finalize self.caller r0 r1 r2;

finalize sell:
    input r0 as address.public;
    input r1 as u64.public;
    input r2 as u64.public;
    input r3 as u64.public;
    get.or_use price_decimals[r1] 6u8 into r4;
    mul r2 r3 into r5;
    pow 10u64 r4 into r6;
    div r5 r6 into r7;
    cast r0 r1 into r8 as Pair;
    get deposited[r8] into r9;
    sub r9 r2 into r10;
    set r10 into deposited[r8];
    get.or_use locked[r8] 0u64 into r11;
    add r11 r2 into r12;
    set r12 into locked[r8];
    get.or_use sequence[1u64] 0u64 into r13;
    add r13 1u64 into r14;
    set r14 into sequence[1u64];
    cast r0 false r1 r2 0u64 r3 0u8 into r15 as Order;
    set r15 into orders[r13];




// function cancel:
//     input r0 as u64.public;

//     finalize self.caller r0;

// finalize cancel:
//     input r0 as address.public;
//     input r1 as u64.public;
//     get orders[r1] into r2;
//     assert.eq r2.status 0u8;
//     assert.eq r2.placer r0;
//     cast r0 r2.token_id into r3 as Pair;
//     cast r2.placer r2.is_buy r2.token_id r2.amount r2.dealed_amount r2.price 1u8 into r4 as Order;
//     set r4 into orders[r1];
//     // Fix compile error
//     // is.eq r2.is_buy true into r5;
//     branch.eq r2.is_buy false to start_cancel_sell;

//     // Cancel buy order
//     position start_cancel_buy;
//     get.or_use price_decimals[r2.token_id] 6u8 into r6;
//     mul r2.amount r2.price into r7;
//     pow 10u64 r6 into r8;
//     div r7 r8 into r9;
//     get locked[r3] into r10;
//     get deposited[r3] into r11;
//     sub r10 r9 into r12;
//     set r12 into locked[r3];
//     add r11 r9 into r13;
//     set r13 into deposited[r3];
//     branch.eq true true to end;

//     // Cancel sell order
//     position start_cancel_sell;
//     get locked[r3] into r14;
//     get deposited[r3] into r15;
//     sub r14 r2.amount into r16;
//     set r16 into locked[r3];
//     add r15 r2.amount into r17;
//     set r17 into deposited[r3];

//     // End
//     position end;

function knockdown:
    input r0 as u64.public;
    input r1 as u64.public;

    finalize r0 r1;

finalize knockdown:
    input r0 as u64.public;
    input r1 as u64.public;
    get orders[r0] into r2;
    get orders[r1] into r3;
    assert.eq r2.status 0u8;
    assert.eq r3.status 0u8;
    gt r2.amount 0u64 into r4;
    assert.eq r4 true;
    gt r3.amount 0u64 into r5;
    assert.eq r5 true;
    assert.eq r2.is_buy true;
    assert.eq r3.is_buy false;
    assert.eq r2.token_id r3.token_id;
    gte r2.price r3.price into r6;
    assert.eq r6 true;
    get.or_use price_decimals[r2.token_id] 6u8 into r7;
    gt r2.amount r3.amount into r8;
    ternary r8 r3.amount r2.amount into r9;
    mul r3.price r9 into r10;
    pow 10u64 r7 into r11;
    div r10 r11 into r12;
    mul r2.price r9 into r13;
    pow 10u64 r7 into r14;
    div r13 r14 into r15;
    sub r15 r12 into r16;
    sub r2.amount r9 into r17;
    add r2.dealed_amount r9 into r18;
    cast r2.placer r2.is_buy r2.token_id r17 r18 r2.price 0u8 into r19 as Order;
    sub r3.amount r9 into r20;
    add r3.dealed_amount r9 into r21;
    cast r3.placer r3.is_buy r3.token_id r20 r21 r3.price 0u8 into r22 as Order;
    set r19 into orders[r0];
    set r22 into orders[r1];
    cast r2.placer 0u64 into r23 as Pair;
    cast r3.placer 0u64 into r24 as Pair;
    get locked[r23] into r25;
    sub r25 r15 into r26;
    set r26 into locked[r23];
    get.or_use deposited[r24] 0u64 into r27;
    add r27 r12 into r28;
    set r28 into deposited[r24];
    get deposited[r23] into r29;
    add r29 r16 into r30;
    set r30 into deposited[r23];
    cast r2.placer r2.token_id into r31 as Pair;
    cast r3.placer r3.token_id into r32 as Pair;
    get locked[r32] into r33;
    sub r33 r9 into r34;
    set r34 into locked[r32];
    get.or_use deposited[r31] 0u64 into r35;
    add r35 r9 into r36;
    set r36 into deposited[r31];










