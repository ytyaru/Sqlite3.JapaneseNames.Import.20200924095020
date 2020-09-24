create table if not exists FirstNames(
    Id      int     not null,
    Yomi    text    not null,
    Kaki    text    not null,
    Sex     text    not null,
    primary key(Id),
    unique(Yomi,Kaki),
    check(Sex='m' or Sex='f' or Sex='c' or Sex='mc' or Sex='fc' or Sex='cm' or Sex='cf')
)
