CREATE TABLE teams (
    teamname varchar(32) NOT NULL,
    PRIMARY KEY (teamname)
);

CREATE TABLE users (
    username varchar(32) NOT NULL,
    password varchar(32) NOT NULL,
    fullname varchar(32) NOT NULL,
    email varchar(254) UNIQUE,
    teamname varchar(32),
    team_role varchar(32),
    about text,
    access varchar(16),
    PRIMARY KEY(username),
    FOREIGN KEY (teamname) REFERENCES teams (teamname)
);

CREATE TABLE sessions (
    username varchar(32) NOT NULL,
    token text NOT NULL,
    expires timestamp NOT NULL,
    PRIMARY KEY (token),
    FOREIGN KEY (username) REFERENCES users (username)
);

CREATE TABLE teamleads (
    username varchar(32) NOT NULL,
    teamname varchar(32) NOT NULL,
    PRIMARY KEY (username, teamname),
    FOREIGN KEY (username) REFERENCES users (username),
    FOREIGN KEY (teamname) REFERENCES teams (teamname)
);

CREATE TABLE comps (
    compname varchar(32) NOT NULL,
    class varchar(32) NOT NULL,
    compcolor varchar(10) NOT NULL,
    PRIMARY KEY (compname)
);

CREATE TABLE compchecks (
    checkname varchar(32) NOT NULL,
    compname varchar(32) NOT NULL,
    comptier int NOT NULL,
    description text NOT NULL,
    PRIMARY KEY(checkname),
    FOREIGN KEY (compname) REFERENCES comps (compname)
);

CREATE TABLE usercomps (
    username varchar(32) NOT NULL,
    checkname varchar(32) NOT NULL,
    PRIMARY KEY(username, checkname),
    FOREIGN KEY (checkname) REFERENCES compchecks (checkname),
    FOREIGN KEY (username) REFERENCES users (username)
);

CREATE TABLE tasks (
    taskid serial NOT NULL,
    taskname varchar(32) NOT NULL,
    teamname varchar(32) NOT NULL,
    about text,
    PRIMARY KEY (taskid),
    UNIQUE (taskname, teamname),
    FOREIGN KEY (teamname) REFERENCES teams (teamname)
);

CREATE TABLE tasktags (
    taskid int NOT NULL,
    tagname varchar(32) NOT NULL,
    tagcolor varchar(10) NOT NULL,
    PRIMARY KEY (taskid, tagname),
    FOREIGN KEY (taskid) REFERENCES tasks (taskid)
);

CREATE TABLE taskusers (
    taskid int NOT NULL,
    username varchar(32) NOT NULL,
    PRIMARY KEY (taskid, username),
    FOREIGN KEY (taskid) REFERENCES tasks (taskid),
    FOREIGN KEY (username) REFERENCES users (username)
);

INSERT INTO
    teams (teamname)
VALUES
    ('Оценщики');

INSERT INTO
    users (
        username,
        password,
        fullname,
        email,
        teamname,
        team_role,
        about,
        access
    )
VALUES
    (
        'binarycat',
        'aboba',
        'Владимир Смирнов',
        'smirnov.vladimir17@gmail.com',
        'Оценщики',
        'programmer',
        'I like cats',
        'user'
    ),
    (
        'edunorog',
        'aboba',
        'Диденко',
        'megachel1@gmail.com',
        'Оценщики',
        'scrum master',
        'I like startaps',
        'user'
    ),
    (
        'deusagile',
        'aboba',
        'Сергей Калюжный',
        'megachel2@gmail.com',
        'Оценщики',
        'pruduct master',
        'lol kek cheburek ',
        'user'
    ),
    (
        'qwerty',
        'aboba',
        'Александр Полторопавлов',
        'megachel3@gmail.com',
        'Оценщики',
        'UI master',
        'lol kek cheburek',
        'user'
    ),
    (
        'shahov',
        'aboba',
        'Артём Шахов',
        'megachel4@gmail.com',
        'Оценщики',
        'Front master',
        'lol kek cheburek',
        'user'
    );