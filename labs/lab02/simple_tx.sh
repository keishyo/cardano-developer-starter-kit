
testnet="--testnet-magic 2"
address=$(cat base.addr)
address_skey="payment.skey"
cardano-cli query utxo $testnet --address $address

#chỉnh sửa lại giá trị các biến
BOB_ADDR="addr_test1qzldl9u0j6ap7mdugtdcre43f8dfrnv7uqd3a6furpyuzw3z70zawv8g3tyg7uh833x50geeul2vpyujyzac0d6dmgcsyu5akw"
VALUE=2000000
UTXO_IN=a621a2509c6a8a3cb347224c698a32301fe1581148b7ea48235392787ccae460#1

# B1. Xây dựng giao dịch (Build Tx)


cardano-cli conway transaction build $testnet \
--tx-in $UTXO_IN \
--tx-out $BOB_ADDR+$VALUE \
--change-address $address \
--metadata-json-file metadata.json \
--out-file simple-tx.raw


# B2. Ký giao dịch (Sign Tx)

cardano-cli conway transaction sign $testnet \
--signing-key-file $address_skey \
--tx-body-file simple-tx.raw \
--out-file simple-tx.signed

# B3. Gửi giao dịch (Submit Tx)

cardano-cli conway transaction submit $testnet \
--tx-file simple-tx.signed

# IPFS ID: QmTPoBBis8n6EmkQv554DHZMjgECycb6mrTsAMBbFrnSNX

cardano-cli conway address key-gen \
--verification-key-file policy/policy.vkey \
--signing-key-file policy/policy.skey

ipfs_hash=QmRE3Qnz5Q8dVtKghL4NBhJBH4cXPwfRge7HMiBhK92SJX
realtokenname=TEMPO

echo "{" >> metadata.json
echo "  \"721\": {" >> metadata.json
echo "    \"$(cat policy/policyID)\": {" >> metadata.json
echo "      \"$(echo $realtokenname)\": {" >> metadata.json
echo "        \"description\": \"Đây là token của TEMPO\"," >> metadata.json
echo "        \"name\": \"$(echo $realtokenname)\"," >> metadata.json
echo "        \"id\": \"1\"," >> metadata.json
echo "        \"image\": \"ipfs://$(echo $ipfs_hash)\"" >> metadata.json
echo "      }" >> metadata.json
echo "    }" >> metadata.json
echo "  }" >> metadata.json
echo "}" >> metadata.json