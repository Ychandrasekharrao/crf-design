# SDTM Dataset Validation

## Overview
This project demonstrates validation of clinical trial datasets mapped to CDISC SDTM standards using the Pharmaverse synthetic SDTM dataset.  
It includes edit check logic, discrepancy reports, and compliance checks across multiple domains (DM, AE, CM, LB, VS).

## Dataset Source
Validation performed on the Pharmaverse SDTM dataset:  
[Pharmaverse SDTM Dataset](https://github.com/pharmaverse/sdtm.oak/tree/main/inst)

## Deliverables
- **validation_reports/**  
  - EC-002 cross domain subject mismatch issues.csv  
  - EC-004 study day mismatch issues.csv  
  - EC-005 lab values issue (out of the range).csv  
  - all edit checks log record.csv  
- **validation_scripts/**  
  - sdtm.sql  

## Example Edit Checks
- **EC-002 (DM, AE, CM, LB, VS):** Cross-reference DM with data domains + withdrawal status reconciliation  
- **EC-004 (CM):** Study Day validity: sign consistency + missing pairs (partial dates excluded)  
- **EC-005 (LB):** Out-of-range lab values flagged for medical review (no AE assumption)  

## CDM Philosophy
> *"Validation ensures compliance and traceability; data issues are flagged, not cleaned."*
