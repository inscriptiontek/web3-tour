#[lint_allow(self_transfer)]
module notes::notes {
    use sui::tx_context::{TxContext, Self};
    use sui::transfer::Self;
    use sui::object::{Self, UID};
    use std::string::String;

    struct Notes has key {
        id: UID
    }

    struct Note has key, store {
        id: UID,
        title: String,
        body: String
    }

    #[allow(unused_function)]
    fun init(ctx: &mut TxContext) {
        let notes = Notes{
            id: sui::object::new(ctx),
        };
        transfer::share_object(notes)
    }

    public fun create_note(title: String, body: String, ctx: &mut TxContext) {
        let note = Note {
            id: object::new(ctx),
            title,
            body
        };
        transfer::transfer(note, tx_context::sender(ctx))
    }

    public fun delete_note(note: Note, _ctx: &mut TxContext) {
        let Note {id, title: _title, body: _body} = note;
        sui::object::delete(id)
    }
}