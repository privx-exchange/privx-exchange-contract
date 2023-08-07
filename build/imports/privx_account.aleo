program privx_account.aleo;

record Account:
    owner as address.private;
    id as u64.private;


function create_account:
    input r0 as u64.private;
    cast self.caller r0 into r1 as Account.record;
    output r1 as Account.record;
