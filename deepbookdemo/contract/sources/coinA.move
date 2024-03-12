module deepbookdemo::coinA {

    use std::option;
    use sui::coin;
    use sui::coin::TreasuryCap;
    use sui::transfer;
    use sui::tx_context::{TxContext, sender};

    struct FCOINA has drop {}

    fun init(witness: FCOINA, ctx: &mut TxContext){
        let (treasury, metada) = coin::create_currency(witness,6,b"FCOINA",b"fcoina",b"for test",option::none(),ctx);

        transfer::public_freeze_object(metada);
        transfer::public_transfer(treasury,sender(ctx));
    }

    public entry fun mint(
        treasury_cap: &mut TreasuryCap<FCOINA>,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx)
    }
}