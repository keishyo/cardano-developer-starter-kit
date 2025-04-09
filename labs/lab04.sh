#Gán biến môi trường
testnet="--testnet-magic 2"
address=$(cat base.addr)
address_SKEY="payment.skey"
ipfs_hash=QmRE3Qnz5Q8dVtKghL4NBhJBH4cXPwfRge7HMiBhK92SJX
realtokenname="Hồ Duy Long_365"
tokenname=$(echo -n $realtokenname | xxd -b -ps -c 80 | tr -d '\n')
tokenamount="1"
policyid=$(cat tokens/policy/policyID)
txhash="4192391b0bc45a17a63da1bdcbd0921436e7a5a11947d8ef230c293ab1c85f25"
txix="1"
output="2000000"
thaygiao="addr_test1qzldl9u0j6ap7mdugtdcre43f8dfrnv7uqd3a6furpyuzw3z70zawv8g3tyg7uh833x50geeul2vpyujyzac0d6dmgcsyu5akw"
f31091c9469a585c05e36877527a74ee4f3daef99db5f338e0dcba3c9bc02148

#Kiểm tra UTXO
cardano-cli query utxo --address $address $testnet

#Tạo folder:
mkdir tokens
mkdir policy

#Tạo key + Policy:
cardano-cli conway address key-gen \
--verification-key-file policy/policy.vkey \
--signing-key-file policy/policy.skey

touch policy/policy.script && echo "" > policy/policy.script

echo "{" >> policy/policy.script
echo "  \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file policy/policy.vkey)\"," >> policy/policy.script
echo "  \"type\": \"sig\"" >> policy/policy.script
echo "}" >> policy/policy.script

cardano-cli conway transaction policyid --script-file ./policy/policy.script > policy/policyID

#Tạo metadata
echo "{" >> metadata.json
echo "  \"721\": {" >> metadata.json
echo "    \"$(cat policy/policyID)\": {" >> metadata.json
echo "      \"$(echo $realtokenname)\": {" >> metadata.json
echo "        \"description\": \"Đây là NFT của học viên khóa BK03\"," >> metadata.json
echo "        \"name\": \"$(echo $realtokenname)\"," >> metadata.json
echo "        \"id\": \"1\"," >> metadata.json
echo "        \"image\": \"ipfs://$(echo $ipfs_hash)\"" >> metadata.json
echo "      }" >> metadata.json
echo "    }" >> metadata.json
echo "  }" >> metadata.json
echo "}" >> metadata.json

echo $txhash
echo $txid
echo $address
echo $output
echo $tokenamount
echo $policyid.$tokenname
echo $tokenamount

#Tạo giao dịch
cardano-cli conway transaction build \
$testnet \
--tx-in $txhash#$txix \
--tx-out $address+$output+"$tokenamount $policyid.$tokenname" \
--mint "$tokenamount $policyid.$tokenname" \
--mint-script-file tokens/policy/policy.script \
--change-address $address \
--metadata-json-file tokens/metadata.json  \
--out-file mint-nft.raw

#Ký giao dịch
cardano-cli conway transaction sign $testnet \
--signing-key-file $address_SKEY  \
--signing-key-file tokens/policy/policy.skey  \
--tx-body-file mint-nft.raw \
--out-file mint-nft.signed

#Gửi giao dịch:
cardano-cli conway transaction submit $testnet --tx-file mint-nft.signed

#Gửi NFT cho thầy:
cardano-cli conway transaction build \
$testnet \
--tx-in acb01f03fa4005075a58e13b7d633c39fedb98486d3aa647f41eb7f36daa7650#0 \
--tx-in acb01f03fa4005075a58e13b7d633c39fedb98486d3aa647f41eb7f36daa7650#1 \
--tx-out $thaygiao+$output+"$tokenamount $policyid.$tokenname" \
--change-address $address \
--metadata-json-file meta.json \
--out-file send-nft.raw

cardano-cli conway transaction sign $testnet \
--signing-key-file $address_SKEY  \
--signing-key-file tokens/policy/policy.skey  \
--tx-body-file send-nft.raw \
--out-file send-nft.signed

cardano-cli conway transaction submit $testnet --tx-file send-nft.signed