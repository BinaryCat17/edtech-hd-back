SELECT
    uc.username,
    uc.currentlevel,
    c.compname,
    c.levelcount,
    c.description,
    c.color
FROM
    usercomps uc,
    comps c
WHERE
    uc.compname = c.compname
ORDER BY uc.username, uc.currentlevel;