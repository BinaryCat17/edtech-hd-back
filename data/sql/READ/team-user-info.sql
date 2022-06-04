SELECT
    username,
    fullname,
    email,
    team_role,
    teamname,
    about,
    id
FROM
    users
WHERE
    teamname = $1;