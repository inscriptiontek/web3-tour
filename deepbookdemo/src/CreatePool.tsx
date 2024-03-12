import { useCurrentAccount, useSuiClientQuery } from "@mysten/dapp-kit";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { normalizeSuiObjectId } from "@mysten/sui.js/utils";
import { Flex, Heading, Text } from "@radix-ui/themes";


const ENOUGH_GAS_BUDGET = 10000000;

const DEEPBOOK_PACKAGE_ID = 'https://explorer.sui.io/object/0x000000000000000000000000000000000000000000000000000000000000dee9'
const CLOCK = normalizeSuiObjectId("0x6")
/**
 * @description: Create pool for trading pair
 * @param token1 Full coin type of the base asset, eg: "0x3d0d0ce17dcd3b40c2d839d96ce66871ffb40e1154a8dd99af72292b3d10d7fc::wbtc::WBTC"
 * @param token2 Full coin type of quote asset, eg: "0x3d0d0ce17dcd3b40c2d839d96ce66871ffb40e1154a8dd99af72292b3d10d7fc::usdt::USDT"
 * @param tickSize Minimal Price Change Accuracy of this pool, eg: 10000000
 * @param lotSize Minimal Lot Change Accuracy of this pool, eg: 10000
 */
function createPool(
    base_coin: string,
    quote_coin: string,
    tickSize: number,
    lotSize: number,
): TransactionBlock {
    const txb = new TransactionBlock();
    // 100 sui to create a pool
    const [coin] = txb.splitCoins(txb.gas, [txb.pure(100000000000)]);
    txb.moveCall({
        typeArguments: [base_coin, quote_coin],
        target: `dee9::clob::create_pool`,
        arguments: [txb.pure(`${tickSize}`), txb.pure(`${lotSize}`), coin],
    });
    txb.setGasBudget(ENOUGH_GAS_BUDGET);
    return txb;
}


function createAccount(currentAccount: string): TransactionBlock {
    const txb = new TransactionBlock();
    let [cap] = txb.moveCall({
        typeArguments: [],
        target: `dee9::clob_v2::create_account`,
        arguments: [],
    })
    txb.transferObjects([cap], txb.pure(currentAccount));
    txb.setSenderIfNotSet(currentAccount);
    txb.setGasBudget(ENOUGH_GAS_BUDGET)

    return txb;
}

export function OwnedObjects() {
    const account = useCurrentAccount();
    const { data, isPending, error } = useSuiClientQuery(
        "getOwnedObjects",
        {
            owner: account?.address as string,
        },
        {
            enabled: !!account,
        },
    );

    if (!account) {
        return;
    }

    if (error) {
        return <Flex>Error: {error.message}</Flex>;
    }

    if (isPending || !data) {
        return <Flex>Loading...</Flex>;
    }

    return (
        <Flex direction="column" my="2">
            {data.data.length === 0 ? (
                <Text>No objects owned by the connected wallet</Text>
            ) : (
                <Heading size="4">Objects owned by the connected wallet</Heading>
            )}
            {data.data.map((object) => (
                <Flex key={object.data?.objectId}>
                    <Text>Object ID: {object.data?.objectId}</Text>
                </Flex>
            ))}
        </Flex>
    );
}


