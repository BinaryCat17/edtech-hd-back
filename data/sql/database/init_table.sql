CREATE TABLE teams (
    teamname varchar(32) NOT NULL,
    PRIMARY KEY (teamname)
);

CREATE TABLE users (
    username varchar(32) NOT NULL,
    password varchar(32) NOT NULL,
    fullname varchar(32) NOT NULL,
    shortname varchar(32) NOT NULL,
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
    color varchar(16) NOT NULL,
    levelcount int NOT NULL,
    description text NOT NULL,
    PRIMARY KEY (compname)
);

CREATE TABLE compchecks (
    checkname varchar(32) NOT NULL,
    compname varchar(32) NOT NULL,
    level int NOT NULL,
    maxvotes int NOT NULL,
    description text NOT NULL,
    PRIMARY KEY(compname, checkname),
    FOREIGN KEY (compname) REFERENCES comps (compname)
);

CREATE TABLE usercomps (
    username varchar(32) NOT NULL,
    compname varchar(32) NOT NULL,
    currentlevel int NOT NULL,
    PRIMARY KEY(username, compname),
    FOREIGN KEY (username) REFERENCES users(username),
    FOREIGN KEY (compname) REFERENCES comps(compname)
);

CREATE TABLE usercompchecks (
    username varchar(32) NOT NULL,
    compname varchar(32) NOT NULL,
    checkname varchar(32) NOT NULL,
    votes int NOT NULL,
    PRIMARY KEY(username, compname, checkname),
    FOREIGN KEY (username, compname) REFERENCES usercomps (username, compname),
    FOREIGN KEY (compname, checkname) REFERENCES compchecks (compname, checkname)
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

CREATE TABLE userattach (
    username varchar(32) NOT NULL,
    file varchar(32) NOT NULL,
    PRIMARY KEY (file, username),
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
        shortname,
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
        'Смирнов В.',
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
        'DrD PhD',
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
        'Калюжный С.',
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
        'Полторапалов А.',
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
        'Шахов А.',
        'megachel4@gmail.com',
        'Оценщики',
        'Front master',
        'lol kek cheburek',
        'user'
    );

INSERT INTO
    comps (
        compname,
        description,
        levelcount,
        color
    )
VALUES
    (
        'communication',
        'aboba228',
        3,
        'red'
    ),
    (
        'programming',
        'aboba228',
        2,
        'darkred'
    ),
    (
        'leadership',
        'aboba228',
        2,
        'green'
    ),
    (
        'electronic',
        'aboba228',
        2,
        'darkgreen'
    ),
    (
        'economic',
        'aboba228',
        2,
        'blue'
    ),
    (
        'abobus',
        'aboba228',
        2,
        'darkblue'
    );

INSERT INTO
    compchecks (
        checkname,
        compname,
        level,
        description,
        maxvotes
    )
VALUES
    (
        'умею говорить',
        'communication',
        1,
        'НЕ МОЛЧИ!',
        20
    ),
    (
        'умею слышать',
        'communication',
        1,
        'СЛУШАЙ, ЧТО ГОВОРИТ ПОЛКОВНИК!',
        10
    ),
    (
        'умею видеть',
        'communication',
        1,
        'ПОКАЗЫВАЮ ТОЛЬКО ОДИН РАЗ!',
        30
    ),
    (
        'умею рассказывать',
        'communication',
        2,
        'ДОКЛАДЫВАТЬ О ПОКРАСКЕ ТРАВЫ!',
        20
    ),
    (
        'умею слушать',
        'communication',
        2,
        'ДОГАДАТЬСЯ, ЧТО ПОПРОСИЛИ КРАСИТЬ ТРАВУ!',
        10
    ),
    (
        'умею понимать',
        'communication',
        3,
        'ПОНИМАТЬ КАК КРАСИТЬ ТРАВУ!',
        30
    ),
    (
        'недожаба',
        'programming',
        1,
        'ЖАБАСКРИПТ!',
        20
    ),
    (
        'пихтон',
        'programming',
        1,
        'ПИХТОН!',
        10
    ),
    (
        'кресты',
        'programming',
        2,
        'СИГФАУЛТ!',
        30
    ),
    (
        'графика',
        'programming',
        2,
        'ВСЕЛЕННАЯ ЖДЁТ ТЕБЯ!',
        20
    ),
    (
        'паять',
        'electronic',
        1,
        'кар!',
        10
    ),
    (
        'непаясть',
        'electronic',
        1,
        'гав!',
        30
    ),
    (
        'робот',
        'electronic',
        2,
        'УБИВАТЬ!',
        25
    ),
    (
        'всё сгорело',
        'electronic',
        2,
        'ХАШЕВ ЖДЁТ ТЕБЯ!',
        15
    );

INSERT INTO
    usercomps (username, compname, currentlevel)
VALUES
    ('deusagile', 'communication', 2),
    ('deusagile', 'programming', 1),
    ('deusagile', 'electronic', 1),
    ('binarycat', 'communication', 2),
    ('binarycat', 'programming', 1),
    ('binarycat', 'electronic', 1);

INSERT INTO
    usercompchecks (username, compname, checkname, votes)
VALUES
    (
        'deusagile',
        'communication',
        'умею говорить',
        14
    ),
    ('deusagile', 'communication', 'умею слышать', 26),
    ('deusagile', 'communication', 'умею видеть', 35),
    ('deusagile', 'programming', 'недожаба', 15),
    ('deusagile', 'programming', 'пихтон', 13),
    ('deusagile', 'electronic', 'паять', 66),
    ('deusagile', 'electronic', 'непаясть', 12),
    ('deusagile', 'electronic', 'всё сгорело', 88),
    (
        'binarycat',
        'communication',
        'умею говорить',
        22
    ),
    ('binarycat', 'communication', 'умею слышать', 32),
    ('binarycat', 'communication', 'умею видеть', 31),
    (
        'binarycat',
        'communication',
        'умею рассказывать',
        4
    ),
    ('binarycat', 'communication', 'умею слушать', 51),
    ('binarycat', 'programming', 'недожаба', 43),
    ('binarycat', 'programming', 'пихтон', 23),
    ('binarycat', 'programming', 'кресты', 12),
    ('binarycat', 'electronic', 'паять', 28),
    ('binarycat', 'electronic', 'непаясть', 17),
    ('binarycat', 'electronic', 'всё сгорело', 10);

INSERT INTO
    userattach (username, file)
VALUES
    ('binarycat', 'resume.pdf'),
    ('binarycat', 'sql.pdf');