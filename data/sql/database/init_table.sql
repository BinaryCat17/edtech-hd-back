CREATE TABLE teams (teamname varchar(32) NOT NULL, PRIMARY KEY (teamname));

CREATE TABLE users (
    id serial NOT NULL,
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

CREATE TABLE users_feedback (
    toname varchar(32) NOT NULL,
    fromname varchar(32) NOT NULL,
    mark real NOT NULL,
    comment text NOT NULL,
    teammark real NOT NULL,
    teamcomment text NOT NULL,
    PRIMARY KEY (toname, fromname),
    FOREIGN KEY (toname) REFERENCES users (username),
    FOREIGN KEY (fromname) REFERENCES users (username)
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
    compname varchar(128) NOT NULL,
    color varchar(16) NOT NULL,
    levelcount int NOT NULL,
    description text NOT NULL,
    PRIMARY KEY (compname)
);

CREATE TABLE compchecks (
    checkname varchar(128) NOT NULL,
    compname varchar(128) NOT NULL,
    level int NOT NULL,
    maxvotes int NOT NULL,
    description text NOT NULL,
    PRIMARY KEY(compname, checkname),
    FOREIGN KEY (compname) REFERENCES comps (compname)
);

CREATE TABLE usercomps (
    username varchar(32) NOT NULL,
    compname varchar(128) NOT NULL,
    currentlevel int NOT NULL,
    comment text NOT NULL,
    PRIMARY KEY(username, compname),
    FOREIGN KEY (username) REFERENCES users(username),
    FOREIGN KEY (compname) REFERENCES comps(compname)
);

CREATE TABLE usercompchecks (
    username varchar(32) NOT NULL,
    compname varchar(128) NOT NULL,
    checkname varchar(128) NOT NULL,
    votes int NOT NULL,
    status varchar(32) NOT NULL,
    PRIMARY KEY(username, compname, checkname),
    FOREIGN KEY (username, compname) REFERENCES usercomps (username, compname),
    FOREIGN KEY (compname, checkname) REFERENCES compchecks (compname, checkname),
    CHECK (status IN ('unknown', 'insufficient', 'complete'))
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

CREATE TABLE kanban (v int DEFAULT 0, j json);

INSERT INTO
    kanban (j, teamname)
VALUES
    ('[]':: json, 'Работяги'),
    ('[]':: json, 'Едунароги'),
    ('[]':: json, 'Магачелы');

INSERT INTO
    teams (teamname)
VALUES
    ('Оценщики'),
    ('Работяги'),
    ('Едунароги'),
    ('Мегачелы');

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
        'Владимир',
        'smirnov.vladimir17@gmail.com',
        'Оценщики',
        'programmer',
        'I like cats',
        'user'
    ),
    (
        'edunorog',
        'aboba',
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
        'Сергей',
        'megachel2@gmail.com',
        'Оценщики',
        'pruduct master',
        'lol kek cheburek ',
        'user'
    ),
    (
        'qwerty',
        'aboba',
        'Александр',
        'megachel3@gmail.com',
        'Оценщики',
        'UI master',
        'lol kek cheburek',
        'user'
    ),
    (
        'shahov',
        'aboba',
        'Артём',
        'megachel4@gmail.com',
        'Оценщики',
        'Front master',
        'lol kek cheburek',
        'user'
    );

INSERT INTO
    comps (compname, description, levelcount, color)
VALUES
    ('communication', 'aboba communication', 3, 'red'),
    ('programming', 'aboba programming', 2, 'darkred'),
    ('leadership', 'aboba leadership', 2, 'green'),
    ('electronic', 'aboba electronic', 2, 'darkgreen'),
    ('economic', 'aboba economic', 2, 'blue'),
    ('abobus', 'aboba abobus', 2, 'darkblue');

INSERT INTO
    compchecks (checkname, compname, level, description, maxvotes)
VALUES
    (
        'умею говорить',
        'communication',
        1,
        'Генерирует идеи решения задач в стрессовых и непредвиденных ситуациях, использует технологии генерации.',
        20
    ),
    (
        'умею слышать',
        'communication',
        1,
        'Использует технологии освобождения от стереотипов',
        10
    ),
    (
        'умею видеть',
        'communication',
        1,
        'Оценивает идеи исходя из эффективности достижения результата, может принять идею, которая эмоционально неприятна',
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
    ('недожаба', 'programming', 1, 'ЖАБАСКРИПТ!', 20),
    ('пихтон', 'programming', 1, 'ПИХТОН!', 10),
    ('кресты', 'programming', 2, 'СИГФАУЛТ!', 30),
    (
        'графика',
        'programming',
        2,
        'ВСЕЛЕННАЯ ЖДЁТ ТЕБЯ!',
        20
    ),
    ('паять', 'electronic', 1, 'кар!', 10),
    ('непаясть', 'electronic', 1, 'гав!', 30),
    ('робот', 'electronic', 2, 'УБИВАТЬ!', 25),
    (
        'всё сгорело',
        'electronic',
        2,
        'ХАШЕВ ЖДЁТ ТЕБЯ!',
        15
    );

INSERT INTO
    usercomps (username, compname, currentlevel, comment)
VALUES
    (
        'shahov',
        'communication',
        2,
        'mega deusagile communication comment'
    ),
    (
        'shahov',
        'programming',
        1,
        'mega deusagile programming comment'
    ),
    (
        'shahov',
        'electronic',
        1,
        'mega deusagile electronic comment'
    ),
    (
        'qwerty',
        'communication',
        2,
        'mega binarycat communication comment'
    ),
    (
        'qwerty',
        'programming',
        2,
        'mega binarycat programming comment'
    ),
    (
        'qwerty',
        'electronic',
        1,
        'mega binarycat electronic comment'
    ),
    (
        'binarycat',
        'Системное мышление',
        1,
        'mega deusagile programming comment'
    ),
    (
        'binarycat',
        'Межотраслевая коммуникация',
        1,
        'mega deusagile programming comment'
    ),
    (
        'binarycat',
        'Управление проектами и процессами',
        2,
        'mega deusagile programming comment'
    ),
    (
        'binarycat',
        'Работа с ИТ-системами',
        2,
        'mega deusagile programming comment'
    ),
    (
        'binarycat',
        'Клиентоориентированность',
        2,
        'mega deusagile programming comment'
    ),
    (
        'binarycat',
        'Работа с людьми и работа в команде',
        3,
        'mega deusagile programming comment'
    ),
    (
        'edunorog',
        'Работа в условиях неопределенности',
        3,
        'mega deusagile programming comment'
    ),
    (
        'edunorog',
        'Мультикультурность и открытость',
        2,
        'mega deusagile programming comment'
    ),
    (
        'edunorog',
        'Осознанность',
        2,
        'mega deusagile programming comment'
    ),
    (
        'edunorog',
        'Коммуникация',
        1,
        'mega deusagile programming comment'
    ),
    (
        'deusagile',
        'Работа с ИТ-системами',
        2,
        'mega deusagile programming comment'
    ),
    (
        'deusagile',
        'Клиентоориентированность',
        2,
        'mega deusagile programming comment'
    ),
    (
        'deusagile',
        'Работа с людьми и работа в команде',
        3,
        'mega deusagile programming comment'
    ),
    (
        'deusagile',
        'Работа в условиях неопределенности',
        3,
        'mega deusagile programming comment'
    );

INSERT INTO
    usercompchecks (username, compname, checkname, votes, status)
VALUES
    (
        'shahov',
        'communication',
        'умею говорить',
        14,
        'complete'
    ),
    (
        'shahov',
        'communication',
        'умею слышать',
        26,
        'complete'
    ),
    (
        'shahov',
        'communication',
        'умею видеть',
        35,
        'complete'
    ),
    (
        'shahov',
        'programming',
        'недожаба',
        15,
        'insufficient'
    ),
    ('shahov', 'programming', 'пихтон', 13, 'complete'),
    ('shahov', 'electronic', 'паять', 66, 'complete'),
    (
        'shahov',
        'electronic',
        'непаясть',
        12,
        'insufficient'
    ),
    (
        'shahov',
        'electronic',
        'всё сгорело',
        88,
        'complete'
    ),
    (
        'qwerty',
        'communication',
        'умею говорить',
        22,
        'complete'
    ),
    (
        'qwerty',
        'communication',
        'умею слышать',
        32,
        'complete'
    ),
    (
        'qwerty',
        'communication',
        'умею видеть',
        31,
        'complete'
    ),
    (
        'qwerty',
        'communication',
        'умею рассказывать',
        5,
        'insufficient'
    ),
    (
        'qwerty',
        'communication',
        'умею слушать',
        51,
        'complete'
    ),
    ('qwerty', 'programming', 'недожаба', 43, 'complete'),
    ('qwerty', 'programming', 'пихтон', 23, 'complete'),
    (
        'qwerty',
        'programming',
        'кресты',
        12,
        'insufficient'
    ),
    ('qwerty', 'electronic', 'паять', 28, 'complete'),
    (
        'qwerty',
        'electronic',
        'непаясть',
        17,
        'insufficient'
    ),
    (
        'qwerty',
        'electronic',
        'всё сгорело',
        10,
        'insufficient'
    ),
    (
        'binarycat',
        'Системное мышление',
        'Видение целого',
        23,
        'insufficient'
    ),
    (
        'binarycat',
        'Системное мышление',
        'Видение взаимосвязанных циклов причинности',
        10,
        'insufficient'
    ),
    (
        'binarycat',
        'Системное мышление',
        'Видение динамических процессов изменений во времени',
        18,
        'insufficient'
    ),
    (
        'binarycat',
        'Системное мышление',
        'Видение истинных системных причин',
        16,
        'insufficient'
    ),
    (
        'binarycat',
        'Системное мышление',
        'Учет задержки реакции системы',
        20,
        'insufficient'
    ),
    (
        'binarycat',
        'Межотраслевая коммуникация',
        'Эмпатия',
        17,
        'insufficient'
    ),
    (
        'binarycat',
        'Межотраслевая коммуникация',
        'Фокусировка',
        10,
        'insufficient'
    ),
    (
        'binarycat',
        'Межотраслевая коммуникация',
        'Генерация идей',
        28,
        'insufficient'
    ),
    (
        'binarycat',
        'Межотраслевая коммуникация',
        'Выбор идеи',
        14,
        'insufficient'
    ),
    (
        'binarycat',
        'Межотраслевая коммуникация',
        'Прототипирование',
        23,
        'insufficient'
    ),
    (
        'binarycat',
        'Межотраслевая коммуникация',
        'Тест',
        23,
        'insufficient'
    );

INSERT INTO
    userattach (username, file)
VALUES
    ('binarycat', 'resume.pdf'),
    ('binarycat', 'sql.pdf'),
    ('edunorog', 'эффективный c++.pdf'),
    ('edunorog', 'c++ мультипоточность.pdf'),
    ('deusagile', 'Совершенный код.pdf'),
    ('deusagile', 'Язык программирования Go.pdf'),
    ('qwerty', 'Cloud Native Go.pdf'),
    ('qwerty', 'swebok-v3.pdf'),
    ('shahov', 'c++ базовый курс.pdf'),
    ('shahov', 'data oriented design.pdf');

INSERT INTO
    users_feedback (
        toname,
        fromname,
        mark,
        comment,
        teammark,
        teamcomment
    )
VALUES
    (
        'binarycat',
        'edunorog',
        5.0,
        'Очень классный чел, работал с восьми до восьми, сделал очень много задач, помог лично мне множество раз, приносил тортики по пятницам, а в субботу развлекал команду игрой в настолки.',
        4.0,
        'Каждый из нас понимает очевидную вещь: новая модель организационной деятельности предопределяет высокую востребованность поэтапного и последовательного развития общества. И нет сомнений, что базовые сценарии поведения пользователей призваны к ответу.'
    ),
    (
        'binarycat',
        'qwerty',
        2.0,
        'Очень плохой чел, не работал с восьми до восьми, сделал очень мало задач, послал меня подальше, отбирал тортики по пятницам, а в субботу мешал играть в настолкиКстати, многие известные личности, которые представляют собой яркий пример континентально-европейского типа политической культуры, будут смешаны с не уникальными данными до степени совершенной неузнаваемости, из-за чего возрастает их статус бесполезности. Безусловно, постоянный количественный рост и сфера нашей активности создаёт предпосылки для кластеризации усилий.',
        5.0,
        'Кстати, многие известные личности, которые представляют собой яркий пример континентально-европейского типа политической культуры, будут смешаны с не уникальными данными до степени совершенной неузнаваемости, из-за чего возрастает их статус бесполезности. Безусловно, постоянный количественный рост и сфера нашей активности создаёт предпосылки для кластеризации усилий.'
    ),
    (
        'binarycat',
        'deusagile',
        5.0,
        'Мало работал, но чел зачётный',
        2.0,
        'Ясность нашей позиции очевидна: дальнейшее развитие различных форм деятельности способствует подготовке и реализации новых предложений. Ясность нашей позиции очевидна: понимание сути ресурсосберегающих технологий не даёт нам иного выбора, кроме определения глубокомысленных рассуждений.'
    ),
    (
        'deusagile',
        'edunorog',
        5.0,
        'В своём стремлении повысить качество жизни, они забывают, что убеждённость некоторых оппонентов способствует повышению качества новых предложений. Предварительные выводы неутешительны: экономическая повестка сегодняшнего дня предопределяет высокую востребованность благоприятных перспектив.',
        4.0,
        'В рамках спецификации современных стандартов, представители современных социальных резервов набирают популярность среди определенных слоев населения, а значит, должны быть смешаны с не уникальными данными до степени совершенной неузнаваемости, из-за чего возрастает их статус бесполезности. Прежде всего, выбранный нами инновационный путь прекрасно подходит для реализации соответствующих условий активизации.'
    ),
    (
        'deusagile',
        'qwerty',
        4.0,
        'Мы вынуждены отталкиваться от того, что глубокий уровень погружения создаёт необходимость включения в производственный план целого ряда внеочередных мероприятий с учётом комплекса своевременного выполнения сверхзадачи. Сложно сказать, почему базовые сценарии поведения пользователей, которые представляют собой яркий пример континентально-европейского типа политической культуры, будут представлены в исключительно положительном свете.',
        4.0,
        'Равным образом, новая модель организационной деятельности в значительной степени обусловливает важность глубокомысленных рассуждений. Безусловно, перспективное планирование позволяет оценить значение укрепления моральных ценностей.'
    ),
    (
        'deusagile',
        'binarycat',
        1.0,
        'А ещё тщательные исследования конкурентов, инициированные исключительно синтетически, объявлены нарушающими общечеловеческие нормы этики и морали! Современные технологии достигли такого уровня, что современная методология разработки обеспечивает широкому кругу (специалистов) участие в формировании вывода текущих активов.',
        5.0,
        'С учётом сложившейся международной обстановки, постоянное информационно-пропагандистское обеспечение нашей деятельности обеспечивает широкому кругу (специалистов) участие в формировании новых предложений. Но новая модель организационной деятельности напрямую зависит от соответствующих условий активизации.'
    ),
    (
        'edunorog',
        'binarycat',
        3.0,
        'Повседневная практика показывает, что постоянное информационно-пропагандистское обеспечение нашей деятельности требует анализа направлений прогрессивного развития. Высокий уровень вовлечения представителей целевой аудитории является четким доказательством простого факта: сплочённость команды профессионалов, в своём классическом представлении, допускает внедрение укрепления моральных ценностей.',
        4.0,
        'И нет сомнений, что ключевые особенности структуры проекта призывают нас к новым свершениям, которые, в свою очередь, должны быть обнародованы. В своём стремлении повысить качество жизни, они забывают, что высокое качество позиционных исследований не оставляет шанса для как самодостаточных, так и внешне зависимых концептуальных решений.'
    ),
    (
        'edunorog',
        'qwerty',
        5.0,
        'Высокий уровень вовлечения представителей целевой аудитории является четким доказательством простого факта: сложившаяся структура организации однозначно определяет каждого участника как способного принимать собственные решения касаемо экономической целесообразности принимаемых решений. В своём стремлении улучшить пользовательский опыт мы упускаем, что акционеры крупнейших компаний, инициированные исключительно синтетически, смешаны с не уникальными данными до степени совершенной неузнаваемости, из-за чего возрастает их статус бесполезности.',
        3.0,
        'А ещё реплицированные с зарубежных источников, современные исследования являются только методом политического участия и указаны как претенденты на роль ключевых факторов. Противоположная точка зрения подразумевает, что непосредственные участники технического прогресса превращены в посмешище, хотя само их существование приносит несомненную пользу обществу.'
    ),
    (
        'edunorog',
        'shahov',
        1.0,
        'С другой стороны, современная методология разработки играет определяющее значение для поставленных обществом задач. Повседневная практика показывает, что высококачественный прототип будущего проекта создаёт предпосылки для системы массового участия.',
        5.0,
        'Являясь всего лишь частью общей картины, независимые государства, вне зависимости от их уровня, должны быть заблокированы в рамках своих собственных рациональных ограничений. Прежде всего, перспективное планирование играет определяющее значение для существующих финансовых и административных условий.'
    ),
    (
        'qwerty',
        'binarycat',
        3.0,
        'Значимость этих проблем настолько очевидна, что укрепление и развитие внутренней структуры не оставляет шанса для укрепления моральных ценностей. Таким образом, перспективное планирование предполагает независимые способы реализации форм воздействия.',
        5.0,
        'Имеется спорная точка зрения, гласящая примерно следующее: диаграммы связей своевременно верифицированы. Каждый из нас понимает очевидную вещь: высокое качество позиционных исследований играет важную роль в формировании системы массового участия.'
    ),
    (
        'qwerty',
        'edunorog',
        2.0,
        'Задача организации, в особенности же высокотехнологичная концепция общественного уклада играет важную роль в формировании первоочередных требований. Банальные, но неопровержимые выводы, а также акционеры крупнейших компаний призывают нас к новым свершениям, которые, в свою очередь, должны быть ассоциативно распределены по отраслям.',
        1.0,
        'Не следует, однако, забывать, что существующая теория создаёт необходимость включения в производственный план целого ряда внеочередных мероприятий с учётом комплекса экономической целесообразности принимаемых решений! Безусловно, начало повседневной работы по формированию позиции прекрасно подходит для реализации поэтапного и последовательного развития общества.'
    ),
    (
        'qwerty',
        'shahov',
        4.5,
        'Однозначно, непосредственные участники технического прогресса обнародованы. В рамках спецификации современных стандартов, многие известные личности обнародованы.',
        5.0,
        'А ещё предприниматели в сети интернет превращены в посмешище, хотя само их существование приносит несомненную пользу обществу. Сложно сказать, почему некоторые особенности внутренней политики ограничены исключительно образом мышления!'
    ),
    (
        'shahov',
        'binarycat',
        3.1,
        'Не следует, однако, забывать, что внедрение современных методик позволяет оценить значение модели развития. Ясность нашей позиции очевидна: выбранный нами инновационный путь требует от нас анализа новых предложений.Не следует, однако, забывать, что внедрение современных методик позволяет оценить значение модели развития. Ясность нашей позиции очевидна: выбранный нами инновационный путь требует от нас анализа новых предложений.',
        4.5,
        'Как принято считать, действия представителей оппозиции являются только методом политического участия и превращены в посмешище, хотя само их существование приносит несомненную пользу обществу. Внезапно, независимые государства ассоциативно распределены по отраслям.'
    ),
    (
        'shahov',
        'edunorog',
        5.0,
        'Как уже неоднократно упомянуто, некоторые особенности внутренней политики, вне зависимости от их уровня, должны быть преданы социально-демократической анафеме! В целом, конечно, перспективное планирование играет важную роль в формировании переосмысления внешнеэкономических политик.',
        4.0,
        'Повседневная практика показывает, что курс на социально-ориентированный национальный проект не оставляет шанса для кластеризации усилий. С другой стороны, экономическая повестка сегодняшнего дня является качественно новой ступенью первоочередных требований.'
    ),
    (
        'shahov',
        'deusagile',
        4.0,
        'Однозначно, независимые государства лишь добавляют фракционных разногласий и ограничены исключительно образом мышления. Также как выбранный нами инновационный путь напрямую зависит от распределения внутренних резервов и ресурсов.',
        2.0,
        'Предварительные выводы неутешительны: повышение уровня гражданского сознания способствует подготовке и реализации распределения внутренних резервов и ресурсов. Принимая во внимание показатели успешности, сложившаяся структура организации является качественно новой ступенью инновационных методов управления процессами.'
    );