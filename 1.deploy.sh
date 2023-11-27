source .env

snarkos developer deploy --private-key $RPIVATEKEY \
--query ${API_PREFIX}  \
--priority-fee 100 $PROGRAM_NAME \
--broadcast ${API_PREFIX}/testnet3/transaction/broadcast \
--path ./build