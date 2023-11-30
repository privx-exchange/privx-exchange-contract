source .env

TOKEN_ID=0u64
TOKEN_SETTING='{claim_amount: 100000000u64}'

snarkos developer execute \
--private-key $RPIVATEKEY \
--query ${API_PREFIX} \
--priority-fee 100 $PROGRAM_NAME change_setting $TOKEN_ID "$TOKEN_SETTING" \
--broadcast ${API_PREFIX}/testnet3/transaction/broadcast

TOKEN_ID=1u64

snarkos developer execute \
--private-key $RPIVATEKEY \
--query ${API_PREFIX} \
--priority-fee 100 $PROGRAM_NAME change_setting $TOKEN_ID "$TOKEN_SETTING" \
--broadcast ${API_PREFIX}/testnet3/transaction/broadcast