INSERT INTO
    users (
        username,
        password,
        fullname,
        email,
        access,
        teamname,
        about,
        team_role
    )
VALUES
    ($1, $2, $3, $4, $5, $6, $7, $8);