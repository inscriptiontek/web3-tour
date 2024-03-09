module nft::mynft {
    use std::ascii::String;
    use std::string::utf8;
    use sui::display;
    use sui::event;
    use sui::object;
    use sui::object::{UID, ID};
    use sui::package;
    use sui::transfer;
    use sui::transfer::public_transfer;
    use sui::tx_context;
    use sui::tx_context::{TxContext};

    // otw
    struct MYNFT has drop {}

    struct NFT has key,store {
        id: UID,
        name: String,
        description: String,
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

    
    fun init(otw: MYNFT, ctx: &mut sui::tx_context::TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"image_url"),
            utf8(b"project_url"),
        ];

        let values = vector[
            // For `name` we can use the `Github.name` property
            utf8(b"{name}"),
            // Image URL wo can use the `Github.name` property
            utf8(b"https://github.com/{name}.png"),
            // Project URL is usually static
            utf8(b"https://github.com"),
        ];

        let publisher = package::claim(otw, ctx);
        let display = display::new_with_fields<NFT>(&publisher, keys, values,ctx);

        // update version to 1
        display::update_version(&mut display);

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));
    }

    // every one can mint
    public entry fun mint(name: String,description: String, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let nft = NFT{
            id: object::new(ctx),
            name,
            description,
        };

        event::emit(MintNFT{
            object_id: object::uid_to_inner(&nft.id),
            creator: sender,
            name: nft.name,
        });
        public_transfer(nft, sender)
    }



    public entry fun burn(nft: NFT, ctx: &mut TxContext) {
        let NFT{id,name:_, description:_} = nft;

        event::emit(BrunNFT{
            object_id: object::uid_to_inner(&id),
            operator: tx_context::sender(ctx),
        });

        object::delete(id)
    }
}