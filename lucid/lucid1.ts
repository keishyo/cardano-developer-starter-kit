/* import { Blockfrost, Lucid, Crypto } from "https://deno.land/x/lucid/mod.ts";

const lucid = new Lucid({
  provider: new Blockfrost(
    "https://cardano-preview.blockfrost.io/api/v0",
    "previewuidN5IhGWbXXX4o6ITfvMbPGHQaeYk9h",
  ),
});

const seed = "snow diesel crouch wagon science happy prepare lounge search party hope cannon board remain acoustic type annual search tornado acoustic return until garlic organ"
lucid.selectWalletFromSeed(seed, { addressType: "Base", index: 0 });

const utxos = await lucid.utxosAt(address);
console.log("UTXOs:", utxos);

if (utxos.length > 0) {
    console.log(`Lovelace: ${utxos[0].assets.lovelace}`);
} else {
    console.log("Không tìm thấy UTXO nào tại địa chỉ này.");
}
 */
import { Blockfrost, Lucid, Crypto } from "https://deno.land/x/lucid/mod.ts";

const lucid = new Lucid({
  provider: new Blockfrost(
    "https://cardano-preview.blockfrost.io/api/v0",
    "previewuidN5IhGWbXXX4o6ITfvMbPGHQaeYk9h"
  ),
});

const seed = "snow diesel crouch wagon science happy prepare lounge search party hope cannon board remain acoustic type annual search tornado acoustic return until garlic organ";
lucid.selectWalletFromSeed(seed, { addressType: "Base", index: 0 });

async function main() {
  const address = await lucid.wallet.address();
  console.log(`Địa chỉ ví gửi: ${address}`);

  const utxos = await lucid.utxosAt(address);
  console.log("UTXOs:", utxos);

  if (utxos.length > 0) {
    console.log(`Lovelace: ${utxos[0].assets.lovelace}`);
  } else {
    console.log("Không tìm thấy UTXO nào tại địa chỉ này.");
  }
}

await main();