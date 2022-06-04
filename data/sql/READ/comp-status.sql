SELECT
    status
FROM
    usercompchecks
WHERE
    username = $1 AND
    compname = $2 AND
    checkname = $3;