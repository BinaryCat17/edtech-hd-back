CREATE TABLE users (
    username varchar(16) NOT NULL,
    fullname varchar(32) NOT NULL,
    email varchar(254) UNIQUE,
    team_role varchar(32),
    about text,
    PRIMARY KEY(username)
);

INSERT INTO users VALUES ('binarycat', 'Владимир Смирнов', 'smirnov.vladimir17@gmail.com', 'programmer', 'I like cats');
INSERT INTO users VALUES ('edunorog', 'Диденко', 'megachel@gmail.com', 'scrup master', 'I like startaps');