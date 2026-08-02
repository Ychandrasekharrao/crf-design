create database sdtm;

use sdtm;

describe ae ;

describe cm ;

describe dm ;

describe lb ;

describe vs ;


-- ============================================================
-- INDEXES FOR SDTM TABLES (dm, ae, cm, lb, vs)
-- Each index maps to the validation query / edit check it speeds up.
-- ============================================================

-- ---------- DM : Demographics ----------
CREATE INDEX idx_dm_usubjid   ON dm (USUBJID);            -- join key for EVERY cross-domain query
CREATE INDEX idx_dm_site_subj ON dm (SITEID, USUBJID);    -- EC-001  uniqueness per site
CREATE INDEX idx_dm_age       ON dm (AGE);                -- EC-002  age eligibility (AGE < 18 ...)
CREATE INDEX idx_dm_dthdtc    ON dm (DTHDTC);             -- EC-009  death date present when fatal

-- ---------- AE : Adverse Events ----------
CREATE INDEX idx_ae_usubjid    ON ae (USUBJID);            -- join key (EC-003/005/008, orphan check)
CREATE INDEX idx_ae_dates      ON ae (AESTDTC, AEENDTC);   -- EC-004  AEENDTC < AESTDTC
CREATE INDEX idx_ae_ser_sev    ON ae (AESER, AESEV);       -- EC-007  Serious + Mild mismatch
CREATE INDEX idx_ae_outcome    ON ae (AEOUT, AESDTH);      -- EC-009  Fatal outcome vs death flag
CREATE INDEX idx_ae_subj_term  ON ae (USUBJID, AETERM);    -- EC-008  AE-log vs ADR-form reconciliation

-- ---------- CM : Concomitant Medications ----------
CREATE INDEX idx_cm_usubjid ON cm (USUBJID);               -- join key (EC-003 "no CM recorded")
CREATE INDEX idx_cm_trt     ON cm (CMTRT);                 -- suspect-drug / drug-name lookups

-- ---------- LB : Laboratory ----------
CREATE INDEX idx_lb_usubjid ON lb (USUBJID);               -- join key (EC-003 "no LB", AE<->LB reconcile)
CREATE INDEX idx_lb_range   ON lb (LBSTRESN, LBSTNRLO, LBSTNRHI);  -- out-of-range lab check
CREATE INDEX idx_lb_testcd  ON lb (LBTESTCD);              -- filter by lab test

-- ---------- VS : Vital Signs / Visits ----------
CREATE INDEX idx_vs_usubjid ON vs (USUBJID);               -- join key
CREATE INDEX idx_vs_vstdtc  ON vs (VSDTC);                 -- visit-date logic
CREATE INDEX idx_vs_testcd  ON vs (VSTESTCD);              -- filter by vital-sign test

-- Refresh optimizer statistics so the new indexes are actually used
ANALYZE TABLE dm, ae, cm, lb, vs;


SELECT TABLE_NAME, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
GROUP BY TABLE_NAME, INDEX_NAME
ORDER BY TABLE_NAME, INDEX_NAME;

-- 01. Validation 

-- EC-INT: Orphan subjects + Post-screen-failure data reconciliation
-- Calibrated to CDISCPILOT ARMCD values: Scrnfail = screen failure/withdrawal proxy
SELECT 
    'EC-INT' AS check_id,
    'Orphan subjects or post-screen-failure data' AS description,
    COUNT(*) AS violations,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'REVIEW' END AS status
FROM (
    -- Part A: True orphans (in domain but NOT in dm at all)
    SELECT DISTINCT USUBJID FROM ae WHERE USUBJID NOT IN (SELECT USUBJID FROM dm)
    UNION ALL
    SELECT DISTINCT USUBJID FROM cm WHERE USUBJID NOT IN (SELECT USUBJID FROM dm)
    UNION ALL
    SELECT DISTINCT USUBJID FROM lb WHERE USUBJID NOT IN (SELECT USUBJID FROM dm)
    UNION ALL
    SELECT DISTINCT USUBJID FROM vs WHERE USUBJID NOT IN (SELECT USUBJID FROM dm)
    
    UNION ALL
    
    -- Part B: Subject IS in dm as Scrnfail, but has collected data
    SELECT DISTINCT a.USUBJID 
    FROM ae a JOIN dm d ON a.USUBJID = d.USUBJID
    WHERE d.ARMCD = 'Scrnfail'
) combined;


SELECT check_id, USUBJID, domain, field, observed, stated_issue FROM (

    -- TRUE ORPHANS: Data exists but no demographics record
    SELECT 'EC-INT' AS check_id, USUBJID, 'AE' AS domain, 
           'USUBJID' AS field, USUBJID AS observed,
           'Subject found in AE but missing from DM. Verify enrollment status.' AS stated_issue
    FROM ae WHERE USUBJID NOT IN (SELECT USUBJID FROM dm)
    
    UNION ALL
    SELECT 'EC-INT', USUBJID, 'CM', 'USUBJID', USUBJID,
           'Subject found in CM but missing from DM. Verify enrollment status.'
    FROM cm WHERE USUBJID NOT IN (SELECT USUBJID FROM dm)
    
    UNION ALL
    SELECT 'EC-INT', USUBJID, 'LB', 'USUBJID', USUBJID,
           'Subject found in LB but missing from DM. Verify enrollment status.'
    FROM lb WHERE USUBJID NOT IN (SELECT USUBJID FROM dm)
    
    UNION ALL
    SELECT 'EC-INT', USUBJID, 'VS', 'USUBJID', USUBJID,
           'Subject found in VS but missing from DM. Verify enrollment status.'
    FROM vs WHERE USUBJID NOT IN (SELECT USUBJID FROM dm)
    
    UNION ALL
    
    -- SCREEN FAILURE RECONCILIATION: In DM as Scrnfail, but has collected data
    SELECT 'EC-INT', a.USUBJID, 'AE', 'ARMCD',
           CONCAT('ARMCD=Scrnfail | AE Records=', COUNT(*)),
           'Subject marked as Screen Failure in DM but has AE records. Confirm screening data collection cutoff and eligibility determination.'
    FROM ae a JOIN dm d ON a.USUBJID = d.USUBJID
    WHERE d.ARMCD = 'Scrnfail'
    GROUP BY a.USUBJID
    
    UNION ALL
    SELECT 'EC-INT', c.USUBJID, 'CM', 'ARMCD',
           CONCAT('ARMCD=Scrnfail | CM Records=', COUNT(*)),
           'Subject marked as Screen Failure in DM but has CM records. Confirm screening data collection cutoff and eligibility determination.'
    FROM cm c JOIN dm d ON c.USUBJID = d.USUBJID
    WHERE d.ARMCD = 'Scrnfail'
    GROUP BY c.USUBJID
    
    UNION ALL
    SELECT 'EC-INT', l.USUBJID, 'LB', 'ARMCD',
           CONCAT('ARMCD=Scrnfail | LB Records=', COUNT(*)),
           'Subject marked as Screen Failure in DM but has LB records. Confirm screening data collection cutoff and eligibility determination.'
    FROM lb l JOIN dm d ON l.USUBJID = d.USUBJID
    WHERE d.ARMCD = 'Scrnfail'
    GROUP BY l.USUBJID
    
    UNION ALL
    SELECT 'EC-INT', v.USUBJID, 'VS', 'ARMCD',
           CONCAT('ARMCD=Scrnfail | VS Records=', COUNT(*)),
           'Subject marked as Screen Failure in DM but has VS records. Confirm screening data collection cutoff and eligibility determination.'
    FROM vs v JOIN dm d ON v.USUBJID = d.USUBJID
    WHERE d.ARMCD = 'Scrnfail'
    GROUP BY v.USUBJID

) issues
ORDER BY domain, USUBJID;