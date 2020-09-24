create table if not exists LastNames(
    Id      int,
    Yomi    text    not null,
    Kaki    text    not null,
    primary key(Id),
    unique(Yomi,Kaki)
)
