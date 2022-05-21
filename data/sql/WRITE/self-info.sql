UPDATE
    users
SET
    username = '$1',
    password = '$2',
    fullname = '$3',
    email = '$4',
    about = '$5'
WHERE
    username = '$1';