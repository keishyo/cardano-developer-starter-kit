#1-Cài đặt xxd nếu chưa có
apt upgrade
apt update
apt install xxd


#2-Tạo thư mục và Policy
mkdir policy
cardano-cli address key-gen \
    --verification-key-file policy/policy.vkey \
    --signing-key-file policy/policy.skey
	
touch policy/policy.script && echo "" > policy/policy.script

echo "{" >> policy/policy.script
echo "  \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file policy/policy.vkey)\"," >> policy/policy.script
echo "  \"type\": \"sig\"" >> policy/policy.script
echo "}" >> policy/policy.script

cardano-cli conway transaction policyid --script-file ./policy/policy.script > policy/policyID

#3-Tạo biến môi trường
testnet="--testnet-magic 2"
address=$(cat base.addr)
address_SKEY="payment.skey"
cardano-cli query utxo --address $address $testnet

txhash="6977087859c102520b88eb34ed8babc4313c604bf7eb440766adffc7dfa1a972"
txix="1"
policyid=$(cat tokens/policy/policyID)

realtokenname="Hồ Duy Long_365"
tokenname=$(echo -n $realtokenname | xxd -b -ps -c 80 | tr -d '\n')
tokenamount="1"
output="2000000"
ipfs_hash="QmRE3Qnz5Q8dVtKghL4NBhJBH4cXPwfRge7HMiBhK92SJX"

#4-Tạo metadata
echo "{" >> metadatan.json
echo "  \"721\": {" >> metadatan.json
echo "    \"$(cat policy/policyID)\": {" >> metadatan.json
echo "      \"$(echo $realtokenname)\": {" >> metadatan.json
echo "        \"Class\": \"C2VN_BK02\"," >> metadatan.json
echo "        \"Name\": \"Hồ Duy Long\"," >> metadatan.json
echo "        \"Student_No\": \"08\"," >> metadatan.json
echo "        \"Image\": \"ipfs://$(echo $ipfs_hash)\"," >> metadatan.json
echo "        \"Module\": \"Module 1 - CLI\"" >> metadatan.json
echo "      }" >> metadatan.json
echo "    }" >> metadatan.json
echo "  }" >> metadatan.json
echo "}" >> metadatan.json


#4-Tạo giao dịch
cardano-cli conway transaction build \
$testnet \
--tx-in $txhash#$txix \
--tx-out $address+$output+"$tokenamount $policyid.$tokenname" \
--mint "$tokenamount $policyid.$tokenname" \
--mint-script-file tokens/policy/policy.script \
--change-address $address \
--metadata-json-file metadata.json  \
--out-file mint-nft.raw

thaygiao="addr_test1qz3vhmpcm2t25uyaz0g3tk7hjpswg9ud9am4555yghpm3r770t25gsqu47266lz7lsnl785kcnqqmjxyz96cddrtrhnsdzl228"
#4a-Gửi NFT giao dịch
cardano-cli conway transaction build \
$testnet \
--tx-in 07ad28c51d1f1291c72012834982a6eb2eba1fbb5363604d5ac8331df776bdf7#0 \
--tx-in d442f76690c6650d9c7a7edb6223e410a9c6089296ee19f47695d6d0799d382a#1 \
--tx-out $thaygiao+$output+"$tokenamount $policyid.$tokenname" \
--change-address $address \
--metadata-json-file meta.json  \
--out-file send-nft.raw

#4b-Tạo ký giao dịch send NFT
cardano-cli conway transaction sign $testnet \
--signing-key-file $address_SKEY  \
--signing-key-file tokens/policy/policy.skey  \
--tx-body-file send-nft.raw \
--out-file send-nft.signed

cardano-cli conway transaction sign $testnet \
--signing-key-file $address_SKEY  \
--signing-key-file tokens/policy/policy.skey  \
--tx-body-file mint-nft.raw \
--out-file mint-nft.signed

cardano-cli conway transaction submit $testnet --tx-file send-nft.signed 

#5-Tạo ký giao dịch
cardano-cli conway transaction sign $testnet \
--signing-key-file $address_SKEY  \
--signing-key-file tokens/policy/policy.skey  \
--tx-body-file mint-nft.raw \
--out-file mint-nft.signed

#5-Gửi giao dịch 

cardano-cli conway transaction submit $testnet --tx-file mint-nft.signed
148c5f96a4b26bdcae31a7d12d8c9c8ff88f857d039143383bb76af7.54454d504f
6977087859c102520b88eb34ed8babc4313c604bf7eb440766adffc7dfa1a972




#================= Burn token vừa tạo=============
#1-Truy vấn token nằm ở UTXO nào
cardano-cli query utxo $testnet --address $address 

#2- cập nhật biến môi trường
txhash="c8a61d193bc6e9ce2ef67ded2f2dd5b63933381a6fb753205bf00fb783615de7"
txix="0"
burnoutput="1400000"

#3-Tạo giao dịch
cardano-cli conway transaction build \
 --testnet-magic 2\
 --tx-in $txhash#$txix\
 --tx-in 9d6f11e796d762afdcbfdd91b7db0fb5ccd6d8b86b590d0965e8f1dcd14eb22f#1\
 --tx-out $address+$burnoutput\
 --mint="-1 $policyid.$tokenname"\
 --minting-script-file policy/policy.script \
 --change-address $address \
 --witness-override 2 \
 --out-file burning.raw

#4-Ký giao dịch
cardano-cli conway transaction sign  $testnet \
--signing-key-file $address_SKEY  \
--signing-key-file policy/policy.skey  \
--tx-body-file burning.raw \
--out-file burning.signed

#5-Gửi giao dịch

cardano-cli conway transaction submit $testnet --tx-file burning.signed 