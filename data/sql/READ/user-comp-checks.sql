SELECT
    cc.checkname,
    cc.compname,
    cc.comptier,
    cc.description,
    cc.maxvotes,
    CASE WHEN u.username = $1 THEN u.votes ELSE 0 END as votes
FROM
    compchecks cc
    LEFT OUTER JOIN usercomps u ON u.checkname = cc.checkname AND u.username = $1
    ORDER BY cc.comptier, votes DESC;