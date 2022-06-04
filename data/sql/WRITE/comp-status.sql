UPDATE
    usercompchecks
SET
    status = $4
WHERE
    username = $1 AND
    compname = $2 AND
    checkname = $3;