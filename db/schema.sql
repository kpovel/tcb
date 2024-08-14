create table images (
    id    integer primary key autoincrement,
    name  text not null,
    value blob not null
) strict;

create table categories (
    id         integer primary key autoincrement,
    name       text                                not null,
    group_name text                                not null,
    lang       text check ( lang in ('en', 'uk') ) not null
) strict;

create table validate_email_codes (
    id              integer primary key autoincrement,
    code            integer                                   not null,
    validated_email integer check (validated_email in (0, 1)) not null
) strict;

create table users (
    id             integer primary key autoincrement,
    login          text not null,
    nickname       text,
    email          text not null,
    validate_email integer foreign key references validate_email_codes (id),
    password       text not null,
    onboarded check (onboarded in (0, 1)),
    avatar_id      integer foreign key references images (id),
    about_me       text
) strict;

create table access_tokens (
    id         integer primary key autoincrement,
    user_id    integer foreign key references users (id) not null,
    token      text                                      not null,
    expired_at date                                      not null
) strict;

create table refresh_tokens (
    id         integer primary key autoincrement,
    user_id    integer foreign key references users (id) not null,
    token      text                                      not null,
    expired_at date default current_timestamp            not null
) strict;

create table user_categories (
    id          integer primary key autoincrement,
    user_id     integer foreign key references users (id),
    category_id integer primary key references categories (id)
) strict;

--- 

create table chat_messages_id (
    id          integer primary key autoincrement,
    sent_by     integer                        not null,
    sent_at     date default current_timestamp not null,
    modified_at date default current_timestamp not null
--     replay_to integer, 
);

create table chat_id (
    id primary key autoincrement,
    uuid     text                                          not null,
    chat_type check ( chat_type in ('public', 'private') ) not null,
    owner_id integer foreign key references users (id)
) strict;
