source .env

snarkos developer execute \
--private-key $RPIVATEKEY \
--query ${API_PREFIX} \
--priority-fee 100 $PROGRAM_NAME register_stablecoin 3u32 \
--broadcast http://127.0.0.1:3030/testnet3/transaction/broadcast