module nft::mycat {
    use std::ascii::String;
    use sui::event;
    use sui::object;
    use sui::object::{UID, ID};
    use sui::transfer::public_transfer;
    use sui::tx_context;
    use sui::tx_context::TxContext;

    struct NFT has key,store {
        id: UID,
        name: String,
        desc: String,
        url:  String,
    }

    // ====== events ======
    struct MintNFT has copy, drop {
        object_id: ID,
        creator: address,
        name: String,
    }

    struct BrunNFT has copy, drop {
        object_id: ID,
        operator: address,
    }

    // every one can mint
    public entry fun mint(name: String,desc: String, url: String, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let nft = NFT{
            id: object::new(ctx),
            name,
            desc,
            url,
        };

        event::emit(MintNFT{
            object_id: object::uid_to_inner(&nft.id),
            creator: sender,
            name: nft.name,
        });
        public_transfer(nft, sender)
    }

    public entry fun update_description(
        nft: &mut NFT,
        new_desc: String,
        _: &mut TxContext
    ) {
        nft.desc = new_desc
    }

    public entry fun burn(nft: NFT, ctx: &mut TxContext) {
        let NFT{id,name:_,desc:_,url:_} = nft;

        event::emit(BrunNFT{
            object_id: object::uid_to_inner(&id),
            operator: tx_context::sender(ctx),
        });
        object::delete(id)
    }
}