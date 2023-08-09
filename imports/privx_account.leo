program privx_account.aleo {
    record Account {
        owner: address,
        id: u64
    }

    transition create_account(id: u64) -> Account {
        return Account {
            owner: self.caller,
            id: id,
        };
    }

    
}