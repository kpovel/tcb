begin transaction;

create table public_chat (
    id       integer primary key autoincrement,
    name     text not null,
    image_id integer references image (id)
);

create table chat_members (
    id      integer primary key autoincrement,
    chat_id integer references public_chat (id),
    user_id integer references users (id),
    owner   boolean not null
);

create table chat_messages (
    id             integer primary key autoincrement,
    chat_member_id integer references chat_messages (id) not null,
    message        text                                  not null,
    inserted_at    text                                  not null
    -- updated_at text not null
    -- todo: if an inserted and updated date is different it means that the message is modified
);
